import 'dart:async';

import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  String _lastQuery = '';
  List<Article>? _results;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = null;
        _loading = false;
        _error = null;
        _lastQuery = '';
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 380), () => _run(trimmed));
  }

  Future<void> _run(String query) async {
    setState(() {
      _loading = true;
      _error = null;
      _lastQuery = query;
    });
    try {
      final results =
          await ApiService.instance.fetchArticles(limit: 30, search: query);
      if (!mounted || _lastQuery != query) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || _lastQuery != query) return;
      setState(() {
        _error = 'Search failed. Try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.lineLightStrong),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 20, color: AppColors.textLightMuted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focus,
                            textInputAction: TextInputAction.search,
                            onChanged: _onChanged,
                            onSubmitted: (v) => _run(v.trim()),
                            decoration: const InputDecoration(
                              hintText: 'Search news, shows, topics…',
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _controller.clear();
                              _onChanged('');
                              _focus.requestFocus();
                            },
                            child: const Icon(Icons.close,
                                size: 18, color: AppColors.textLightMuted),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _StateBlock(
        icon: Icons.wifi_off,
        title: 'Search failed',
        message: _error!,
      );
    }
    if (_results == null) {
      return const _EmptyStateHints();
    }
    if (_results!.isEmpty) {
      return _StateBlock(
        icon: Icons.search_off,
        title: 'Nothing found',
        message: 'No results for “$_lastQuery”. Try a different phrase.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _results!.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => ArticleCard(article: _results![i]),
    );
  }
}

class _EmptyStateHints extends StatelessWidget {
  const _EmptyStateHints();

  @override
  Widget build(BuildContext context) {
    const suggestions = [
      'Kalenjin',
      'Elections',
      'Sports',
      'Diaspora',
      'Culture',
      'Music',
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text(
          'Trending searches',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textLightMuted,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .map((s) => ActionChip(
                    label: Text(s),
                    onPressed: () {
                      final state =
                          context.findAncestorStateOfType<_SearchScreenState>();
                      state?._controller.text = s;
                      state?._run(s);
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _StateBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _StateBlock({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textLightMuted),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textLightMuted),
            ),
          ],
        ),
      ),
    );
  }
}
