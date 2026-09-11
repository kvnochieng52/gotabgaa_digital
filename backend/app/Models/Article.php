<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class Article extends Model
{
    protected $fillable = [
        'slug', 'title', 'excerpt', 'body',
        'category_id', 'author_id', 'author_name',
        'image', 'featured', 'breaking',
        'published_at', 'reading_time', 'tags',
        'youtube_url', 'is_short', 'view_count', 'like_count',
        'comment_count', 'share_count',
        'remote_id', 'status',
    ];

    protected $casts = [
        'featured' => 'boolean',
        'breaking' => 'boolean',
        'is_short' => 'boolean',
        'published_at' => 'datetime',
        'tags' => 'array',
    ];

    protected static function booted(): void
    {
        static::saving(function (Article $a) {
            if (empty($a->slug)) {
                $a->slug = Str::slug($a->title);
            }
            if (empty($a->reading_time) && $a->body) {
                $words = str_word_count(strip_tags($a->body));
                $a->reading_time = max(1, (int) ceil($words / 220));
            }
        });
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    public function scopePublished(Builder $q): Builder
    {
        return $q->whereNotNull('published_at')->where('published_at', '<=', now());
    }

    public function scopeBreaking(Builder $q): Builder
    {
        return $q->where('breaking', true);
    }
}
