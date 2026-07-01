import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pcl/app/modules/courses/controllers/courses_controller.dart';
import 'package:pcl/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:pcl/app/modules/my_courses/controllers/my_courses_controller.dart';
import 'package:pcl/app/routes/app_pages.dart';
import 'package:pcl/app/data/services/auth_service.dart';
import 'package:pcl/app/data/services/network_error_handler.dart';
import 'package:pcl/app/services/validation_service.dart';
import '../../../core/utils/app_logger.dart';
import 'package:pcl/app/data/services/course_service.dart';

class AuthController extends GetxController {
  final _validationService = Get.find<ValidationService>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLogin = true.obs;
  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final rememberMe = false.obs;
  final acceptTerms = false.obs;
  final password = ''.obs; // For password strength indicator

  // Registration optional parameters
  final selectedLanguage = Rx<String?>(null); // language_id
  final selectedExperienceLevel = Rx<String?>(null); // experience_level

  // Available options from Next.js API
  static const List<String> availableLanguages = [
    'python_3',
    'javascript_es6',
    'java_17',
    'cpp_20',
    'go_1_21',
  ];

  static const List<String> availableExperienceLevels = [
    'beginner',
    'intermediate',
    'advanced',
  ];

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('AuthController.onInit(): ready for auth flow');
    if (Get.arguments != null) {
      if (Get.arguments['language'] != null) {
        selectedLanguage.value = Get.arguments['language'];
      }
      if (Get.arguments['difficulty'] != null) {
        selectedExperienceLevel.value = Get.arguments['difficulty'];
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    AppLogger.debug('AuthController.onReady(): view attached');
  }

  @override
  void onClose() {
    AppLogger.info('AuthController.onClose(): closed');
    super.onClose();
  }

  void toggleAuthMode() {
    AppLogger.info(
      'AuthController.toggleAuthMode(): isLogin=${!isLogin.value}',
    );
    isLogin.value = !isLogin.value;
    clearControllers();
  }

  void clearControllers() {
    AppLogger.debug('AuthController.clearControllers(): clearing form inputs');
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
  }

  void login() async {
    AppLogger.info('AuthController.login(): submitted');
    final emailError = _validationService.validateEmail(emailController.text);
    
    // Only check if password is provided for login, don't run strict validation
    String? passwordError;
    if (passwordController.text.isEmpty) {
      passwordError = 'Please enter your password';
    }

    if (emailError != null || passwordError != null) {
      AppLogger.warning('AuthController.login(): validation failed');
      Get.snackbar(
        'Validation Error',
        emailError ?? passwordError!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
      );
      return;
    }

    isLoading.value = true;
    try {
      // Use real AuthService with Next.js backend
      final authService = Get.find<AuthService>();
      AppLogger.debug('AuthController.login(): calling AuthService.login');
      final user = await authService.login(
        emailController.text,
        passwordController.text,
      );

      // Handle Persistence
      final storage = GetStorage();
      storage.write('isLoggedIn', true);
      storage.write('userEmail', user.email);
      storage.write('userName', user.name ?? user.email ?? 'User');
      storage.write('userId', user.id);
      storage.write('userLanguage', user.lastActiveLanguage);
      storage.write(
        'isFirstLaunch',
        false,
      ); // No longer first launch after successful login

      AppLogger.info('AuthController.login(): success userId=${user.id}');
      Get.snackbar(
        'Success',
        'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
      );

      // Process pending enrollment from registration
      final pendingLang = storage.read('pending_enrollment_lang');
      final pendingLevel = storage.read('pending_enrollment_level');

      if (pendingLang != null) {
        try {
          AppLogger.debug('AuthController.login(): Processing pending enrollment for language $pendingLang');
          final courseService = Get.find<CourseService>();
          await courseService.enrollInLanguage(pendingLang, pendingLevel ?? 'beginner');
          storage.remove('pending_enrollment_lang');
          storage.remove('pending_enrollment_level');
          AppLogger.info('AuthController.login(): Successfully auto-enrolled');
        } catch (e) {
          AppLogger.warning('AuthController.login(): Failed to process pending enrollment', e);
        }
      }

      // Force refresh data for main controllers if they are already in memory
      try {
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchData();
        }
        if (Get.isRegistered<MyCoursesController>()) {
          Get.find<MyCoursesController>().fetchEnrolledCourses();
        }
        if (Get.isRegistered<CoursesController>()) {
          Get.find<CoursesController>().fetchCourses();
        }
      } catch (e) {
        AppLogger.warning(
          'AuthController.login(): could not refresh controllers',
          e,
        );
      }

      Get.offAllNamed(Routes.main);
    } on NetworkException catch (e, stackTrace) {
      AppLogger.error('AuthController.login(): network failure', e, stackTrace);
      Get.snackbar(
        'Login Failed',
        e.getUserMessage(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        duration: const Duration(seconds: 4),
      );
    } on Exception catch (e, stackTrace) {
      AppLogger.error(
        'AuthController.login(): unexpected failure',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Login Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void socialLogin(String provider) async {
    AppLogger.info('AuthController.socialLogin(): provider=$provider');
    isLoading.value = true;
    try {
      // TODO: Implement social login with Next.js backend when API endpoint available
      Get.snackbar(
        'Not Available',
        '$provider login coming soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthController.socialLogin(): provider=$provider failed',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Error',
        '$provider login failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Google Sign-In
  void signInWithGoogle() async {
    AppLogger.info('AuthController.signInWithGoogle(): submitted');
    isGoogleLoading.value = true;
    try {
      // TODO: Implement Google Sign-In with Next.js backend when API endpoint available
      Get.snackbar(
        'Not Available',
        'Google sign-in coming soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthController.signInWithGoogle(): failed',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Error',
        'Google sign-in failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void register() async {
    AppLogger.info('AuthController.register(): submitted');
    final nameError = _validationService.validateName(nameController.text);
    final emailError = _validationService.validateEmail(emailController.text);
    final passwordError = _validationService.validatePassword(
      passwordController.text,
    );
    final confirmError = _validationService.validateConfirmPassword(
      passwordController.text,
      confirmPasswordController.text,
    );

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmError != null) {
      AppLogger.warning('AuthController.register(): validation failed');
      Get.snackbar(
        'Validation Error',
        nameError ?? emailError ?? passwordError ?? confirmError!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
      );
      return;
    }

    isLoading.value = true;
    try {
      // Use real AuthService with Next.js backend
      final authService = Get.find<AuthService>();
      AppLogger.debug(
        'AuthController.register(): calling AuthService.register',
      );
      final user = await authService.register(
        emailController.text,
        passwordController.text,
        languageId: selectedLanguage.value,
        experienceLevel: selectedExperienceLevel.value,
      );
      
      // Save language for post-login auto-enrollment since backend doesn't populate languages_learning during registration
      // The actual enrollment will happen after successful login when we have a valid token
      if (selectedLanguage.value != null) {
        try {
          AppLogger.debug('AuthController.register(): Saving language for post-login auto-enroll');
          final storage = GetStorage();
          storage.write('pending_enrollment_lang', selectedLanguage.value);
          storage.write('pending_enrollment_level', selectedExperienceLevel.value ?? 'beginner');
        } catch (e) {
          AppLogger.warning('AuthController.register(): Failed to save pending auto-enroll', e);
        }
      }

      // Handle Persistence
      final storage = GetStorage();
      storage.write(
        'isFirstLaunch',
        false,
      ); // No longer first launch after successful registration

      AppLogger.info('AuthController.register(): success userId=${user.id}');
      Get.snackbar(
        'Success',
        'Account created successfully. Please log in.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
      );

      Get.offAllNamed(Routes.auth);
    } on NetworkException catch (e, stackTrace) {
      AppLogger.error(
        'AuthController.register(): network failure',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Registration Failed',
        e.getUserMessage(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        duration: const Duration(seconds: 4),
      );
    } on Exception catch (e, stackTrace) {
      AppLogger.error(
        'AuthController.register(): unexpected failure',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Registration Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void sendResetEmail() async {
    AppLogger.info('AuthController.sendResetEmail(): submitted');
    if (emailController.text.isEmpty) {
      AppLogger.warning('AuthController.sendResetEmail(): email missing');
      Get.snackbar('Error', 'Please enter your email');
      return;
    }
    isLoading.value = true;
    try {
      // TODO: Implement password reset with Next.js backend
      Get.toNamed('/reset-email-sent');
    } catch (e, stackTrace) {
      AppLogger.error('AuthController.sendResetEmail(): failed', e, stackTrace);
      Get.snackbar('Error', 'Failed to send reset email');
    } finally {
      isLoading.value = false;
    }
  }

  void handlePasswordReset() async {
    AppLogger.info('AuthController.handlePasswordReset(): submitted');
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      AppLogger.warning('AuthController.handlePasswordReset(): missing fields');
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }
    isLoading.value = true;
    try {
      // TODO: Use changePassword if we have the old password
      // For now, just clear fields
      AppLogger.info(
        'AuthController.handlePasswordReset(): navigating to auth after reset',
      );
      Get.offAllNamed(Routes.auth);
      Get.snackbar('Success', 'Password reset successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthController.handlePasswordReset(): failed',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Failed to reset password');
    } finally {
      isLoading.value = false;
    }
  }

  void sendVerificationEmail() async {
    AppLogger.info('AuthController.sendVerificationEmail(): submitted');
    isLoading.value = true;
    try {
      // TODO: Implement email verification with backend API
      AppLogger.info(
        'AuthController.sendVerificationEmail(): navigating to verification sent screen',
      );
      Get.toNamed('/verification-sent');
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthController.sendVerificationEmail(): failed',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Failed to send verification email');
    } finally {
      isLoading.value = false;
    }
  }

  void checkVerificationStatus() async {
    AppLogger.info('AuthController.checkVerificationStatus(): submitted');
    isLoading.value = true;
    try {
      // TODO: Implement verification status check with backend API
      AppLogger.info(
        'AuthController.checkVerificationStatus(): verified, routing to onboarding',
      );
      Get.offAllNamed(Routes.onboarding);
      Get.snackbar('Success', 'Email verified successfully');
    } catch (e, stackTrace) {
      AppLogger.warning(
        'AuthController.checkVerificationStatus(): not verified yet',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Email not verified yet');
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout user - clears session and redirects to login
  Future<void> logout() async {
    AppLogger.info('AuthController.logout(): submitted');
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      AppLogger.debug('AuthController.logout(): calling AuthService.logout');
      await authService.logout();

      // Clear storage
      final storage = GetStorage();
      storage.remove('isLoggedIn');
      storage.remove('userEmail');
      storage.remove('userName');
      storage.remove('userId');
      storage.remove('userLanguage');

      AppLogger.info('AuthController.logout(): success');
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
      );

      // Navigate to login
      Get.offAllNamed(Routes.auth);
    } on Exception catch (e, stackTrace) {
      AppLogger.error('AuthController.logout(): failed', e, stackTrace);
      Get.snackbar(
        'Logout Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
