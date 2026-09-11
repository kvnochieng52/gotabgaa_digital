<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProgramResource;
use App\Models\Program;
use Illuminate\Http\Request;

class ProgramController extends Controller
{
    public function index(Request $request)
    {
        $query = Program::query()
            ->active()
            ->orderByRaw("CASE day WHEN 'Sunday' THEN 0 WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3 WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 END")
            ->orderBy('start_time');

        if ($type = $request->string('type')->toString()) {
            $query->where('type', $type);
        }

        return ProgramResource::collection($query->get());
    }

    public function now(Request $request)
    {
        $type = $request->string('type', 'tv')->toString();
        $day = now()->format('l');
        $time = now()->format('H:i');

        $current = Program::active()
            ->where('type', $type)
            ->where('day', $day)
            ->where('start_time', '<=', $time)
            ->where('end_time', '>=', $time)
            ->first();

        $next = Program::active()
            ->where('type', $type)
            ->where('day', $day)
            ->where('start_time', '>', $time)
            ->orderBy('start_time')
            ->first();

        return response()->json([
            'current' => $current ? new ProgramResource($current) : null,
            'next' => $next ? new ProgramResource($next) : null,
        ]);
    }
}
