import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcl/app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final onboardingData = [
    {
      'title': 'Interactive Learning',
      'description': 'Learn programming by doing, not just watching.',
      'icon': Icons.code,
    },
    {
      'title': 'Personalized Roadmap',
      'description': 'Get a study plan tailored to your skill level.',
      'icon': Icons.map_outlined,
    },
    {
      'title': 'Smart Assessments',
      'description': 'Track your progress with intelligent quizzes.',
      'icon': Icons.auto_graph,
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void skip() {
    Get.offAllNamed(Routes.AUTH);
  }

  void next() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Get.offAllNamed(Routes.AUTH);
    }
  }
}
