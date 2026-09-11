<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;

class CategoryController extends Controller
{
    public function index()
    {
        return Category::orderBy('sort_order')->orderBy('name')
            ->withCount('articles')
            ->get()
            ->map(fn ($c) => [
                'slug' => $c->slug,
                'name' => $c->name,
                'color' => $c->color,
                'articleCount' => $c->articles_count,
            ]);
    }
}
