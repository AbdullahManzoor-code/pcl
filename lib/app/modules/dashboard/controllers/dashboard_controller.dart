import 'package:get/get.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../routes/app_pages.dart';

class DashboardController extends GetxController {
  late final CourseRepository _courseRepository;

  final stats = <String, dynamic>{}.obs;
  final enrolledCourses = <Course>[].obs;
  final completedCourses = <Course>[].obs;
  final recommendedCourses = <Course>[].obs;
  final isLoading = true.obs;
  final aiEvaluation = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _courseRepository = CourseRepositoryImpl(Get.find<MockApiService>());
    fetchData();

    // Listen to global course changes for instant sync
    final service = Get.find<MockApiService>();
    ever(service.courses, (_) => fetchData());
  }

  void fetchData() async {
    isLoading.value = true;
    try {
      final service = Get.find<MockApiService>();
      stats.assignAll(service.getUserStats());

      enrolledCourses.value = _courseRepository.getEnrolledCourses();
      completedCourses.value = _courseRepository.getCompletedCourses();
      recommendedCourses.value = _courseRepository.getRecommendedCourses();

      if (service.lastEvaluation.isNotEmpty) {
        aiEvaluation.assignAll(service.lastEvaluation);
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      Get.snackbar(
        'Error',
        'Could not load your dashboard data. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToRecommendation() {
    if (aiEvaluation.isEmpty) return;

    final courseId = aiEvaluation['course_id'];
    if (courseId == null) return;

    // Find course in our lists to get the full model
    final course =
        enrolledCourses.firstWhereOrNull((c) => c.id == courseId) ??
        recommendedCourses.firstWhereOrNull((c) => c.id == courseId);

    if (course != null) {
      Get.toNamed(Routes.COURSE_DETAILS, arguments: {'course': course});
    } else {
      // Fallback: try to fetch by ID if not in lists (mocked as simple navigation)
      Get.snackbar('Navigation', 'Redirecting to related course...');
      // In a real app: await _courseRepository.getCourseById(courseId)
    }
  }

  void openCourse(Course course) {
    // Navigate with model. Arguments can be the model object.
    // Ensure receiver handles it.
    Get.toNamed(Routes.COURSE_DETAILS, arguments: course);
  }
}
