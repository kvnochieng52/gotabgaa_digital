class LiveChatMessage {
  final int id;
  final int? parentId;
  final String name;
  final String message;
  final DateTime? createdAt;
  final Map<String, int> reactions;
  final List<LiveChatMessage> replies;

  const LiveChatMessage({
    required this.id,
    required this.parentId,
    required this.name,
    required this.message,
    required this.createdAt,
    required this.reactions,
    this.replies = const [],
  });

  factory LiveChatMessage.fromJson(Map<String, dynamic> j) {
    final rawReactions = j['reactions'];
    Map<String, int> reactions = const {};
    if (rawReactions is Map) {
      reactions = rawReactions.map(
        (k, v) => MapEntry(k.toString(), (v as num).toInt()),
      );
    }
    final rawReplies = j['replies'];
    final replies = rawReplies is List
        ? rawReplies
            .map((r) => LiveChatMessage.fromJson(r as Map<String, dynamic>))
            .toList()
        : const <LiveChatMessage>[];
    return LiveChatMessage(
      id: (j['id'] as num).toInt(),
      parentId: j['parent_id'] != null ? (j['parent_id'] as num).toInt() : null,
      name: j['name']?.toString() ?? 'Anon',
      message: j['message']?.toString() ?? '',
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())?.toLocal()
          : null,
      reactions: reactions,
      replies: replies,
    );
  }

  LiveChatMessage copyWith({
    Map<String, int>? reactions,
    List<LiveChatMessage>? replies,
  }) =>
      LiveChatMessage(
        id: id,
        parentId: parentId,
        name: name,
        message: message,
        createdAt: createdAt,
        reactions: reactions ?? this.reactions,
        replies: replies ?? this.replies,
      );

  LiveChatMessage copyWithReactions(Map<String, int> next) =>
      copyWith(reactions: next);
}

class LiveChatDay {
  final DateTime date;
  final bool isToday;
  final List<LiveChatMessage> messages;
  final List<String> allowedEmojis;

  const LiveChatDay({
    required this.date,
    required this.isToday,
    required this.messages,
    required this.allowedEmojis,
  });

  factory LiveChatDay.fromJson(Map<String, dynamic> j) {
    final msgs = (j['messages'] as List<dynamic>? ?? [])
        .map((m) => LiveChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();
    final emojis = (j['allowed_emojis'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return LiveChatDay(
      date: DateTime.parse('${j['date']}T00:00:00'),
      isToday: j['is_today'] == true,
      messages: msgs,
      allowedEmojis: emojis,
    );
  }
}

class LiveChatDaySummary {
  final DateTime date;
  final int count;

  const LiveChatDaySummary({required this.date, required this.count});

  factory LiveChatDaySummary.fromJson(Map<String, dynamic> j) =>
      LiveChatDaySummary(
        date: DateTime.parse('${j['date']}T00:00:00'),
        count: (j['count'] as num).toInt(),
      );
}
