import 'package:flutter/material.dart';

import '../models/article.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import 'category_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<Article>? _articles;
  List<ApiCategory>? _cats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await Future.wait([
        ApiService.instance.fetchArticles(limit: 60),
        ApiService.instance.fetchCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _articles = r[0] as List<Article>;
        _cats = r[1] as List<ApiCategory>;
      });
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Latest news')),
      body: RefreshIndicator(
        color: AppColors.brandRed,
        onRefresh: _load,
        child: _loading && _articles == null
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (_cats != null && _cats!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _cats!.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final c = _cats![i];
                              return ActionChip(
                                label: Text(c.name),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoryScreen(
                                      slug: c.slug,
                                      name: c.name,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (_articles != null)
                    SliverList.separated(
                      itemCount: _articles!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ArticleCard(article: _articles![i]),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
      ),
    );
  }
}
