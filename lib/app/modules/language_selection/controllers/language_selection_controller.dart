import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcl/app/routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';

class LanguageSelectionController extends GetxController {
  final selectedLanguage = ''.obs;
  final selectedLevel = ''.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('LanguageSelectionController.onInit(): ready for selection');
  }

  final languages = [
    {'name': 'C++', 'icon': Icons.code},
    {'name': 'Java', 'icon': Icons.coffee},
    {'name': 'JavaScript', 'icon': Icons.javascript},
    {'name': 'Python', 'icon': Icons.terminal},
  ];

  final levels = ['Beginner', 'Intermediate', 'Advanced'];

  void selectLanguage(String language) {
    AppLogger.info(
      'LanguageSelectionController.selectLanguage(): language=$language',
    );
    selectedLanguage.value = language;
    // Navigate to Level Selection (same module, different view logic or route)
    // For simplicity, I'll use a boolean to switch view or just Get.to a new view class
    // But since I am in a controller, I'll use a navigation to a sub-route or just a widget switch
    // Let's assume we maintain state and just show Level Selection View in the same scaffold or navigate.
    // I'll navigate to a LevelSelectionView (which I will define in the view file).
  }

  void selectLevel(String level) {
    AppLogger.info('LanguageSelectionController.selectLevel(): level=$level');
    selectedLevel.value = level;
    Get.offAllNamed(Routes.assessment);
  }
}
