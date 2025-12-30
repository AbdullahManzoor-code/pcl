import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../courses/controllers/courses_controller.dart';
import '../../my_courses/controllers/my_courses_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    // Lazily put child controllers here or ensure they are bound by their own bindings if used as Pages
    // For IndexedStack usage, it's often good to have them available.
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<CoursesController>(() => CoursesController());
    Get.lazyPut<MyCoursesController>(() => MyCoursesController());
  }
}
