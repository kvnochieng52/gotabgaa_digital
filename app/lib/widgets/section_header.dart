import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 2,
                      decoration: const BoxDecoration(
                        gradient: AppColors.brandGradient,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      eyebrow.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandOrange,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton.icon(
              onPressed: onSeeAll,
              icon: const Text('See all'),
              label: const Icon(Icons.arrow_forward, size: 16),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(color: AppColors.lineLightStrong),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
