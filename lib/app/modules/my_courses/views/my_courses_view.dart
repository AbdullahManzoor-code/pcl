import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/my_courses_controller.dart';
import '../../main/controllers/main_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../routes/app_pages.dart';

class MyCoursesView extends GetView<MyCoursesController> {
  const MyCoursesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Courses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.enrolledCourses.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refreshCourses(),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.enrolledCourses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final course = controller.enrolledCourses[index];
              return _buildCourseCard(context, course);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCourseCard(BuildContext context, course) {
    final progress = course.progress ?? 0.0;

    return AppCard(
      onTap: () => Get.toNamed(
        Routes.COURSE_DETAILS,
        arguments: {
          'course': course,
          'heroTag': 'my_courses_image_${course.id}',
        },
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Hero(
            tag: 'my_courses_image_${course.id}',
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.code,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  progress >= 1.0 ? 'Completed' : 'Continue Learning',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'You haven\'t enrolled in any courses yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your learning journey today!',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to Explore tab (MainView uses index 1 for Explore)
              // This requires finding the MainController.
              Get.find<MainController>().changePage(1);
            },
            child: const Text('Explore Courses'),
          ),
        ],
      ),
    );
  }
}
