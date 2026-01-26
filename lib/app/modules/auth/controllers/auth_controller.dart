import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pcl/app/routes/app_pages.dart';
import 'package:pcl/app/data/services/mock_api_service.dart';
import 'package:pcl/app/services/validation_service.dart';

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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleAuthMode() {
    isLogin.value = !isLogin.value;
    clearControllers();
  }

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
  }

  void login() async {
    final emailError = _validationService.validateEmail(emailController.text);
    final passwordError = _validationService.validatePassword(
      passwordController.text,
    );

    if (emailError != null || passwordError != null) {
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
      final authService = Get.find<MockApiService>();
      final userData = await authService.login(
        emailController.text,
        passwordController.text,
      );

      // Handle Persistence
      final storage = GetStorage();
      storage.write('isLoggedIn', true);
      storage.write('userEmail', emailController.text);
      storage.write('userName', userData['name'] ?? 'User');

      Get.offAllNamed(
        Routes.main,
      ); // Changed from onboarding to main for smoother mock flow
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void socialLogin(String provider) async {
    isLoading.value = true;
    try {
      final authService = Get.find<MockApiService>();
      await authService.socialLogin(provider);
      Get.offAllNamed(Routes.main);
    } catch (e) {
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
    isGoogleLoading.value = true;
    try {
      final authService = Get.find<MockApiService>();
      final userData = await authService.socialLogin('google');

      // Save user data
      final storage = GetStorage();
      storage.write('isLoggedIn', true);
      storage.write('userEmail', userData['email'] ?? 'user@example.com');
      storage.write('userName', userData['name'] ?? 'User');

      Get.offAllNamed(Routes.main);
    } catch (e) {
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
      Get.snackbar(
        'Validation Error',
        nameError ?? emailError ?? passwordError ?? confirmError!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
      );
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Mock API delay
    isLoading.value = false;

    // Mock Success
    final storage = GetStorage();
    storage.write('isLoggedIn', true);
    storage.write('userName', nameController.text);
    storage.write('userEmail', emailController.text);

    // Update user in MockApiService
    final authService = Get.find<MockApiService>();
    authService.updateUserName(nameController.text);

    Get.offAllNamed(Routes.assessment);
  }

  void sendResetEmail() async {
    if (emailController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your email');
      return;
    }
    isLoading.value = true;
    try {
      final authService = Get.find<MockApiService>();
      await authService.sendPasswordReset(emailController.text);
      Get.toNamed('/reset-email-sent');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reset email');
    } finally {
      isLoading.value = false;
    }
  }

  void handlePasswordReset() async {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }
    isLoading.value = true;
    try {
      final authService = Get.find<MockApiService>();
      await authService.resetPassword(passwordController.text);
      Get.offAllNamed(Routes.auth);
      Get.snackbar('Success', 'Password reset successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reset password');
    } finally {
      isLoading.value = false;
    }
  }

  void sendVerificationEmail() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock delay
      Get.toNamed('/verification-sent');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send verification email');
    } finally {
      isLoading.value = false;
    }
  }

  void checkVerificationStatus() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock delay
      Get.offAllNamed(Routes.onboarding);
      Get.snackbar('Success', 'Email verified successfully');
    } catch (e) {
      Get.snackbar('Error', 'Email not verified yet');
    } finally {
      isLoading.value = false;
    }
  }
}
