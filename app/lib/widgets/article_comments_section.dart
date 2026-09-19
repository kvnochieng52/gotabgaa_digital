import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article_comment.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ArticleCommentsSection extends StatefulWidget {
  final String articleSlug;
  const ArticleCommentsSection({super.key, required this.articleSlug});

  @override
  State<ArticleCommentsSection> createState() => _ArticleCommentsSectionState();
}

class _ArticleCommentsSectionState extends State<ArticleCommentsSection> {
  static const _prefsNameKey = 'article_comment_name';
  static const _prefsEmailKey = 'article_comment_email';

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  List<ArticleComment>? _comments;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _nameCtrl.text = prefs.getString(_prefsNameKey) ?? '';
    _emailCtrl.text = prefs.getString(_prefsEmailKey) ?? '';
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list =
          await ApiService.instance.fetchArticleComments(widget.articleSlug);
      if (!mounted) return;
      setState(() {
        _comments = list;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load comments';
      });
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and comment are required')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      final created = await ApiService.instance.postArticleComment(
        widget.articleSlug,
        name: name,
        email: email.isEmpty ? null : email,
        body: body,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsNameKey, name);
      if (email.isNotEmpty) await prefs.setString(_prefsEmailKey, email);
      if (!mounted) return;
      setState(() {
        _comments = [created, ...(_comments ?? const [])];
        _bodyCtrl.clear();
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not post comment')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = _comments?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mode_comment_outlined,
                  size: 20, color: AppColors.brandOrange),
              const SizedBox(width: 8),
              Text(
                'Comments${count > 0 ? " · $count" : ""}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _composer(),
          const SizedBox(height: 20),
          _list(),
        ],
      ),
    );
  }

  Widget _composer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lineLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  maxLength: 60,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    isDense: true,
                    counterText: '',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bodyCtrl,
            maxLength: 2000,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Share your thoughts…',
              border: OutlineInputBorder(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _sending ? null : _submit,
              icon: _sending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, size: 16),
              label: const Text('Post comment'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandOrange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(_error!,
                  style: const TextStyle(color: AppColors.textLightMuted)),
            ),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_comments == null || _comments!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Be the first to comment.',
          style: TextStyle(color: AppColors.textLightMuted),
        ),
      );
    }
    return Column(
      children: _comments!
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CommentTile(comment: c),
              ))
          .toList(),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final ArticleComment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final initial = comment.name.isEmpty
        ? '?'
        : comment.name.substring(0, 1).toUpperCase();
    final when = comment.createdAt != null
        ? DateFormat('MMM d, yyyy · HH:mm').format(comment.createdAt!)
        : '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lineLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.brandOrange,
            child: Text(
              initial,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.name,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textLight,
                                )),
                    const SizedBox(width: 8),
                    Text(when,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textLightMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(comment.body,
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.textLightDim)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
