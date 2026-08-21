import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/target_gpa_provider.dart';

class TargetGpaScreen extends ConsumerWidget {
  const TargetGpaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(targetGpaProvider);

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
                  Expanded(child: Text('Target GPA', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                  TextButton.icon(
                    onPressed: () => ref.read(targetGpaProvider.notifier).reset(),
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
                    // Result Card
                    _ResultCard(state: state),

                    const SizedBox(height: 24),

                    // Input Fields
                    Text('Your Current Status', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),

                    // Current CGPA
                    _InputCard(
                      icon: Icons.bar_chart_rounded,
                      label: 'Current CGPA',
                      color: AppColors.primary,
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) {
                          final val = double.tryParse(v);
                          if (val != null) ref.read(targetGpaProvider.notifier).setCurrentCgpa(val);
                        },
                        decoration: const InputDecoration(
                          hintText: 'e.g. 3.25',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          isDense: true,
                        ),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Completed Credits
                    _InputCard(
                      icon: Icons.school_rounded,
                      label: 'Credits Completed',
                      color: AppColors.secondary,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final val = int.tryParse(v);
                          if (val != null) ref.read(targetGpaProvider.notifier).setCompletedCredits(val);
                        },
                        decoration: const InputDecoration(
                          hintText: 'e.g. 60',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          isDense: true,
                        ),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text('Your Goal', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),

                    // Target CGPA Slider
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
                      ),
                      child: Column(
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
                              Text('Target CGPA', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSurface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  state.targetCgpa.toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accentDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.accent,
                              inactiveTrackColor: AppColors.accent.withValues(alpha: 0.15),
                              thumbColor: AppColors.accent,
                              overlayColor: AppColors.accent.withValues(alpha: 0.1),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: state.targetCgpa,
                              min: 1.0,
                              max: 4.0,
                              divisions: 60,
                              onChanged: (v) => ref.read(targetGpaProvider.notifier).setTargetCgpa(double.parse(v.toStringAsFixed(2))),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('1.0', style: TextStyle(fontSize: 11, color: AppColors.textTertiaryLight)),
                              Row(
                                children: [
                                  _QuickTarget(label: '3.0', val: 3.0, current: state.targetCgpa, onTap: () => ref.read(targetGpaProvider.notifier).setTargetCgpa(3.0)),
                                  const SizedBox(width: 6),
                                  _QuickTarget(label: '3.5', val: 3.5, current: state.targetCgpa, onTap: () => ref.read(targetGpaProvider.notifier).setTargetCgpa(3.5)),
                                  const SizedBox(width: 6),
                                  _QuickTarget(label: '3.7', val: 3.7, current: state.targetCgpa, onTap: () => ref.read(targetGpaProvider.notifier).setTargetCgpa(3.7)),
                                  const SizedBox(width: 6),
                                  _QuickTarget(label: '4.0', val: 4.0, current: state.targetCgpa, onTap: () => ref.read(targetGpaProvider.notifier).setTargetCgpa(4.0)),
                                ],
                              ),
                              const Text('4.0', style: TextStyle(fontSize: 11, color: AppColors.textTertiaryLight)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Semester Credits
                    _InputCard(
                      icon: Icons.credit_score_rounded,
                      label: 'This Semester Credits',
                      color: AppColors.info,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: state.semesterCredits,
                            isExpanded: true,
                            isDense: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            items: List.generate(13, (i) => i + 10).map((h) {
                              return DropdownMenuItem(value: h, child: Text('$h Credit Hours'));
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) ref.read(targetGpaProvider.notifier).setSemesterCredits(v);
                            },
                          ),
                        ),
                      ),
                    ),

                    // Scenario Table
                    if (state.hasData) ...[
                      const SizedBox(height: 24),
                      Text('What-If Scenarios', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      _ScenarioTable(state: state),
                    ],

                    const SizedBox(height: 32),
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

class _ResultCard extends StatelessWidget {
  final TargetGpaState state;
  const _ResultCard({required this.state});

  @override
  Widget build(BuildContext context) {
    Color color;
    String title;
    String value;

    if (!state.hasData) {
      color = AppColors.primary;
      title = 'Required GPA';
      value = '—';
    } else if (state.isAlreadyAchieved) {
      color = AppColors.success;
      title = 'Already Achieved!';
      value = '✓';
    } else if (state.isImpossible) {
      color = AppColors.error;
      title = 'Required GPA';
      value = state.requiredGpa.toStringAsFixed(2);
    } else {
      color = AppColors.gpaColor(state.requiredGpa);
      title = 'You Need This Semester';
      value = state.requiredGpa.toStringAsFixed(2);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 56),
          ),
          if (state.hasData) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                state.verdict,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (!state.hasData)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Enter your details below', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget child;

  const _InputCard({required this.icon, required this.label, required this.color, required this.child});

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
          Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _QuickTarget extends StatelessWidget {
  final String label;
  final double val;
  final double current;
  final VoidCallback onTap;

  const _QuickTarget({required this.label, required this.val, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = (current - val).abs() < 0.01;
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

class _ScenarioTable extends StatelessWidget {
  final TargetGpaState state;
  const _ScenarioTable({required this.state});

  @override
  Widget build(BuildContext context) {
    final scenarios = [4.0, 3.7, 3.5, 3.3, 3.0, 2.7, 2.5, 2.0];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('If You Get', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                SizedBox(width: 80, child: Text('New CGPA', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                const SizedBox(width: 60, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          // Rows
          ...scenarios.map((gpa) {
            final newCgpa = state.cgpaWith(gpa);
            final meetsTarget = newCgpa >= state.targetCgpa;
            final gpaColor = AppColors.gpaColor(gpa);
            final isRequired = state.isAchievable && (gpa - state.requiredGpa).abs() < 0.15;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isRequired ? AppColors.accentSurface.withValues(alpha: 0.5) : null,
                border: Border(bottom: BorderSide(color: AppColors.dividerLight.withValues(alpha: 0.5))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: gpaColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          gpa.toStringAsFixed(1),
                          style: TextStyle(fontSize: 14, fontWeight: isRequired ? FontWeight.w800 : FontWeight.w500, color: isRequired ? AppColors.accentDark : null),
                        ),
                        if (isRequired)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4)),
                            child: const Text('TARGET', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      newCgpa.toStringAsFixed(2),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gpaColor(newCgpa)),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Icon(
                      meetsTarget ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 18,
                      color: meetsTarget ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}