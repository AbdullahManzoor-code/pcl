import 'quiz_model.dart';

class TestResult {
  final String sessionId;
  final String conceptId;
  final String conceptName;
  final int score;
  final int totalQuestions;
  final int accuracy;
  final Map<int, dynamic> answers;
  final List<Question> questions;
  final String mode; // 'practice', 'review', 'exam'
  final double difficulty;

  TestResult({
    required this.sessionId,
    required this.conceptId,
    required this.conceptName,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.answers,
    required this.questions,
    required this.mode,
    required this.difficulty,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    var questionsList = <Question>[];
    if (json['questions'] != null) {
      json['questions'].forEach((v) {
        questionsList.add(Question.fromJson(v));
      });
    }

    var answersMap = <int, dynamic>{};
    if (json['answers'] != null) {
      (json['answers'] as Map<String, dynamic>).forEach((key, value) {
        answersMap[int.parse(key)] = value;
      });
    }

    return TestResult(
      sessionId: json['session_id'] ?? '',
      conceptId: json['concept_id'] ?? '',
      conceptName: json['concept_name'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      accuracy: json['accuracy'] ?? 0,
      answers: answersMap,
      questions: questionsList,
      mode: json['mode'] ?? 'practice',
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'concept_id': conceptId,
      'concept_name': conceptName,
      'score': score,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
      'questions': questions.map((v) => v.toJson()).toList(),
      'mode': mode,
      'difficulty': difficulty,
    };
  }
}
