<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ArticleResource;
use App\Models\Article;
use Illuminate\Http\Request;

class ArticleController extends Controller
{
    public function index(Request $request)
    {
        $query = Article::query()
            ->published()
            ->with('category')
            ->orderByDesc('published_at');

        if ($category = $request->string('category')->toString()) {
            $query->whereHas('category', fn ($q) => $q->where('slug', $category));
        }

        if ($request->boolean('featured')) {
            $query->where('featured', true);
        }

        if ($request->boolean('breaking')) {
            $query->where('breaking', true);
        }

        $limit = min((int) $request->input('limit', 20), 100);

        return ArticleResource::collection($query->limit($limit)->get());
    }

    public function show(string $slug)
    {
        $article = Article::published()
            ->with('category')
            ->where('slug', $slug)
            ->firstOrFail();

        return new ArticleResource($article);
    }
}
