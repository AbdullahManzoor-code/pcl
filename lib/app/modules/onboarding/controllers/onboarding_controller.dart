import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcl/app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  // Selection states
  final selectedLanguage = RxnString();
  final selectedDifficulty = RxnString();

  final languages = [
    {
      'id': 'python_3',
      'name': 'Python',
      'version': '3.11+',
      'logo': 'python', // Use icons or asset paths
      'description': 'Perfect for beginners, data science, and web development',
      'color': const Color(0xFF3B82F6), // blue-500
      'bgColor': const Color(0xFFEFF6FF), // blue-50
    },
    {
      'id': 'javascript_es6',
      'name': 'JavaScript',
      'version': 'ES6+',
      'logo': 'javascript',
      'description': 'Essential for web development and modern applications',
      'color': const Color(0xFFEAB308), // yellow-500
      'bgColor': const Color(0xFFFEFCE8), // yellow-50
    },
    {
      'id': 'java_17',
      'name': 'Java',
      'version': '17 LTS',
      'logo': 'java',
      'description': 'Enterprise applications and Android development',
      'color': const Color(0xFFEF4444), // red-500
      'bgColor': const Color(0xFFFEF2F2), // red-50
    },
    {
      'id': 'cpp_20',
      'name': 'C++',
      'version': 'C++20',
      'logo': 'cpp',
      'description': 'High-performance systems and game development',
      'color': const Color(0xFFA855F7), // purple-500
      'bgColor': const Color(0xFFFAF5FF), // purple-50
    },
    {
      'id': 'go_1_21',
      'name': 'Go',
      'version': '1.21+',
      'logo': 'go',
      'description': 'Cloud services, microservices, and concurrent systems',
      'color': const Color(0xFF06B6D4), // cyan-500
      'bgColor': const Color(0xFFECFEFF), // cyan-50
    },
    {
      'id': 'typescript',
      'name': 'TypeScript',
      'version': '5.0+',
      'logo': 'typescript',
      'description': 'Type-safe JavaScript for large-scale applications',
      'color': const Color(0xFF60A5FA), // blue-400
      'bgColor': const Color(0xFFEFF6FF), // blue-50
    },
  ];

  final difficultyLevels = [
    {
      'id': 'beginner',
      'name': 'Beginner',
      'description': 'New to programming or this language',
      'icon': '🌱',
      'color': const Color(0xFF22C55E), // green-500
    },
    {
      'id': 'intermediate',
      'name': 'Intermediate',
      'description': 'Comfortable with basic concepts',
      'icon': '📘',
      'color': const Color(0xFF3B82F6), // blue-500
    },
    {
      'id': 'advanced',
      'name': 'Advanced',
      'description': 'Experienced and looking to master',
      'icon': '⚡',
      'color': const Color(0xFFA855F7), // purple-500
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void selectLanguage(String id) {
    selectedLanguage.value = id;
    if (currentPage.value == 0) {
      next();
    }
  }

  void selectDifficulty(String id) {
    selectedDifficulty.value = id;
    if (currentPage.value == 1) {
      next();
    }
  }

  void skip() {
    Get.offAllNamed(Routes.main);
  }

  void next() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    } else {
      handleContinue();
    }
  }

  void handleContinue() {
    if (selectedLanguage.value != null && selectedDifficulty.value != null) {
      // In production, sync with API
      Get.offAllNamed(Routes.main);
    }
  }
}
