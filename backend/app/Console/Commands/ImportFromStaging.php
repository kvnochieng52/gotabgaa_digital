<?php

namespace App\Console\Commands;

use App\Models\Article;
use App\Models\BreakingNews;
use App\Models\Category;
use App\Models\Poll;
use App\Models\Programme;
use App\Models\Setting;
use App\Models\Short;
use App\Models\Staff;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class ImportFromStaging extends Command
{
    protected $signature = 'import:staging {--fresh : Wipe local content before importing}';

    protected $description = 'Import all content from the staging_source MySQL DB (loaded from gotabgaa_staging.sql).';

    public function handle(): int
    {
        // Sanity check: the source connection reachable?
        try {
            DB::connection('staging_source')->getPdo();
        } catch (\Throwable $e) {
            $this->error('Cannot connect to staging_source DB: '.$e->getMessage());
            $this->line('Ensure the SQL dump is loaded: mysql -u root gotabgaa_stg_import < gotabgaa_staging.sql');
            return self::FAILURE;
        }

        if ($this->option('fresh')) {
            $this->warn('Wiping local content…');
            Short::query()->delete();
            Article::query()->delete();
            Category::query()->delete();
            BreakingNews::query()->delete();
            Staff::query()->delete();
            Programme::query()->delete();
        }

        $catMap = $this->importCategories();
        $staffMap = $this->importStaff();
        $articleMap = $this->importArticles($catMap, $staffMap);
        $this->importShorts($articleMap);
        $this->importSettings();
        $this->importBreakingNews();
        $this->importPolls();
        $this->importProgrammes();

        $this->info('');
        $this->info('=== Import complete ===');
        $this->table(['Table', 'Local rows'], [
            ['Categories', Category::count()],
            ['Articles', Article::count()],
            ['  Shorts (via articles)', Article::where('is_short', true)->count()],
            ['  Featured', Article::where('featured', true)->count()],
            ['Standalone Shorts', Short::count()],
            ['Breaking news', BreakingNews::count()],
            ['Staff', Staff::count()],
            ['Programmes', Programme::count()],
            ['Polls', Poll::count()],
            ['Settings', Setting::count()],
        ]);
        return self::SUCCESS;
    }

    /* ==================== IMPORTERS ==================== */

    private function importCategories(): array
    {
        $this->info('Importing categories…');
        $map = [];
        DB::connection('staging_source')->table('news_categories')->orderBy('sort_order')->orderBy('id')->each(function ($c) use (&$map) {
            $local = Category::updateOrCreate(
                ['slug' => $c->slug],
                [
                    'name' => $c->name,
                    'icon' => $c->icon,
                    'color' => $c->color,
                    'sort_order' => (int) $c->sort_order,
                    'is_active' => (bool) $c->is_active,
                ]
            );
            $map[(int) $c->id] = $local->id;
        });
        $this->line('  '.count($map).' categories imported.');
        return $map;
    }

    private function importStaff(): array
    {
        $this->info('Importing staff…');
        $map = [];
        DB::connection('staging_source')->table('staff')
            ->leftJoin('roles', 'staff.role_id', '=', 'roles.id')
            ->select('staff.*', 'roles.name as role_name')
            ->orderBy('staff.id')
            ->each(function ($s) use (&$map) {
                $local = Staff::updateOrCreate(
                    ['remote_id' => (int) $s->id],
                    [
                        'name' => $s->name,
                        'phone' => $s->phone,
                        'email' => $s->email,
                        'role' => $s->role_name ?? null,
                        'photo' => $s->photo,
                        'bio' => $s->bio,
                        'is_visible' => (bool) $s->is_visible,
                        'is_active' => (bool) $s->is_active,
                    ]
                );
                $map[(int) $s->id] = $local->id;
            });
        $this->line('  '.count($map).' staff members imported.');
        return $map;
    }

    private function importArticles(array $catMap, array $staffMap): array
    {
        $this->info('Importing articles…');
        $map = [];
        $rows = DB::connection('staging_source')->table('news_articles')
            ->whereNull('deleted_at')
            ->orderBy('id')
            ->get();

        foreach ($rows as $a) {
            $catId = $catMap[(int) $a->category_id] ?? null;

            $local = Article::updateOrCreate(
                ['remote_id' => (int) $a->id],
                [
                    'slug' => $a->slug,
                    'title' => $a->title,
                    'excerpt' => $a->excerpt,
                    'body' => $a->body,
                    'category_id' => $catId,
                    'author_name' => optional(Staff::where('remote_id', (int) $a->submitted_by)->first())->name,
                    'image' => $a->featured_image,
                    'youtube_url' => $a->youtube_url,
                    'is_short' => (bool) $a->is_short,
                    'view_count' => (int) $a->view_count,
                    'like_count' => (int) $a->like_count,
                    'comment_count' => (int) $a->comment_count,
                    'share_count' => (int) $a->share_count,
                    'status' => $a->status,
                    'published_at' => $a->published_at,
                    'reading_time' => max(1, (int) ceil(str_word_count(strip_tags((string) $a->body)) / 220)),
                ]
            );
            $map[(int) $a->id] = $local->id;
        }
        $this->line('  '.count($map).' articles imported.');
        return $map;
    }

    private function importShorts(array $articleMap): void
    {
        $this->info('Importing shorts…');
        $count = 0;
        DB::connection('staging_source')->table('shorts')
            ->whereNull('deleted_at')
            ->orderBy('id')
            ->orderBy('id')
            ->each(function ($s) use ($articleMap, &$count) {
                Short::updateOrCreate(
                    ['remote_id' => (int) $s->id],
                    [
                        'article_id' => $articleMap[(int) $s->article_id] ?? null,
                        'title' => $s->title,
                        'caption' => $s->caption,
                        'source' => $s->source,
                        'video_id' => $s->video_id,
                        'thumbnail' => $s->thumbnail,
                        'duration_seconds' => $s->duration_seconds ? (int) $s->duration_seconds : null,
                        'is_sponsored' => (bool) $s->is_sponsored,
                        'sponsor_label' => $s->sponsor_label,
                        'is_published' => (bool) $s->is_published,
                        'view_count' => (int) $s->view_count,
                    ]
                );
                $count++;
            });
        $this->line("  {$count} shorts imported.");
    }

    private function importSettings(): void
    {
        $this->info('Importing settings…');
        $mapping = [
            'stream_url' => ['tv_stream_url', 'stream'],
            'stream_is_live' => ['stream_is_live', 'stream'],
            'facebook_url' => ['social_facebook', 'social'],
            'youtube_channel_url' => ['social_youtube', 'social'],
            'tiktok_url' => ['social_tiktok', 'social'],
            'instagram_url' => ['social_instagram', 'social'],
            'twitter_url' => ['social_twitter', 'social'],
            'whatsapp_channel_url' => ['social_whatsapp', 'social'],
            'station_name' => ['station_name', 'general'],
            'station_tagline' => ['station_tagline', 'general'],
            'contact_phone' => ['contact_phone', 'general'],
            'contact_email' => ['contact_email', 'general'],
            'contact_address' => ['contact_address', 'general'],
            'ga_measurement_id' => ['ga_measurement_id', 'analytics'],
        ];
        $mapped = 0;
        DB::connection('staging_source')->table('settings')->orderBy('id')->each(function ($s) use ($mapping, &$mapped) {
            if (! isset($mapping[$s->key])) {
                return;
            }
            [$key, $group] = $mapping[$s->key];
            Setting::updateOrCreate(['key' => $key], ['value' => $s->value, 'group' => $group]);
            Cache::forget("setting.{$key}");
            $mapped++;
        });
        $this->line("  {$mapped} settings imported.");
    }

    private function importBreakingNews(): void
    {
        $this->info('Importing breaking news…');
        $count = 0;
        DB::connection('staging_source')->table('breaking_news')->orderBy('id')->each(function ($b) use (&$count) {
            BreakingNews::updateOrCreate(
                ['id' => (int) $b->id],
                [
                    'headline' => $b->headline,
                    'link_url' => $b->link_url,
                    'is_active' => (bool) $b->is_active,
                    'expires_at' => $b->expires_at,
                ]
            );
            $count++;
        });
        $this->line("  {$count} breaking news items imported.");
    }

    private function importPolls(): void
    {
        $this->info('Importing polls…');
        $count = 0;
        DB::connection('staging_source')->table('live_polls')->orderBy('id')->each(function ($p) use (&$count) {
            $options = DB::connection('staging_source')->table('poll_options')
                ->where('poll_id', $p->id)
                ->orderBy('sort_order')
                ->get()
                ->map(fn ($o) => [
                    'id' => \Illuminate\Support\Str::slug($o->label),
                    'label' => $o->label,
                    'votes' => (int) $o->vote_count,
                ])
                ->toArray();

            Poll::updateOrCreate(
                ['slug' => \Illuminate\Support\Str::slug($p->question).'-'.$p->id],
                [
                    'question' => $p->question,
                    'options' => $options,
                    'active' => (bool) $p->is_active,
                    'closes_at' => $p->closes_at,
                ]
            );
            $count++;
        });
        $this->line("  {$count} polls imported.");
    }

    private function importProgrammes(): void
    {
        $this->info('Importing programmes…');
        $count = 0;
        DB::connection('staging_source')->table('programmes')
            ->whereNull('deleted_at')
            ->orderBy('id')
            ->each(function ($p) use (&$count) {
                Programme::updateOrCreate(
                    ['remote_id' => (int) $p->id],
                    [
                        'title' => $p->title,
                        'slug' => $p->slug,
                        'description' => $p->description,
                        'thumbnail' => $p->thumbnail,
                        'category' => $p->category,
                        'is_active' => (bool) $p->is_active,
                    ]
                );
                $count++;
            });
        $this->line("  {$count} programmes imported.");
    }
}
