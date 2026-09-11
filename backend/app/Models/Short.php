<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Short extends Model
{
    protected $fillable = [
        'remote_id', 'article_id', 'title', 'caption',
        'source', 'video_id', 'thumbnail', 'duration_seconds',
        'is_sponsored', 'sponsor_label', 'is_published', 'view_count',
    ];

    protected $casts = [
        'is_sponsored' => 'boolean',
        'is_published' => 'boolean',
    ];

    public function article(): BelongsTo
    {
        return $this->belongsTo(Article::class);
    }

    public function getPlaybackUrlAttribute(): ?string
    {
        return match ($this->source) {
            'youtube' => "https://www.youtube.com/embed/{$this->video_id}",
            'cloudinary' => "https://res.cloudinary.com/dnr3waj4p/video/upload/{$this->video_id}.mp4",
            default => null,
        };
    }
}
