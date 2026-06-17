import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/topic_model.dart';
import '../../../data/services/course_service.dart';
import '../../../routes/app_pages.dart';

class CourseDetailsController extends GetxController {
  final course = Rxn<Course>();
  final topics = <Topic>[].obs;
  final isLoading = true.obs;
  final RxnString selectedTopicId = RxnString();
  final numQuestions = 10.obs;

  final CourseService _courseService = Get.find<CourseService>();

  @override
  void onInit() {
    super.onInit();
    AppLogger.info(
      'CourseDetailsController.onInit(): reading navigation arguments',
    );
    final args = Get.arguments;
    if (args != null) {
      if (args is Course) {
        course.value = args;
        AppLogger.debug(
          'CourseDetailsController.onInit(): course passed directly id=${args.id}',
        );
      } else if (args is Map<String, dynamic>) {
        course.value = args['course'] as Course?;
        AppLogger.debug(
          'CourseDetailsController.onInit(): course received from map',
        );
      }

      if (course.value != null) {
        AppLogger.info(
          'CourseDetailsController.onInit(): loading topics for courseId=${course.value!.id}',
        );
        fetchTopics(course.value!.id);
      }
    }
  }

  void enroll() async {
    if (course.value == null) return;
    try {
      AppLogger.info(
        'CourseDetailsController.enroll(): courseId=${course.value!.id}',
      );
      await _courseService.enrollInLanguage(course.value!.id, 'beginner');

      // Assume user is now enrolled and fetch data again to sync progress tracking
      final portfolio = await _courseService.getUserLanguages();
      final stats = portfolio.languages.firstWhereOrNull(
        (l) => l.languageId == course.value!.id,
      );

      if (stats != null) {
        course.value = course.value!.copyWith(isEnrolled: true, progress: 0.0);
      }

      Get.snackbar(
        'Success',
        'You have successfully enrolled in ${course.value!.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
      );

      // Reload topics/progress
      fetchTopics(course.value!.id);
    } catch (e, stackTrace) {
      AppLogger.error(
        'CourseDetailsController.enroll(): failed',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Error',
        'Enrollment failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
      );
    }
  }

  void continueLearning() {
    AppLogger.info('CourseDetailsController.continueLearning(): tapped');
    if (topics.isNotEmpty) {
      // Find first incomplete topic
      final nextTopic =
          topics.firstWhereOrNull((t) => !t.completed) ?? topics.first;

      if (nextTopic.subTopics.isNotEmpty) {
        // Find first incomplete subtopic
        final nextSub =
            nextTopic.subTopics.firstWhereOrNull((s) => !s.completed) ??
            nextTopic.subTopics.first;
        openSubTopic(nextSub);
      } else {
        AppLogger.warning(
          'CourseDetailsController.continueLearning(): topic has no lessons',
        );
        Get.snackbar('Notice', 'No lessons available for this topic yet.');
      }
    } else {
      AppLogger.warning(
        'CourseDetailsController.continueLearning(): no topics available',
      );
      Get.snackbar('Notice', 'No lessons available for this course yet.');
    }
  }

  Future<void> fetchTopics(String courseId) async {
    AppLogger.info('CourseDetailsController.fetchTopics(): courseId=$courseId');
    isLoading.value = true;
    try {
      // Fetch both curriculum structure and user progress concurrently
      final curriculums = await _courseService.getCurriculum();
      final roadmap =
          curriculums
              .firstWhereOrNull((c) => c.languageId == courseId)
              ?.roadmap ??
          [];

      // Try to fetch progress (might fail if not enrolled, handle gracefully)
      Map<String, dynamic> topicProgress = {};
      try {
        final progress = await _courseService.getLanguageProgress(courseId);
        // Map concept ID to its progress details
        for (var tp in progress.topics) {
          topicProgress[tp.majorTopicId] = {
            'completed':
                tp.mastery > 0.5, // Arbitrary threshold for "completed" topic
            'accuracy': (tp.confidence * 100).toInt(),
          };
        }
      } catch (e, stackTrace) {
        // User not enrolled or progress not available yet.
        AppLogger.warning(
          'CourseDetailsController.fetchTopics(): progress unavailable for courseId=$courseId',
          e,
          stackTrace,
        );
      }

      final mergedTopics = roadmap.map((ct) {
        final prog =
            topicProgress[ct.majorTopicId] ??
            {'completed': false, 'accuracy': 0};
        return Topic(
          id: ct.majorTopicId,
          name: ct.name,
          completed: prog['completed'],
          accuracy: prog['accuracy'],
          subTopics: ct.subTopics.map((st) {
            return SubTopic(
              id: st,
              title: st.replaceAll('_', ' ').capitalizeFirst ?? st,
              completed:
                  prog['completed'], // In lack of subtopic progress tracking
              isLocked: false,
              type: 'lesson',
            );
          }).toList(),
        );
      }).toList();

      topics.assignAll(mergedTopics);
      AppLogger.info(
        'CourseDetailsController.fetchTopics(): topics loaded count=${mergedTopics.length}',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'CourseDetailsController.fetchTopics(): failed',
        e,
        stackTrace,
      );
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
    AppLogger.info(
      'CourseDetailsController.startTest(): topicId=${topic.id}, numQuestions=$numQuestions',
    );
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
    AppLogger.info('CourseDetailsController.handleDemoTest(): tapped');
    Get.toNamed(
      Routes.quiz,
      arguments: {'courseId': course.value?.id, 'isDiagnostic': true},
    );
  }

  void openSubTopic(SubTopic subTopic) {
    AppLogger.info(
      'CourseDetailsController.openSubTopic(): subTopicId=${subTopic.id}, type=${subTopic.type}',
    );
    if (subTopic.isLocked) {
      AppLogger.warning(
        'CourseDetailsController.openSubTopic(): locked subtopic=${subTopic.id}',
      );
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
      AppLogger.debug(
        'CourseDetailsController.openSubTopic(): opening lesson ${subTopic.id}',
      );
      Get.snackbar('Lesson', 'Opening Lesson: ${subTopic.title}');
    }
  }
}
