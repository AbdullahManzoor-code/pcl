import 'analytics_model.dart';

class RecentSession {
  final String id;
  final String timestamp;
  final String conceptId;
  final String conceptName;
  final String? subTopic;
  final double score;
  final double difficulty;
  final double masteryGain;
  final int questionsAnswered;

  RecentSession({
    required this.id,
    required this.timestamp,
    required this.conceptId,
    required this.conceptName,
    this.subTopic,
    required this.score,
    required this.difficulty,
    required this.masteryGain,
    required this.questionsAnswered,
  });

  factory RecentSession.fromJson(Map<String, dynamic> json) {
    return RecentSession(
      id: json['id'],
      timestamp: json['timestamp'],
      conceptId: json['concept_id'],
      conceptName: json['concept_name'],
      subTopic: json['sub_topic'],
      score: (json['score'] as num).toDouble(),
      difficulty: (json['difficulty'] as num).toDouble(),
      masteryGain: (json['mastery_gain'] as num).toDouble(),
      questionsAnswered: json['questions_answered'],
    );
  }
}

class DecayAlert {
  final String conceptId;
  final String conceptName;
  final double currentMastery;
  final double originalMastery;
  final int daysPassed;

  DecayAlert({
    required this.conceptId,
    required this.conceptName,
    required this.currentMastery,
    required this.originalMastery,
    required this.daysPassed,
  });

  factory DecayAlert.fromJson(Map<String, dynamic> json) {
    return DecayAlert(
      conceptId: json['concept_id'],
      conceptName: json['concept_name'],
      currentMastery: (json['current_mastery'] as num).toDouble(),
      originalMastery: (json['original_mastery'] as num).toDouble(),
      daysPassed: json['days_passed'],
    );
  }
}

class DashboardSummary {
  final List<TopicMastery> masteryData;
  final List<DecayAlert> decayAlerts;
  final RecommendedTopic? recommendation;
  final List<RecentSession> recentSessions;

  DashboardSummary({
    required this.masteryData,
    required this.decayAlerts,
    this.recommendation,
    required this.recentSessions,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      masteryData:
          (json['mastery_data'] as List?)
              ?.map((e) => TopicMastery.fromJson(e))
              .toList() ??
          [],
      decayAlerts:
          (json['decay_alerts'] as List?)
              ?.map((e) => DecayAlert.fromJson(e))
              .toList() ??
          [],
      recommendation: json['recommendation'] != null
          ? RecommendedTopic.fromJson(json['recommendation'])
          : null,
      recentSessions:
          (json['recent_sessions'] as List?)
              ?.map((e) => RecentSession.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class StudentProgressStats {
  final int totalCompleted;
  final int totalInProgress;
  final double overallMastery;

  StudentProgressStats({
    required this.totalCompleted,
    required this.totalInProgress,
    required this.overallMastery,
  });

  factory StudentProgressStats.fromJson(Map<String, dynamic> json) {
    return StudentProgressStats(
      totalCompleted: json['total_completed'] as int? ?? 0,
      totalInProgress: json['total_in_progress'] as int? ?? 0,
      overallMastery: (json['overall_mastery'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_completed': totalCompleted,
    'total_in_progress': totalInProgress,
    'overall_mastery': overallMastery,
  };
}

class TopicProgressDetail {
  final String topicId;
  final String name;
  final double progress;
  final String status;

  TopicProgressDetail({
    required this.topicId,
    required this.name,
    required this.progress,
    required this.status,
  });

  factory TopicProgressDetail.fromJson(Map<String, dynamic> json) {
    return TopicProgressDetail(
      topicId: (json['topic_id'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'Unknown Topic',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] as String?) ?? 'not_started',
    );
  }

  Map<String, dynamic> toJson() => {
    'topic_id': topicId,
    'name': name,
    'progress': progress,
    'status': status,
  };
}

class StudentProgressResponse {
  final String languageId;
  final String languageName;
  final List<TopicProgressDetail> topics;
  final StudentProgressStats stats;

  StudentProgressResponse({
    required this.languageId,
    required this.languageName,
    required this.topics,
    required this.stats,
  });

  factory StudentProgressResponse.fromJson(Map<String, dynamic> json) {
    final topicsList =
        (json['topics'] as List<dynamic>?)
            ?.map(
              (item) =>
                  TopicProgressDetail.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return StudentProgressResponse(
      languageId: (json['language_id'] as String?) ?? '',
      languageName: (json['language_name'] as String?) ?? 'Unknown',
      topics: topicsList,
      stats: StudentProgressStats.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'language_id': languageId,
    'language_name': languageName,
    'topics': topics.map((t) => t.toJson()).toList(),
    'stats': stats.toJson(),
  };
}

class TransferBoost {
  final String sourceLanguage;
  final String sourceConcept;
  final String targetLanguage;
  final String targetConcept;
  final double sourceMastery;
  final double boostAmount;

  TransferBoost({
    required this.sourceLanguage,
    required this.sourceConcept,
    required this.targetLanguage,
    required this.targetConcept,
    required this.sourceMastery,
    required this.boostAmount,
  });

  factory TransferBoost.fromJson(Map<String, dynamic> json) {
    return TransferBoost(
      sourceLanguage: json['source_language'] ?? '',
      sourceConcept: json['source_concept'] ?? '',
      targetLanguage: json['target_language'] ?? '',
      targetConcept: json['target_concept'] ?? '',
      sourceMastery: (json['source_mastery'] as num?)?.toDouble() ?? 0.0,
      boostAmount: (json['boost_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SynergyBonus {
  final String fromConcept;
  final String toConcept;
  final double bonusAmount;
  final bool bidirectional;
  final String? appliedAt;

  SynergyBonus({
    required this.fromConcept,
    required this.toConcept,
    required this.bonusAmount,
    required this.bidirectional,
    this.appliedAt,
  });

  factory SynergyBonus.fromJson(Map<String, dynamic> json) {
    return SynergyBonus(
      fromConcept: json['from_concept'] ?? '',
      toConcept: json['to_concept'] ?? '',
      bonusAmount: (json['bonus_amount'] as num?)?.toDouble() ?? 0.0,
      bidirectional: json['bidirectional'] ?? false,
      appliedAt: json['applied_at'],
    );
  }
}
