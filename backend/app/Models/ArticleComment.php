<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ArticleComment extends Model
{
    protected $fillable = [
        'article_id', 'name', 'email', 'body', 'ip', 'approved',
    ];

    protected $casts = ['approved' => 'boolean'];

    public function article(): BelongsTo
    {
        return $this->belongsTo(Article::class);
    }
}
