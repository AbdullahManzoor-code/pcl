import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';

class PracticeController extends GetxController {
  // 8 Universal Concepts
  final concepts = [
    {
      'id': 'UNIV_VAR',
      'name': 'Variables & Data Types',
      'icon': Icons.data_array_rounded,
      'color': [Color(0xFF2563EB), Color(0xFF3B82F6)], // Blue
    },
    {
      'id': 'UNIV_COND',
      'name': 'Conditionals',
      'icon': Icons.account_tree_rounded,
      'color': [Color(0xFF16A34A), Color(0xFF22C55E)], // Green
    },
    {
      'id': 'UNIV_LOOP',
      'name': 'Loops',
      'icon': Icons.loop_rounded,
      'color': [Color(0xFF9333EA), Color(0xFFA855F7)], // Purple
    },
    {
      'id': 'UNIV_FUNC',
      'name': 'Functions',
      'icon': Icons.functions_rounded,
      'color': [Color(0xFFEA580C), Color(0xFFF97316)], // Orange
    },
    {
      'id': 'UNIV_COLL',
      'name': 'Collections',
      'icon': Icons.storage_rounded,
      'color': [Color(0xFFDB2777), Color(0xFFEC4899)], // Pink
    },
    {
      'id': 'UNIV_ERR',
      'name': 'Error Handling',
      'icon': Icons.warning_amber_rounded,
      'color': [Color(0xFFDC2626), Color(0xFFEF4444)], // Red
    },
    {
      'id': 'UNIV_OOP_BASIC',
      'name': 'OOP Basics',
      'icon': Icons.layers_rounded,
      'color': [Color(0xFFCA8A04), Color(0xFFEAB308)], // Yellow
    },
    {
      'id': 'UNIV_OOP_ADV',
      'name': 'Advanced OOP',
      'icon': Icons.widgets_rounded,
      'color': [Color(0xFF4F46E5), Color(0xFF6366F1)], // Indigo
    },
  ].obs;

  final modes = [
    {
      'id': 'practice',
      'name': 'Practice Mode',
      'description': 'Learn with hints and explanations',
      'icon': Icons.track_changes_rounded,
      'color': Colors.blue,
    },
    {
      'id': 'exam',
      'name': 'Exam Mode',
      'description': 'Test your knowledge under pressure',
      'icon': Icons.bolt_rounded,
      'color': Colors.red,
    },
    {
      'id': 'review',
      'name': 'Review Mode',
      'description': "Reinforce concepts you've decayed",
      'icon': Icons.refresh_rounded,
      'color': Colors.green,
    },
  ];

  final questionCounts = [5, 10, 15, 20, 30, 50];

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('PracticeController.onInit(): practice setup loaded');
    _handleArgs();
  }

  void _handleArgs() {
    if (Get.arguments != null && Get.arguments is Map) {
      final String? conceptName = Get.arguments['concept'];
      if (conceptName != null) {
        AppLogger.info(
          'PracticeController._handleArgs(): received concept=$conceptName',
        );
        final concept = concepts.firstWhereOrNull(
          (c) =>
              (c['name'] as String).toLowerCase() == conceptName.toLowerCase(),
        );
        if (concept != null) {
          selectedConcept.value = concept['id'] as String;
          selectedMode.value = 'review'; // Default to review for retakes
        }
      }
    }
  }

  // Configuration State
  final selectedConcept = RxnString();
  final difficulty = 0.5.obs;
  final selectedQuestionCount = 10.obs;
  final selectedMode = 'practice'.obs;

  void selectConcept(String id) {
    AppLogger.info('PracticeController.selectConcept(): conceptId=$id');
    selectedConcept.value = id;
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

  void startPractice() {
    if (selectedConcept.value == null) {
      AppLogger.warning(
        'PracticeController.startPractice(): blocked, no concept selected',
      );
      Get.snackbar(
        'Required',
        'Please select a concept to practice',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final concept = concepts.firstWhere(
      (c) => c['id'] == selectedConcept.value,
    );

    AppLogger.info(
      'PracticeController.startPractice(): concept=${selectedConcept.value}, mode=${selectedMode.value}, difficulty=${difficulty.value}, questions=${selectedQuestionCount.value}',
    );

    Get.toNamed(
      Routes.quiz,
      arguments: {
        'conceptId': selectedConcept.value,
        'conceptName': concept['name'],
        'difficulty': difficulty.value,
        'numQuestions': selectedQuestionCount.value,
        'mode': selectedMode.value,
      },
    );
  }
}
