enum QuestionType { mcq, text }

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int? correctAnswer; // Nullable for non-MCQ
  final String? correctAnswerText; // For text-based answers
  final QuestionType type;

  Question({
    required this.id,
    required this.question,
    required this.options,
    this.correctAnswer,
    this.correctAnswerText,
    this.type = QuestionType.mcq,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'],
      correctAnswerText: json['correctAnswerText'],
      type: json['type'] == 'text' ? QuestionType.text : QuestionType.mcq,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'correctAnswerText': correctAnswerText,
      'type': type == QuestionType.text ? 'text' : 'mcq',
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
