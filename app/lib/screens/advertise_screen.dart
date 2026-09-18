import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'contact_screen.dart';

class AdvertiseScreen extends StatelessWidget {
  const AdvertiseScreen({super.key});

  static const _stats = [
    ('500K+', 'Weekly reach'),
    ('24/7', 'Live broadcast'),
    ('9', 'Countries'),
    ('3', 'Languages'),
  ];

  static const _packages = [
    (
      'Starter',
      'For small businesses',
      'KSh 25,000',
      '/ week',
      [
        'Banner ad on gotabgaa.co.ke',
        '3 mentions on Prime Time News',
        'Post on Facebook & WhatsApp channel',
        'Basic performance report',
      ],
      false,
    ),
    (
      'Growth',
      'Most popular',
      'KSh 85,000',
      '/ month',
      [
        'Homepage takeover — 7 days',
        '30-second TV spot × 15 airings',
        'Sponsored article + video short',
        'Weekly analytics dashboard',
        'Dedicated account manager',
      ],
      true,
    ),
    (
      'Premier',
      'For campaigns & brands',
      'Custom',
      '',
      [
        'Show or program sponsorship',
        '60-second TV spots × unlimited',
        'Live event coverage & branded content',
        'Cross-channel amplification',
        'Bespoke content team',
      ],
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advertise with us')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ---- Hero ----
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.brandRed.withValues(alpha: 0.12),
                    border: Border.all(
                        color: AppColors.brandRed.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: AppColors.brandRed, size: 8),
                      SizedBox(width: 6),
                      Text(
                        'PARTNER WITH GOTABGAA TV',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandRed,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: AppColors.textLight, fontSize: 30),
                    children: const [
                      TextSpan(text: 'Reach the '),
                      TextSpan(
                        text: 'Kalenjin community',
                        style: TextStyle(color: AppColors.brandRed),
                      ),
                      TextSpan(text: ' wherever they live.'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your brand on the largest media platform serving the Kalenjin community — home and diaspora. Live TV, radio, digital, social — one partner, every channel.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLightDim,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: _stats
                      .map((s) => _statTile(s.$1, s.$2))
                      .toList(growable: false),
                ),
              ],
            ),
          ),

          const Divider(),

          // ---- Packages ----
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
            child: Text(
              'Simple, transparent pricing.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          ..._packages.map((p) => _packageCard(context, p)),

          // ---- Talk to sales CTA ----
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F0F14), Color(0xFF1A1A22)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ready to talk?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Tell us about your brand and we'll propose the right mix.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ContactScreen()),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Start a conversation'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (rect) =>
              AppColors.brandGradient.createShader(rect),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textLightMuted,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _packageCard(
      BuildContext context,
      (String, String, String, String, List<String>, bool) p) {
    final (name, tag, price, period, features, accent) = p;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent
                ? AppColors.brandRed.withValues(alpha: 0.35)
                : AppColors.lineLight,
          ),
          boxShadow: [
            BoxShadow(
              color: accent
                  ? AppColors.brandRed.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (accent)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            Text(
              tag.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.brandOrange,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(price,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(width: 4),
                Text(period,
                    style: const TextStyle(color: AppColors.textLightMuted)),
              ],
            ),
            const Divider(height: 32),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check,
                          size: 16, color: AppColors.brandRed),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(
                          color: AppColors.textLightDim,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: accent
                  ? FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ContactScreen()),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Get started'),
                    )
                  : OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ContactScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Get started'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
