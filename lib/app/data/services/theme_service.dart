import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  final _storage = GetStorage();
  final _key = 'isDarkMode';

  // Reactive observable, default to light mode
  final RxBool isDarkModeObs = false.obs;

  ThemeService() {
    // Load persisted theme on creation
    isDarkModeObs.value = _loadThemeFromBox();
  }

  // Expose current ThemeMode based on observable
  ThemeMode get theme => isDarkModeObs.value ? ThemeMode.dark : ThemeMode.light;

  // Load stored preference
  bool _loadThemeFromBox() => _storage.read(_key) ?? false;

  // Save preference and update observable
  void _saveThemeToBox(bool isDarkMode) {
    _storage.write(_key, isDarkMode);
    isDarkModeObs.value = isDarkMode;
  }

  // Change theme and persist
  void changeThemeMode(bool isDarkMode) {
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    _saveThemeToBox(isDarkMode);
  }

  // Helper to check current mode
  bool isDarkMode() => isDarkModeObs.value;
}
