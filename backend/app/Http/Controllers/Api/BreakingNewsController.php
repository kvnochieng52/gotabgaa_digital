<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BreakingNews;

class BreakingNewsController extends Controller
{
    public function index()
    {
        return response()->json([
            'data' => BreakingNews::active()
                ->orderByDesc('created_at')
                ->limit(10)
                ->get(['id', 'headline', 'link_url', 'expires_at'])
                ->map(fn ($b) => [
                    'headline' => $b->headline,
                    'link_url' => $b->link_url,
                ]),
        ]);
    }
}
