class PollOption {
  final String id;
  final String label;
  final int votes;

  PollOption({required this.id, required this.label, required this.votes});

  factory PollOption.fromJson(Map<String, dynamic> j) => PollOption(
        id: j['id'] as String,
        label: j['label'] as String,
        votes: (j['votes'] as int?) ?? 0,
      );
}

class Poll {
  final String slug;
  final String question;
  final List<PollOption> options;
  final bool active;
  final DateTime? closesAt;
  final int totalVotes;

  Poll({
    required this.slug,
    required this.question,
    required this.options,
    required this.active,
    this.closesAt,
    required this.totalVotes,
  });

  factory Poll.fromJson(Map<String, dynamic> j) => Poll(
        slug: j['slug'] as String,
        question: j['question'] as String,
        options: ((j['options'] as List<dynamic>?) ?? [])
            .map((o) => PollOption.fromJson(o as Map<String, dynamic>))
            .toList(),
        active: (j['active'] as bool?) ?? true,
        closesAt: j['closesAt'] != null
            ? DateTime.tryParse(j['closesAt'] as String)
            : null,
        totalVotes: (j['totalVotes'] as int?) ?? 0,
      );
}
