import 'package:get/get.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/haptic_utils.dart';

class CoursesController extends GetxController {
  late final CourseRepository _courseRepository;

  final courses = <Course>[].obs;
  final isLoading = true.obs;
  final isGridView = true.obs;

  // Search and Filter
  final searchText = ''.obs;
  final selectedCategory = 'All'.obs;
  final selectedDifficulty = 'All'.obs;
  final sortBy = 'Name'.obs; // Name, Progress, Rating
  final categories = <String>['All'].obs;
  final difficulties = <String>['All', 'Easy', 'Medium', 'Hard'].obs;
  final sortOptions = <String>['Name', 'Progress', 'Rating'].obs;

  List<Course> get filteredCourses {
    var filtered = courses.where((course) {
      final matchesSearch =
          course.title.toLowerCase().contains(searchText.value.toLowerCase()) ||
          course.description.toLowerCase().contains(
            searchText.value.toLowerCase(),
          );
      final matchesCategory =
          selectedCategory.value == 'All' ||
          course.category == selectedCategory.value;
      final matchesDifficulty =
          selectedDifficulty.value == 'All' ||
          course.level == selectedDifficulty.value;
      return matchesSearch && matchesCategory && matchesDifficulty;
    }).toList();

    // Apply sorting
    switch (sortBy.value) {
      case 'Progress':
        filtered.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Name':
      default:
        filtered.sort((a, b) => a.title.compareTo(b.title));
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    // In a real app, inject this properly
    _courseRepository = CourseRepositoryImpl(Get.find<MockApiService>());
    fetchCourses();
  }

  void fetchCourses() async {
    isLoading.value = true;
    try {
      final allCourses = _courseRepository.getAllCourses();
      courses.assignAll(allCourses);

      // Extract unique categories
      final distinctCategories = allCourses
          .map((c) => c.category)
          .toSet()
          .toList();
      categories.assignAll(['All', ...distinctCategories]);
    } catch (e) {
      AppLogger.error('Error fetching courses', e);
      Get.snackbar(
        'Error',
        'Failed to load courses. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
    HapticUtils.selectionClick();
  }

  void openCourse(Course course) {
    HapticUtils.lightImpact();
    Get.toNamed(Routes.courseDetails, arguments: {'course': course});
  }

  void clearFilters() {
    searchText.value = '';
    selectedCategory.value = 'All';
    selectedDifficulty.value = 'All';
    sortBy.value = 'Name';
    HapticUtils.mediumImpact();
  }
}
