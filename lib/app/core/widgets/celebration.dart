import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_utils.dart';

class LevelUpOverlay extends StatefulWidget {
  final double accuracy;
  final double newMasteryScore;
  final double fluencyRatio;
  final String topicName;
  final List<String> recommendations;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.accuracy,
    required this.newMasteryScore,
    required this.fluencyRatio,
    required this.topicName,
    required this.recommendations,
    required this.onDismiss,
  });

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();

  /// Show the overlay. All fields come from the real ExamSubmissionResponse.
  static Future<void> show({
    required double accuracy,
    required double newMasteryScore,
    required double fluencyRatio,
    required String topicName,
    List<String> recommendations = const [],
  }) async {
    HapticUtils.heavyImpact();
    Timer(const Duration(milliseconds: 200), () => HapticUtils.heavyImpact());

    await Get.dialog(
      LevelUpOverlay(
        accuracy: accuracy,
        newMasteryScore: newMasteryScore,
        fluencyRatio: fluencyRatio,
        topicName: topicName,
        recommendations: recommendations,
        onDismiss: () => Get.back(),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Determines colour palette + label based on accuracy (0–1)
_PerformanceTier _tier(double accuracy) {
  if (accuracy >= 0.9) {
    return _PerformanceTier(
      label: 'OUTSTANDING!',
      emoji: '🏆',
      subtitle: 'Near-perfect performance — you\'re unstoppable!',
      gradientColors: [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
      glowColor: Colors.amber,
      icon: Icons.emoji_events_rounded,
    );
  } else if (accuracy >= 0.75) {
    return _PerformanceTier(
      label: 'GREAT WORK!',
      emoji: '🌟',
      subtitle: 'Solid mastery — keep building momentum!',
      gradientColors: [const Color(0xFF6C63FF), const Color(0xFF3B82F6)],
      glowColor: AppColors.primary,
      icon: Icons.stars_rounded,
    );
  } else if (accuracy >= 0.5) {
    return _PerformanceTier(
      label: 'GOOD EFFORT!',
      emoji: '💪',
      subtitle: 'Making progress — practice makes perfect!',
      gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
      glowColor: Colors.green,
      icon: Icons.trending_up_rounded,
    );
  } else {
    return _PerformanceTier(
      label: 'KEEP GOING!',
      emoji: '🔥',
      subtitle: 'Every attempt makes you stronger!',
      gradientColors: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      glowColor: Colors.red,
      icon: Icons.local_fire_department_rounded,
    );
  }
}

class _PerformanceTier {
  final String label;
  final String emoji;
  final String subtitle;
  final List<Color> gradientColors;
  final Color glowColor;
  final IconData icon;

  const _PerformanceTier({
    required this.label,
    required this.emoji,
    required this.subtitle,
    required this.gradientColors,
    required this.glowColor,
    required this.icon,
  });
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _particleCtrl;

  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _progressAnim;
  late Animation<double> _masteryAnim;

  late _PerformanceTier _perfTier;

  @override
  void initState() {
    super.initState();
    _perfTier = _tierForAccuracy(widget.accuracy);

    // Entry animation
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeIn);

    // Progress bar animation
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = Tween<double>(begin: 0, end: widget.accuracy.clamp(0, 1))
        .animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _masteryAnim =
        Tween<double>(begin: 0, end: widget.newMasteryScore.clamp(0, 1))
            .animate(
              CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut),
            );

    // Particle rotation
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _entryCtrl.forward().then((_) => _progressCtrl.forward());
  }

  _PerformanceTier _tierForAccuracy(double accuracy) => _tier(accuracy);


  @override
  void dispose() {
    _entryCtrl.dispose();
    _progressCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final surfaceColor =
        isDark ? const Color(0xFF1E1E2E) : Colors.white;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            padding: EdgeInsets.all(28.r),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(
                color: _perfTier.glowColor.withOpacity(0.5),
                width: 2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: _perfTier.glowColor.withOpacity(0.35),
                  blurRadius: 48.r,
                  spreadRadius: 12.r,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated icon ring ──────────────────────────────
                _buildIconRing(),
                SizedBox(height: 20.h),

                // ── Topic tag ───────────────────────────────────────
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _perfTier.glowColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(
                      color: _perfTier.glowColor.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    widget.topicName,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _perfTier.glowColor,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Title ───────────────────────────────────────────
                Text(
                  _perfTier.label,
                  style: GoogleFonts.outfit(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  _perfTier.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: 24.h),

                // ── Stats row ───────────────────────────────────────
                Row(
                  children: [
                    _StatTile(
                      label: 'Accuracy',
                      valueAnim: _progressAnim,
                      suffix: '%',
                      multiplier: 100,
                      color: _perfTier.glowColor,
                    ),
                    SizedBox(width: 12.w),
                    _StatTile(
                      label: 'Mastery',
                      valueAnim: _masteryAnim,
                      suffix: '%',
                      multiplier: 100,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12.w),
                    _StatTile(
                      label: 'Fluency',
                      valueAnim: AlwaysStoppedAnimation(
                        widget.fluencyRatio.clamp(0, 1),
                      ),
                      suffix: '%',
                      multiplier: 100,
                      color: Colors.teal,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // ── Accuracy bar ────────────────────────────────────
                _buildProgressBar(
                  label: 'Accuracy',
                  anim: _progressAnim,
                  color: _perfTier.glowColor,
                  isDark: isDark,
                ),
                SizedBox(height: 10.h),
                _buildProgressBar(
                  label: 'Mastery',
                  anim: _masteryAnim,
                  color: AppColors.primary,
                  isDark: isDark,
                ),

                // ── Top recommendation ──────────────────────────────
                if (widget.recommendations.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.amber,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            widget.recommendations.first,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 28.h),

                // ── CTA ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _perfTier.gradientColors.first,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'SEE DETAILED RESULTS',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconRing() {
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, __) {
        return SizedBox(
          width: 100.w,
          height: 100.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating particles
              ...List.generate(6, (i) {
                final angle =
                    (2 * math.pi / 6) * i + _particleCtrl.value * 2 * math.pi;
                final radius = 44.w;
                return Positioned(
                  left: 50.w + radius * math.cos(angle) - 4.w,
                  top: 50.w + radius * math.sin(angle) - 4.w,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: _perfTier.glowColor.withOpacity(0.7 - i * 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
              // Central icon
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _perfTier.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _perfTier.glowColor.withOpacity(0.45),
                      blurRadius: 20.r,
                      spreadRadius: 4.r,
                    ),
                  ],
                ),
                child: Icon(
                  _perfTier.icon,
                  size: 36.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar({
    required String label,
    required Animation<double> anim,
    required Color color,
    required bool isDark,
  }) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  '${(anim.value * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(100.r),
              child: LinearProgressIndicator(
                value: anim.value,
                minHeight: 6.h,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Stat Tile widget
// ---------------------------------------------------------------------------

class _StatTile extends StatelessWidget {
  final String label;
  final Animation<double> valueAnim;
  final String suffix;
  final double multiplier;
  final Color color;

  const _StatTile({
    required this.label,
    required this.valueAnim,
    required this.suffix,
    required this.multiplier,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return Expanded(
      child: AnimatedBuilder(
        animation: valueAnim,
        builder: (_, __) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Text(
                  '${(valueAnim.value * multiplier).toStringAsFixed(0)}$suffix',
                  style: GoogleFonts.outfit(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
