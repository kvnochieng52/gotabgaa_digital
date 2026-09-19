import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/article.dart';
import '../models/article_comment.dart';
import '../models/breaking_news.dart';
import '../models/category.dart';
import '../models/live_chat.dart';
import '../models/poll.dart';
import '../models/settings.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final _client = http.Client();

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse(ApiConfig.v1(path));
    final res = await _client.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        'Request failed for ${uri.path}',
        statusCode: res.statusCode,
      );
    }
    return json.decode(res.body);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse(ApiConfig.v1(path));
    final res = await _client
        .post(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 15));
    final decoded = res.body.isEmpty ? {} : json.decode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = (decoded is Map) ? (decoded['message']?.toString() ?? 'Error') : 'Error';
      throw ApiException('$msg (${uri.host}${uri.path})',
          statusCode: res.statusCode);
    }
    return decoded;
  }

  // ---------- Categories ----------
  Future<List<ApiCategory>> fetchCategories() async {
    final data = await _get('/categories') as List<dynamic>;
    return data
        .map((c) => ApiCategory.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  // ---------- Articles ----------
  Future<List<Article>> fetchArticles({
    int limit = 20,
    String? category,
    bool? breaking,
    bool? featured,
    String? search,
  }) async {
    final params = <String>[];
    params.add('limit=$limit');
    if (category != null) params.add('category=$category');
    if (breaking == true) params.add('breaking=1');
    if (featured == true) params.add('featured=1');
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    final res = await _get('/articles?${params.join('&')}') as Map<String, dynamic>;
    final data = (res['data'] as List<dynamic>?) ?? [];
    return data
        .map((a) => Article.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  Future<Article> fetchArticle(String slug) async {
    final res = await _get('/articles/$slug') as Map<String, dynamic>;
    return Article.fromJson(res['data'] as Map<String, dynamic>);
  }

  // ---------- Breaking news ----------
  Future<List<BreakingNewsItem>> fetchBreaking() async {
    try {
      final res = await _get('/breaking-news') as Map<String, dynamic>;
      final data = (res['data'] as List<dynamic>?) ?? [];
      return data
          .map((b) => BreakingNewsItem.fromJson(b as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------- Settings ----------
  Future<SiteSettings> fetchSettings() async {
    final res = await _get('/settings') as Map<String, dynamic>;
    return SiteSettings.fromJson(res);
  }

  // ---------- Poll ----------
  Future<Poll?> fetchActivePoll() async {
    final res = await _get('/poll') as Map<String, dynamic>;
    final poll = res['poll'];
    if (poll == null) return null;
    return Poll.fromJson(poll as Map<String, dynamic>);
  }

  Future<Poll> vote(String pollSlug, String optionId) async {
    final res = await _post('/polls/$pollSlug/vote', {'option_id': optionId});
    return Poll.fromJson((res as Map<String, dynamic>)['poll'] as Map<String, dynamic>);
  }

  // ---------- Live chat ----------
  Future<LiveChatDay> fetchLiveChat({DateTime? date}) async {
    final path = date == null
        ? '/live-chat'
        : '/live-chat?date=${date.toIso8601String().substring(0, 10)}';
    final res = await _get(path) as Map<String, dynamic>;
    return LiveChatDay.fromJson(res);
  }

  Future<List<LiveChatDaySummary>> fetchLiveChatDays() async {
    final res = await _get('/live-chat/days') as Map<String, dynamic>;
    final data = (res['data'] as List<dynamic>?) ?? [];
    return data
        .map((d) => LiveChatDaySummary.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  Future<LiveChatMessage> postLiveChat({
    required String name,
    required String message,
    int? parentId,
  }) async {
    final res = await _post('/live-chat', {
      'name': name,
      'message': message,
      'parent_id': ?parentId,
    });
    return LiveChatMessage.fromJson(res as Map<String, dynamic>);
  }

  Future<Map<String, int>> reactLiveChat({
    required int messageId,
    required String emoji,
  }) async {
    final res = await _post('/live-chat/$messageId/react', {'emoji': emoji})
        as Map<String, dynamic>;
    final map = (res['reactions'] as Map<String, dynamic>? ?? {});
    return map.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  // ---------- Article comments ----------
  Future<List<ArticleComment>> fetchArticleComments(String slug) async {
    final res = await _get('/articles/$slug/comments') as Map<String, dynamic>;
    final data = (res['data'] as List<dynamic>?) ?? [];
    return data
        .map((c) => ArticleComment.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<ArticleComment> postArticleComment(
    String slug, {
    required String name,
    String? email,
    required String body,
  }) async {
    final res = await _post('/articles/$slug/comments', {
      'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      'body': body,
    });
    return ArticleComment.fromJson(res as Map<String, dynamic>);
  }

  // ---------- Contact form ----------
  Future<void> sendContact({
    required String name,
    required String email,
    String? phone,
    required String subject,
    required String message,
    String? source,
  }) async {
    await _post('/contact', {
      'name': name,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'subject': subject,
      'message': message,
      if (source != null) 'source': source,
    });
  }
}
