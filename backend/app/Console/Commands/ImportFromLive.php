<?php

namespace App\Console\Commands;

use App\Models\Article;
use App\Models\Category;
use App\Models\Setting;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;

class ImportFromLive extends Command
{
    protected $signature = 'import:live
        {--base=https://staging.gotabgaa.co.ke/api/v1 : Remote API base URL}
        {--fresh : Wipe local articles + categories before importing}';

    protected $description = 'Import categories, articles and shorts from the live Gotabgaa site.';

    public function handle(): int
    {
        $base = rtrim((string) $this->option('base'), '/');

        if ($this->option('fresh')) {
            $this->warn('Wiping local articles and categories…');
            Article::query()->delete();
            Category::query()->delete();
        }

        // ---------- Categories ----------
        $this->info("Fetching categories from {$base}/categories");
        $cats = Http::timeout(15)->get("{$base}/categories")->json('data') ?? [];
        $catMap = []; // remote_id => local Category
        foreach ($cats as $c) {
            $local = Category::updateOrCreate(
                ['slug' => $c['slug']],
                [
                    'name' => $c['name'],
                    'color' => $c['color'] ?? null,
                    'sort_order' => $c['sort_order'] ?? 0,
                ]
            );
            $catMap[$c['id']] = $local;
        }
        $this->line('  Imported '.count($cats).' categories.');

        // ---------- Articles + Shorts ----------
        $totalArticles = $this->importPaginated("{$base}/articles", $catMap, false);
        $totalShorts = $this->importPaginated("{$base}/shorts", $catMap, true);

        $this->line("  Imported {$totalArticles} articles.");
        $this->line("  Imported {$totalShorts} shorts.");

        // ---------- Settings (social URLs + stream) ----------
        $settings = Http::timeout(15)->get("{$base}/settings/public")->json('data') ?? [];
        $mapping = [
            'stream_url' => ['key' => 'tv_stream_url', 'group' => 'stream'],
            'facebook_url' => ['key' => 'social_facebook', 'group' => 'social'],
            'youtube_channel_url' => ['key' => 'social_youtube', 'group' => 'social'],
            'tiktok_url' => ['key' => 'social_tiktok', 'group' => 'social'],
            'instagram_url' => ['key' => 'social_instagram', 'group' => 'social'],
            'twitter_url' => ['key' => 'social_twitter', 'group' => 'social'],
            'whatsapp_channel_url' => ['key' => 'social_whatsapp', 'group' => 'social'],
        ];
        $mapped = 0;
        foreach ($settings as $s) {
            $key = $s['key'] ?? null;
            if (! $key || ! isset($mapping[$key])) {
                continue;
            }
            Setting::updateOrCreate(
                ['key' => $mapping[$key]['key']],
                ['value' => $s['value'], 'group' => $mapping[$key]['group']]
            );
            Cache::forget('setting.'.$mapping[$key]['key']);
            $mapped++;
        }
        $this->line("  Imported {$mapped} settings.");

        $this->info('Import complete.');
        return self::SUCCESS;
    }

    private function importPaginated(string $url, array $catMap, bool $isShort): int
    {
        $this->info("Fetching from {$url}");
        $imported = 0;
        $page = 1;
        while (true) {
            $resp = Http::timeout(20)->get($url, ['page' => $page])->json();
            $items = $resp['data'] ?? [];
            if (empty($items)) {
                break;
            }
            foreach ($items as $item) {
                $this->upsertArticle($item, $catMap, $isShort);
                $imported++;
            }
            $lastPage = $resp['last_page'] ?? 1;
            $this->line("    page {$page}/{$lastPage} — imported ".count($items).' items');
            if ($page >= $lastPage) {
                break;
            }
            $page++;
        }
        return $imported;
    }

    private function upsertArticle(array $item, array $catMap, bool $isShort): void
    {
        $catId = $catMap[$item['category_id']]->id ?? null;

        Article::updateOrCreate(
            ['remote_id' => $item['id']],
            [
                'slug' => $item['slug'],
                'title' => $item['title'],
                'excerpt' => $item['excerpt'] ?? null,
                'body' => $item['body'] ?? '',
                'category_id' => $catId,
                'author_name' => $item['author']['name'] ?? null,
                'image' => $item['featured_image'] ?? null,
                'youtube_url' => $item['youtube_url'] ?? null,
                'is_short' => (bool) ($item['is_short'] ?? $isShort),
                'view_count' => (int) ($item['view_count'] ?? 0),
                'like_count' => (int) ($item['like_count'] ?? 0),
                'status' => $item['status'] ?? 'published',
                'published_at' => $item['published_at'] ?? null,
                'reading_time' => max(1, (int) ceil(str_word_count(strip_tags((string) ($item['body'] ?? ''))) / 220)),
            ]
        );
    }
}
