class BreakingNewsItem {
  final String headline;
  final String? linkUrl;

  BreakingNewsItem({required this.headline, this.linkUrl});

  factory BreakingNewsItem.fromJson(Map<String, dynamic> j) => BreakingNewsItem(
        headline: j['headline'] as String,
        linkUrl: j['link_url'] as String?,
      );
}
