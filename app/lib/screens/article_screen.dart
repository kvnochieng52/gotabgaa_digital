import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/article.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/article_comments_section.dart';
import '../widgets/poster_image.dart';
import '../widgets/rich_article_body.dart';

class ArticleScreen extends StatefulWidget {
  final String slug;
  const ArticleScreen({super.key, required this.slug});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  Article? _article;
  List<Article> _related = [];
  YoutubePlayerController? _ytController;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final article = await ApiService.instance.fetchArticle(widget.slug);
      if (!mounted) return;

      final ytId = article.youtubeId;
      final ytController = ytId != null
          ? YoutubePlayerController(
              initialVideoId: ytId,
              flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
            )
          : null;

      setState(() {
        _article = article;
        _ytController = ytController;
        _loading = false;
      });

      // Fetch related in the background.
      if (article.categorySlug != null) {
        try {
          final related = await ApiService.instance
              .fetchArticles(limit: 4, category: article.categorySlug);
          if (mounted) {
            setState(() {
              _related = related.where((a) => a.slug != article.slug).take(3).toList();
            });
          }
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load article';
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _article == null
              ? _NotFound(message: _error ?? 'Not found')
              : _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final a = _article!;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: false,
          expandedHeight: 280,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                PosterImage(spec: a.image, title: a.title),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (a.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            a.category!.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        a.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---- Meta row ----
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.brandRed,
                  child: Text(
                    a.authorName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.authorName,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        '${a.publishedAt != null ? DateFormat('MMM d, yyyy').format(a.publishedAt!) : ''} · ${a.readingTime} min read',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                _shareButton(context, a),
              ],
            ),
          ),
        ),

        // ---- YouTube embed if present ----
        if (_ytController != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: YoutubePlayer(
                controller: _ytController!,
                progressIndicatorColor: AppColors.brandOrange,
                progressColors: const ProgressBarColors(
                  playedColor: AppColors.brandRed,
                  handleColor: AppColors.brandOrange,
                ),
              ),
            ),
          ),

        // ---- Body ----
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: RichArticleBody(html: a.body ?? a.excerpt ?? ''),
          ),
        ),

        // ---- Tags ----
        if (a.tags.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: a.tags
                    .map((t) => Chip(
                          label: Text('#$t'),
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ),
          ),

        // ---- Comments ----
        SliverToBoxAdapter(
          child: ArticleCommentsSection(articleSlug: a.slug),
        ),

        // ---- Related ----
        if (_related.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
              child: Text('Read next', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          SliverList.separated(
            itemCount: _related.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ArticleCard(article: _related[i]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ],
    );
  }

  Widget _shareButton(BuildContext context, Article a) {
    return IconButton(
      onPressed: () async {
        final text = Uri.encodeComponent(a.title);
        await launchUrl(Uri.parse('https://api.whatsapp.com/send?text=$text'));
      },
      icon: const Icon(Icons.share_outlined),
    );
  }
}

class _NotFound extends StatelessWidget {
  final String message;
  const _NotFound({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.article_outlined, size: 48, color: AppColors.textLightMuted),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }
}
