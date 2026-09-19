class ArticleComment {
  final int id;
  final String name;
  final String body;
  final DateTime? createdAt;

  const ArticleComment({
    required this.id,
    required this.name,
    required this.body,
    required this.createdAt,
  });

  factory ArticleComment.fromJson(Map<String, dynamic> j) => ArticleComment(
        id: (j['id'] as num).toInt(),
        name: j['name']?.toString() ?? 'Anon',
        body: j['body']?.toString() ?? '',
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'].toString())?.toLocal()
            : null,
      );
}
