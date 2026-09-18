import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/article.dart';
import '../screens/article_screen.dart';
import '../theme/app_theme.dart';
import 'poster_image.dart';

enum ArticleCardVariant { standard, large, compact }

class ArticleCard extends StatelessWidget {
  final Article article;
  final ArticleCardVariant variant;

  const ArticleCard({
    super.key,
    required this.article,
    this.variant = ArticleCardVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final large = variant == ArticleCardVariant.large;
    final compact = variant == ArticleCardVariant.compact;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ArticleScreen(slug: article.slug)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.lineLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Media ----
              AspectRatio(
                aspectRatio: compact ? 4 / 3 : 16 / 10,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: PosterImage(
                        spec: article.image,
                        title: article.title,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                      ),
                    ),
                    if (article.category != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _CategoryChip(label: article.category!),
                      ),
                    if (article.youtubeUrl != null)
                      const Positioned(
                        top: 12,
                        right: 12,
                        child: _PlayBadge(),
                      ),
                  ],
                ),
              ),
              // ---- Body ----
              Padding(
                padding: EdgeInsets.fromLTRB(
                  large ? 20 : 16,
                  large ? 18 : 14,
                  large ? 20 : 16,
                  large ? 20 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: large ? 3 : (compact ? 2 : 3),
                      overflow: TextOverflow.ellipsis,
                      style: large
                          ? Theme.of(context).textTheme.headlineSmall
                          : Theme.of(context).textTheme.titleMedium,
                    ),
                    if (!compact && (article.excerpt?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 8),
                      Text(
                        article.excerpt!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLightDim,
                              height: 1.4,
                            ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _CardMeta(article: article),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
    );
  }
}

class _CardMeta extends StatelessWidget {
  final Article article;
  const _CardMeta({required this.article});

  @override
  Widget build(BuildContext context) {
    final date = article.publishedAt;
    final dateStr = date != null ? DateFormat('MMM d, yyyy').format(date) : '';
    return Row(
      children: [
        if (dateStr.isNotEmpty)
          Text(
            dateStr,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textLightMuted),
          ),
        if (dateStr.isNotEmpty) ...[
          const SizedBox(width: 8),
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: AppColors.textLightMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          '${article.readingTime} min read',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textLightMuted),
        ),
      ],
    );
  }
}
