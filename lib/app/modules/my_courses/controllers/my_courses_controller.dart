import 'package:get/get.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/services/mock_api_service.dart';

class MyCoursesController extends GetxController {
  late final CourseRepository _courseRepository;

  final enrolledCourses = <Course>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _courseRepository = Get.find<CourseRepository>();
    fetchEnrolledCourses();

    // Listen to global course changes for instant sync
    final service = Get.find<MockApiService>();
    ever(service.courses, (_) => fetchEnrolledCourses());
  }

  void fetchEnrolledCourses() async {
    isLoading.value = true;
    try {
      final courses = _courseRepository.getEnrolledCourses();
      enrolledCourses.assignAll(courses);
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      Get.snackbar(
        'Error',
        'Failed to load your courses.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshCourses() => fetchEnrolledCourses();
}
