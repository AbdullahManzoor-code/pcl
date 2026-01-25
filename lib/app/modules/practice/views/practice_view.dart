import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/practice_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/utils/haptic_utils.dart';

class PracticeView extends GetView<PracticeController> {
  const PracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configure Practice',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildInfoCard(context),
            SizedBox(height: 24.h),
            _buildSectionHeader('Select Concept', Icons.track_changes_rounded),
            SizedBox(height: 16.h),
            _buildConceptGrid(context),
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
          ],
        ),
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
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
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
                    color: Colors.white.withOpacity(0.1),
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

  Widget _buildConceptGrid(BuildContext context) {
    return Obx(
      () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.25,
        ),
        itemCount: controller.concepts.length,
        itemBuilder: (context, index) {
          final concept = controller.concepts[index];
          final isSelected = controller.selectedConcept.value == concept['id'];
          final colors = concept['color'] as List<Color>;

          return GestureDetector(
            onTap: () {
              HapticUtils.selectionClick();
              controller.selectConcept(concept['id'] as String);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? colors[0] : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? colors[0]
                      : Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors[0].withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    concept['icon'] as IconData,
                    color: isSelected ? Colors.white : colors[0],
                    size: 28.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    concept['name'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                overlayColor: controller.difficultyColor.withOpacity(0.1),
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
          final color = mode['color'] as Color;

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
                        color: color.withOpacity(0.1),
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
        onPressed: controller.selectedConcept.value == null
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
