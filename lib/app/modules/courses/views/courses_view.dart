import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../../core/widgets/enhanced_navigation.dart';
import '../../../core/utils/haptic_utils.dart';
import '../controllers/courses_controller.dart';
import '../../../data/models/course_model.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../routes/app_pages.dart';

class CoursesView extends GetView<CoursesController> {
  const CoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildSearchAndFilters(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredCourses.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.filteredCourses.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final course = controller.filteredCourses[index];
                    return _buildCourseCard(context, course, index);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedTapScale(
        onTap: () => _showCreatePathSheet(context),
        child: Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28.sp),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Courses',
            style: GoogleFonts.outfit(
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          AnimatedTapScale(
            onTap: () => _showFilterSheet(context),
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: DebouncedSearchBar(
            hintText: 'Search for language, topic...',
            onSearch: (val) => controller.searchText.value = val,
          ),
        ),
        SizedBox(
          height: 44.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Obx(() {
                final isSelected =
                    controller.selectedCategory.value == category;
                return _buildCategoryChip(context, category, isSelected);
              });
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    bool isSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getLanguageColor(label);

    return AnimatedTapScale(
      onTap: () {
        HapticUtils.selectionClick();
        controller.selectedCategory.value = label;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _getLanguageColor(course.category);

    return SlideInAnimation(
      index: index,
      child: AnimatedTapScale(
        onTap: () => Get.toNamed(Routes.courseDetails, arguments: course),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.2),
                      accentColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.code_rounded,
                  color: accentColor,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.category.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      course.title,
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildBadge(
                          Icons.star_rounded,
                          course.rating.toString(),
                          Colors.amber,
                        ),
                        SizedBox(width: 12.w),
                        _buildBadge(
                          Icons.signal_cellular_alt_rounded,
                          course.level,
                          Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No courses found',
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search or filters',
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    HapticUtils.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Filter Courses',
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Difficulty Level',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildFilterOptions(['Beginner', 'Intermediate', 'Advanced']),
            SizedBox(height: 24.h),
            Text(
              'Sort By',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildFilterOptions(['Newest', 'Popular', 'Highest Rated']),
            SizedBox(height: 32.h),
            LoadingButton(
              text: 'Apply Filters',
              isFullWidth: true,
              onPressed: () {
                Get.back();
                HapticUtils.mediumImpact();
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptions(List<String> options) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: options.map((opt) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(opt, style: GoogleFonts.inter(fontSize: 13.sp)),
        );
      }).toList(),
    );
  }

  void _showCreatePathSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    HapticUtils.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Learning Path',
                      style: GoogleFonts.outfit(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Customize your AI-generated journey',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Language Selection
                    _buildSectionHeader(
                      'Select Language',
                      Icons.language_rounded,
                    ),
                    SizedBox(height: 16.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: controller.languages.length,
                      itemBuilder: (context, index) {
                        final lang = controller.languages[index];
                        return _buildLanguageOption(context, lang);
                      },
                    ),
                    SizedBox(height: 32.h),

                    // Difficulty Selection
                    _buildSectionHeader(
                      'Target Difficulty',
                      Icons.speed_rounded,
                    ),
                    SizedBox(height: 16.h),
                    Obx(
                      () => _buildSegmentedControl(
                        controller.creationDifficulties,
                        controller.creationSelectedDifficulty.value,
                        (val) =>
                            controller.creationSelectedDifficulty.value = val,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Intensity Selection
                    _buildSectionHeader('Intensity & Pace', Icons.bolt_rounded),
                    SizedBox(height: 16.h),
                    Obx(
                      () => _buildSegmentedControl(
                        controller.creationIntensities,
                        controller.creationSelectedIntensity.value,
                        (val) =>
                            controller.creationSelectedIntensity.value = val,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Path Guidance Card
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Path Guide',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Obx(
                            () => Text(
                              Get.find<MockApiService>()
                                  .generateCourseDescription(
                                    language: controller.selectedLanguage.value,
                                    level: controller
                                        .creationSelectedDifficulty
                                        .value,
                                    intensity: controller
                                        .creationSelectedIntensity
                                        .value,
                                  ),
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Obx(
                () => LoadingButton(
                  text: 'Generate Path',
                  isLoading: controller.isCreating.value,
                  isFullWidth: true,
                  onPressed: () {
                    Get.back();
                    controller.createLearningPath();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl(
    List<String> options,
    String selected,
    Function(String) onSelect,
  ) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          return Expanded(
            child: AnimatedTapScale(
              onTap: () {
                HapticUtils.selectionClick();
                onSelect(opt);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    opt,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, Map<String, String> lang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getLanguageColor(lang['name']!);

    return Obx(() {
      final isSelected = controller.selectedLanguage.value == lang['name'];
      return AnimatedTapScale(
        onTap: () {
          HapticUtils.selectionClick();
          controller.selectedLanguage.value = lang['name']!;
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(lang['icon']!, style: TextStyle(fontSize: 24.sp)),
              SizedBox(height: 8.h),
              Text(
                lang['name']!,
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? color
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Color _getLanguageColor(String label) {
    final title = label.toLowerCase();
    if (title.contains('python')) return const Color(0xFF3B82F6);
    if (title.contains('javascript')) return const Color(0xFFF59E0B);
    if (title.contains('java')) return const Color(0xFFEF4444);
    if (title.contains('c++')) return const Color(0xFFA855F7);
    if (title.contains('go')) return const Color(0xFF06B6D4);
    if (title.contains('typescript')) return const Color(0xFF60A5FA);
    return AppColors.primary;
  }
}
