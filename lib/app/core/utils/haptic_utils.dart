import 'package:flutter/services.dart';

/// Utility class for haptic feedback
class HapticUtils {
  /// Light impact for button taps
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact for selections
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact for important actions
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click for toggles
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate for errors
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
