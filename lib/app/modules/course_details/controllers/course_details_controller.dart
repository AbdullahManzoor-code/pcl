import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/topic_model.dart';
import '../../../data/services/course_service.dart';
import '../../courses/controllers/courses_controller.dart';
import '../../my_courses/controllers/my_courses_controller.dart';
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

      // Check if already enrolled before calling API
      try {
        final portfolio = await _courseService.getUserLanguages();
        if (portfolio.languages.any((l) => l.languageId == course.value!.id)) {
          course.value = course.value!.copyWith(isEnrolled: true);
          Get.snackbar(
            'Already Enrolled',
            'You are already enrolled in ${course.value!.title}.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
            colorText: Get.theme.primaryColor,
          );
          // Sync state immediately across screens
          try {
            if (Get.isRegistered<CoursesController>()) {
              Get.find<CoursesController>().fetchCourses();
            }
            if (Get.isRegistered<MyCoursesController>()) {
              Get.find<MyCoursesController>().fetchEnrolledCourses();
            }
          } catch (e) {
            AppLogger.warning('CourseDetailsController.enroll(): failed to refresh active controllers in pre-check', e);
          }
          // Reload topics/progress just in case
          fetchTopics(course.value!.id);
          return;
        }
      } catch (e) {
        AppLogger.warning(
          'CourseDetailsController.enroll(): failed to check existing enrollment',
          e,
        );
      }

      await _courseService.enrollInLanguage(course.value!.id, 'beginner');

      // Mark as enrolled immediately in details view
      course.value = course.value!.copyWith(isEnrolled: true, progress: 0.0);

      // Sync state immediately across screens
      try {
        if (Get.isRegistered<CoursesController>()) {
          Get.find<CoursesController>().fetchCourses();
        }
        if (Get.isRegistered<MyCoursesController>()) {
          final myCoursesCtrl = Get.find<MyCoursesController>();
          final courseId = course.value!.id;
          if (!myCoursesCtrl.enrolledCourses.any((c) => c.id == courseId)) {
            myCoursesCtrl.enrolledCourses.add(course.value!);
          }
          myCoursesCtrl.fetchEnrolledCourses();
        }
      } catch (e) {
        AppLogger.warning('CourseDetailsController.enroll(): failed to refresh active controllers', e);
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

  void startTest(Topic topic, int numQuestions) async {
    AppLogger.info(
      'CourseDetailsController.startTest(): topicId=${topic.id}, numQuestions=$numQuestions',
    );

    // We need to find the mappingId from the curriculum
    final curriculums = await _courseService.getCurriculum();
    final roadmap =
        curriculums
            .firstWhereOrNull((c) => c.languageId == course.value?.id)
            ?.roadmap ??
        [];
    final currTopic = roadmap.firstWhereOrNull(
      (ct) => ct.majorTopicId == topic.id,
    );
    final mappingId = currTopic?.mappingId ?? 'UNIV_VAR';
    final languageId = course.value?.id ?? 'python';

    Get.toNamed(
      Routes.quiz,
      arguments: {
        'sessionId': '',
        'startTime': null,
        'languageId': languageId,
        'mappingId': mappingId,
        'majorTopicId': topic.id,
        'numQuestions': numQuestions,
        'mode': 'practice',
        'difficulty': 0.5,
        'isDiagnostic': false,
      },
    );
  }

  void handleDemoTest() async {
    AppLogger.info('CourseDetailsController.handleDemoTest(): tapped');
    final langId = course.value?.id ?? 'python_3';

    // Find the first topic from the curriculum roadmap to use dynamically
    final curriculums = await _courseService.getCurriculum();
    final roadmap =
        curriculums.firstWhereOrNull((c) => c.languageId == langId)?.roadmap ??
        [];

    final firstTopic = roadmap.isNotEmpty ? roadmap.first : null;
    final mappingId = firstTopic?.mappingId ?? 'UNIV_VAR';
    final majorTopicId = firstTopic?.majorTopicId ?? '${langId}_intro';

    Get.toNamed(
      Routes.quiz,
      arguments: {
        'sessionId': '',
        'startTime': null,
        'languageId': langId,
        'mappingId': mappingId,
        'majorTopicId': majorTopicId,
        'numQuestions': 10,
        'mode': 'exam',
        'difficulty': 0.5,
        'isDiagnostic': true,
      },
    );
  }

  void openSubTopic(SubTopic subTopic) async {
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
      final parentTopic = topics.firstWhereOrNull(
        (t) => t.subTopics.any((st) => st.id == subTopic.id),
      );
      final majorTopicId =
          parentTopic?.id ?? selectedTopicId.value ?? 'python_intro';
      final langId = course.value?.id ?? 'python_3';

      final curriculums = await _courseService.getCurriculum();
      final roadmap =
          curriculums
              .firstWhereOrNull((c) => c.languageId == langId)
              ?.roadmap ??
          [];
      final currTopic = roadmap.firstWhereOrNull(
        (ct) => ct.majorTopicId == majorTopicId,
      );
      final mappingId = currTopic?.mappingId ?? 'UNIV_VAR';

      Get.toNamed(
        Routes.quiz,
        arguments: {
          'sessionId': '',
          'startTime': null,
          'languageId': langId,
          'mappingId': mappingId,
          'majorTopicId': majorTopicId,
          'numQuestions': 5,
          'mode': 'practice',
          'difficulty': 0.5,
          'isDiagnostic': false,
        },
      );
    } else {
      AppLogger.debug(
        'CourseDetailsController.openSubTopic(): opening lesson ${subTopic.id}',
      );
      Get.snackbar('Lesson', 'Opening Lesson: ${subTopic.title}');
    }
  }
}
