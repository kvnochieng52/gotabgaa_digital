import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';

class CategoryScreen extends StatefulWidget {
  final String slug;
  final String name;
  const CategoryScreen({super.key, required this.slug, required this.name});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Article>? _articles;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.instance
          .fetchArticles(limit: 60, category: widget.slug);
      if (mounted) setState(() => _articles = res);
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: RefreshIndicator(
        color: AppColors.brandRed,
        onRefresh: _load,
        child: _loading && _articles == null
            ? const Center(child: CircularProgressIndicator())
            : (_articles == null || _articles!.isEmpty)
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No stories in this section yet.'),
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _articles!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ArticleCard(article: _articles![i]),
                    ),
                  ),
      ),
    );
  }
}
