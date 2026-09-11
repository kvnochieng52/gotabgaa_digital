<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Programme extends Model
{
    protected $fillable = [
        'remote_id', 'title', 'slug', 'description', 'thumbnail',
        'category', 'is_active',
    ];

    protected $casts = ['is_active' => 'boolean'];
}
