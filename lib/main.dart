import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pcl/app/data/services/mock_api_service.dart';
import 'package:pcl/app/data/services/notification_service.dart';
import 'package:pcl/app/data/services/theme_service.dart';
import 'package:pcl/app/data/repositories/course_repository.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage
  await GetStorage.init();

  // Initialize Services
  final themeService = await Get.putAsync(() => ThemeService().init());
  final notificationService = await Get.putAsync(
    () => NotificationService().init(),
  );
  final apiService = await Get.putAsync(() async => MockApiService());
  Get.put<CourseRepository>(CourseRepositoryImpl(apiService));

  runApp(
    GetMaterialApp(
      title: "Programming Learning App",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.theme,
      debugShowCheckedModeBanner: false,
    ),
  );

  // Request notification permission on first open
  final storage = GetStorage();
  if (storage.read('isFirstLaunch') ?? true) {
    await notificationService.requestPermissions();
    storage.write('isFirstLaunch', false);
  }
}
