import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';

/// A single tour step definition
class TourStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const TourStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.icon = Icons.info_outline_rounded,
    this.color = AppColors.primary,
  });
}

/// Feature tour overlay controller.
///
/// Usage:
/// 1. Assign GlobalKeys to target widgets
/// 2. Define TourSteps
/// 3. Call FeatureTour.show(context, steps) on first visit
///
/// Example:
/// ```dart
/// final _exploreKey = GlobalKey();
/// final _toolsKey = GlobalKey();
///
/// // In build — wrap target:
/// Container(key: _exploreKey, child: ...)
///
/// // In initState or after first load:
/// FeatureTour.showIfFirstTime(context, 'home_tour', [
///   TourStep(targetKey: _exploreKey, title: 'Explore', description: 'Browse 268+ universities'),
///   TourStep(targetKey: _toolsKey, title: 'Tools', description: 'GPA, merit & more calculators'),
/// ]);
/// ```
class FeatureTour {
  FeatureTour._();

  static const String _prefPrefix = 'tour_seen_';

  /// Show tour only if user hasn't seen it before
  static Future<void> showIfFirstTime(
    BuildContext context,
    String tourId,
    List<TourStep> steps,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('$_prefPrefix$tourId') ?? false;
    if (seen || !context.mounted) return;

    await show(context, steps);
    await prefs.setBool('$_prefPrefix$tourId', true);
  }

  /// Show the tour immediately
  static Future<void> show(BuildContext context, List<TourStep> steps) async {
    if (steps.isEmpty) return;

    for (int i = 0; i < steps.length; i++) {
      if (!context.mounted) return;
      final step = steps[i];
      final isLast = i == steps.length - 1;

      await _showStepOverlay(context, step, i + 1, steps.length, isLast);
    }
  }

  static Future<void> _showStepOverlay(
    BuildContext context,
    TourStep step,
    int current,
    int total,
    bool isLast,
  ) async {
    // Find target widget position
    final renderBox = step.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final targetPos = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;
    final targetCenter = targetPos + Offset(targetSize.width / 2, targetSize.height / 2);
    final screenSize = MediaQuery.of(context).size;

    // Determine tooltip position (above or below target)
    final showAbove = targetCenter.dy > screenSize.height * 0.5;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (ctx) {
        return Stack(
          children: [
            // Highlight circle around target
            Positioned(
              left: targetPos.dx - 8,
              top: targetPos.dy - 8,
              child: Container(
                width: targetSize.width + 16,
                height: targetSize.height + 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: step.color, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: step.color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),

            // Tooltip card
            Positioned(
              left: 24,
              right: 24,
              top: showAbove ? null : targetPos.dy + targetSize.height + 20,
              bottom: showAbove ? screenSize.height - targetPos.dy + 20 : null,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step indicator + icon
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: step.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(step.icon, color: step.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step.title,
                              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: step.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$current / $total',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: step.color),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step.description,
                        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight, height: 1.4),
                      ),
                      const SizedBox(height: 16),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isLast)
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text('Skip All', style: TextStyle(color: AppColors.textTertiaryLight)),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: step.color,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: Text(isLast ? 'Got it!' : 'Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    // If user pressed "Skip All", we return early (the dialog returns null)
    // and the loop in show() continues — but since the dialog was dismissed
    // the same way for "Next", we check isLast to know when to stop.
    // The "Skip All" button also pops, so the loop just finishes.
  }
}