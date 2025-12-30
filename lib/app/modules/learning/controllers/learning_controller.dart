import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LearningController extends GetxController {
  final topic = <String, dynamic>{}.obs;
  final isQuizMode = false.obs;

  // Quiz variables
  final quizQuestionIndex = 0.obs;
  final quizScore = 0.obs;

  // Mock content data
  final content = '''
# Introduction to Programming

Programming is the process of creating a set of instructions that tell a computer how to perform a task. Programming can be done using a variety of computer programming languages, such as JavaScript, Python, and C++.

## Why Learn Programming?
- Automate tasks
- Build applications
- Analyze data
- Solve complex problems

## Example (Python)
```python
print("Hello, World!")
```
This simple line of code outputs text to the screen.
''';

  final quizQuestions = [
    {
      'question': 'What is programming?',
      'options': [
        'Cooking',
        'Writing instructions for computer',
        'Playing games',
        'None',
      ],
      'correctAnswer': 1,
    },
    {
      'question': 'Which is a programming language?',
      'options': ['HTML', 'CSS', 'Python', 'English'],
      'correctAnswer': 2,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      topic.value = Get.arguments as Map<String, dynamic>;
    }
  }

  void startQuiz() {
    isQuizMode.value = true;
    quizQuestionIndex.value = 0;
    quizScore.value = 0;
  }

  void answerQuiz(int index) {
    if (quizQuestions[quizQuestionIndex.value]['correctAnswer'] == index) {
      quizScore.value++;
    }

    if (quizQuestionIndex.value < quizQuestions.length - 1) {
      quizQuestionIndex.value++;
    } else {
      finishQuiz();
    }
  }

  void finishQuiz() {
    // Determine if passed (e.g., > 50%)
    bool passed = (quizScore.value / quizQuestions.length) >= 0.5;

    Get.defaultDialog(
      title: passed ? 'Congratulations!' : 'Try Again',
      middleText: passed
          ? 'You passed the quiz! Next topic unlocked.'
          : 'You need to score at least 50% to pass.',
      confirm: ElevatedButton(
        onPressed: () {
          Get.back(); // Close dialog
          if (passed) {
            // Logic to unlock next topic would go here (update persistent state)
            Get.back(); // Go back to dashboard
          } else {
            isQuizMode.value = false; // Retry learning
          }
        },
        child: const Text('OK'),
      ),
      barrierDismissible: false,
    );
  }
}
