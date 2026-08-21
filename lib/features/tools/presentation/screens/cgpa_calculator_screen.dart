import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/cgpa_provider.dart';

class CgpaCalculatorScreen extends ConsumerWidget {
  const CgpaCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cgpaProvider);

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
                  Expanded(child: Text('CGPA Calculator', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                  TextButton.icon(
                    onPressed: () => ref.read(cgpaProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),

            // CGPA Result Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _CgpaResultCard(state: state),
            ),

            const SizedBox(height: 20),

            // Semester List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.semesters.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.semesters.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: GestureDetector(
                        onTap: () => ref.read(cgpaProvider.notifier).addSemester(),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.secondarySurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline_rounded, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 8),
                              Text('Add Semester', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return _SemesterCard(
                    semester: state.semesters[index],
                    index: index,
                    canDelete: state.semesters.length > 1,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CgpaResultCard extends StatelessWidget {
  final CgpaState state;
  const _CgpaResultCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = state.hasResults ? AppColors.gpaColor(state.cgpa) : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cumulative GPA', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 4),
                Text(
                  state.hasResults ? state.cgpa.toStringAsFixed(2) : '0.00',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 48),
                ),
                const SizedBox(height: 4),
                Text(
                  state.hasResults ? _cgpaLabel(state.cgpa) : 'Enter semester GPAs',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _MiniStat(label: 'Semesters', value: '${state.completedSemesters}'),
              const SizedBox(height: 10),
              _MiniStat(label: 'Credits', value: '${state.totalCredits.toInt()}'),
            ],
          ),
        ],
      ),
    );
  }

  String _cgpaLabel(double cgpa) {
    if (cgpa >= 3.7) return 'Outstanding! 🏆';
    if (cgpa >= 3.3) return 'Excellent Performance 🎉';
    if (cgpa >= 3.0) return 'Very Good 💪';
    if (cgpa >= 2.5) return 'Good - Keep Improving';
    if (cgpa >= 2.0) return 'Average ⚠️';
    return 'Needs Improvement';
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10)),
        ],
      ),
    );
  }
}

class _SemesterCard extends ConsumerWidget {
  final SemesterEntry semester;
  final int index;
  final bool canDelete;

  const _SemesterCard({required this.semester, required this.index, required this.canDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasData = semester.hasData;
    final gpaColor = hasData ? AppColors.gpaColor(semester.gpa) : AppColors.textTertiaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasData ? gpaColor.withValues(alpha: 0.25) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: hasData
                      ? LinearGradient(colors: [gpaColor, gpaColor.withValues(alpha: 0.7)])
                      : null,
                  color: hasData ? null : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: hasData ? Colors.white : AppColors.textTertiaryLight),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: semester.name)
                    ..selection = TextSelection.collapsed(offset: semester.name.length),
                  onChanged: (v) => ref.read(cgpaProvider.notifier).updateName(semester.id, v),
                  decoration: InputDecoration(
                    hintText: 'Semester ${index + 1}',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (hasData)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gpaColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: gpaColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    semester.gpa.toStringAsFixed(2),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: gpaColor),
                  ),
                ),
              if (canDelete) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => ref.read(cgpaProvider.notifier).removeSemester(semester.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // GPA + Credits
          Row(
            children: [
              // GPA Input
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) {
                      final val = double.tryParse(v);
                      if (val != null && val >= 0 && val <= 4.0) {
                        ref.read(cgpaProvider.notifier).updateGpa(semester.id, val);
                      } else if (v.isEmpty) {
                        ref.read(cgpaProvider.notifier).updateGpa(semester.id, 0);
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'GPA (0-4.0)',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Credit Hours
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: semester.creditHours,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      style: Theme.of(context).textTheme.bodyMedium,
                      items: List.generate(13, (i) => i + 10).map((h) {
                        return DropdownMenuItem(value: h, child: Text('$h Cr'));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) ref.read(cgpaProvider.notifier).updateCredits(semester.id, v);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}