import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../courses/controllers/courses_controller.dart';
import '../../my_courses/controllers/my_courses_controller.dart';
import '../../practice/controllers/practice_controller.dart';
import '../../analytics/controllers/analytics_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<CoursesController>(() => CoursesController());
    Get.lazyPut<MyCoursesController>(() => MyCoursesController());
    Get.lazyPut<PracticeController>(() => PracticeController());
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
  }
}
