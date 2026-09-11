<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ArticleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'slug' => $this->slug,
            'title' => $this->title,
            'excerpt' => $this->excerpt,
            'body' => $this->when($request->routeIs('articles.show'), $this->body),
            'category' => $this->category?->name,
            'categorySlug' => $this->category?->slug,
            'author' => [
                'name' => $this->author_name ?? $this->author?->name ?? 'Editorial Desk',
            ],
            'publishedAt' => optional($this->published_at)->toIso8601String(),
            'readingTime' => $this->reading_time,
            'image' => $this->image_url(),
            'youtubeUrl' => $this->youtube_url,
            'featured' => (bool) $this->featured,
            'breaking' => (bool) $this->breaking,
            'isShort' => (bool) $this->is_short,
            'viewCount' => (int) $this->view_count,
            'likeCount' => (int) $this->like_count,
            'tags' => $this->tags ?? [],
        ];
    }

    protected function image_url(): string
    {
        // 1. Explicit uploaded/remote image wins.
        if ($this->image) {
            if (str_starts_with($this->image, '#')) {
                return $this->image; // gradient spec
            }
            if (str_starts_with($this->image, 'http://') || str_starts_with($this->image, 'https://')) {
                return $this->image;
            }
            return url('storage/'.$this->image);
        }

        // 2. Derive from YouTube video ID if the article has one.
        if ($ytId = $this->youtube_video_id()) {
            return "https://img.youtube.com/vi/{$ytId}/hqdefault.jpg";
        }

        // 3. Deterministic brand gradient.
        return $this->fallbackGradient();
    }

    protected function youtube_video_id(): ?string
    {
        $url = $this->youtube_url;
        if (! $url) {
            return null;
        }
        if (preg_match('#(?:youtube\.com/(?:watch\?v=|embed/|v/|shorts/)|youtu\.be/)([\w-]{11})#', $url, $m)) {
            return $m[1];
        }
        return null;
    }

    /**
     * Deterministic brand gradient based on article id so cards look varied.
     */
    protected function fallbackGradient(): string
    {
        $palettes = [
            '#E63946|#FF7A1A',
            '#FF7A1A|#FFA31A',
            '#E63946|#FFA31A',
            '#FFA31A|#E63946',
            '#FF7A1A|#E63946',
            '#FFA31A|#FF7A1A',
        ];
        return $palettes[($this->id ?? 0) % count($palettes)];
    }
}
