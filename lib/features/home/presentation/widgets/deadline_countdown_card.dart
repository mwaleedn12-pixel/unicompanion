import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';

/// Admission deadline countdown card for the home screen.
/// Shows days/hours remaining until nearest deadline.
class DeadlineCountdownCard extends StatelessWidget {
  final String universityName;
  final String programOrEvent;
  final DateTime deadline;
  final VoidCallback? onTap;

  const DeadlineCountdownCard({
    super.key,
    required this.universityName,
    required this.programOrEvent,
    required this.deadline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final isPast = diff.isNegative;
    final isUrgent = days <= 3 && !isPast;

    final bgGradient = isPast
        ? [Colors.grey[400]!, Colors.grey[500]!]
        : isUrgent
            ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
            : [const Color(0xFF1C2B4A), const Color(0xFF10192E)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: bgGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: bgGradient[0].withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 2),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isUrgent ? Icons.warning_rounded : Icons.timer_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPast ? 'Deadline Passed' : (isUrgent ? '⚡ Closing Soon!' : 'Next Deadline'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            universityName,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  programOrEvent,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Countdown boxes
                if (!isPast)
                  Row(
                    children: [
                      _CountdownBox(value: '$days', label: 'Days'),
                      const SizedBox(width: 10),
                      _CountdownBox(value: '$hours', label: 'Hours'),
                      const Spacer(),
                      // Action button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A24B),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Apply',
                              style: TextStyle(
                                color: bgGradient[0],
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: bgGradient[0]),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'This deadline has passed',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final String value;
  final String label;
  const _CountdownBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
        ],
      ),
    );
  }
}

/// Shows the nearest deadline from a list of deadlines.
/// Returns null if no upcoming deadlines exist.
class NearestDeadlineWidget extends StatelessWidget {
  final List<DeadlineInfo> deadlines;
  final VoidCallback? onTap;

  const NearestDeadlineWidget({super.key, required this.deadlines, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Find nearest upcoming deadline
    final now = DateTime.now();
    final upcoming = deadlines.where((d) => d.deadline.isAfter(now)).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    if (upcoming.isEmpty) return const SizedBox.shrink();

    final nearest = upcoming.first;
    return DeadlineCountdownCard(
      universityName: nearest.universityName,
      programOrEvent: nearest.eventName,
      deadline: nearest.deadline,
      onTap: onTap,
    )
        .animate()
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.08, end: 0, duration: 450.ms, curve: Curves.easeOutCubic);
  }
}

/// Simple data class for deadline info
class DeadlineInfo {
  final String universityName;
  final String eventName;
  final DateTime deadline;

  const DeadlineInfo({
    required this.universityName,
    required this.eventName,
    required this.deadline,
  });
}