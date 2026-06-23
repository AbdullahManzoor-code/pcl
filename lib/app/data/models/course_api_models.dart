class LanguageStats {
  final String languageId;
  final String languageName;
  final double avgMastery;
  final int topicsCompleted;
  final int topicsInProgress;
  final int totalTopics;
  final String? lastPracticed;
  final int totalSessions;
  final double avgAccuracy;
  final bool isPrimary;

  LanguageStats({
    required this.languageId,
    required this.languageName,
    required this.avgMastery,
    required this.topicsCompleted,
    required this.topicsInProgress,
    required this.totalTopics,
    this.lastPracticed,
    required this.totalSessions,
    required this.avgAccuracy,
    required this.isPrimary,
  });

  factory LanguageStats.fromJson(Map<String, dynamic> json) {
    return LanguageStats(
      languageId: json['language_id'] ?? '',
      languageName: json['language_name'] ?? '',
      avgMastery: (json['avg_mastery'] as num?)?.toDouble() ?? 0.0,
      topicsCompleted: json['topics_completed'] ?? 0,
      topicsInProgress: json['topics_in_progress'] ?? 0,
      totalTopics: json['total_topics'] ?? 0,
      lastPracticed: json['last_practiced'],
      totalSessions: json['total_sessions'] ?? 0,
      avgAccuracy: (json['avg_accuracy'] as num?)?.toDouble() ?? 0.0,
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language_id': languageId,
      'language_name': languageName,
      'avg_mastery': avgMastery,
      'topics_completed': topicsCompleted,
      'topics_in_progress': topicsInProgress,
      'total_topics': totalTopics,
      'last_practiced': lastPracticed,
      'total_sessions': totalSessions,
      'avg_accuracy': avgAccuracy,
      'is_primary': isPrimary,
    };
  }
}

class LanguagePortfolio {
  final String? primaryLanguage;
  final List<LanguageStats> languages;
  final int totalLanguages;

  LanguagePortfolio({
    this.primaryLanguage,
    required this.languages,
    required this.totalLanguages,
  });

  factory LanguagePortfolio.fromJson(Map<String, dynamic> json) {
    return LanguagePortfolio(
      primaryLanguage: json['primary_language'],
      languages:
          (json['languages'] as List?)
              ?.map((e) => LanguageStats.fromJson(e))
              .toList() ??
          [],
      totalLanguages: json['total_languages'] ?? 0,
    );
  }
}

class CurriculumTopic {
  final String majorTopicId;
  final String mappingId;
  final String name;
  final double globalDifficulty;
  final List<String> prerequisites;
  final List<String> subTopics;

  CurriculumTopic({
    required this.majorTopicId,
    required this.mappingId,
    required this.name,
    required this.globalDifficulty,
    required this.prerequisites,
    required this.subTopics,
  });

  factory CurriculumTopic.fromJson(Map<String, dynamic> json) {
    return CurriculumTopic(
      majorTopicId: json['major_topic_id'] ?? '',
      mappingId: json['mapping_id'] ?? '',
      name: json['name'] ?? '',
      globalDifficulty: (json['global_difficulty'] as num?)?.toDouble() ?? 0.0,
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      subTopics: List<String>.from(json['sub_topics'] ?? []),
    );
  }
}

class LanguageCurriculum {
  final String languageId;
  final String name;
  final List<CurriculumTopic> roadmap;

  LanguageCurriculum({
    required this.languageId,
    required this.name,
    required this.roadmap,
  });

  factory LanguageCurriculum.fromJson(Map<String, dynamic> json) {
    return LanguageCurriculum(
      languageId: json['language_id'] ?? '',
      name: json['name'] ?? '',
      roadmap:
          (json['roadmap'] as List?)
              ?.map((e) => CurriculumTopic.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TopicProgress {
  final String mappingId;
  final String majorTopicId;
  final String name;
  final String description;
  final double mastery;
  final double confidence;
  final bool accessible;
  final bool completed;
  final bool? recommended;
  final List<String> prerequisites;
  final double difficulty;
  final String? lastPracticed;
  final int order;

  TopicProgress({
    required this.mappingId,
    required this.majorTopicId,
    required this.name,
    required this.description,
    required this.mastery,
    required this.confidence,
    required this.accessible,
    required this.completed,
    this.recommended,
    required this.prerequisites,
    required this.difficulty,
    this.lastPracticed,
    required this.order,
  });

  factory TopicProgress.fromJson(Map<String, dynamic> json) {
    return TopicProgress(
      mappingId: json['mapping_id'] ?? '',
      majorTopicId: json['major_topic_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      accessible: json['accessible'] ?? false,
      completed: json['completed'] ?? false,
      recommended: json['recommended'],
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.0,
      lastPracticed: json['last_practiced'],
      order: json['order'] ?? 0,
    );
  }
}

class StudentProgressStats {
  final int totalTopics;
  final int completedTopics;
  final double avgMastery;
  final int totalSessions;
  final double avgAccuracy;
  final String? lastActivity;

  StudentProgressStats({
    required this.totalTopics,
    required this.completedTopics,
    required this.avgMastery,
    required this.totalSessions,
    required this.avgAccuracy,
    this.lastActivity,
  });

  factory StudentProgressStats.fromJson(Map<String, dynamic> json) {
    return StudentProgressStats(
      totalTopics: json['total_topics'] ?? 0,
      completedTopics: json['completed_topics'] ?? 0,
      avgMastery: (json['avg_mastery'] as num?)?.toDouble() ?? 0.0,
      totalSessions: json['total_sessions'] ?? 0,
      avgAccuracy: (json['avg_accuracy'] as num?)?.toDouble() ?? 0.0,
      lastActivity: json['last_activity'],
    );
  }
}

class StudentProgressResponse {
  final String languageId;
  final String languageName;
  final List<TopicProgress> topics;
  final StudentProgressStats? stats;

  StudentProgressResponse({
    required this.languageId,
    required this.languageName,
    required this.topics,
    this.stats,
  });

  factory StudentProgressResponse.fromJson(Map<String, dynamic> json) {
    return StudentProgressResponse(
      languageId: json['language_id'] ?? '',
      languageName: json['language_name'] ?? '',
      topics:
          (json['topics'] as List?)
              ?.map((e) => TopicProgress.fromJson(e))
              .toList() ??
          [],
      stats: json['stats'] != null
          ? StudentProgressStats.fromJson(json['stats'])
          : null,
    );
  }
}
