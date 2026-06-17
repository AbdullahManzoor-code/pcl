import 'dart:math';

class TopicMastery {
  final String id;
  final String name;
  final double mastery; // 0.0 - 1.0
  final DateTime lastPracticed;

  TopicMastery({
    required this.id,
    required this.name,
    required this.mastery,
    required this.lastPracticed,
  });

  int get daysPassed {
    return DateTime.now().difference(lastPracticed).inDays;
  }

  double get decayedMastery {
    return mastery * exp(-0.02 * daysPassed);
  }

  factory TopicMastery.fromJson(Map<String, dynamic> json) {
    return TopicMastery(
      id: json['id'] ?? '',
      name: (json['name'] ?? '') as String,
      mastery: (json['mastery'] is num)
          ? (json['mastery'] as num).toDouble()
          : 0.0,
      lastPracticed: json['last_practiced'] != null
          ? DateTime.tryParse(json['last_practiced'].toString()) ??
                DateTime.now()
          : DateTime.now(),
    );
  }
}

class PracticeSession {
  final String id;
  final String conceptId;
  final String conceptName;
  final String subTopic;
  final double score;
  final double difficulty;
  final double masteryGain;
  final DateTime timestamp;
  final int questionsAnswered;

  PracticeSession({
    required this.id,
    required this.conceptId,
    required this.conceptName,
    required this.subTopic,
    required this.score,
    required this.difficulty,
    required this.masteryGain,
    required this.timestamp,
    required this.questionsAnswered,
  });

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'],
      conceptId: json['concept_id'],
      conceptName: json['concept_name'],
      subTopic: json['sub_topic'],
      score: (json['score'] as num).toDouble(),
      difficulty: (json['difficulty'] as num).toDouble(),
      masteryGain: (json['mastery_gain'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      questionsAnswered: json['questions_answered'],
    );
  }
}

class RecommendedTopic {
  final String conceptId;
  final String conceptName;
  final String subTopic;
  final double targetDifficulty;
  final int estimatedTimeMinutes;
  final String reason;
  final bool prerequisiteMet;

  RecommendedTopic({
    required this.conceptId,
    required this.conceptName,
    required this.subTopic,
    required this.targetDifficulty,
    required this.estimatedTimeMinutes,
    required this.reason,
    required this.prerequisiteMet,
  });

  factory RecommendedTopic.fromJson(Map<String, dynamic> json) {
    return RecommendedTopic(
      conceptId: json['concept_id'],
      conceptName: json['concept_name'],
      subTopic: json['sub_topic'],
      targetDifficulty: (json['target_difficulty'] as num).toDouble(),
      estimatedTimeMinutes: json['estimated_time_minutes'],
      reason: json['reason'],
      prerequisiteMet: json['prerequisite_met'] ?? true,
    );
  }
}
