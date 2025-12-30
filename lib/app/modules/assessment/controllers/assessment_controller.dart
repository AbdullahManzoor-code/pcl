import 'package:get/get.dart';
import 'package:pcl/app/routes/app_pages.dart';

class AssessmentController extends GetxController {
  final currentQuestionIndex = 0.obs;
  final answers = <int, int>{}.obs; // Question Index -> Answer Index

  // Dummy Questions Data
  final questions = [
    {
      'question': 'What is the output of print(2 + 2)?',
      'options': ['3', '4', '5', 'Error'],
      'correctAnswer': 1,
    },
    {
      'question': 'Which keyword is used to define a function in Python?',
      'options': ['func', 'def', 'function', 'struct'],
      'correctAnswer': 1,
    },
    {
      'question': 'What is a variable?',
      'options': [
        'A fixed value',
        'A named storage location',
        'A function',
        'A loop',
      ],
      'correctAnswer': 1,
    },
    {
      'question': 'Which of these is a loop structure?',
      'options': ['if-else', 'for', 'switch', 'break'],
      'correctAnswer': 1,
    },
    {
      'question': 'What does HTML stand for?',
      'options': [
        'Hyper Text Makeup Language',
        'Hyper Text Markup Language',
        'Hyper Tech Markup Language',
        'None',
      ],
      'correctAnswer': 1,
    },
  ];

  void selectAnswer(int questionIndex, int answerIndex) {
    answers[questionIndex] = answerIndex;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    } else {
      submitAssessment();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void submitAssessment() {
    // Calculate Score
    int correctCount = 0;
    answers.forEach((key, value) {
      if (questions[key]['correctAnswer'] == value) {
        correctCount++;
      }
    });

    // Pass data to results
    Get.offNamed(
      Routes.RESULTS,
      arguments: {
        'total': questions.length,
        'correct': correctCount,
        'incorrect': questions.length - correctCount, // Simplified
      },
    );
  }
}
