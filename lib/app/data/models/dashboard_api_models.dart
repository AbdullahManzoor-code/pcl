import 'analytics_model.dart';

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
  final List<PracticeSession> recentSessions;

  DashboardSummary({
    required this.masteryData,
    required this.decayAlerts,
    this.recommendation,
    required this.recentSessions,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      masteryData: (json['mastery_data'] as List?)
              ?.map((e) => TopicMastery.fromJson(e))
              .toList() ??
          [],
      decayAlerts: (json['decay_alerts'] as List?)
              ?.map((e) => DecayAlert.fromJson(e))
              .toList() ??
          [],
      recommendation: json['recommendation'] != null
          ? RecommendedTopic.fromJson(json['recommendation'])
          : null,
      recentSessions: (json['recent_sessions'] as List?)
              ?.map((e) => PracticeSession.fromJson(e))
              .toList() ??
          [],
    );
  }
}
