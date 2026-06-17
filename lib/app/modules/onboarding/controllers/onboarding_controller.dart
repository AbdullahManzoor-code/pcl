import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pcl/app/core/theme/app_theme.dart';
import 'package:pcl/app/routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  // Selection states
  final selectedLanguage = RxnString();
  final selectedDifficulty = RxnString();

  // Onboarding Slides Data
  final tutorialSlides = [
    {
      'title': 'Learn with AI',
      'subtitle':
          'Personalized learning paths tailored to your speed and goals.',
      'image':
          'https://ouch-cdn2.icons8.com/V-g-x_K-S_m_X_v_o_S_M_z_X.png', // Mock 3D Illustration
      'color': AppColors.tutorial1,
    },
    {
      'title': 'Master Coding',
      'subtitle':
          'Practical exercises and real-world projects to build your portfolio.',
      'image': 'https://ouch-cdn2.icons8.com/P_V_C-8S_v_r_W_l_j_X_o_M_z_X.png',
      'color': AppColors.tutorial2,
    },
    {
      'title': 'Track Progress',
      'subtitle': 'Detailed analytics and insights into your learning journey.',
      'image': 'https://ouch-cdn2.icons8.com/X-v_o_S_M_z_X_v_o_S_M_z_X.png',
      'color': AppColors.tutorial3,
    },
  ];

  final languages = [
    {
      'id': 'python_3',
      'name': 'Python',
      'version': '3.11+',
      'logo': 'python', // Use icons or asset paths
      'description': 'Perfect for beginners, data science, and web development',
      'color': AppColors.python,
      'bgColor': AppColors.python.withOpacity(0.05),
    },
    {
      'id': 'javascript_es6',
      'name': 'JavaScript',
      'version': 'ES6+',
      'logo': 'javascript',
      'description': 'Essential for web development and modern applications',
      'color': AppColors.javascript,
      'bgColor': AppColors.javascript.withOpacity(0.05),
    },
    {
      'id': 'java_17',
      'name': 'Java',
      'version': '17 LTS',
      'logo': 'java',
      'description': 'Enterprise applications and Android development',
      'color': AppColors.java,
      'bgColor': AppColors.java.withOpacity(0.05),
    },
    {
      'id': 'cpp_20',
      'name': 'C++',
      'version': 'C++20',
      'logo': 'cpp',
      'description': 'High-performance systems and game development',
      'color': AppColors.cpp,
      'bgColor': AppColors.cpp.withOpacity(0.05),
    },
    {
      'id': 'go_1_21',
      'name': 'Go',
      'version': '1.21+',
      'logo': 'go',
      'description': 'Cloud services, microservices, and concurrent systems',
      'color': AppColors.go,
      'bgColor': AppColors.go.withOpacity(0.05),
    },
    {
      'id': 'typescript',
      'name': 'TypeScript',
      'version': '5.0+',
      'logo': 'typescript',
      'description': 'Type-safe JavaScript for large-scale applications',
      'color': AppColors.typescript,
      'bgColor': AppColors.typescript.withOpacity(0.05),
    },
  ];

  final difficultyLevels = [
    {
      'id': 'beginner',
      'name': 'Beginner',
      'description': 'New to programming or this language',
      'icon': '🌱',
      'color': AppColors.success,
    },
    {
      'id': 'intermediate',
      'name': 'Intermediate',
      'description': 'Comfortable with basic concepts',
      'icon': '📘',
      'color': AppColors.primary,
    },
    {
      'id': 'advanced',
      'name': 'Advanced',
      'description': 'Experienced and looking to master',
      'icon': '⚡',
      'color': AppColors.violet600,
    },
  ];

  void onPageChanged(int index) {
    AppLogger.debug('OnboardingController.onPageChanged(): index=$index');
    currentPage.value = index;
  }

  void selectLanguage(String id) {
    AppLogger.info('OnboardingController.selectLanguage(): languageId=$id');
    selectedLanguage.value = id;
  }

  void selectDifficulty(String id) {
    AppLogger.info('OnboardingController.selectDifficulty(): difficulty=$id');
    selectedDifficulty.value = id;
  }

  void skip() {
    AppLogger.warning('OnboardingController.skip(): skipping onboarding');
    final storage = GetStorage();
    storage.write('isFirstLaunch', false);
    Get.offAllNamed(Routes.main);
  }

  void next() {
    AppLogger.debug(
      'OnboardingController.next(): currentPage=${currentPage.value}',
    );
    if (currentPage.value < 6) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    } else {
      handleContinue();
    }
  }

  void handleContinue() {
    if (selectedLanguage.value != null && selectedDifficulty.value != null) {
      AppLogger.info(
        'OnboardingController.handleContinue(): language=${selectedLanguage.value}, difficulty=${selectedDifficulty.value}',
      );
      // storage.write('isFirstLaunch', false);
      Get.toNamed(Routes.register);
    } else {
      AppLogger.warning(
        'OnboardingController.handleContinue(): selection incomplete',
      );
      Get.snackbar(
        'Requirement',
        'Please select a language and difficulty to proceed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
