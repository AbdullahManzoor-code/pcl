class DashboardSummaryResponse {
  final List<RecentSession> recentSessions;

  DashboardSummaryResponse({required this.recentSessions});

  factory DashboardSummaryResponse.fromJson(Map<String, dynamic> json) {
    var sessionsList = json['recent_sessions'] as List;
    List<RecentSession> sessions = sessionsList
        .map((i) => RecentSession.fromJson(i))
        .toList();
    return DashboardSummaryResponse(recentSessions: sessions);
  }
}

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
      score: json['score'],
      difficulty: json['difficulty'],
      masteryGain: json['mastery_gain'],
      questionsAnswered: json['questions_answered'],
    );
  }
}
