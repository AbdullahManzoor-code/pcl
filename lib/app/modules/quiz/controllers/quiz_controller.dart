import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/models/test_result_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../routes/app_pages.dart';

class QuizController extends GetxController {
  late final CourseRepository _courseRepository;

  final quiz = Rxn<Quiz>();
  final currentIndex = 0.obs;
  // Map of question index -> answer (int for MCQ, String for Text)
  final answers = <int, dynamic>{}.obs;
  final timeLeft = 1800.obs; // 30 mins default
  final isLoading = true.obs;
  final isDiagnostic = false.obs;
  String courseId = '';

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _courseRepository = Get.find<CourseRepository>();
    final args = Get.arguments;
    if (args != null) {
      if (args is String) {
        courseId = args;
      } else if (args is Map<String, dynamic>) {
        courseId = args['courseId'] ?? '';
        isDiagnostic.value = args['isDiagnostic'] ?? false;
      }
      loadQuiz();
    } else {
      Get.back();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void loadQuiz() {
    isLoading.value = true;
    try {
      // Logic to fetch quiz
      final fetchedQuiz = isDiagnostic.value
          ? _courseRepository.getQuizForCourse(
              courseId,
            ) // Fallback to normal quiz if diagnostic is missing
          : _courseRepository.getQuizForCourse(courseId);

      if (fetchedQuiz != null) {
        quiz.value = fetchedQuiz;
        // Start timer based on questions count * 1.5 mins
        timeLeft.value = fetchedQuiz.questions.length * 90;
        startTimer();
      } else {
        // Fallback or error
        Get.snackbar('Error', 'No quiz found.');
      }
    } catch (e) {
      print('Error loading quiz: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper for mock data availability
  bool argCourseIdHasQuiz() => true;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        submitQuiz();
        timer.cancel();
      }
    });
  }

  void selectOption(int answerIndex) {
    answers[currentIndex.value] = answerIndex;
  }

  void nextQuestion() {
    if (currentIndex.value < (quiz.value?.questions.length ?? 0) - 1) {
      currentIndex.value++;
    }
  }

  void prevQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  void jumpToQuestion(int index) {
    currentIndex.value = index;
  }

  void submitQuiz() async {
    _timer?.cancel();
    isLoading.value = true;

    try {
      final questions = quiz.value!.questions;
      int score = 0;

      answers.forEach((index, answer) {
        final question = questions[index];
        if (question.type == QuestionType.mcq) {
          if (question.correctAnswer == answer) {
            score++;
          }
        } else if (question.type == QuestionType.text) {
          // Normalize both for comparison
          final userAnswer = answer.toString().trim().toLowerCase();
          final correctAnswer = (question.correctAnswerText ?? '')
              .trim()
              .toLowerCase();
          if (userAnswer == correctAnswer) {
            score++;
          }
        }
      });

      final total = questions.length;

      // Mock submit
      await Future.delayed(const Duration(seconds: 1));

      // Construct TestResult
      final result = TestResult(
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        conceptId: courseId,
        conceptName: isDiagnostic.value
            ? 'Initial Assessment'
            : courseId.split('_').first.capitalizeFirst!,
        score: score,
        totalQuestions: total,
        accuracy: total > 0 ? ((score / total) * 100).toInt() : 0,
        answers: Map<int, dynamic>.from(answers),
        questions: questions,
        mode: isDiagnostic.value ? 'review' : 'practice',
        difficulty: 0.5, // Default
      );

      Get.offNamed(Routes.results, arguments: result);
    } catch (e) {
      print('Error submitting quiz: $e');
      isLoading.value = false;
    }
  }

  String get formattedTime {
    final mins = (timeLeft.value / 60).floor().toString().padLeft(2, '0');
    final secs = (timeLeft.value % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
