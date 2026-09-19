<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Article;
use App\Models\ArticleComment;
use Illuminate\Http\Request;

class ArticleCommentController extends Controller
{
    public function index(string $slug)
    {
        $article = Article::where('slug', $slug)->firstOrFail();

        $comments = ArticleComment::where('article_id', $article->id)
            ->where('approved', true)
            ->orderByDesc('created_at')
            ->limit(200)
            ->get(['id', 'name', 'body', 'created_at']);

        return response()->json([
            'data' => $comments->map(fn ($c) => [
                'id' => $c->id,
                'name' => $c->name,
                'body' => $c->body,
                'created_at' => optional($c->created_at)->toIso8601String(),
            ]),
            'total' => $comments->count(),
        ]);
    }

    public function store(Request $request, string $slug)
    {
        $article = Article::where('slug', $slug)->firstOrFail();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:60'],
            'email' => ['nullable', 'email', 'max:200'],
            'body' => ['required', 'string', 'max:2000'],
        ]);

        $comment = ArticleComment::create([
            'article_id' => $article->id,
            'name' => trim($data['name']),
            'email' => $data['email'] ?? null,
            'body' => trim($data['body']),
            'ip' => $request->ip(),
            'approved' => true,
        ]);

        return response()->json([
            'id' => $comment->id,
            'name' => $comment->name,
            'body' => $comment->body,
            'created_at' => optional($comment->created_at)->toIso8601String(),
        ], 201);
    }
}
