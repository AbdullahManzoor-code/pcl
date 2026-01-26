import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:get/get.dart';
import 'package:pcl/app/core/theme/app_theme.dart';
import '../controllers/main_controller.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../profile/views/profile_view.dart';
import '../../courses/views/courses_view.dart';
import '../../my_courses/views/my_courses_view.dart';

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
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
            child: NavigationBar(
              backgroundColor: AppColors.primary,
              indicatorColor: Colors.white,
              elevation: 0,
              selectedIndex: controller.currentIndex.value,
              onDestinationSelected: (index) {
                HapticUtils.selectionClick();
                controller.changePage(index);
              },
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              labelTextStyle: WidgetStateProperty.all(
                GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              height: 80.h,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: Colors.white),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: AppColors.primary,
                  ),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined, color: Colors.white),
                  selectedIcon: Icon(
                    Icons.explore_rounded,
                    color: AppColors.primary,
                  ),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_outlined, color: Colors.white),
                  selectedIcon: Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                  ),
                  label: 'My Learning',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, color: Colors.white),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
