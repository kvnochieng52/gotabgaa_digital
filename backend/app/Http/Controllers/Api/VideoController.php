<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\VideoResource;
use App\Models\Video;
use Illuminate\Http\Request;

class VideoController extends Controller
{
    public function index(Request $request)
    {
        $query = Video::query()
            ->published()
            ->with('category');

        if ($category = $request->string('category')->toString()) {
            $query->whereHas('category', fn ($q) => $q->where('slug', $category));
        }

        $sort = $request->string('sort', 'recent')->toString();
        match ($sort) {
            'trending' => $query->orderByDesc('views'),
            default => $query->orderByDesc('aired_at'),
        };

        $limit = min((int) $request->input('limit', 20), 100);

        return VideoResource::collection($query->limit($limit)->get());
    }

    public function show(string $slug)
    {
        $video = Video::published()
            ->with('category')
            ->where('slug', $slug)
            ->firstOrFail();

        // increment view count (fire-and-forget, no update timestamps)
        $video->timestamps = false;
        $video->increment('views');

        return new VideoResource($video);
    }
}
