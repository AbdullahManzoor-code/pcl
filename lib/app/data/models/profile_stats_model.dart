/// Models for profile statistics aggregated from multiple API endpoints.
/// Sources: /api/auth/me, /api/user/languages, /api/dashboard/summary

// ─────────────────────────────────────────────
// Dashboard Summary Models
// ─────────────────────────────────────────────

class DashboardMasteryData {
  final String mappingId;
  final String name;
  final double mastery;
  final double decayedMastery;
  final double confidence;
  final double fluency;
  final String? lastPracticed;
  final int daysSincePractice;

  DashboardMasteryData({
    required this.mappingId,
    required this.name,
    required this.mastery,
    required this.decayedMastery,
    required this.confidence,
    required this.fluency,
    this.lastPracticed,
    required this.daysSincePractice,
  });

  factory DashboardMasteryData.fromJson(Map<String, dynamic> json) {
    return DashboardMasteryData(
      mappingId: json['mapping_id'] ?? '',
      name: json['name'] ?? '',
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0.0,
      decayedMastery: (json['decayed_mastery'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      fluency: (json['fluency'] as num?)?.toDouble() ?? 0.0,
      lastPracticed: json['last_practiced'],
      daysSincePractice: json['days_since_practice'] ?? 0,
    );
  }
}

class DashboardDecayAlert {
  final String conceptId;
  final String conceptName;
  final double currentMastery;
  final double originalMastery;
  final int daysPassed;

  DashboardDecayAlert({
    required this.conceptId,
    required this.conceptName,
    required this.currentMastery,
    required this.originalMastery,
    required this.daysPassed,
  });

  double get decayPercent =>
      originalMastery > 0
          ? ((originalMastery - currentMastery) / originalMastery * 100)
          : 0.0;

  factory DashboardDecayAlert.fromJson(Map<String, dynamic> json) {
    return DashboardDecayAlert(
      conceptId: json['concept_id'] ?? '',
      conceptName: json['concept_name'] ?? '',
      currentMastery: (json['current_mastery'] as num?)?.toDouble() ?? 0.0,
      originalMastery: (json['original_mastery'] as num?)?.toDouble() ?? 0.0,
      daysPassed: json['days_passed'] ?? 0,
    );
  }
}

class DashboardRecentSession {
  final String id;
  final String timestamp;
  final String conceptId;
  final String conceptName;
  final String? subTopic;
  final double score;
  final double difficulty;
  final double masteryGain;
  final int questionsAnswered;

  DashboardRecentSession({
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

  factory DashboardRecentSession.fromJson(Map<String, dynamic> json) {
    return DashboardRecentSession(
      id: json['id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      conceptId: json['concept_id'] ?? '',
      conceptName: json['concept_name'] ?? '',
      subTopic: json['sub_topic'],
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.5,
      masteryGain: (json['mastery_gain'] as num?)?.toDouble() ?? 0.0,
      questionsAnswered: json['questions_answered'] ?? 0,
    );
  }

  DateTime? get parsedTimestamp {
    try {
      return DateTime.parse(timestamp);
    } catch (_) {
      return null;
    }
  }
}

class DashboardSummary {
  final List<DashboardMasteryData> masteryData;
  final List<DashboardDecayAlert> decayAlerts;
  final List<DashboardRecentSession> recentSessions;

  DashboardSummary({
    required this.masteryData,
    required this.decayAlerts,
    required this.recentSessions,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      masteryData:
          (json['mastery_data'] as List?)
              ?.map((e) => DashboardMasteryData.fromJson(e))
              .toList() ??
          [],
      decayAlerts:
          (json['decay_alerts'] as List?)
              ?.map((e) => DashboardDecayAlert.fromJson(e))
              .toList() ??
          [],
      recentSessions:
          (json['recent_sessions'] as List?)
              ?.map((e) => DashboardRecentSession.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// ─────────────────────────────────────────────
// Aggregated Profile Stats
// ─────────────────────────────────────────────

class ProfileStats {
  // Computed / derived gamification fields
  final int xp;
  final int level;
  final double levelProgress; // 0.0 – 1.0 within current level
  final int xpInCurrentLevel; // XP earned within the current level
  final int xpRequiredForNextLevel; // XP needed to reach next level

  // Real data aggregated across all languages
  final int totalSessions;
  final int totalTopicsCompleted;
  final double overallAccuracy; // 0–100
  final int totalHoursEstimate; // estimated from sessions
  final int languagesCount;
  final String? primaryLanguage;
  final int streakDays;

  // Raw dashboard data
  final List<DashboardMasteryData> masteryData;
  final List<DashboardDecayAlert> decayAlerts;
  final List<DashboardRecentSession> recentSessions;

  ProfileStats({
    required this.xp,
    required this.level,
    required this.levelProgress,
    required this.xpInCurrentLevel,
    required this.xpRequiredForNextLevel,
    required this.totalSessions,
    required this.totalTopicsCompleted,
    required this.overallAccuracy,
    required this.totalHoursEstimate,
    required this.languagesCount,
    this.primaryLanguage,
    required this.streakDays,
    required this.masteryData,
    required this.decayAlerts,
    required this.recentSessions,
  });

  /// Build ProfileStats from aggregated API responses.
  factory ProfileStats.fromAggregated({
    required int totalSessions,
    required int totalTopicsCompleted,
    required double overallAccuracy, // 0–100
    required int languagesCount,
    required String? primaryLanguage,
    required String? lastActivityDate,
    required List<DashboardMasteryData> masteryData,
    required List<DashboardDecayAlert> decayAlerts,
    required List<DashboardRecentSession> recentSessions,
  }) {
    // XP formula: 50 per session + accuracy bonus
    final xp = (totalSessions * 50 + (overallAccuracy * 10).toInt());
    const xpPerLevel = 500;
    final level = (xp ~/ xpPerLevel) + 1;
    final xpInLevel = xp % xpPerLevel;
    final levelProgress = xpInLevel / xpPerLevel;

    // Streak: if last_activity was today or yesterday, count as 1 day streak.
    int streak = 0;
    if (lastActivityDate != null) {
      try {
        final last = DateTime.parse(lastActivityDate);
        final diff = DateTime.now().difference(last).inDays;
        streak = diff <= 1 ? 1 : 0;
      } catch (_) {
        streak = 0;
      }
    }
    // Use recent sessions to compute streak more accurately
    if (recentSessions.isNotEmpty) {
      final dates =
          recentSessions
              .map((s) => s.parsedTimestamp)
              .where((d) => d != null)
              .map((d) => d!)
              .toSet()
              .map((d) => DateTime(d.year, d.month, d.day))
              .toList();
      dates.sort((a, b) => b.compareTo(a));
      streak = 0;
      DateTime expected = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      for (final date in dates) {
        if (date == expected || date == expected.subtract(const Duration(days: 1))) {
          streak++;
          expected = date.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return ProfileStats(
      xp: xp,
      level: level,
      levelProgress: levelProgress,
      xpInCurrentLevel: xpInLevel,
      xpRequiredForNextLevel: xpPerLevel,
      totalSessions: totalSessions,
      totalTopicsCompleted: totalTopicsCompleted,
      overallAccuracy: overallAccuracy,
      totalHoursEstimate: (totalSessions * 15 / 60).round(),
      languagesCount: languagesCount,
      primaryLanguage: primaryLanguage,
      streakDays: streak,
      masteryData: masteryData,
      decayAlerts: decayAlerts,
      recentSessions: recentSessions,
    );
  }

  /// Formatted XP string (e.g. "1.2k")
  String get formattedXP {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}k';
    }
    return xp.toString();
  }

  /// Level label
  String get levelLabel => 'Level $level';
}
