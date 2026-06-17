import 'package:flutter_skill/flutter_skill.dart';
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

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppLogger.info('main(): bootstrap start');

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        AppLogger.fatal(
          'main(): Flutter framework error',
          details.exception,
          details.stack,
        );
      };

      ui.PlatformDispatcher.instance.onError = (error, stack) {
        AppLogger.fatal('main(): uncaught platform error', error, stack);
        return true;
      };

      AppLogger.info('main(): initializing storage');
      await GetStorage.init();

      AppLogger.info('main(): initializing services');
      final themeService = await Get.putAsync(() => ThemeService().init());
      final notificationService = await Get.putAsync(
        () => NotificationService().init(),
      );

      AppLogger.info('main(): registering API and domain services');
      Get.put<ApiAdapterService>(ApiAdapterService());
      Get.put<AuthService>(AuthService());
      Get.put<CourseService>(CourseService());
      Get.put<DashboardService>(DashboardService());
      Get.put<ExamService>(ExamService());
      // Register ReportsService lazily so it's available app-wide when needed.
      Get.lazyPut<ReportsService>(() => ReportsService(), fenix: true);

      final apiService = await Get.putAsync(() async => MockApiService());
      Get.put<CourseRepository>(CourseRepositoryImpl(apiService));
      Get.put(ValidationService());

      runApp(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return GetMaterialApp(
              title: 'Programming Learning App',
              initialRoute: AppPages.initial,
              getPages: AppPages.routes,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeService.theme,
              debugShowCheckedModeBanner: false,
              routingCallback: (routing) {
                if (routing == null) return;
                if (routing.current != routing.previous) {
                  final previousRoute = routing.previous.isEmpty
                      ? 'unknown'
                      : routing.previous;
                  AppLogger.info(
                    'main(): route $previousRoute -> ${routing.current}',
                  );
                }
              },
            );
          },
        ),
      );

      final storage = GetStorage();
      if (storage.read('isFirstLaunch') ?? true) {
        AppLogger.info(
          'main(): requesting notification permissions on first launch',
        );
        try {
          final granted = await notificationService.requestPermissions();
          AppLogger.info('main(): notification permission granted=$granted');
        } catch (error, stackTrace) {
          AppLogger.error(
            'main(): notification permission request failed',
            error,
            stackTrace,
          );
        }
        storage.write('isFirstLaunch', false);
      }

      AppLogger.info('main(): bootstrap complete');
    },
    (error, stackTrace) {
      AppLogger.fatal('main(): uncaught zone error', error, stackTrace);
    },
  );
}
