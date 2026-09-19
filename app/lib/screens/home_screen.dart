import 'package:flutter/material.dart';

import '../models/article.dart';
import '../models/breaking_news.dart';
import '../models/settings.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/breaking_ticker.dart';
import '../widgets/hls_player.dart';
import '../widgets/live_chat_widget.dart';
import '../widgets/live_poll_widget.dart';
import '../widgets/section_header.dart';
import 'category_screen.dart';
import 'live_tv_screen.dart';
import 'news_screen.dart';
import 'search_screen.dart';

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
          // ---- App bar with brand-gradient hero + pill search ----
          const _HomeHeader(),

          // ---- Breaking news ticker ----
          if (_breaking.isNotEmpty)
            SliverToBoxAdapter(child: BreakingTicker(items: _breaking)),

          // ---- Live TV card ----
          SliverToBoxAdapter(child: _LiveTVCard(settings: _settings)),

          // ---- Live conversation (immediately after live stream) ----
          const SliverToBoxAdapter(child: LiveChatWidget()),

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
              separatorBuilder: (_, _) => const SizedBox(height: 14),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- Edge-to-edge player with floating LIVE + title chips ----
        Stack(
          children: [
            Container(
              color: Colors.black,
              child: HlsPlayer(url: settings?.stream.tvStreamUrl),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8),
                        SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- Open-fullscreen CTA below (still padded) ----
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: SizedBox(
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
        ),
      ],
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
          separatorBuilder: (_, _) => const SizedBox(width: 8),
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

/// Home screen header. A pinned SliverAppBar with a dark cinematic
/// background, subtle brand-gradient sheen, the logo, a pill-shaped
/// search input, and a small "LIVE" chip.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 8,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      toolbarHeight: 74,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF14090C),
              Color(0xFF0A0A0F),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandRed.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                ),
              ),
            ),
          ],
        ),
      ),
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Image.asset('assets/images/logo.png', height: 34),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SearchPill(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _LiveChip(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LiveTVScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search,
                  size: 18, color: Colors.white.withValues(alpha: 0.75)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search news, shows…',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveChip extends StatelessWidget {
  final VoidCallback onTap;
  const _LiveChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandRed.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingDot(),
              SizedBox(width: 6),
              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_c),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
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
