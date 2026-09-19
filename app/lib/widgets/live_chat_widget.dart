import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/live_chat.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Interactive live-chat panel that sits under the live stream.
///
/// - Today's messages by default (auto-refreshes every 8s).
/// - Users can pick any past day and read the archived conversation
///   (read-only for archives).
/// - Emoji reactions per message (toggle by IP on the server).
/// - Display name persisted via SharedPreferences.
class LiveChatWidget extends StatefulWidget {
  const LiveChatWidget({super.key});

  @override
  State<LiveChatWidget> createState() => _LiveChatWidgetState();
}

class _LiveChatWidgetState extends State<LiveChatWidget> {
  static const _prefsNameKey = 'live_chat_name';

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _composerFocus = FocusNode();
  Timer? _pollTimer;

  LiveChatDay? _day;
  List<LiveChatDaySummary> _days = const [];
  bool _loading = true;
  String? _error;
  String _displayName = '';
  bool _sending = false;
  DateTime? _selectedDate;
  LiveChatMessage? _replyTo;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _displayName = prefs.getString(_prefsNameKey) ?? '');
    await _load();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_selectedDate == null) _load(silent: true);
    });
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.instance.fetchLiveChat(date: _selectedDate),
        ApiService.instance.fetchLiveChatDays(),
      ]);
      if (!mounted) return;
      setState(() {
        _day = results[0] as LiveChatDay;
        _days = results[1] as List<LiveChatDaySummary>;
        _loading = false;
        _error = null;
      });
      _scrollToBottomIfNeeded();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load chat';
      });
    }
  }

  void _scrollToBottomIfNeeded() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final cur = _scrollController.position.pixels;
      // Auto-scroll only if user is already near the bottom.
      if (max - cur < 120) {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;
    if (_displayName.trim().isEmpty) {
      await _promptForName();
      if (_displayName.trim().isEmpty) return;
    }

    setState(() => _sending = true);
    final replyingTo = _replyTo;
    // Reply-to-reply hoists to the root parent (one level of nesting).
    final targetParentId =
        replyingTo == null ? null : (replyingTo.parentId ?? replyingTo.id);

    try {
      final msg = await ApiService.instance.postLiveChat(
        name: _displayName.trim(),
        message: text,
        parentId: targetParentId,
      );
      _messageController.clear();
      if (mounted && _day != null && _day!.isToday) {
        setState(() {
          if (targetParentId != null) {
            _day = LiveChatDay(
              date: _day!.date,
              isToday: _day!.isToday,
              messages: _day!.messages.map((m) {
                if (m.id != targetParentId) return m;
                return m.copyWith(replies: [...m.replies, msg]);
              }).toList(),
              allowedEmojis: _day!.allowedEmojis,
            );
          } else {
            _day = LiveChatDay(
              date: _day!.date,
              isToday: _day!.isToday,
              messages: [..._day!.messages, msg],
              allowedEmojis: _day!.allowedEmojis,
            );
          }
          _replyTo = null;
        });
        _scrollToBottomIfNeeded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Send failed: $e'),
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startReply(LiveChatMessage m) {
    setState(() => _replyTo = m);
    _composerFocus.requestFocus();
  }

  void _cancelReply() {
    if (_replyTo == null) return;
    setState(() => _replyTo = null);
  }

  Future<void> _promptForName() async {
    final controller = TextEditingController(text: _displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your display name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g. Kip from Nairobi'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsNameKey, result);
    if (mounted) setState(() => _displayName = result);
  }

  Future<void> _react(LiveChatMessage msg, String emoji) async {
    // Optimistic update.
    final next = Map<String, int>.from(msg.reactions);
    next[emoji] = (next[emoji] ?? 0) + 1;
    setState(() => _updateMessage(msg.id, next));

    try {
      final actual =
          await ApiService.instance.reactLiveChat(messageId: msg.id, emoji: emoji);
      if (mounted) setState(() => _updateMessage(msg.id, actual));
    } catch (_) {
      // Revert.
      if (mounted) setState(() => _updateMessage(msg.id, msg.reactions));
    }
  }

  void _updateMessage(int id, Map<String, int> reactions) {
    if (_day == null) return;
    final updated = _day!.messages.map((m) {
      if (m.id == id) return m.copyWithReactions(reactions);
      if (m.replies.any((r) => r.id == id)) {
        return m.copyWith(
          replies: m.replies
              .map((r) => r.id == id ? r.copyWithReactions(reactions) : r)
              .toList(),
        );
      }
      return m;
    }).toList();
    _day = LiveChatDay(
      date: _day!.date,
      isToday: _day!.isToday,
      messages: updated,
      allowedEmojis: _day!.allowedEmojis,
    );
  }

  void _pickDay() async {
    final choice = await showModalBottomSheet<DateTime?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _DayPickerSheet(days: _days, selected: _selectedDate),
    );
    if (!mounted) return;
    // `choice` may be null (dismissed) or a marker for "today" via _todaySentinel.
    if (choice == null) return;
    setState(() {
      _selectedDate =
          choice == _todaySentinel ? null : DateTime(choice.year, choice.month, choice.day);
    });
    _load();
  }

  static final _todaySentinel = DateTime.utc(1970, 1, 1);

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const Divider(height: 1),
          _messagesArea(),
          if (_day?.isToday ?? true) ...[
            const Divider(height: 1),
            _composer(),
          ] else
            _archiveNotice(),
        ],
      ),
    );
  }

  Widget _header() {
    final label = _day == null
        ? 'Live conversation'
        : (_day!.isToday
            ? "Today's conversation"
            : DateFormat('EEE, MMM d').format(_day!.date));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: (_day?.isToday ?? true)
                  ? AppColors.brandRed
                  : AppColors.textLightMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
            ),
          ),
          TextButton.icon(
            onPressed: _days.isEmpty ? null : _pickDay,
            icon: const Icon(Icons.history, size: 16),
            label: const Text('Past chats'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandRed,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messagesArea() {
    if (_loading && _day == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }
    if (_error != null && _day == null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 32, color: AppColors.textLightMuted),
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(color: AppColors.textLightMuted)),
                const SizedBox(height: 4),
                Text(
                  'API: ${ApiConfig.base}',
                  style: const TextStyle(
                    color: AppColors.textLightMuted,
                    fontSize: 10.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }
    final messages = _day?.messages ?? const <LiveChatMessage>[];
    if (messages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Row(
          children: [
            Icon(Icons.forum_outlined,
                size: 16, color: AppColors.textLightMuted),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No messages yet — start the conversation!',
                style: TextStyle(
                  color: AppColors.textLightMuted,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final isToday = _day?.isToday ?? true;
    final emojis = _day?.allowedEmojis ?? const <String>[];
    return SizedBox(
      height: 320,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        itemCount: messages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, i) {
          final m = messages[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MessageTile(
                message: m,
                allowedEmojis: emojis,
                onReact: (emoji) => _react(m, emoji),
                onReply: isToday ? () => _startReply(m) : null,
                canReact: isToday,
                isReply: false,
              ),
              if (m.replies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 42, top: 8),
                  child: Container(
                    padding: const EdgeInsets.only(left: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0x33E63946), width: 2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final r in m.replies) ...[
                          _MessageTile(
                            message: r,
                            allowedEmojis: emojis,
                            onReact: (emoji) => _react(r, emoji),
                            onReply: isToday ? () => _startReply(m) : null,
                            canReact: isToday,
                            isReply: true,
                          ),
                          if (r != m.replies.last) const SizedBox(height: 6),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _composer() {
    final reply = _replyTo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (reply != null) _replyBanner(reply),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Set display name',
                onPressed: _promptForName,
                icon: const Icon(Icons.person_outline, size: 20),
                color: AppColors.textLightMuted,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _composerFocus,
                  maxLength: 500,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: reply != null
                        ? 'Reply to ${reply.name}…'
                        : (_displayName.isEmpty
                            ? 'Say something (tap to set your name)…'
                            : 'Say something as $_displayName…'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide(color: AppColors.lineLightStrong),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide(color: AppColors.lineLightStrong),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(
                          color: AppColors.brandOrange, width: 1.4),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    counterText: '',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _SendButton(onTap: _send, sending: _sending),
            ],
          ),
        ),
      ],
    );
  }

  Widget _replyBanner(LiveChatMessage reply) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
      decoration: BoxDecoration(
        color: AppColors.brandRed.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 14, color: AppColors.brandRed),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to ${reply.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  reply.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textLightMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: _cancelReply,
            icon: const Icon(Icons.close, size: 16),
            color: AppColors.textLightMuted,
          ),
        ],
      ),
    );
  }

  Widget _archiveNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: const BoxDecoration(
        color: Color(0x08000000),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline,
              size: 14, color: AppColors.textLightMuted),
          const SizedBox(width: 6),
          Text(
            "Archived chat — read only",
            style: TextStyle(
              color: AppColors.textLightMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() => _selectedDate = null);
              _load();
            },
            child: const Text('Back to today'),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final LiveChatMessage message;
  final List<String> allowedEmojis;
  final void Function(String emoji) onReact;
  final VoidCallback? onReply;
  final bool canReact;
  final bool isReply;

  const _MessageTile({
    required this.message,
    required this.allowedEmojis,
    required this.onReact,
    required this.onReply,
    required this.canReact,
    required this.isReply,
  });

  @override
  Widget build(BuildContext context) {
    final initial = message.name.isEmpty
        ? '?'
        : message.name.substring(0, 1).toUpperCase();
    final ts = message.createdAt != null
        ? DateFormat('HH:mm').format(message.createdAt!)
        : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: isReply ? 11 : 13,
          backgroundColor: _colorForName(message.name),
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontSize: isReply ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // FB-style speech pill: author name inline with message text
              Container(
                padding: EdgeInsets.fromLTRB(
                  isReply ? 9 : 11,
                  isReply ? 4 : 5,
                  isReply ? 9 : 11,
                  isReply ? 5 : 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEAE4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isReply ? 12.5 : 13.5,
                      color: AppColors.textLight,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: '${message.name}  ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: message.message),
                    ],
                  ),
                ),
              ),
              if (canReact || onReply != null || message.reactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 2),
                  child: _MetaActions(
                    time: ts,
                    reactions: message.reactions,
                    allowedEmojis: allowedEmojis,
                    onReact: onReact,
                    onReply: onReply,
                    canReact: canReact,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaActions extends StatelessWidget {
  final String time;
  final Map<String, int> reactions;
  final List<String> allowedEmojis;
  final void Function(String) onReact;
  final VoidCallback? onReply;
  final bool canReact;

  const _MetaActions({
    required this.time,
    required this.reactions,
    required this.allowedEmojis,
    required this.onReact,
    required this.onReply,
    required this.canReact,
  });

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.textLightMuted,
    );
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (canReact)
          _AddReactionButton(
            allowedEmojis: allowedEmojis,
            onSelect: onReact,
            child: const Text('React', style: linkStyle),
          ),
        if (onReply != null)
          InkWell(
            onTap: onReply,
            borderRadius: BorderRadius.circular(4),
            child: const Text('Reply', style: linkStyle),
          ),
        if (time.isNotEmpty)
          Text(time,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLightMuted,
              )),
        for (final entry in reactions.entries)
          _ReactionChip(
            emoji: entry.key,
            count: entry.value,
            onTap: canReact ? () => onReact(entry.key) : null,
          ),
      ],
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String emoji;
  final int count;
  final VoidCallback? onTap;
  const _ReactionChip(
      {required this.emoji, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: AppColors.lineLightStrong),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 3),
              Text(
                '$count',
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLightDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddReactionButton extends StatelessWidget {
  final List<String> allowedEmojis;
  final void Function(String emoji) onSelect;
  final Widget? child;

  const _AddReactionButton({
    required this.allowedEmojis,
    required this.onSelect,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'React',
      position: PopupMenuPosition.under,
      onSelected: onSelect,
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Wrap(
              spacing: 6,
              children: allowedEmojis
                  .map((e) => InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          Navigator.pop(context);
                          onSelect(e);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child:
                              Text(e, style: const TextStyle(fontSize: 20)),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
      child: child ??
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.lineLightStrong),
              color: Colors.white,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_reaction_outlined,
                    size: 14, color: AppColors.textLightMuted),
                SizedBox(width: 4),
                Text(
                  'React',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLightMuted,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool sending;
  const _SendButton({required this.onTap, required this.sending});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: sending ? null : onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandRed.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: sending
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _DayPickerSheet extends StatelessWidget {
  final List<LiveChatDaySummary> days;
  final DateTime? selected;

  const _DayPickerSheet({required this.days, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lineLightStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Past conversations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Pick a day to read that conversation',
            style: TextStyle(color: AppColors.textLightMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: days.length + 1,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 20, endIndent: 20),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return ListTile(
                    leading: const Icon(Icons.circle,
                        color: AppColors.brandRed, size: 12),
                    title: const Text("Today (live)"),
                    trailing: selected == null
                        ? const Icon(Icons.check, color: AppColors.brandOrange)
                        : null,
                    onTap: () => Navigator.pop(
                        context, _LiveChatWidgetState._todaySentinel),
                  );
                }
                final d = days[i - 1];
                final isSelected = selected != null &&
                    selected!.year == d.date.year &&
                    selected!.month == d.date.month &&
                    selected!.day == d.date.day;
                return ListTile(
                  leading: const Icon(Icons.chat_bubble_outline,
                      color: AppColors.textLightMuted),
                  title:
                      Text(DateFormat('EEEE, MMM d, yyyy').format(d.date)),
                  subtitle: Text('${d.count} message${d.count == 1 ? '' : 's'}'),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.brandOrange)
                      : null,
                  onTap: () => Navigator.pop(context, d.date),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

Color _colorForName(String name) {
  const palette = [
    Color(0xFFE63946),
    Color(0xFFFF7A1A),
    Color(0xFFFFA31A),
    Color(0xFF2A9D8F),
    Color(0xFF264653),
    Color(0xFF9D4EDD),
    Color(0xFF3A86FF),
    Color(0xFFF15BB5),
  ];
  var hash = 0;
  for (final c in name.codeUnits) {
    hash = (hash * 31 + c) & 0x7fffffff;
  }
  return palette[hash % palette.length];
}
