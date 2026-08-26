import 'package:flutter/services.dart';

/// Centralized haptic feedback utility.
/// Usage: AppHaptics.light()  or  AppHaptics.tap()
class AppHaptics {
  AppHaptics._();

  /// Light tap — for chip/filter selections, toggles
  static void light() => HapticFeedback.lightImpact();

  /// Medium tap — for button presses, card taps
  static void medium() => HapticFeedback.mediumImpact();

  /// Heavy tap — for important actions (delete, submit)
  static void heavy() => HapticFeedback.heavyImpact();

  /// Selection tick — for list item selection, picker changes
  static void selection() => HapticFeedback.selectionClick();

  /// Alias for medium (most common use)
  static void tap() => HapticFeedback.mediumImpact();

  /// Success vibration pattern
  static void success() => HapticFeedback.lightImpact();

  /// Error vibration
  static void error() => HapticFeedback.heavyImpact();
}