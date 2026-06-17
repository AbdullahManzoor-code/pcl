class ExamStartRequest {
  final String userId;
  final String languageId;
  final String majorTopicId;
  final String sessionType;
  final int? rlActionId;
  final String? rlRecommendationId;

  ExamStartRequest({
    required this.userId,
    required this.languageId,
    required this.majorTopicId,
    required this.sessionType,
    this.rlActionId,
    this.rlRecommendationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'language_id': languageId,
      'major_topic_id': majorTopicId,
      'session_type': sessionType,
      if (rlActionId != null) 'rl_action_id': rlActionId,
      if (rlRecommendationId != null)
        'rl_recommendation_id': rlRecommendationId,
    };
  }

  /// Payload for starting an exam session without sending user_id, which is derived from auth cookie.
  Map<String, dynamic> toSubmitJson() {
    return {
      'language_id': languageId,
      'major_topic_id': majorTopicId,
      'session_type': sessionType,
      if (rlActionId != null) 'rl_action_id': rlActionId,
      if (rlRecommendationId != null)
        'rl_recommendation_id': rlRecommendationId,
    };
  }
}

class ExamStartResponse {
  final String sessionId;
  final DateTime startedAt;

  ExamStartResponse({required this.sessionId, required this.startedAt});

  factory ExamStartResponse.fromJson(Map<String, dynamic> json) {
    return ExamStartResponse(
      sessionId: json['session_id'],
      startedAt: DateTime.parse(json['started_at']),
    );
  }
}

class QuestionOption {
  final String id;
  final String text;
  final bool isCorrect;
  final String? errorType;
  final String? explanation;

  QuestionOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.errorType,
    this.explanation,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'] ?? false,
      errorType: json['error_type'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_correct': isCorrect,
      if (errorType != null) 'error_type': errorType,
      if (explanation != null) 'explanation': explanation,
    };
  }
}

class QuestionData {
  final String questionText;
  final String? codeSnippet;
  final List<QuestionOption> options;
  final String? explanation;
  final String? primaryErrorPattern;
  final List<String>? targetedErrors;
  final String? questionType;
  final double? qualityScore;
  final String? mediaUrl;

  QuestionData({
    required this.questionText,
    this.codeSnippet,
    required this.options,
    this.explanation,
    this.primaryErrorPattern,
    this.targetedErrors,
    this.questionType,
    this.qualityScore,
    this.mediaUrl,
  });
  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      questionText: json['question_text'],
      codeSnippet: json['code_snippet'],
      options:
          (json['options'] as List?)
              ?.map((e) => QuestionOption.fromJson(e))
              .toList() ??
          [],
      explanation: json['explanation'],
      primaryErrorPattern: json['primary_error_pattern'],
      targetedErrors: (json['targeted_errors'] as List?)?.cast<String>(),
      questionType: json['question_type'],
      qualityScore: json['quality_score'] != null
          ? (json['quality_score'] as num).toDouble()
          : null,
      mediaUrl: json['media_url'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'question_text': questionText,
      if (codeSnippet != null) 'code_snippet': codeSnippet,
      'options': options.map((o) => o.toJson()).toList(),
      if (explanation != null) 'explanation': explanation,
      if (primaryErrorPattern != null)
        'primary_error_pattern': primaryErrorPattern,
      if (targetedErrors != null) 'targeted_errors': targetedErrors,
      if (questionType != null) 'question_type': questionType,
      if (qualityScore != null) 'quality_score': qualityScore,
      if (mediaUrl != null) 'media_url': mediaUrl,
    };
  }
}

class SelectedQuestion {
  final String id;
  final QuestionData questionData;
  final double difficulty;
  final double qualityScore;
  final bool isVerified;
  final String? mappingId;
  final String? languageId;
  final String? subTopic;

  SelectedQuestion({
    required this.id,
    required this.questionData,
    required this.difficulty,
    required this.qualityScore,
    required this.isVerified,
    this.mappingId,
    this.languageId,
    this.subTopic,
  });

  factory SelectedQuestion.fromJson(Map<String, dynamic> json) {
    return SelectedQuestion(
      id: json['id'],
      questionData: QuestionData.fromJson(json['question_data']),
      difficulty: (json['difficulty'] as num).toDouble(),
      qualityScore: (json['quality_score'] as num).toDouble(),
      isVerified: json['is_verified'] ?? false,
      mappingId: json['mapping_id'],
      languageId: json['language_id'],
      subTopic: json['sub_topic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_data': questionData.toJson(),
      'difficulty': difficulty,
      'quality_score': qualityScore,
      'is_verified': isVerified,
      if (mappingId != null) 'mapping_id': mappingId,
      if (languageId != null) 'language_id': languageId,
      if (subTopic != null) 'sub_topic': subTopic,
    };
  }
}

class SelectQuestionsRequest {
  final String userId;
  final String sessionId;
  final String languageId;
  final String mappingId;
  final double targetDifficulty;
  final int count;
  final double? difficultyTolerance;
  final String mode;
  final double? seenRatio;

  SelectQuestionsRequest({
    required this.userId,
    required this.sessionId,
    required this.languageId,
    required this.mappingId,
    required this.targetDifficulty,
    required this.count,
    this.difficultyTolerance,
    required this.mode,
    this.seenRatio,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'session_id': sessionId,
      'language_id': languageId,
      'mapping_id': mappingId,
      'target_difficulty': targetDifficulty,
      'count': count,
      if (difficultyTolerance != null)
        'difficulty_tolerance': difficultyTolerance,
      'mode': mode,
      if (seenRatio != null) 'seen_ratio': seenRatio,
    };
  }
}

class SelectQuestionsResponse {
  final List<SelectedQuestion> questions;
  final int totalSelected;
  final int totalRequested;
  final bool moreQuestionsLoading;

  SelectQuestionsResponse({
    required this.questions,
    required this.totalSelected,
    required this.totalRequested,
    required this.moreQuestionsLoading,
  });

  factory SelectQuestionsResponse.fromJson(Map<String, dynamic> json) {
    return SelectQuestionsResponse(
      questions:
          (json['questions'] as List?)
              ?.map((e) => SelectedQuestion.fromJson(e))
              .toList() ??
          [],
      totalSelected: json['total_selected'] ?? 0,
      totalRequested: json['total_requested'] ?? 0,
      moreQuestionsLoading: json['more_questions_loading'] ?? false,
    );
  }
}

class QuestionResultPayload {
  final String qId;
  final String subTopic;
  final double difficulty;
  final bool isCorrect;
  final String selectedChoice;
  final String correctChoice;
  final int timeSpent;
  final int expectedTime;
  final String? errorType;
  final String? questionText;
  final String? codeSnippet;
  final List<QuestionOption>? options;
  final String? explanation;
  final String? mediaUrl;

  QuestionResultPayload({
    required this.qId,
    required this.subTopic,
    required this.difficulty,
    required this.isCorrect,
    required this.selectedChoice,
    required this.correctChoice,
    required this.timeSpent,
    required this.expectedTime,
    this.errorType,
    this.questionText,
    this.codeSnippet,
    this.options,
    this.explanation,
    this.mediaUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'q_id': qId,
      'sub_topic': subTopic,
      'difficulty': difficulty,
      'is_correct': isCorrect,
      'selected_choice': selectedChoice,
      'correct_choice': correctChoice,
      'time_spent': timeSpent,
      'expected_time': expectedTime,
      if (errorType != null) 'error_type': errorType,
      if (questionText != null) 'question_text': questionText,
      if (codeSnippet != null) 'code_snippet': codeSnippet,
      if (options != null) 'options': options?.map((o) => o.toJson()).toList(),
      if (explanation != null) 'explanation': explanation,
      if (mediaUrl != null) 'media_url': mediaUrl,
    };
  }

  factory QuestionResultPayload.fromJson(Map<String, dynamic> json) {
    return QuestionResultPayload(
      qId: json['q_id'],
      subTopic: json['sub_topic'],
      difficulty: (json['difficulty'] as num).toDouble(),
      isCorrect: json['is_correct'],
      selectedChoice: json['selected_choice'],
      correctChoice: json['correct_choice'],
      timeSpent: (json['time_spent'] as num?)?.toInt() ?? 0,
      expectedTime: (json['expected_time'] as num?)?.toInt() ?? 0,
      errorType: json['error_type'],
      questionText: json['question_text'],
      codeSnippet: json['code_snippet'],
      options: json['options'] != null
          ? (json['options'] as List)
                .map((o) => QuestionOption.fromJson(o))
                .toList()
          : null,
      explanation: json['explanation'],
      mediaUrl: json['media_url'],
    );
  }
}

class ExamSubmissionPayload {
  final String userId;
  final String sessionId;
  final String languageId;
  final String majorTopicId;
  final String sessionType;
  final List<QuestionResultPayload> results;
  final int totalTimeSeconds;

  ExamSubmissionPayload({
    required this.userId,
    required this.sessionId,
    required this.languageId,
    required this.majorTopicId,
    required this.sessionType,
    required this.results,
    required this.totalTimeSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'session_id': sessionId,
      'language_id': languageId,
      'major_topic_id': majorTopicId,
      'session_type': sessionType,
      'results': results.map((r) => r.toJson()).toList(),
      'total_time_seconds': totalTimeSeconds,
    };
  }

  /// Payload for submission sent to the backend.
  Map<String, dynamic> toSubmitJson() {
    return {
      'user_id': userId,
      'session_id': sessionId,
      'language_id': languageId,
      'major_topic_id': majorTopicId,
      'session_type': sessionType,
      'results': results.map((r) => r.toJson()).toList(),
      'total_time_seconds': totalTimeSeconds,
    };
  }
}

class EnhancedErrorPattern {
  final String errorType;
  final int count;
  final String? whyWrong;
  final String? correctApproach;
  final String? languageTip;
  final String? practiceSuggestion;

  EnhancedErrorPattern({
    required this.errorType,
    required this.count,
    this.whyWrong,
    this.correctApproach,
    this.languageTip,
    this.practiceSuggestion,
  });

  factory EnhancedErrorPattern.fromJson(Map<String, dynamic> json) {
    return EnhancedErrorPattern(
      errorType: json['error_type'],
      count: json['count'] ?? 0,
      whyWrong: json['why_wrong'],
      correctApproach: json['correct_approach'],
      languageTip: json['language_tip'],
      practiceSuggestion: json['practice_suggestion'],
    );
  }
}

class EnhancedRecommendation {
  final String title;
  final String description;
  final int? estimatedTimeMinutes;
  final String? targetsError;

  EnhancedRecommendation({
    required this.title,
    required this.description,
    this.estimatedTimeMinutes,
    this.targetsError,
  });

  factory EnhancedRecommendation.fromJson(Map<String, dynamic> json) {
    return EnhancedRecommendation(
      title: json['title'] ?? 'Recommendation',
      description: json['description'] ?? '',
      estimatedTimeMinutes: json['estimated_time_minutes'],
      targetsError: json['targets_error'],
    );
  }
}

class StrongTopic {
  final String name;
  final double accuracy;

  StrongTopic({required this.name, required this.accuracy});

  factory StrongTopic.fromJson(Map<String, dynamic> json) {
    return StrongTopic(
      name: json['name'] ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PrerequisiteGap {
  final String prereqId;
  final String name;
  final double currentMastery;
  final double requiredMastery;
  final double gapSize;
  final double weight;
  final String impact;
  final String recommendation;

  PrerequisiteGap({
    required this.prereqId,
    required this.name,
    required this.currentMastery,
    required this.requiredMastery,
    required this.gapSize,
    required this.weight,
    required this.impact,
    required this.recommendation,
  });

  factory PrerequisiteGap.fromJson(Map<String, dynamic> json) {
    return PrerequisiteGap(
      prereqId: json['prereq_id'] ?? '',
      name: json['name'] ?? '',
      currentMastery: (json['current_mastery'] as num?)?.toDouble() ?? 0.0,
      requiredMastery: (json['required_mastery'] as num?)?.toDouble() ?? 0.0,
      gapSize: (json['gap_size'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      impact: json['impact'] ?? 'low',
      recommendation: json['recommendation'] ?? '',
    );
  }
}

class ExamSubmissionResponse {
  final bool success;
  final String sessionId;
  final double accuracy;
  final double fluencyRatio;
  final double newMasteryScore;
  final List<String> recommendations;

  ExamSubmissionResponse({
    required this.success,
    required this.sessionId,
    required this.accuracy,
    required this.fluencyRatio,
    required this.newMasteryScore,
    required this.recommendations,
  });

  factory ExamSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return ExamSubmissionResponse(
      success: json['success'] ?? false,
      sessionId: json['session_id'] ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      fluencyRatio: (json['fluency_ratio'] as num?)?.toDouble() ?? 0.0,
      newMasteryScore: (json['new_mastery_score'] as num?)?.toDouble() ?? 0.0,
      recommendations: (json['recommendations'] as List?)?.cast<String>() ?? [],
    );
  }
}

class ExamResultsResponse {
  final String sessionId;
  final String sessionType;
  final String languageId;
  final String majorTopicId;
  final double overallScore;
  final double accuracy;
  final int timeTakenSeconds;
  final List<QuestionResultPayload> questions;
  final List<StrongTopic> strongTopics;
  final List<EnhancedErrorPattern> errorPatterns;
  final List<EnhancedRecommendation> recommendations;
  final String analysisStatus;
  final List<String>? analysisBullets;
  final String? recommendationsSource;
  final String? errorPatternsSource;
  final List<PrerequisiteGap> prerequisiteGaps;
  final double? overallReadiness;

  ExamResultsResponse({
    required this.sessionId,
    required this.sessionType,
    required this.languageId,
    required this.majorTopicId,
    required this.overallScore,
    required this.accuracy,
    required this.timeTakenSeconds,
    required this.questions,
    required this.strongTopics,
    required this.errorPatterns,
    required this.recommendations,
    required this.analysisStatus,
    required this.analysisBullets,
    required this.recommendationsSource,
    required this.errorPatternsSource,
    required this.prerequisiteGaps,
    required this.overallReadiness,
  });

  factory ExamResultsResponse.fromJson(Map<String, dynamic> json) {
    return ExamResultsResponse(
      sessionId: json['session_id'] ?? '',
      sessionType: json['session_type'] ?? '',
      languageId: json['language_id'] ?? '',
      majorTopicId: json['major_topic_id'] ?? '',
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      timeTakenSeconds: (json['time_taken_seconds'] as num?)?.toInt() ?? 0,
      questions:
          (json['questions'] as List?)
              ?.map((e) => QuestionResultPayload.fromJson(e))
              .toList() ??
          [],
      strongTopics:
          (json['strong_topics'] as List?)
              ?.map((e) => StrongTopic.fromJson(e))
              .toList() ??
          [],
      errorPatterns:
          (json['error_patterns'] as List?)
              ?.map((e) => EnhancedErrorPattern.fromJson(e))
              .toList() ??
          [],
      recommendations:
          (json['recommendations'] as List?)
              ?.map((e) => EnhancedRecommendation.fromJson(e))
              .toList() ??
          [],
      analysisStatus: json['analysis_status'] ?? 'unknown',
      analysisBullets: (json['analysis_bullets'] as List?)?.cast<String>(),
      recommendationsSource: json['recommendations_source'],
      errorPatternsSource: json['error_patterns_source'],
      prerequisiteGaps:
          (json['prerequisite_gaps'] as List?)
              ?.map((e) => PrerequisiteGap.fromJson(e))
              .toList() ??
          [],
      overallReadiness: (json['overall_readiness'] as num?)?.toDouble(),
    );
  }
}

class SessionHistoryItem {
  final String sessionId;
  final String sessionType;
  final String languageId;
  final String majorTopicId;
  final String topicName;
  final double overallScore;
  final double accuracy;
  final double difficulty;
  final int timeTakenSeconds;
  final DateTime createdAt;
  final DateTime completedAt;
  final int questionCount;
  final int correctCount;

  SessionHistoryItem({
    required this.sessionId,
    required this.sessionType,
    required this.languageId,
    required this.majorTopicId,
    required this.topicName,
    required this.overallScore,
    required this.accuracy,
    required this.difficulty,
    required this.timeTakenSeconds,
    required this.createdAt,
    required this.completedAt,
    required this.questionCount,
    required this.correctCount,
  });

  factory SessionHistoryItem.fromJson(Map<String, dynamic> json) {
    return SessionHistoryItem(
      sessionId: json['session_id'] ?? '',
      sessionType: json['session_type'] ?? 'practice',
      languageId: json['language_id'] ?? '',
      majorTopicId: json['major_topic_id'] ?? '',
      topicName: json['topic_name'] ?? '',
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.0,
      timeTakenSeconds: (json['time_taken_seconds'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      completedAt: DateTime.parse(
        json['completed_at'] ?? DateTime.now().toIso8601String(),
      ),
      questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
      correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class SessionHistoryResponse {
  final List<SessionHistoryItem> sessions;
  final int totalCount;
  final int limit;
  final int offset;

  SessionHistoryResponse({
    required this.sessions,
    required this.totalCount,
    required this.limit,
    required this.offset,
  });

  factory SessionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SessionHistoryResponse(
      sessions:
          (json['sessions'] as List?)
              ?.map((e) => SessionHistoryItem.fromJson(e))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      limit: json['limit'] ?? 10,
      offset: json['offset'] ?? 0,
    );
  }
}
