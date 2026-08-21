import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/attendance_provider.dart';

class AttendanceCalculatorScreen extends ConsumerWidget {
  const AttendanceCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Attendance', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                  TextButton.icon(
                    onPressed: () => ref.read(attendanceProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Attendance Circle
                    _AttendanceCircle(state: state),

                    const SizedBox(height: 24),

                    // Input Fields
                    Text('Enter Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),

                    _InputRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Total Classes Held',
                      color: AppColors.primary,
                      value: state.totalClasses,
                      onChanged: (v) => ref.read(attendanceProvider.notifier).setTotalClasses(v),
                    ),
                    const SizedBox(height: 10),

                    _InputRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Classes Attended',
                      color: AppColors.success,
                      value: state.attendedClasses,
                      max: state.totalClasses,
                      onChanged: (v) => ref.read(attendanceProvider.notifier).setAttendedClasses(v),
                    ),
                    const SizedBox(height: 10),

                    _InputRow(
                      icon: Icons.upcoming_rounded,
                      label: 'Upcoming Classes',
                      color: AppColors.info,
                      value: state.upcomingClasses,
                      onChanged: (v) => ref.read(attendanceProvider.notifier).setUpcomingClasses(v),
                    ),
                    const SizedBox(height: 10),

                    // Target Percentage
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.flag_rounded, size: 18, color: AppColors.accent),
                              ),
                              const SizedBox(width: 10),
                              Text('Target', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${state.targetPercentage.toInt()}%',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accentDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.accent,
                              inactiveTrackColor: AppColors.accent.withValues(alpha: 0.15),
                              thumbColor: AppColors.accent,
                              overlayColor: AppColors.accent.withValues(alpha: 0.1),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: state.targetPercentage,
                              min: 50,
                              max: 100,
                              divisions: 50,
                              onChanged: (v) => ref.read(attendanceProvider.notifier).setTargetPercentage(v),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('50%', style: Theme.of(context).textTheme.bodySmall),
                              Row(
                                children: [
                                  _QuickTarget(label: '75%', current: state.targetPercentage, onTap: () => ref.read(attendanceProvider.notifier).setTargetPercentage(75)),
                                  const SizedBox(width: 6),
                                  _QuickTarget(label: '80%', current: state.targetPercentage, onTap: () => ref.read(attendanceProvider.notifier).setTargetPercentage(80)),
                                  const SizedBox(width: 6),
                                  _QuickTarget(label: '85%', current: state.targetPercentage, onTap: () => ref.read(attendanceProvider.notifier).setTargetPercentage(85)),
                                ],
                              ),
                              Text('100%', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Results
                    if (state.hasData) ...[
                      Text('Analysis', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),

                      // Can miss / Must attend
                      Row(
                        children: [
                          Expanded(
                            child: _ResultCard(
                              icon: Icons.beach_access_rounded,
                              label: 'Can Miss',
                              value: '${state.canMiss}',
                              subtitle: 'classes',
                              color: state.canMiss > 0 ? AppColors.success : AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ResultCard(
                              icon: Icons.priority_high_rounded,
                              label: 'Must Attend',
                              value: state.upcomingClasses > 0 ? '${state.mustAttend}' : '-',
                              subtitle: state.upcomingClasses > 0 ? 'of ${state.upcomingClasses} upcoming' : 'set upcoming',
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _ResultCard(
                              icon: Icons.cancel_outlined,
                              label: 'Missed',
                              value: '${state.missedClasses}',
                              subtitle: 'classes',
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ResultCard(
                              icon: state.isTargetAchievable ? Icons.check_circle_outline : Icons.warning_rounded,
                              label: 'Target',
                              value: state.isTargetAchievable ? 'Possible' : 'Not Possible',
                              subtitle: '${state.targetPercentage.toInt()}% target',
                              color: state.isTargetAchievable ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),

                      // Scenario bar
                      if (state.upcomingClasses > 0) ...[
                        const SizedBox(height: 16),
                        _ScenarioCard(state: state),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCircle extends StatelessWidget {
  final AttendanceState state;
  const _AttendanceCircle({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct = state.currentPercentage;
    final color = state.hasData ? AppColors.attendanceColor(pct) : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Text('Current Attendance', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            state.hasData ? '${pct.toStringAsFixed(1)}%' : '0%',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 52),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              state.hasData ? '${state.attendedClasses} / ${state.totalClasses} classes' : 'Enter your classes',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int value;
  final int? max;
  final ValueChanged<int> onChanged;

  const _InputRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
    this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          // Minus button
          GestureDetector(
            onTap: () {
              if (value > 0) onChanged(value - 1);
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.remove_rounded, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              '$value',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          // Plus button
          GestureDetector(
            onTap: () {
              if (max == null || value < max!) onChanged(value + 1);
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_rounded, size: 18, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _ResultCard({required this.icon, required this.label, required this.value, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _QuickTarget extends StatelessWidget {
  final String label;
  final double current;
  final VoidCallback onTap;

  const _QuickTarget({required this.label, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = '${current.toInt()}%' == label;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondaryLight),
        ),
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final AttendanceState state;
  const _ScenarioCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Scenarios', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          _ScenarioRow(label: 'Attend all ${state.upcomingClasses} upcoming', value: '${state.bestCasePercentage.toStringAsFixed(1)}%', color: AppColors.success),
          const SizedBox(height: 8),
          _ScenarioRow(label: 'Miss all ${state.upcomingClasses} upcoming', value: '${state.worstCasePercentage.toStringAsFixed(1)}%', color: AppColors.error),
        ],
      ),
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScenarioRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }
}