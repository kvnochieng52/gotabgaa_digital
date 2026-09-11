<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class Video extends Model
{
    protected $fillable = [
        'slug', 'title', 'description', 'category_id',
        'duration', 'video_url', 'image',
        'aired_at', 'views', 'published',
    ];

    protected $casts = [
        'published' => 'boolean',
        'aired_at' => 'datetime',
    ];

    protected static function booted(): void
    {
        static::saving(function (Video $v) {
            if (empty($v->slug)) {
                $v->slug = Str::slug($v->title);
            }
        });
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function scopePublished(Builder $q): Builder
    {
        return $q->where('published', true);
    }
}
