class CreateQuestionReportRequest {
  final String questionId;
  final String? sessionId;
  final String reportType;
  final String description;

  CreateQuestionReportRequest({
    required this.questionId,
    this.sessionId,
    required this.reportType,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      if (sessionId != null) 'session_id': sessionId,
      'report_type': reportType,
      'description': description,
    };
  }
}

class QuestionPreview {
  final String questionText;
  final String languageId;
  final String mappingId;
  final double difficulty;

  QuestionPreview({
    required this.questionText,
    required this.languageId,
    required this.mappingId,
    required this.difficulty,
  });

  factory QuestionPreview.fromJson(Map<String, dynamic> json) {
    return QuestionPreview(
      questionText: json['question_text'] ?? '',
      languageId: json['language_id'] ?? '',
      mappingId: json['mapping_id'] ?? '',
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class QuestionReportResponse {
  final int id;
  final String questionId;
  final String reporterUserId;
  final String reporterEmail;
  final String? sessionId;
  final String reportType;
  final String description;
  final String status;
  final String createdAt;
  final String? resolvedAt;
  final String? resolvedBy;
  final String? resolvedByEmail;
  final QuestionPreview? questionPreview;

  QuestionReportResponse({
    required this.id,
    required this.questionId,
    required this.reporterUserId,
    required this.reporterEmail,
    this.sessionId,
    required this.reportType,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolvedByEmail,
    this.questionPreview,
  });

  factory QuestionReportResponse.fromJson(Map<String, dynamic> json) {
    return QuestionReportResponse(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? '',
      reporterUserId: json['reporter_user_id'] ?? '',
      reporterEmail: json['reporter_email'] ?? '',
      sessionId: json['session_id'],
      reportType: json['report_type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      resolvedAt: json['resolved_at'],
      resolvedBy: json['resolved_by'],
      resolvedByEmail: json['resolved_by_email'],
      questionPreview: json['question_preview'] != null
          ? QuestionPreview.fromJson(json['question_preview'])
          : null,
    );
  }
}

class ReportListResponse {
  final List<QuestionReportResponse> reports;
  final int totalCount;
  final int filteredCount;

  ReportListResponse({
    required this.reports,
    required this.totalCount,
    required this.filteredCount,
  });

  factory ReportListResponse.fromJson(Map<String, dynamic> json) {
    return ReportListResponse(
      reports:
          (json['reports'] as List?)
              ?.map((e) => QuestionReportResponse.fromJson(e))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      filteredCount: json['filtered_count'] ?? 0,
    );
  }
}

class ReportStatsResponse {
  final int pendingCount;
  final int resolvedCount;
  final int dismissedCount;
  final int totalCount;

  ReportStatsResponse({
    required this.pendingCount,
    required this.resolvedCount,
    required this.dismissedCount,
    required this.totalCount,
  });

  factory ReportStatsResponse.fromJson(Map<String, dynamic> json) {
    return ReportStatsResponse(
      pendingCount: json['pending_count'] ?? 0,
      resolvedCount: json['resolved_count'] ?? 0,
      dismissedCount: json['dismissed_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
    );
  }
}
