<?php

use App\Http\Controllers\Api\ArticleController;
use App\Http\Controllers\Api\BreakingNewsController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ContactController;
use App\Http\Controllers\Api\PollController;
use App\Http\Controllers\Api\ProgramController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\VideoController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', fn (Request $r) => $r->user())->middleware('auth:sanctum');

// Public read-only API — consumed by the Next.js frontend.
Route::prefix('v1')->group(function () {
    // Categories
    Route::get('categories', [CategoryController::class, 'index']);

    // Articles
    Route::get('articles', [ArticleController::class, 'index'])->name('articles.index');
    Route::get('articles/{slug}', [ArticleController::class, 'show'])->name('articles.show');

    // Videos
    Route::get('videos', [VideoController::class, 'index'])->name('videos.index');
    Route::get('videos/{slug}', [VideoController::class, 'show'])->name('videos.show');

    // Programs (live TV / radio schedule)
    Route::get('programs', [ProgramController::class, 'index']);
    Route::get('programs/now', [ProgramController::class, 'now']);

    // Poll (single active poll + voting)
    Route::get('poll', [PollController::class, 'active']);
    Route::get('polls/{slug}', [PollController::class, 'show']);
    Route::post('polls/{slug}/vote', [PollController::class, 'vote'])
        ->middleware('throttle:10,1');

    // Public settings (stream URLs + social links)
    Route::get('settings', [SettingsController::class, 'public']);

    // Breaking-news ticker
    Route::get('breaking-news', [BreakingNewsController::class, 'index']);

    // Contact form submission
    Route::post('contact', [ContactController::class, 'store'])->middleware('throttle:5,1');
});
