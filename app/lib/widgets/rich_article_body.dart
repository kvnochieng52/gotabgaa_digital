import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

/// Renders our article body — a mix of plain text and simple HTML tags emitted
/// by the CMS's rich editor (p, h2, h3, blockquote, ul/li, strong/em, a, br).
///
/// We deliberately avoid `flutter_html` (unmaintained, breaks against current
/// `html` package) and roll a tiny renderer for exactly the tags we support.
class RichArticleBody extends StatelessWidget {
  final String html;
  const RichArticleBody({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    final blocks = _splitIntoBlocks(html);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in blocks) _buildBlock(context, b),
      ],
    );
  }

  Widget _buildBlock(BuildContext context, _Block b) {
    final theme = Theme.of(context);
    switch (b.kind) {
      case _BlockKind.h2:
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            _stripInlineTags(b.text),
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontSize: 22, height: 1.2),
          ),
        );
      case _BlockKind.h3:
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            _stripInlineTags(b.text),
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
        );
      case _BlockKind.blockquote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.brandOrange.withValues(alpha: 0.08),
            border: const Border(
              left: BorderSide(color: AppColors.brandOrange, width: 4),
            ),
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(8)),
          ),
          child: _paragraph(context, b.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textLightDim,
              )),
        );
      case _BlockKind.li:
        return Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6, right: 10),
                child:
                    Icon(Icons.circle, size: 5, color: AppColors.brandOrange),
              ),
              Expanded(child: _paragraph(context, b.text)),
            ],
          ),
        );
      case _BlockKind.p:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _paragraph(context, b.text),
        );
    }
  }

  Widget _paragraph(BuildContext context, String htmlFragment,
      {TextStyle? style}) {
    final base = style ??
        Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.6,
              color: AppColors.textLightDim,
            );
    return SelectableText.rich(
      _inlineToSpans(htmlFragment, base ?? const TextStyle()),
      style: base,
    );
  }

  // ---------- Block splitting ----------

  static final _blockRegex = RegExp(
    r'<(h2|h3|blockquote|li|p)[^>]*>([\s\S]*?)</\1>',
    caseSensitive: false,
  );

  List<_Block> _splitIntoBlocks(String raw) {
    if (raw.trim().isEmpty) return const [];
    final blocks = <_Block>[];
    final matches = _blockRegex.allMatches(raw).toList();

    if (matches.isEmpty) {
      // No block-level tags — treat every non-empty line as a paragraph.
      for (final line in raw.split(RegExp(r'\n\s*\n|<br\s*/?>', caseSensitive: false))) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        blocks.add(_Block(kind: _BlockKind.p, text: trimmed));
      }
      return blocks;
    }

    var cursor = 0;
    for (final m in matches) {
      // Any raw text between block matches — treat as its own paragraph.
      if (m.start > cursor) {
        final between = raw.substring(cursor, m.start).trim();
        if (between.isNotEmpty && between != '<br>' && between != '<br/>') {
          blocks.add(_Block(kind: _BlockKind.p, text: between));
        }
      }
      final tag = m.group(1)!.toLowerCase();
      final content = m.group(2)!.trim();
      blocks.add(_Block(kind: _kindFor(tag), text: content));
      cursor = m.end;
    }
    if (cursor < raw.length) {
      final tail = raw.substring(cursor).trim();
      if (tail.isNotEmpty) {
        blocks.add(_Block(kind: _BlockKind.p, text: tail));
      }
    }
    return blocks;
  }

  static _BlockKind _kindFor(String tag) => switch (tag) {
        'h2' => _BlockKind.h2,
        'h3' => _BlockKind.h3,
        'blockquote' => _BlockKind.blockquote,
        'li' => _BlockKind.li,
        _ => _BlockKind.p,
      };

  // ---------- Inline tag → TextSpan ----------

  static final _inlineRegex = RegExp(
    r'<(strong|b|em|i|a)(?:\s+href="([^"]*)")?[^>]*>([\s\S]*?)</\1>',
    caseSensitive: false,
  );

  TextSpan _inlineToSpans(String fragment, TextStyle base) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final m in _inlineRegex.allMatches(fragment)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: _decode(fragment.substring(cursor, m.start))));
      }
      final tag = m.group(1)!.toLowerCase();
      final href = m.group(2);
      final text = _stripInlineTags(m.group(3)!);
      spans.add(_styleFor(tag, href, text, base));
      cursor = m.end;
    }
    if (cursor < fragment.length) {
      spans.add(TextSpan(text: _decode(fragment.substring(cursor))));
    }
    return TextSpan(children: spans, style: base);
  }

  InlineSpan _styleFor(String tag, String? href, String text, TextStyle base) {
    switch (tag) {
      case 'strong':
      case 'b':
        return TextSpan(
          text: text,
          style: base.copyWith(fontWeight: FontWeight.w700),
        );
      case 'em':
      case 'i':
        return TextSpan(
          text: text,
          style: base.copyWith(fontStyle: FontStyle.italic),
        );
      case 'a':
        return TextSpan(
          text: text,
          style: base.copyWith(
            color: AppColors.brandRed,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (href != null && href.isNotEmpty) {
                launchUrl(Uri.parse(href),
                    mode: LaunchMode.externalApplication);
              }
            },
        );
    }
    return TextSpan(text: text, style: base);
  }

  // ---------- Utilities ----------

  static String _stripInlineTags(String s) => _decode(
      s.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim());

  static String _decode(String s) => s
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&rsquo;', '’')
      .replaceAll('&lsquo;', '‘')
      .replaceAll('&mdash;', '—')
      .replaceAll('&ndash;', '–')
      .replaceAll('&hellip;', '…');
}

enum _BlockKind { p, h2, h3, blockquote, li }

class _Block {
  final _BlockKind kind;
  final String text;
  const _Block({required this.kind, required this.text});
}
