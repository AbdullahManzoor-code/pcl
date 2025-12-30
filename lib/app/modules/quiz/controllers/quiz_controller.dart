import 'package:get/get.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repositories/course_repository.dart';

class QuizController extends GetxController {
  late final CourseRepository _courseRepository;

  final quiz = Rxn<Quiz>();
  final currentIndex = 0.obs;
  final selectedOption = Rxn<int>();
  final score = 0.obs;
  final isFinished = false.obs;
  final isLoading = true.obs;
  final isDiagnostic = false.obs;
  String courseId = '';

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

  void loadQuiz() {
    isLoading.value = true;
    try {
      final data = _courseRepository.getQuizForCourse(courseId);
      if (data != null) {
        quiz.value = data;
      } else {
        Get.snackbar(
          'Error',
          'No quiz found for this course.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error loading quiz: $e');
      Get.snackbar(
        'Error',
        'Could not load the quiz. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectOption(int index) {
    if (selectedOption.value == null) {
      selectedOption.value = index;
    }
  }

  void nextQuestion() async {
    if (selectedOption.value == null) return;

    if (selectedOption.value ==
        quiz.value!.questions[currentIndex.value].correctAnswerIndex) {
      score.value++;
    }

    if (currentIndex.value < quiz.value!.questions.length - 1) {
      currentIndex.value++;
      selectedOption.value = null;
    } else {
      // Quiz Finished - Call ML Backend
      isLoading.value = true;
      try {
        final total = quiz.value!.questions.length;
        final result = await _courseRepository.submitQuiz(
          courseId,
          score.value,
          total,
        );

        Get.offNamed(
          '/results',
          arguments: {
            ...result,
            'total': total,
            'correct': score.value,
            'incorrect': total - score.value,
            'courseId': courseId,
          },
        );
      } catch (e) {
        print('Error submitting quiz: $e');
        isFinished.value = true;
      } finally {
        isLoading.value = false;
      }
    }
  }

  void restartQuiz() {
    currentIndex.value = 0;
    selectedOption.value = null;
    score.value = 0;
    isFinished.value = false;
  }
}
