import 'package:get/get.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../routes/app_pages.dart';

class CoursesController extends GetxController {
  late final CourseRepository _courseRepository;

  final courses = <Course>[].obs;
  final isLoading = true.obs;
  final isGridView = true.obs;

  // Search and Filter
  final searchText = ''.obs;
  final selectedCategory = 'All'.obs;
  final categories = <String>['All'].obs;

  List<Course> get filteredCourses {
    return courses.where((course) {
      final matchesSearch =
          course.title.toLowerCase().contains(searchText.value.toLowerCase()) ||
          course.description.toLowerCase().contains(
            searchText.value.toLowerCase(),
          );
      final matchesCategory =
          selectedCategory.value == 'All' ||
          course.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
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
      print('Error fetching courses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  void openCourse(Course course) {
    Get.toNamed(Routes.COURSE_DETAILS, arguments: course);
  }
}
