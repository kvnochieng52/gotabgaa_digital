<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Poll;
use App\Models\PollVote;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class PollController extends Controller
{
    public function active()
    {
        $poll = Poll::active()->latest('id')->first();
        if (! $poll) {
            return response()->json(['poll' => null]);
        }

        return response()->json([
            'poll' => $this->serialize($poll),
        ]);
    }

    public function show(string $slug)
    {
        $poll = Poll::where('slug', $slug)->firstOrFail();
        return response()->json(['poll' => $this->serialize($poll)]);
    }

    public function vote(Request $request, string $slug)
    {
        $data = $request->validate([
            'option_id' => ['required', 'string', 'max:60'],
        ]);

        $poll = Poll::active()->where('slug', $slug)->firstOrFail();
        if ($poll->closes_at && $poll->closes_at->isPast()) {
            throw ValidationException::withMessages(['option_id' => 'Poll is closed.']);
        }

        $fingerprint = hash('sha256', $request->ip().'|'.$request->userAgent());

        $existing = PollVote::where('poll_id', $poll->id)
            ->where('voter_fingerprint', $fingerprint)
            ->first();
        if ($existing) {
            throw ValidationException::withMessages(['option_id' => 'Already voted.']);
        }

        $found = false;
        $options = array_map(function ($opt) use ($data, &$found) {
            if (($opt['id'] ?? null) === $data['option_id']) {
                $opt['votes'] = (int) ($opt['votes'] ?? 0) + 1;
                $found = true;
            }
            return $opt;
        }, $poll->options ?? []);

        if (! $found) {
            throw ValidationException::withMessages(['option_id' => 'Unknown option.']);
        }

        $poll->options = $options;
        $poll->save();

        PollVote::create([
            'poll_id' => $poll->id,
            'option_id' => $data['option_id'],
            'voter_fingerprint' => $fingerprint,
            'voted_at' => now(),
        ]);

        return response()->json(['poll' => $this->serialize($poll->fresh())]);
    }

    private function serialize(Poll $poll): array
    {
        return [
            'slug' => $poll->slug,
            'question' => $poll->question,
            'options' => $poll->options ?? [],
            'active' => (bool) $poll->active,
            'closesAt' => optional($poll->closes_at)->toIso8601String(),
            'totalVotes' => collect($poll->options ?? [])->sum(fn ($o) => (int) ($o['votes'] ?? 0)),
        ];
    }
}
