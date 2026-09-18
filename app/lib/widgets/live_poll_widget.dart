import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/poll.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

const _voteKey = 'gotabgaa-poll-votes'; // Map<pollSlug, optionId> in JSON

/// Live poll widget that mirrors the web LivePoll component:
/// - Fetches the active poll from /api/v1/poll
/// - Casts votes via POST /polls/{slug}/vote
/// - Remembers the local vote in SharedPreferences
class LivePollWidget extends StatefulWidget {
  const LivePollWidget({super.key});

  @override
  State<LivePollWidget> createState() => _LivePollWidgetState();
}

class _LivePollWidgetState extends State<LivePollWidget> {
  Poll? _poll;
  String? _votedOption;
  bool _loading = true;
  bool _submitting = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      final poll = await ApiService.instance.fetchActivePoll();
      if (!mounted) return;
      String? voted;
      if (poll != null) {
        final prefs = await SharedPreferences.getInstance();
        final map = prefs.getString(_voteKey);
        if (map != null) {
          final regex = RegExp('"${poll.slug}":"([^"]+)"');
          voted = regex.firstMatch(map)?.group(1);
        }
      }
      setState(() {
        _poll = poll;
        _votedOption = voted;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = 'Could not load poll';
        _loading = false;
      });
    }
  }

  Future<void> _vote(String optionId) async {
    if (_poll == null || _votedOption != null || _submitting) return;
    setState(() => _submitting = true);

    // Optimistic UI update.
    final updatedOptions = _poll!.options
        .map((o) => o.id == optionId
            ? PollOption(id: o.id, label: o.label, votes: o.votes + 1)
            : o)
        .toList();
    setState(() {
      _poll = Poll(
        slug: _poll!.slug,
        question: _poll!.question,
        options: updatedOptions,
        active: _poll!.active,
        closesAt: _poll!.closesAt,
        totalVotes: _poll!.totalVotes + 1,
      );
      _votedOption = optionId;
    });

    try {
      final fresh = await ApiService.instance.vote(_poll!.slug, optionId);
      if (mounted) setState(() => _poll = fresh);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_voteKey, '{"${_poll!.slug}":"$optionId"}');
    } catch (e) {
      if (mounted && !e.toString().toLowerCase().contains('already')) {
        setState(() => _errorMsg = e.toString());
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _closesInText() {
    final closes = _poll?.closesAt;
    if (closes == null) return null;
    final diff = closes.difference(DateTime.now());
    if (diff.isNegative) return 'Closed';
    if (diff.inDays > 0) return 'Closes in ${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return 'Closes in ${diff.inHours}h ${diff.inMinutes % 60}m';
    return 'Closes in ${diff.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lineLightStrong),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_poll == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(closesText: null),
          const SizedBox(height: 16),
          Text(
            _errorMsg ?? 'No live poll right now.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    final total = _poll!.totalVotes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(closesText: _closesInText()),
        const SizedBox(height: 14),
        Text(
          _poll!.question,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 14),
        ..._poll!.options.map((opt) {
          final pct = total > 0 ? (opt.votes / total * 100) : 0.0;
          final isPicked = _votedOption == opt.id;
          final showResults = _votedOption != null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PollOptionTile(
              option: opt,
              pct: pct,
              picked: isPicked,
              showResults: showResults,
              enabled: !showResults && !_submitting,
              onTap: () => _vote(opt.id),
            ),
          );
        }),
        const SizedBox(height: 10),
        Divider(color: AppColors.lineLight, height: 20),
        Row(
          children: [
            const Icon(Icons.people_outline,
                size: 14, color: AppColors.textLightMuted),
            const SizedBox(width: 6),
            Text(
              '${_formatCount(total)} votes'
              '${_votedOption == null ? ' · tap to cast yours' : ' · thanks for voting'}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _header({required String? closesText}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.brandRed.withValues(alpha: 0.12),
            border: Border.all(
                color: AppColors.brandRed.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _DotBlink(),
              SizedBox(width: 6),
              Text(
                'LIVE POLL',
                style: TextStyle(
                  color: AppColors.brandRed,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (closesText != null)
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 12, color: AppColors.textLightMuted),
              const SizedBox(width: 4),
              Text(closesText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontFamily: 'monospace',
                      )),
            ],
          ),
      ],
    );
  }

  static String _formatCount(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : n.toString();
}

class _PollOptionTile extends StatelessWidget {
  final PollOption option;
  final double pct;
  final bool picked;
  final bool showResults;
  final bool enabled;
  final VoidCallback onTap;

  const _PollOptionTile({
    required this.option,
    required this.pct,
    required this.picked,
    required this.showResults,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: picked
                  ? AppColors.brandRed
                  : AppColors.lineLightStrong,
              width: picked ? 1.5 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (showResults)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: pct / 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.brandRed.withValues(alpha: 0.24),
                            AppColors.brandOrange.withValues(alpha: 0.24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    if (picked)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.check,
                            size: 16, color: AppColors.brandRed),
                      ),
                    Expanded(
                      child: Text(
                        option.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: picked
                                  ? AppColors.brandRed
                                  : AppColors.textLight,
                              fontSize: 13,
                            ),
                      ),
                    ),
                    if (showResults) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w800,
                              color: AppColors.textLight,
                            ),
                      ),
                    ],
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

class _DotBlink extends StatefulWidget {
  const _DotBlink();
  @override
  State<_DotBlink> createState() => _DotBlinkState();
}

class _DotBlinkState extends State<_DotBlink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.3).animate(_c),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.brandRed,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
