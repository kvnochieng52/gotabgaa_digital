import 'package:flutter/material.dart';

import '../models/breaking_news.dart';
import '../theme/app_theme.dart';

/// Horizontally-scrolling breaking-news strip, brand-gradient background.
/// Auto-scrolls at a steady rate.
class BreakingTicker extends StatefulWidget {
  final List<BreakingNewsItem> items;
  const BreakingTicker({super.key, required this.items});

  @override
  State<BreakingTicker> createState() => _BreakingTickerState();
}

class _BreakingTickerState extends State<BreakingTicker> {
  final _controller = ScrollController();
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  Future<void> _startAutoScroll() async {
    // Wait one frame so we have a real maxScrollExtent.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    while (!_disposed && _controller.hasClients) {
      final max = _controller.position.maxScrollExtent;
      if (max <= 0) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        continue;
      }
      await _controller.animateTo(
        max,
        duration: Duration(seconds: (max / 40).clamp(20, 90).toInt()),
        curve: Curves.linear,
      );
      if (_disposed || !_controller.hasClients) return;
      _controller.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    // Duplicate the list for the seamless-loop illusion.
    final loopItems = [...widget.items, ...widget.items];
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _PulseDot(),
                  SizedBox(width: 6),
                  Text(
                    'BREAKING',
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
          Expanded(
            child: SizedBox(
              height: 22,
              child: ListView.separated(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: loopItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 40),
                itemBuilder: (context, i) => Center(
                  child: Text(
                    loopItems[i].headline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
      opacity: Tween(begin: 1.0, end: 0.35).animate(_c),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
