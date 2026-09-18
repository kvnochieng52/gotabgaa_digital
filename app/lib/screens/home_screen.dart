import 'package:flutter/material.dart';

import '../models/article.dart';
import '../models/breaking_news.dart';
import '../models/settings.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/breaking_ticker.dart';
import '../widgets/hls_player.dart';
import '../widgets/live_poll_widget.dart';
import '../widgets/section_header.dart';
import 'category_screen.dart';
import 'live_tv_screen.dart';
import 'news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Article>? _articles;
  List<BreakingNewsItem> _breaking = [];
  SiteSettings? _settings;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.instance.fetchArticles(limit: 30),
        ApiService.instance.fetchBreaking(),
        ApiService.instance.fetchSettings(),
      ]);
      if (!mounted) return;
      setState(() {
        _articles = results[0] as List<Article>;
        _breaking = results[1] as List<BreakingNewsItem>;
        _settings = results[2] as SiteSettings;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load content. Pull to retry.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.brandRed,
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ---- App bar with logo + search + theme dot ----
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: AppColors.cream,
            elevation: 0,
            scrolledUnderElevation: 4,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Image.asset('assets/images/logo.png', height: 44),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NewsScreen()),
                    );
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            titleSpacing: 16,
            toolbarHeight: 68,
          ),

          // ---- Breaking news ticker ----
          if (_breaking.isNotEmpty)
            SliverToBoxAdapter(child: BreakingTicker(items: _breaking)),

          // ---- Live TV card ----
          SliverToBoxAdapter(child: _LiveTVCard(settings: _settings)),

          // ---- Live Poll ----
          const SliverToBoxAdapter(child: LivePollWidget()),

          // ---- Loading / error states ----
          if (_loading && _articles == null)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (_error != null && _articles == null)
            SliverToBoxAdapter(child: _ErrorBanner(message: _error!)),

          if (_articles != null && _articles!.isNotEmpty) ...[
            // ---- Category chips ----
            const SliverToBoxAdapter(child: _CategoryStrip()),

            // ---- Latest news heading ----
            SliverToBoxAdapter(
              child: SectionHeader(
                eyebrow: 'Fresh off the desk',
                title: 'Latest news',
                onSeeAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewsScreen()),
                ),
              ),
            ),

            // ---- Featured (first article, large) ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ArticleCard(
                  article: _articles!.first,
                  variant: ArticleCardVariant.large,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ---- Rest of the articles ----
            SliverList.separated(
              itemCount: _articles!.length - 1,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ArticleCard(article: _articles![i + 1]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ],
      ),
    );
  }
}

class _LiveTVCard extends StatelessWidget {
  final SiteSettings? settings;
  const _LiveTVCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    final title = settings?.stream.tvTitle ?? 'Gotabgaa TV';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF15070C), Color(0xFF060309)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandRed.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: HlsPlayer(url: settings?.stream.tvStreamUrl),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LiveTVScreen(settings: settings)),
              ),
              icon: const Icon(Icons.fullscreen),
              label: const Text('Open live TV'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStrip extends StatefulWidget {
  const _CategoryStrip();
  @override
  State<_CategoryStrip> createState() => _CategoryStripState();
}

class _CategoryStripState extends State<_CategoryStrip> {
  List<dynamic> _cats = const [];

  @override
  void initState() {
    super.initState();
    ApiService.instance.fetchCategories().then((c) {
      if (mounted) setState(() => _cats = c);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    if (_cats.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final c = _cats[i];
            return ActionChip(
              label: Text(c.name as String),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryScreen(
                    slug: c.slug as String,
                    name: c.name as String,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.brandRed.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.brandRed),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: AppColors.brandRed)),
            ),
          ],
        ),
      ),
    );
  }
}
