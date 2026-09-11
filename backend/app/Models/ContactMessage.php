<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ContactMessage extends Model
{
    protected $fillable = [
        'name', 'email', 'phone', 'subject', 'message',
        'source', 'ip', 'user_agent', 'read',
    ];

    protected $casts = ['read' => 'boolean'];
}
