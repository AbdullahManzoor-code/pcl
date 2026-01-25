import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../profile/views/profile_view.dart';
import '../../courses/views/courses_view.dart';
import '../../my_courses/views/my_courses_view.dart';
import '../../practice/views/practice_view.dart';
import '../../analytics/views/analytics_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            DashboardView(),
            CoursesView(),
            MyCoursesView(),
            ProfileView(),
            PracticeView(),
            AnalyticsView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: (index) {
            HapticUtils.selectionClick();
            controller.changePage(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school_rounded),
              label: 'Courses',
            ),
            // NavigationDestination(
            //   icon: Icon(Icons.fitness_center_outlined),
            //   selectedIcon: Icon(Icons.fitness_center_rounded),
            //   label: 'Practice',
            // ),
            // NavigationDestination(
            //   icon: Icon(Icons.analytics_outlined),
            //   selectedIcon: Icon(Icons.analytics_rounded),
            //   label: 'Stats',
            // ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
