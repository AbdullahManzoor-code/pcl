import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Theme controller for managing app theme
class ThemeController extends GetxController {
  final _storage = GetStorage();
  static const String _themeKey = 'app_theme_mode';

  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _storage.read(_themeKey);
    if (savedTheme != null) {
      isDarkMode.value = savedTheme == 'dark';
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _saveTheme();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void setTheme(bool dark) {
    isDarkMode.value = dark;
    _saveTheme();
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  }

  void _saveTheme() {
    _storage.write(_themeKey, isDarkMode.value ? 'dark' : 'light');
  }

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}
