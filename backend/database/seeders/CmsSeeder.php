<?php

namespace Database\Seeders;

use App\Models\Article;
use App\Models\Category;
use App\Models\Poll;
use App\Models\Program;
use App\Models\Setting;
use App\Models\User;
use App\Models\Video;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class CmsSeeder extends Seeder
{
    public function run(): void
    {
        // ---------- Admin user ----------
        User::updateOrCreate(
            ['email' => 'admin@gotabgaa.digital'],
            [
                'name' => 'Gotabgaa Admin',
                'password' => Hash::make('gotabgaa2026'),
                'email_verified_at' => now(),
            ]
        );

        // ---------- Categories ----------
        $cats = [
            ['name' => 'News', 'color' => '#E63946', 'sort_order' => 1],
            ['name' => 'Politics', 'color' => '#FF7A1A', 'sort_order' => 2],
            ['name' => 'Sports', 'color' => '#FFA31A', 'sort_order' => 3],
            ['name' => 'Culture', 'color' => '#22C55E', 'sort_order' => 4],
            ['name' => 'Diaspora', 'color' => '#3B82F6', 'sort_order' => 5],
            ['name' => 'Business', 'color' => '#8B5CF6', 'sort_order' => 6],
            ['name' => 'Opinion', 'color' => '#EC4899', 'sort_order' => 7],
        ];
        foreach ($cats as $c) {
            Category::updateOrCreate(['name' => $c['name']], $c);
        }

        $byName = fn (string $n) => Category::where('name', $n)->value('id');

        // ---------- Articles ----------
        $articles = [
            [
                'slug' => 'kalenjin-diaspora-summit-dallas',
                'title' => 'Kalenjin Diaspora Summit Draws Record Attendance in Dallas',
                'excerpt' => 'Community leaders and cultural ambassadors from across the United States gathered in Dallas over the weekend for the annual Kalenjin Diaspora Summit, drawing a record number of attendees.',
                'body' => "Community leaders and cultural ambassadors from across the United States gathered in Dallas over the weekend for the annual Kalenjin Diaspora Summit. The three-day event brought together over 2,000 attendees from 30 states and marked the largest gathering of Kalenjin diaspora ever recorded in North America.\n\nThe summit featured keynote addresses from prominent community elders, panel discussions on cultural preservation, and a marketplace showcasing East African arts and cuisine.\n\n\"This is a landmark moment for our community and we are proud to build these bridges between home and the diaspora,\" said summit chair Cherotich Bett.",
                'category_id' => $byName('Diaspora'),
                'author_name' => 'Cherotich Bett',
                'image' => '#E63946|#FF7A1A',
                'featured' => true,
                'breaking' => true,
                'published_at' => now()->subDays(2),
                'reading_time' => 6,
                'tags' => ['summit', 'diaspora', 'dallas'],
            ],
            [
                'slug' => 'kenya-parliament-digital-rights',
                'title' => "Kenya's Parliament Passes Landmark Digital Rights Bill",
                'excerpt' => "In a rare display of bipartisan support, Kenya's National Assembly has passed a comprehensive digital rights bill that promises to strengthen online privacy and freedom of expression.",
                'body' => "In a rare display of bipartisan support, Kenya's National Assembly has passed a comprehensive digital rights bill. The legislation, three years in the making, establishes strong protections for online privacy, data portability, and freedom of expression on digital platforms.\n\nKey provisions include mandatory transparency reports from social media companies operating in Kenya, a data protection ombudsman with enforcement powers, and criminal penalties for state actors who unlawfully surveil private communications.",
                'category_id' => $byName('Politics'),
                'author_name' => "Kipchumba Lang'at",
                'image' => '#FF7A1A|#FFA31A',
                'breaking' => true,
                'published_at' => now()->subDays(2)->subHours(3),
                'reading_time' => 5,
                'tags' => ['politics', 'kenya', 'digital-rights'],
            ],
            [
                'slug' => 'faith-kipyegon-fourth-olympic',
                'title' => 'Faith Kipyegon Sets Sights on Fourth Olympic Gold',
                'excerpt' => 'Reigning Olympic champion Faith Kipyegon has confirmed her intention to defend her title, aiming to become the first woman to win four consecutive Olympic 1500m titles.',
                'body' => "Reigning Olympic champion Faith Kipyegon has confirmed her intention to defend her title at the upcoming Games. If successful, she would become the first woman to win four consecutive Olympic 1500m titles — a feat unmatched in track and field history.",
                'category_id' => $byName('Sports'),
                'author_name' => 'Kip Chumba',
                'image' => '#E63946|#FFA31A',
                'breaking' => true,
                'published_at' => now()->subDays(2)->subHours(5),
                'reading_time' => 4,
                'tags' => ['athletics', 'olympics', 'kipyegon'],
            ],
            [
                'slug' => 'kalenjin-songs-modern-revival',
                'title' => 'Traditional Kalenjin Songs Get Modern Revival',
                'excerpt' => 'A collective of young Kenyan artists based in Boston is bringing ancient Kalenjin folk songs to global audiences through a groundbreaking new album.',
                'body' => "A collective of young Kenyan artists based in Boston is bringing ancient Kalenjin folk songs to global audiences through a groundbreaking new album. Titled 'Roots & Frequencies', the 12-track project blends traditional melodies with contemporary electronic production.",
                'category_id' => $byName('Culture'),
                'author_name' => 'Chebet Kiplagat',
                'image' => '#FFA31A|#FF7A1A',
                'published_at' => now()->subDays(3),
                'reading_time' => 5,
                'tags' => ['music', 'culture', 'diaspora'],
            ],
            [
                'slug' => 'us-immigration-reform-east-africa',
                'title' => 'US Immigration Reform Impact on East African Diaspora',
                'excerpt' => 'Legal experts and community advocates discuss the implications of the newly proposed immigration reforms for East African communities across the United States.',
                'body' => "Legal experts and community advocates gathered in a virtual town hall this week to discuss the implications of the newly proposed immigration reforms. The forum drew over 5,000 participants from across the United States.",
                'category_id' => $byName('Diaspora'),
                'author_name' => 'Sarah Kimeli',
                'image' => '#E63946|#FF7A1A',
                'published_at' => now()->subDays(3)->subHours(4),
                'reading_time' => 7,
                'tags' => ['immigration', 'policy', 'diaspora'],
            ],
            [
                'slug' => 'nairobi-startup-series-b',
                'title' => 'Nairobi Startup Raises $25M in Series B Funding Round',
                'excerpt' => 'A Nairobi-based fintech startup has raised $25 million in Series B funding, marking one of the largest recent investments in Kenya\'s tech ecosystem.',
                'body' => "A Nairobi-based fintech startup has raised \$25 million in Series B funding, marking one of the largest recent investments in Kenya's rapidly growing tech ecosystem.",
                'category_id' => $byName('Business'),
                'author_name' => 'Kipkoech Mutai',
                'image' => '#FF7A1A|#FFA31A',
                'published_at' => now()->subDays(4),
                'reading_time' => 4,
                'tags' => ['business', 'startup', 'fintech'],
            ],
            [
                'slug' => 'kipchoge-retirement-announcement',
                'title' => 'Kipchoge Announces Retirement After Historic Career',
                'excerpt' => 'Legendary marathon runner Eliud Kipchoge has announced his retirement from competitive racing, capping a career that redefined long-distance running.',
                'body' => "Legendary marathon runner Eliud Kipchoge has announced his retirement from competitive racing, capping a career that redefined the possibilities of long-distance running.",
                'category_id' => $byName('Sports'),
                'author_name' => 'Kip Chumba',
                'image' => '#E63946|#FFA31A',
                'published_at' => now()->subDays(5),
                'reading_time' => 6,
                'tags' => ['athletics', 'marathon', 'kipchoge'],
            ],
            [
                'slug' => 'gotabgaa-youth-mentorship',
                'title' => 'Gotabgaa International Launches Youth Mentorship Program',
                'excerpt' => 'Gotabgaa International today unveiled a new mentorship initiative connecting Kalenjin youth in the diaspora with successful professionals worldwide.',
                'body' => "Gotabgaa International today unveiled a new mentorship initiative connecting Kalenjin youth in the diaspora with successful professionals in fields ranging from medicine to technology and the arts.",
                'category_id' => $byName('Diaspora'),
                'author_name' => 'Editorial Desk',
                'image' => '#FFA31A|#E63946',
                'published_at' => now()->subDays(5)->subHours(6),
                'reading_time' => 3,
                'tags' => ['community', 'mentorship', 'youth'],
            ],
            [
                'slug' => 'rift-valley-climate-smart-farming',
                'title' => 'Rift Valley Farmers Adopt Climate-Smart Agriculture',
                'excerpt' => 'A growing number of farmers in Kenya\'s Rift Valley region are turning to climate-smart agricultural practices to combat unpredictable weather patterns.',
                'body' => "A growing number of farmers in Kenya's Rift Valley region are turning to climate-smart agricultural practices.",
                'category_id' => $byName('News'),
                'author_name' => 'Cherotich Bett',
                'image' => '#FF7A1A|#E63946',
                'published_at' => now()->subDays(6),
                'reading_time' => 5,
                'tags' => ['agriculture', 'climate', 'rift-valley'],
            ],
            [
                'slug' => 'kalenjin-duolingo-launch',
                'title' => 'Kalenjin Language Now Available on Duolingo',
                'excerpt' => 'Digital language platform Duolingo has officially added Kalenjin to its catalog, a milestone hailed by cultural preservationists worldwide.',
                'body' => "Digital language platform Duolingo has officially added Kalenjin to its catalog of supported languages, a milestone hailed by cultural preservationists worldwide.",
                'category_id' => $byName('Culture'),
                'author_name' => 'Chebet Kiplagat',
                'image' => '#FFA31A|#FF7A1A',
                'published_at' => now()->subDays(7),
                'reading_time' => 4,
                'tags' => ['language', 'culture', 'technology'],
            ],
        ];
        foreach ($articles as $a) {
            Article::updateOrCreate(['slug' => $a['slug']], $a);
        }

        // ---------- Programs ----------
        $programs = [
            ['title' => 'Morning Bulletin', 'host' => 'Cherotich Bett', 'day' => 'Monday', 'start_time' => '06:00', 'end_time' => '09:00', 'type' => 'tv', 'description' => 'Start your day with the latest headlines from around the world.', 'image' => '#E63946|#FF7A1A'],
            ['title' => 'Midday Brief', 'host' => 'Kip Chumba', 'day' => 'Monday', 'start_time' => '12:00', 'end_time' => '13:00', 'type' => 'tv', 'description' => 'A quick update on stories developing throughout the morning.', 'image' => '#FFA31A|#E63946'],
            ['title' => 'Prime Time News', 'host' => "Kipchumba Lang'at", 'day' => 'Monday', 'start_time' => '20:00', 'end_time' => '21:00', 'type' => 'tv', 'description' => 'The definitive evening news broadcast for the diaspora.', 'image' => '#FF7A1A|#FFA31A'],
            ['title' => 'Business Focus', 'host' => 'Kipkoech Mutai', 'day' => 'Wednesday', 'start_time' => '19:00', 'end_time' => '20:00', 'type' => 'tv', 'description' => 'Deep dives into East African markets, startups and investment.', 'image' => '#E63946|#FFA31A'],
            ['title' => 'Weekend Culture Show', 'host' => 'Chebet Kiplagat', 'day' => 'Saturday', 'start_time' => '10:00', 'end_time' => '12:00', 'type' => 'tv', 'description' => 'Music, art, and stories from across the Kalenjin community.', 'image' => '#FFA31A|#FF7A1A'],
            ['title' => 'Youth Forum', 'host' => 'Sarah Kimeli', 'day' => 'Friday', 'start_time' => '17:00', 'end_time' => '18:30', 'type' => 'tv', 'description' => 'The next generation debates the issues that matter most.', 'image' => '#FF7A1A|#E63946'],
            ['title' => 'Morning Vibes', 'host' => 'DJ Kimutai', 'day' => 'Monday', 'start_time' => '06:00', 'end_time' => '10:00', 'type' => 'radio', 'description' => 'Wake up to the best of East African and international music.', 'image' => '#E63946|#FF7A1A'],
            ['title' => 'Talk & Music', 'host' => 'Faith Chepkorir', 'day' => 'Tuesday', 'start_time' => '14:00', 'end_time' => '17:00', 'type' => 'radio', 'description' => 'Conversation and curated music from around the world.', 'image' => '#FFA31A|#E63946'],
            ['title' => 'Sunday Sanctuary', 'host' => 'Elder Kiplangat', 'day' => 'Sunday', 'start_time' => '09:00', 'end_time' => '12:00', 'type' => 'radio', 'description' => 'Spiritual reflections and inspirational music.', 'image' => '#FF7A1A|#FFA31A'],
            ['title' => 'Night Cruise', 'host' => 'DJ Cherop', 'day' => 'Friday', 'start_time' => '22:00', 'end_time' => '01:00', 'type' => 'radio', 'description' => 'Late night mixes to close out your week.', 'image' => '#E63946|#FFA31A'],
        ];
        foreach ($programs as $p) {
            Program::updateOrCreate([
                'title' => $p['title'],
                'day' => $p['day'],
                'start_time' => $p['start_time'],
            ], $p);
        }

        // ---------- Videos ----------
        $videos = [
            ['slug' => 'prime-time-weekly-roundup', 'title' => 'Prime Time News — Weekly Roundup', 'description' => 'The stories that mattered most this week.', 'category_id' => $byName('News'), 'duration' => '1:12:30', 'aired_at' => now()->subDays(4), 'image' => '#E63946|#FF7A1A', 'views' => 12400],
            ['slug' => 'kalenjin-sacred-rituals', 'title' => 'Kalenjin Cultural Special: Sacred Rituals', 'description' => 'An immersive look at initiation ceremonies preserved for generations.', 'category_id' => $byName('Culture'), 'duration' => '48:22', 'aired_at' => now()->subDays(6), 'image' => '#FFA31A|#FF7A1A', 'views' => 8900],
            ['slug' => 'east-african-trade-corridor', 'title' => 'Business Focus: East African Trade Corridor', 'description' => 'How Kenya, Uganda and Tanzania are re-imagining regional commerce.', 'category_id' => $byName('Business'), 'duration' => '32:15', 'aired_at' => now()->subDays(7), 'image' => '#FF7A1A|#E63946', 'views' => 5100],
            ['slug' => 'marathon-highlights', 'title' => 'Sports Rewind: Marathon Highlights', 'description' => 'The best moments from a record-breaking marathon season.', 'category_id' => $byName('Sports'), 'duration' => '24:08', 'aired_at' => now()->subDays(8), 'image' => '#E63946|#FFA31A', 'views' => 15600],
            ['slug' => 'diaspora-voices-boston', 'title' => 'Diaspora Voices: Boston Community Chat', 'description' => 'Boston\'s Kalenjin community shares stories of migration and belonging.', 'category_id' => $byName('Diaspora'), 'duration' => '58:45', 'aired_at' => now()->subDays(9), 'image' => '#FFA31A|#E63946', 'views' => 3400],
            ['slug' => 'late-night-kip-chumba', 'title' => 'Late Night Talk with Kip Chumba', 'description' => 'Comedy, culture, and conversation.', 'category_id' => $byName('Culture'), 'duration' => '1:05:12', 'aired_at' => now()->subDays(10), 'image' => '#FF7A1A|#FFA31A', 'views' => 9800],
            ['slug' => 'youth-forum-debate', 'title' => 'Youth Forum: Great Diaspora Debate', 'description' => 'Next-generation leaders discuss identity, work, and going home.', 'category_id' => $byName('Diaspora'), 'duration' => '44:20', 'aired_at' => now()->subDays(11), 'image' => '#E63946|#FF7A1A', 'views' => 4200],
            ['slug' => 'election-analysis-special', 'title' => 'Election Analysis Special', 'description' => 'A panel of experts break down the latest polling.', 'category_id' => $byName('Politics'), 'duration' => '1:22:00', 'aired_at' => now()->subDays(12), 'image' => '#FFA31A|#FF7A1A', 'views' => 21500],
        ];
        foreach ($videos as $v) {
            Video::updateOrCreate(['slug' => $v['slug']], $v);
        }

        // ---------- Poll ----------
        Poll::updateOrCreate(
            ['slug' => 'biggest-story-week'],
            [
                'question' => "What's the biggest story of the week?",
                'options' => [
                    ['id' => 'summit', 'label' => 'Kalenjin Diaspora Summit in Dallas', 'votes' => 1247],
                    ['id' => 'digital', 'label' => "Kenya's Digital Rights Bill passes", 'votes' => 486],
                    ['id' => 'olympic', 'label' => 'Kipyegon eyes fourth Olympic gold', 'votes' => 892],
                ],
                'active' => true,
                'closes_at' => now()->addDays(2),
            ]
        );

        // ---------- Settings ----------
        $defaults = [
            'tv_title' => 'Gotabgaa TV',
            'tv_stream_url' => '',
            'radio_title' => 'Gotabgaa Radio',
            'radio_frequency' => '102.5 FM',
            'radio_stream_url' => '',
        ];
        foreach ($defaults as $key => $value) {
            Setting::firstOrCreate(['key' => $key], ['value' => $value, 'group' => 'stream']);
        }
    }
}
