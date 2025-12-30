class SubTopic {
  final String id;
  final String title;
  final String type; // 'video', 'quiz', 'text'
  final bool isLocked;
  final bool isCompleted;

  SubTopic({
    required this.id,
    required this.title,
    required this.type,
    this.isLocked = false,
    this.isCompleted = false,
  });

  factory SubTopic.fromJson(Map<String, dynamic> json) {
    return SubTopic(
      id: json['id'],
      title: json['title'],
      type: json['type'] ?? 'text',
      isLocked: json['is_locked'] ?? false,
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'is_locked': isLocked,
      'is_completed': isCompleted,
    };
  }
}
