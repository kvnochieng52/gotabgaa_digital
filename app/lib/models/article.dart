class Article {
  final String slug;
  final String title;
  final String? excerpt;
  final String? body;
  final String? category;
  final String? categorySlug;
  final String authorName;
  final DateTime? publishedAt;
  final int readingTime;
  final String image; // Gradient "#hex|#hex" OR a full URL
  final String? youtubeUrl;
  final bool featured;
  final bool breaking;
  final bool isShort;
  final int viewCount;
  final int likeCount;
  final List<String> tags;

  Article({
    required this.slug,
    required this.title,
    this.excerpt,
    this.body,
    this.category,
    this.categorySlug,
    required this.authorName,
    this.publishedAt,
    this.readingTime = 3,
    required this.image,
    this.youtubeUrl,
    this.featured = false,
    this.breaking = false,
    this.isShort = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.tags = const [],
  });

  factory Article.fromJson(Map<String, dynamic> j) => Article(
        slug: j['slug'] as String,
        title: j['title'] as String,
        excerpt: j['excerpt'] as String?,
        body: j['body'] as String?,
        category: j['category'] as String?,
        categorySlug: j['categorySlug'] as String?,
        authorName: (j['author'] as Map<String, dynamic>?)?['name'] as String? ??
            'Editorial Desk',
        publishedAt: j['publishedAt'] != null
            ? DateTime.tryParse(j['publishedAt'] as String)
            : null,
        readingTime: (j['readingTime'] as int?) ?? 3,
        image: (j['image'] as String?) ?? '#E63946|#FF7A1A',
        youtubeUrl: j['youtubeUrl'] as String?,
        featured: (j['featured'] as bool?) ?? false,
        breaking: (j['breaking'] as bool?) ?? false,
        isShort: (j['isShort'] as bool?) ?? false,
        viewCount: (j['viewCount'] as int?) ?? 0,
        likeCount: (j['likeCount'] as int?) ?? 0,
        tags: ((j['tags'] as List<dynamic>?) ?? []).cast<String>(),
      );

  /// True when [image] is a normal URL vs a "#hex|#hex" gradient spec.
  bool get hasImageUrl =>
      image.startsWith('http://') || image.startsWith('https://');

  /// Best-effort YouTube video ID for embedding.
  String? get youtubeId {
    if (youtubeUrl == null) return null;
    final match = RegExp(r'(?:youtu\.be/|v=|/embed/|/shorts/)([\w-]{11})')
        .firstMatch(youtubeUrl!);
    return match?.group(1);
  }
}
