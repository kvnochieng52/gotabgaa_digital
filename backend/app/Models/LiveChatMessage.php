<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LiveChatMessage extends Model
{
    protected $fillable = [
        'name', 'message', 'day', 'ip', 'hidden', 'reaction_count', 'parent_id',
    ];

    protected $casts = [
        'day' => 'date',
        'hidden' => 'boolean',
    ];

    public function reactions(): HasMany
    {
        return $this->hasMany(LiveChatReaction::class);
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(LiveChatMessage::class, 'parent_id');
    }

    public function replies(): HasMany
    {
        return $this->hasMany(LiveChatMessage::class, 'parent_id');
    }
}
