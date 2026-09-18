import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Displays either:
///   • A remote image URL (with caching + gradient placeholder)
///   • A "#hex|#hex" gradient spec — falls back to the letter or logo of [title]
///
/// Matches the web frontend's PosterImage component 1:1.
class PosterImage extends StatelessWidget {
  final String spec;
  final String? title;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const PosterImage({
    super.key,
    required this.spec,
    this.title,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  bool get _isUrl => spec.startsWith('http://') || spec.startsWith('https://');

  LinearGradient _parseGradient() {
    // "#E63946|#FF7A1A" → LinearGradient(topLeft → bottomRight)
    final parts = spec.split('|');
    Color parse(String hex) {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    }

    if (parts.length >= 2) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [parse(parts[0]), parse(parts[1])],
      );
    }
    return AppColors.brandGradient;
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;

    if (_isUrl) {
      return ClipRRect(
        borderRadius: radius,
        child: CachedNetworkImage(
          imageUrl: spec,
          fit: fit,
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (_, __) => Container(
            decoration: BoxDecoration(gradient: AppColors.brandGradient),
          ),
          errorWidget: (_, __, ___) => _GradientLetter(
            title: title,
            gradient: AppColors.brandGradient,
          ),
        ),
      );
    }

    // Gradient spec (no image).
    return ClipRRect(
      borderRadius: radius,
      child: _GradientLetter(title: title, gradient: _parseGradient()),
    );
  }
}

class _GradientLetter extends StatelessWidget {
  final String? title;
  final LinearGradient gradient;
  const _GradientLetter({this.title, required this.gradient});

  @override
  Widget build(BuildContext context) {
    final letter = (title?.trim().isNotEmpty ?? false)
        ? title!.trim().substring(0, 1).toUpperCase()
        : 'G';
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: -3,
          ),
        ),
      ),
    );
  }
}
