import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  final _storage = GetStorage();
  final _key = 'isDarkMode';

  // Use RxBool to make it reactive for Obx
  late final RxBool isDarkModeObs;

  Future<ThemeService> init() async {
    isDarkModeObs = _loadThemeFromBox().obs;
    return this;
  }

  /// Get ThemeMode based on current state
  ThemeMode get theme => isDarkModeObs.value ? ThemeMode.dark : ThemeMode.light;

  /// Load isDarkMode from local storage
  bool _loadThemeFromBox() => _storage.read(_key) ?? false;

  /// Save isDarkMode to local storage and update observable
  void _saveThemeToBox(bool isDarkMode) {
    _storage.write(_key, isDarkMode);
    isDarkModeObs.value = isDarkMode;
  }

  /// Change theme to a specific mode
  void changeThemeMode(bool isDarkMode) {
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    _saveThemeToBox(isDarkMode);
  }

  /// Check if the current theme is dark (reactive)
  bool isDarkMode() => isDarkModeObs.value;
}
