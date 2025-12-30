import 'sub_topic_model.dart';

class Topic {
  final String id;
  final String title;
  final String description;
  final List<SubTopic> subTopics;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.subTopics,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    var subTopicsList = <SubTopic>[];
    if (json['sub_topics'] != null) {
      json['sub_topics'].forEach((v) {
        subTopicsList.add(SubTopic.fromJson(v));
      });
    }

    return Topic(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      subTopics: subTopicsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sub_topics': subTopics.map((v) => v.toJson()).toList(),
    };
  }
}
