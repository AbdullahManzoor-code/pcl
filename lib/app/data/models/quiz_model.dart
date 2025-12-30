class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correct_answer_index': correctAnswerIndex,
    };
  }
}

class Quiz {
  final String courseId;
  final List<Question> questions;

  Quiz({required this.courseId, required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var questionsList = <Question>[];
    if (json['questions'] != null) {
      json['questions'].forEach((v) {
        questionsList.add(Question.fromJson(v));
      });
    }
    return Quiz(courseId: json['course_id'] ?? '', questions: questionsList);
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'questions': questions.map((v) => v.toJson()).toList(),
    };
  }
}
