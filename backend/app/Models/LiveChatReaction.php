<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LiveChatReaction extends Model
{
    protected $fillable = ['live_chat_message_id', 'emoji', 'ip'];

    public function message(): BelongsTo
    {
        return $this->belongsTo(LiveChatMessage::class, 'live_chat_message_id');
    }
}
