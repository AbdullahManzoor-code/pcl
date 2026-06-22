import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pcl/app/data/models/course_api_models.dart';
import 'package:pcl/app/data/services/course_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/services/exam_service.dart';
import '../../../data/models/exam_api_models.dart';
import '../../../data/services/auth_service.dart';

class PracticeController extends GetxController {
  final CourseService _courseService = Get.find<CourseService>();
  final ExamService _examService = Get.find<ExamService>();
  final AuthService _authService = Get.find<AuthService>();

  final availableTopics = <CurriculumTopic>[].obs;
  String? currentLanguageId;
  final isLoading = true.obs;
  final selectedTopic = Rxn<CurriculumTopic>();
  final difficulty = 0.5.obs;
  final selectedQuestionCount = 10.obs;
  final selectedMode = 'practice'.obs;
  final isFromPracticeAgain = false.obs;

  final modes = [
    {
      'id': 'practice',
      'name': 'Practice Mode',
      'description': 'Learn with hints and explanations',
      'icon': Icons.track_changes_rounded,
    },
    {
      'id': 'exam',
      'name': 'Exam Mode',
      'description': 'Test your knowledge under pressure',
      'icon': Icons.bolt_rounded,
    },
    {
      'id': 'review',
      'name': 'Review Mode',
      'description': "Reinforce concepts you've decayed",
      'icon': Icons.refresh_rounded,
    },
  ];

  final questionCounts = [5, 10, 15, 20, 30, 50];

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('PracticeController.onInit(): practice setup loaded');
    fetchAvailableTopics();
  }

  void fetchAvailableTopics() async {
    isLoading.value = true;
    try {
      final curriculumList = await _courseService.getCurriculum();
      if (curriculumList.isNotEmpty) {
        currentLanguageId = curriculumList.first.languageId;
        availableTopics.assignAll(curriculumList.first.roadmap);
      }
      _handleArgs();
    } catch (e, stackTrace) {
      AppLogger.error(
        'PracticeController.fetchAvailableTopics(): failed',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Could not load topics to practice.');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleArgs() {
    if (Get.arguments != null && Get.arguments is Map) {
      final String? conceptId = Get.arguments['conceptId'];
      if (conceptId != null) {
        AppLogger.info(
          'PracticeController._handleArgs(): received conceptId=$conceptId',
        );
        final topic = availableTopics.firstWhereOrNull(
          (t) => t.majorTopicId == conceptId || t.mappingId == conceptId,
        );
        if (topic != null) {
          selectedTopic.value = topic;
          selectedMode.value = Get.arguments['mode'] ?? 'practice';
          isFromPracticeAgain.value = true;
        }
      }
    }
  }

  void selectTopic(CurriculumTopic? topic) {
    AppLogger.info('PracticeController.selectTopic(): topic=${topic?.name}');
    selectedTopic.value = topic;
  }

  void setDifficulty(double val) {
    AppLogger.debug('PracticeController.setDifficulty(): value=$val');
    difficulty.value = val;
  }

  void setQuestionCount(int count) {
    AppLogger.info('PracticeController.setQuestionCount(): count=$count');
    selectedQuestionCount.value = count;
  }

  void selectMode(String id) {
    AppLogger.info('PracticeController.selectMode(): mode=$id');
    selectedMode.value = id;
  }

  String get difficultyLabel {
    if (difficulty.value <= 0.4) return 'Easy';
    if (difficulty.value <= 0.6) return 'Medium';
    if (difficulty.value <= 0.8) return 'Hard';
    return 'Expert';
  }

  Color get difficultyColor {
    if (difficulty.value <= 0.4) return Colors.green;
    if (difficulty.value <= 0.6) return Colors.yellow[700]!;
    if (difficulty.value <= 0.8) return Colors.orange;
    return Colors.red;
  }

  void startPractice() async {
    if (selectedTopic.value == null) {
      AppLogger.warning(
        'PracticeController.startPractice(): blocked, no topic selected',
      );
      Get.snackbar(
        'Required',
        'Please select a topic to practice',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    isLoading.value = true;
    try {
      final topic = selectedTopic.value!;
      AppLogger.info(
        'PracticeController.startPractice(): topic=${topic.name}, mode=${selectedMode.value}, difficulty=${difficulty.value}, questions=${selectedQuestionCount.value}',
      );

      String? userId = _authService.getStoredUser()?.id;
      if (userId == null) {
        try {
          final me = await _authService.getMe();
          userId = me.id;
        } catch (_) {}
      }
      if (userId == null) {
        Get.snackbar('Error', 'Please login to start a session');
        isLoading.value = false;
        return;
      }

      if (currentLanguageId == null) {
        Get.snackbar('Error', 'No language selected. Please restart practice.');
        isLoading.value = false;
        return;
      }
      
      if (topic.mappingId.isEmpty || topic.majorTopicId.isEmpty) {
        Get.snackbar('Error', 'Invalid curriculum mapping for this topic.');
        isLoading.value = false;
        return;
      }

      Get.toNamed(
        Routes.quiz,
        arguments: {
          'sessionId': '', // Let QuizController handle session creation while rendering skeleton
          'startTime': null,
          'languageId': currentLanguageId!,
          'mappingId': topic.mappingId,
          'majorTopicId': topic.majorTopicId,
          'numQuestions': selectedQuestionCount.value,
          'mode': selectedMode.value,
          'difficulty': difficulty.value,
          'isDiagnostic': false,
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'PracticeController.startPractice(): failed',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Failed to start session. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
