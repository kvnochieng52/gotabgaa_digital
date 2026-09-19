<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LiveChatMessage;
use App\Models\LiveChatReaction;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class LiveChatController extends Controller
{
    private const ALLOWED_EMOJIS = [
        '👍', '❤️', '🔥', '😂', '😮', '👏', '🙏', '🎉',
    ];

    public function index(Request $request)
    {
        $day = $this->parseDay($request->query('date'));

        // All visible messages for the day (roots + replies).
        $all = LiveChatMessage::query()
            ->whereDate('day', $day)
            ->where('hidden', false)
            ->orderBy('created_at', 'asc')
            ->limit(1000)
            ->get(['id', 'parent_id', 'name', 'message', 'created_at', 'reaction_count']);

        $reactions = $this->reactionsFor($all->pluck('id'));

        [$roots, $repliesByParent] = $this->splitRootsAndReplies($all);

        $mapMsg = function (LiveChatMessage $m) use ($reactions, $repliesByParent) {
            return [
                'id' => $m->id,
                'parent_id' => $m->parent_id,
                'name' => $m->name,
                'message' => $m->message,
                'created_at' => optional($m->created_at)->toIso8601String(),
                'reactions' => $reactions[$m->id] ?? [],
                'replies' => ($repliesByParent[$m->id] ?? collect())
                    ->map(fn (LiveChatMessage $r) => [
                        'id' => $r->id,
                        'parent_id' => $r->parent_id,
                        'name' => $r->name,
                        'message' => $r->message,
                        'created_at' => optional($r->created_at)->toIso8601String(),
                        'reactions' => $reactions[$r->id] ?? [],
                    ])
                    ->values(),
            ];
        };

        return response()->json([
            'date' => $day->toDateString(),
            'is_today' => $day->isSameDay(Carbon::today()),
            'messages' => $roots->map($mapMsg)->values(),
            'allowed_emojis' => self::ALLOWED_EMOJIS,
        ]);
    }

    public function days()
    {
        // Distinct days with at least one visible root message, newest first.
        $days = LiveChatMessage::query()
            ->where('hidden', false)
            ->whereNull('parent_id')
            ->select('day', DB::raw('COUNT(*) as c'))
            ->groupBy('day')
            ->orderByDesc('day')
            ->limit(30)
            ->get();

        return response()->json([
            'data' => $days->map(fn ($d) => [
                'date' => Carbon::parse($d->day)->toDateString(),
                'count' => (int) $d->c,
            ]),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:60'],
            'message' => ['required', 'string', 'max:500'],
            'parent_id' => ['nullable', 'integer', 'exists:live_chat_messages,id'],
        ]);

        $parentId = null;
        if (! empty($data['parent_id'])) {
            $parent = LiveChatMessage::find($data['parent_id']);
            if ($parent && ! $parent->hidden) {
                // One level of nesting — if reply is on a reply, hoist to root.
                $parentId = $parent->parent_id ?? $parent->id;
            }
        }

        $msg = LiveChatMessage::create([
            'name' => trim($data['name']),
            'message' => trim($data['message']),
            'day' => Carbon::today(),
            'ip' => $request->ip(),
            'parent_id' => $parentId,
        ]);

        return response()->json([
            'id' => $msg->id,
            'parent_id' => $msg->parent_id,
            'name' => $msg->name,
            'message' => $msg->message,
            'created_at' => optional($msg->created_at)->toIso8601String(),
            'reactions' => [],
            'replies' => [],
        ], 201);
    }

    public function react(Request $request, int $id)
    {
        $data = $request->validate([
            'emoji' => ['required', 'string'],
        ]);

        if (! in_array($data['emoji'], self::ALLOWED_EMOJIS, true)) {
            return response()->json(['message' => 'Unsupported emoji'], 422);
        }

        $message = LiveChatMessage::findOrFail($id);
        $ip = $request->ip();

        // Toggle: if the same IP already reacted with this emoji, remove it.
        $existing = LiveChatReaction::where('live_chat_message_id', $message->id)
            ->where('emoji', $data['emoji'])
            ->where('ip', $ip)
            ->first();

        if ($existing) {
            $existing->delete();
            $message->decrement('reaction_count');
        } else {
            LiveChatReaction::create([
                'live_chat_message_id' => $message->id,
                'emoji' => $data['emoji'],
                'ip' => $ip,
            ]);
            $message->increment('reaction_count');
        }

        $counts = LiveChatReaction::where('live_chat_message_id', $message->id)
            ->select('emoji', DB::raw('COUNT(*) as c'))
            ->groupBy('emoji')
            ->pluck('c', 'emoji')
            ->map(fn ($v) => (int) $v)
            ->toArray();

        return response()->json(['reactions' => $counts]);
    }

    /**
     * @param  Collection<int, int>  $ids
     * @return array<int, array<string, int>>
     */
    private function reactionsFor(Collection $ids): array
    {
        if ($ids->isEmpty()) {
            return [];
        }
        return LiveChatReaction::query()
            ->whereIn('live_chat_message_id', $ids)
            ->select('live_chat_message_id', 'emoji', DB::raw('COUNT(*) as c'))
            ->groupBy('live_chat_message_id', 'emoji')
            ->get()
            ->groupBy('live_chat_message_id')
            ->map(fn ($group) => $group->mapWithKeys(fn ($r) => [$r->emoji => (int) $r->c])->toArray())
            ->toArray();
    }

    /**
     * @param  Collection<int, LiveChatMessage>  $all
     * @return array{0: Collection<int, LiveChatMessage>, 1: Collection<int, Collection<int, LiveChatMessage>>}
     */
    private function splitRootsAndReplies(Collection $all): array
    {
        $roots = $all->whereNull('parent_id')->values();
        $replies = $all->whereNotNull('parent_id')->groupBy('parent_id');
        return [$roots, $replies];
    }

    private function parseDay(?string $raw): Carbon
    {
        if (! $raw) {
            return Carbon::today();
        }
        try {
            return Carbon::createFromFormat('Y-m-d', $raw)->startOfDay();
        } catch (\Throwable) {
            return Carbon::today();
        }
    }
}
