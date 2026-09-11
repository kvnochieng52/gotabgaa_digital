<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class Poll extends Model
{
    protected $fillable = ['slug', 'question', 'options', 'active', 'closes_at'];

    protected $casts = [
        'options' => 'array',
        'active' => 'boolean',
        'closes_at' => 'datetime',
    ];

    protected static function booted(): void
    {
        static::saving(function (Poll $p) {
            if (empty($p->slug)) {
                $p->slug = Str::slug($p->question);
            }
            // Normalize options — ensure each has id/label/votes.
            if (is_array($p->options)) {
                $p->options = array_map(function ($o, $i) {
                    return [
                        'id' => $o['id'] ?? Str::slug($o['label'] ?? "opt-$i"),
                        'label' => $o['label'] ?? '',
                        'votes' => (int) ($o['votes'] ?? 0),
                    ];
                }, $p->options, array_keys($p->options));
            }
        });
    }

    public function votes(): HasMany
    {
        return $this->hasMany(PollVote::class);
    }

    public function scopeActive(Builder $q): Builder
    {
        return $q->where('active', true);
    }
}
