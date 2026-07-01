// Topic Model
class Topic {
  final String id;
  final String name;
  final bool completed;
  final bool isLocked;
  final int accuracy;
  final List<SubTopic> subTopics;

  Topic({
    required this.id,
    required this.name,
    this.completed = false,
    this.isLocked = false,
    this.accuracy = 0,
    this.subTopics = const [],
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    var subTopicsList = <SubTopic>[];
    if (json['sub_topics'] != null) {
      json['sub_topics'].forEach((v) {
        subTopicsList.add(SubTopic.fromJson(v));
      });
    }
    return Topic(
      id: json['id'] ?? '',
      name:
          json['title'] ??
          '', // Supporting 'title' from old JSON but targeting 'name'
      completed: json['is_completed'] ?? false,
      isLocked: json['is_locked'] ?? false,
      accuracy: json['accuracy'] ?? 0,
      subTopics: subTopicsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'completed': completed,
      'is_locked': isLocked,
      'accuracy': accuracy,
      'sub_topics': subTopics.map((v) => v.toJson()).toList(),
    };
  }
}

class SubTopic {
  final String id;
  final String title;
  final bool completed;
  final bool isLocked;
  final String type;

  SubTopic({
    required this.id,
    required this.title,
    this.completed = false,
    this.isLocked = false,
    this.type = 'lesson',
  });

  factory SubTopic.fromJson(Map<String, dynamic> json) {
    return SubTopic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      completed: json['is_completed'] ?? false,
      isLocked: json['is_locked'] ?? false,
      type: json['type'] ?? 'lesson',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'is_locked': isLocked,
      'type': type,
    };
  }
}
