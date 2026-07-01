import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcl/app/data/models/course_api_models.dart';
import '../controllers/practice_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/widgets/shimmer_widgets.dart';

class PracticeView extends GetView<PracticeController> {
  const PracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const PracticeShimmer();
        }
        if (controller.availableTopics.isEmpty) {
          return const Center(child: Text('No topics available for practice.'));
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, isDark)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 16.h),
                  _buildInfoCard(context),
                  SizedBox(height: 24.h),
                  _buildSectionHeader('Select Topic', Icons.track_changes_rounded),
                  SizedBox(height: 16.h),
                  _buildTopicSelector(context),
                  SizedBox(height: 32.h),
                  _buildSectionHeader(
                    'Difficulty Level',
                    Icons.settings_input_component_rounded,
                  ),
                  SizedBox(height: 16.h),
                  _buildDifficultySlider(context),
                  SizedBox(height: 32.h),
                  _buildSectionHeader(
                    'Question Count',
                    Icons.format_list_numbered_rounded,
                  ),
                  SizedBox(height: 16.h),
                  _buildQuestionCountPicker(context),
                  SizedBox(height: 32.h),
                  _buildSectionHeader('Practice Mode', Icons.bolt_rounded),
                  SizedBox(height: 16.h),
                  _buildModeSelector(context),
                  SizedBox(height: 32.h),
                  _buildStartButton(context),
                  SizedBox(height: 48.h),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  AppColors.darkBg,
                  AppColors.primary.withOpacity(0.30),
                  AppColors.darkBg,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.practiceGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // decorative circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // top bar row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          controller.fetchAvailableTopics();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // icon emblem
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Practice',
                    style: GoogleFonts.outfit(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Configure your session & start',
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.75),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // stat pills
                  Obx(() => Row(
                    children: [
                      _buildHeaderPill(
                        Icons.track_changes_rounded,
                        '${controller.availableTopics.length} Topics',
                      ),
                      SizedBox(width: 10.w),
                      _buildHeaderPill(
                        Icons.format_list_numbered_rounded,
                        '${controller.selectedQuestionCount.value} Questions',
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderPill(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
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

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Power Up Your Learning',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Customized sessions based on your mastery data.',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 40.sp),
        ],
      ),
    );
  }

  Widget _buildTopicSelector(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<CurriculumTopic>(
            value: controller.selectedTopic.value,
            isExpanded: true,
            hint: const Text('Select a topic to practice'),
            onChanged: (topic) {
              HapticUtils.selectionClick();
              controller.selectTopic(topic);
            },
            items: controller.availableTopics.map((topic) {
              return DropdownMenuItem(
                value: topic,
                child: Text(topic.name, style: GoogleFonts.inter()),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySlider(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Target Difficulty',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                Text(
                  controller.difficultyLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: controller.difficultyColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: controller.difficultyColor,
                thumbColor: controller.difficultyColor,
                overlayColor: controller.difficultyColor.withOpacity(0.2),
              ),
              child: Slider(
                value: controller.difficulty.value,
                min: 0.3,
                max: 1.0,
                divisions: 7,
                onChanged: controller.setDifficulty,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Easy',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
                Text(
                  'Expert',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCountPicker(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.questionCounts.map((count) {
            final isSelected = controller.selectedQuestionCount.value == count;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ChoiceChip(
                backgroundColor: AppColors.lightTextTertiary,
                label: Text('$count Qs'),
                selected: isSelected,
                onSelected: (_) {
                  HapticUtils.lightImpact();
                  controller.setQuestionCount(count);
                },
                selectedColor: AppColors.primary,
                labelStyle: GoogleFonts.inter(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context) {
    return Obx(
      () => Column(
        children: controller.modes.map((mode) {
          final isSelected = controller.selectedMode.value == mode['id'];
          final String modeId = mode['id'] as String;
          final Color color;
          switch (modeId) {
            case 'practice':
              color = Colors.blue;
              break;
            case 'exam':
              color = Colors.red;
              break;
            case 'review':
              color = Colors.green;
              break;
            default:
              color = Colors.grey;
          }

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: InkWell(
              onTap: () {
                HapticUtils.selectionClick();
                controller.selectMode(mode['id'] as String);
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.1)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(mode['icon'] as IconData, color: color),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode['name'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? color : null,
                            ),
                          ),
                          Text(
                            mode['description'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: color),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Obx(
      () => NextButton(
        text: 'Start Practice Session',
        onPressed: controller.selectedTopic.value == null
            ? null
            : () {
                HapticUtils.mediumImpact();
                controller.startPractice();
              },
        isFullWidth: true,
        color: AppColors.primary,
      ),
    );
  }
}
