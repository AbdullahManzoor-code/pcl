import 'package:get/get.dart';
import '../../../data/models/course_model.dart';
// import '../../../data/models/sub_topic_model.dart'; // Removing to avoid conflict if Topic model includes SubTopic
import '../../../data/models/topic_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../routes/app_pages.dart';

class CourseDetailsController extends GetxController {
  final course = Rxn<Course>(); // Use Rxn for nullable or just late
  final topics = <Topic>[].obs;
  final isLoading = true.obs;
  final RxnString selectedTopicId = RxnString();
  final numQuestions = 10.obs;

  final CourseRepository _courseRepository = Get.find<CourseRepository>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      if (args is Course) {
        course.value = args;
      } else if (args is Map<String, dynamic>) {
        course.value = args['course'] as Course?;
      }

      if (course.value != null) {
        fetchTopics(course.value!.id);
      }
    }
  }

  void enroll() {
    if (course.value == null) return;
    try {
      _courseRepository.enrollInCourse(course.value!.id);
      // Refresh course data
      final updatedCourses = _courseRepository.getAllCourses();
      course.value = updatedCourses.firstWhere((c) => c.id == course.value!.id);

      Get.snackbar(
        'Success',
        'You have successfully enrolled in ${course.value!.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Enrollment failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
      );
    }
  }

  void continueLearning() {
    if (topics.isNotEmpty && topics.first.subTopics.isNotEmpty) {
      openSubTopic(topics.first.subTopics.first);
    } else {
      Get.snackbar('Notice', 'No lessons available for this course yet.');
    }
  }

  void fetchTopics(String courseId) {
    isLoading.value = true;
    try {
      final data = _courseRepository.getTopics(courseId);
      topics.assignAll(data);
    } catch (e) {
      print('Error fetching topics: $e');
      Get.snackbar(
        'Error',
        'Failed to load course contents.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void startTest(Topic topic, int numQuestions) {
    Get.toNamed(
      Routes.quiz,
      arguments: {
        'courseId': course.value?.id,
        'topicId': topic.id,
        'numQuestions': numQuestions,
        'isDiagnostic': false,
      },
    );
  }

  void handleDemoTest() {
    Get.toNamed(
      Routes.quiz,
      arguments: {'courseId': course.value?.id, 'isDiagnostic': true},
    );
  }

  void openSubTopic(SubTopic subTopic) {
    if (subTopic.isLocked) {
      Get.snackbar(
        'Locked',
        'Complete previous lessons to unlock this one.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (subTopic.type == 'quiz') {
      Get.toNamed(Routes.quiz, arguments: subTopic);
    } else {
      Get.snackbar('Lesson', 'Opening Lesson: ${subTopic.title}');
    }
  }
}
