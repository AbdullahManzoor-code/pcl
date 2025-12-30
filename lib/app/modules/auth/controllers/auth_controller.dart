import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pcl/app/routes/app_pages.dart';
import 'package:pcl/app/data/services/mock_api_service.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLogin = true.obs;
  final isLoading = false.obs;

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
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final authService = Get.find<MockApiService>();
      await authService.login(emailController.text, passwordController.text);
      Get.offAllNamed(Routes.LANGUAGE_SELECTION);
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
      Get.offAllNamed(Routes.MAIN);
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

  void register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Mock API delay
    isLoading.value = false;

    // Mock Success
    Get.offAllNamed(Routes.ONBOARDING);
  }
}
