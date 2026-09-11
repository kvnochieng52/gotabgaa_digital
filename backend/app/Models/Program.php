<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Program extends Model
{
    protected $fillable = [
        'slug', 'title', 'description', 'host',
        'type', 'day', 'start_time', 'end_time',
        'image', 'active',
    ];

    protected $casts = [
        'active' => 'boolean',
    ];

    protected static function booted(): void
    {
        static::saving(function (Program $p) {
            if (empty($p->slug)) {
                $p->slug = Str::slug($p->title.'-'.$p->day.'-'.$p->start_time);
            }
        });
    }

    public function scopeActive(Builder $q): Builder
    {
        return $q->where('active', true);
    }

    public function scopeOfType(Builder $q, string $type): Builder
    {
        return $q->where('type', $type);
    }
}
