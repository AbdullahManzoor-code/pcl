import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/analytics_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/dashboard_api_models.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/datetime_utils.dart';
import '../../../core/widgets/shimmer_widgets.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AnalyticsShimmer();
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, isDark)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 24.h),
                  _buildStatsGrid(context),
                  SizedBox(height: 32.h),
                  _buildSectionHeader('Mastery Progress', Icons.insights_rounded),
                  SizedBox(height: 16.h),
                  _buildMasteryGrid(context),
                  SizedBox(height: 32.h),
                  _buildSectionHeader('Recent Sessions', Icons.history_rounded),
                  SizedBox(height: 16.h),
                  _buildSessionsTimeline(context),
                  SizedBox(height: 80.h),
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
            : AppColors.analyticsGradient,
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
                          controller.fetchAnalytics();
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
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Analytics',
                    style: GoogleFonts.outfit(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Track your learning insights',
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
                        Icons.bolt_rounded,
                        '${controller.totalSessions.value} Sessions',
                      ),
                      SizedBox(width: 10.w),
                      _buildHeaderPill(
                        Icons.track_changes_rounded,
                        '${controller.conceptsPracticed.value} Concepts',
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
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.1,
      children: [
        _buildSummaryCard(
          'Concepts',
          '${controller.conceptsPracticed.value}/8',
          Icons.track_changes_rounded,
          const [Color(0xFF9333EA), Color(0xFFA855F7)],
        ),
        _buildSummaryCard(
          'Avg Mastery',
          '${controller.avgMastery.value.toStringAsFixed(2)}%',
          Icons.trending_up_rounded,
          const [Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        _buildSummaryCard(
          'Sessions',
          '${controller.totalSessions.value}',
          Icons.bar_chart_rounded,
          const [Color(0xFF16A34A), Color(0xFF22C55E)],
        ),
        _buildSummaryCard(
          'Avg Score',
          '${controller.avgScore.value}%',
          Icons.timer_rounded,
          const [Color(0xFFEA580C), Color(0xFFF97316)],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors[0].withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: Colors.white, size: 18.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: colors[0],
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryGrid(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.masteryList.length,
      itemBuilder: (context, index) {
        final mastery = controller.masteryList[index];
        final decayed = mastery.decayedMastery;

        Color statusColor;
        String statusLabel;
        String decayIndicator;

        if (decayed < 0.5) {
          statusColor = Colors.red;
          statusLabel = 'Needs Work';
          decayIndicator = '⚠️';
        } else if (decayed < 0.75) {
          statusColor = Colors.orange;
          statusLabel = 'Good';
          decayIndicator = '⏰';
        } else {
          statusColor = Colors.green;
          statusLabel = 'Mastered';
          decayIndicator = '🔥';
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: NextCard(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mastery.name,
                            style: GoogleFonts.outfit(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Last practiced: ${_getRelativeTime(mastery.lastPracticed)}',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(decayIndicator, style: TextStyle(fontSize: 20.sp)),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mastery',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${(decayed * 100).round()}%',
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: decayed),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 8.h,
                      );
                    },
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (mastery.mastery > decayed)
                      Text(
                        '↓ ${((mastery.mastery - decayed) * 100).round()}% decay',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Colors.red[300],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionsTimeline(BuildContext context) {
    if (controller.sessionList.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Text(
            'No recent sessions yet.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: controller.sessionList
          .map((session) => _buildTimelineItem(context, session))
          .toList(),
    );
  }

  Widget _buildTimelineItem(BuildContext context, RecentSession session) {
    final isPositive = session.masteryGain >= 0;

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: Colors.white,
                  size: 14.sp,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2.w,
                  color: Colors.grey[300],
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: NextCard(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.conceptName,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                session.subTopic!
                                    .replaceAll('_', ' ')
                                    .capitalizeFirst!,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _getRelativeTime(
                            DateTime.parse(session.timestamp as String),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSessionStat(
                          'Score',
                          '${(session.score * 100).round()}%',
                          Colors.blue,
                        ),
                        _buildSessionStat(
                          'Difficulty',
                          '${session.difficulty}',
                          Colors.grey,
                        ),
                        _buildSessionStat(
                          'Gain',
                          '${isPositive ? '+' : ''}${(session.masteryGain * 100).round()}%',
                          isPositive ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticUtils.lightImpact();
                          controller.practiceAgain(
                            session.conceptId,
                            session.subTopic,
                            difficulty: session.difficulty,
                            questionCount: session.questionsAnswered,
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Practice Again'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          textStyle: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.grey),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    return DateTimeUtils.formatRelative(dateTime);
  }
}
