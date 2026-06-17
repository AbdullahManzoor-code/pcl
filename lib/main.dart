/// Main entry point for the Programming Learning App
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pcl/app/data/services/mock_api_service.dart';
import 'package:pcl/app/data/services/auth_service.dart';
import 'package:pcl/app/data/services/api_adapter_service.dart';
import 'package:pcl/app/data/services/notification_service.dart';
import 'package:pcl/app/data/services/theme_service.dart';
import 'package:pcl/app/data/services/course_service.dart';
import 'package:pcl/app/data/services/dashboard_service.dart';
import 'package:pcl/app/data/services/exam_service.dart';
import 'package:pcl/app/data/services/reports_service.dart';
import 'package:pcl/app/data/repositories/course_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/utils/app_logger.dart';
import 'app/services/validation_service.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        final ThemeService themeService = Get.find<ThemeService>();
        return GetMaterialApp(
          title: 'Programming Learning App',
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.theme,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

Future<void> main() async {
  // Register core services and initialize ThemeService
  AppLogger.info('main(): registering API and domain services');
  // Initialize ThemeService with stored value
  final themeService = Get.put<ThemeService>(ThemeService(), permanent: true);
  Get.put<ApiAdapterService>(ApiAdapterService());
  Get.put<AuthService>(AuthService());
  Get.put<CourseService>(CourseService());
  Get.put<DashboardService>(DashboardService());
  Get.put<ExamService>(ExamService());
  // Register NotificationService
  Get.put<NotificationService>(NotificationService());
  // Lazy register ReportsService
  Get.lazyPut<ReportsService>(() => ReportsService(), fenix: true);

  // Initialize mock API and repositories
  final apiService = await Get.putAsync<MockApiService>(
    () async => MockApiService(),
  );
  Get.put<CourseRepository>(CourseRepositoryImpl(apiService));
  Get.put(ValidationService());

  // Global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.fatal(
      'main(): Flutter framework error',
      details.exception,
      details.stack,
    );
  };
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.fatal('main(): uncaught async error', error, stack);
    return true;
  };

  // Notification permissions on first launch
  final storage = GetStorage();
  if (storage.read('isFirstLaunch') ?? true) {
    AppLogger.info(
      'main(): requesting notification permissions on first launch',
    );
    try {
      final notificationService = Get.find<NotificationService>();
      final granted = await notificationService.requestPermissions();
      AppLogger.info('main(): notification permission granted=$granted');
    } catch (e, st) {
      AppLogger.error('main(): notification permission request failed', e, st);
    }
    storage.write('isFirstLaunch', false);
  }

  // Run the app
  runApp(const AppEntry());

  AppLogger.info('main(): bootstrap complete');
}

// Simple MyApp wrapper for widget tests
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const AppEntry();
}

// Simple CounterPage used in widget tests
class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;
  void _increment() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Text('$_counter', style: const TextStyle(fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
