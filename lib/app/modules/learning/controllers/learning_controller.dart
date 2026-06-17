import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_logger.dart';

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
    AppLogger.info(
      'LearningController.onInit(): topic=${topic['name'] ?? 'unknown'}',
    );
  }

  void startQuiz() {
    AppLogger.info('LearningController.startQuiz(): tapped');
    isQuizMode.value = true;
    quizQuestionIndex.value = 0;
    quizScore.value = 0;
  }

  void answerQuiz(int index) {
    AppLogger.debug(
      'LearningController.answerQuiz(): selected=$index questionIndex=${quizQuestionIndex.value}',
    );
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
    AppLogger.info(
      'LearningController.finishQuiz(): score=${quizScore.value}/${quizQuestions.length}',
    );
    // Determine if passed (e.g., > 50%)
    bool passed = (quizScore.value / quizQuestions.length) >= 0.5;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Icon(
              passed ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
              size: 64.sp,
              color: passed ? Colors.amber : Colors.blue,
            ),
            SizedBox(height: 24.h),
            Text(
              passed ? 'Congratulations!' : 'Try Again',
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              passed
                  ? 'You passed the quiz! You\'ve earned XP and unlocked the next topic.'
                  : 'You scored ${((quizScore.value / quizQuestions.length) * 100).toInt()}%. You need at least 50% to pass this module.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.grey),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  AppLogger.info(
                    'LearningController.finishQuiz(): result action pressed passed=$passed',
                  );
                  Get.back(); // Close bottom sheet
                  if (passed) {
                    Get.back(); // Exit learning view
                  } else {
                    isQuizMode.value = false; // Retry learning
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: passed
                      ? AppColors.secondary
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  passed ? 'Continue' : 'Review Topic',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }
}
