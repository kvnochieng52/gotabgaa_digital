import 'package:flutter/material.dart';

class ApiCategory {
  final String slug;
  final String name;
  final String? colorHex;
  final int articleCount;

  ApiCategory({
    required this.slug,
    required this.name,
    this.colorHex,
    this.articleCount = 0,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> j) => ApiCategory(
        slug: j['slug'] as String,
        name: j['name'] as String,
        colorHex: j['color'] as String?,
        articleCount: (j['articleCount'] as int?) ?? 0,
      );

  Color? get color {
    if (colorHex == null) return null;
    final hex = colorHex!.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return null;
  }
}
