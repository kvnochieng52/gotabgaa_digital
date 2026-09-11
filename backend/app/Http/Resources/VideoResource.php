<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VideoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'slug' => $this->slug,
            'title' => $this->title,
            'description' => $this->description,
            'category' => $this->category?->name,
            'duration' => $this->duration,
            'videoUrl' => $this->when($request->routeIs('videos.show'), $this->video_url),
            'image' => $this->image && str_starts_with($this->image, '#')
                ? $this->image
                : ($this->image ? url('storage/'.$this->image) : '#E63946|#FF7A1A'),
            'airedAt' => optional($this->aired_at)->toIso8601String(),
            'views' => (int) $this->views,
        ];
    }
}
