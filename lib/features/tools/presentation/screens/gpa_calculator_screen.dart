import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/gpa_provider.dart';

class GpaCalculatorScreen extends ConsumerWidget {
  const GpaCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gpaProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('GPA Calculator', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  TextButton.icon(
                    onPressed: () => ref.read(gpaProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),

            // GPA Result Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _GpaResultCard(gpa: state.gpa, totalCredits: state.totalCreditHours, hasResults: state.hasResults),
            ),

            const SizedBox(height: 16),

            // Grading System Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(gradingSystems.length, (i) {
                  final isSelected = state.selectedGradingSystem == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => ref.read(gpaProvider.notifier).setGradingSystem(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.dividerLight),
                        ),
                        child: Text(
                          gradingSystems[i],
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondaryLight),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Course List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.courses.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.courses.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: GestureDetector(
                        onTap: () => ref.read(gpaProvider.notifier).addCourse(),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text('Add Course', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return _CourseCard(
                    course: state.courses[index],
                    index: index,
                    canDelete: state.courses.length > 1,
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

// ── GPA Result Card ──
class _GpaResultCard extends StatelessWidget {
  final double gpa;
  final double totalCredits;
  final bool hasResults;

  const _GpaResultCard({required this.gpa, required this.totalCredits, required this.hasResults});

  @override
  Widget build(BuildContext context) {
    final color = hasResults ? AppColors.gpaColor(gpa) : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your GPA',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 4),
                Text(
                  hasResults ? gpa.toStringAsFixed(2) : '0.00',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 48,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasResults ? _gpaLabel(gpa) : 'Select grades to calculate',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '${totalCredits.toInt()}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
                ),
                Text(
                  'Credits',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _gpaLabel(double gpa) {
    if (gpa >= 3.7) return 'Excellent! Dean\'s List 🎉';
    if (gpa >= 3.3) return 'Very Good! Keep it up 💪';
    if (gpa >= 3.0) return 'Good Performance 👍';
    if (gpa >= 2.5) return 'Average - Room to improve';
    if (gpa >= 2.0) return 'Below Average ⚠️';
    return 'Needs Improvement';
  }
}

// ── Course Card ──
class _CourseCard extends ConsumerWidget {
  final GpaCourse course;
  final int index;
  final bool canDelete;

  const _CourseCard({required this.course, required this.index, required this.canDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: course.grade != null
              ? AppColors.gpaColor(course.gradePoints ?? 0).withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Course name + delete
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: course.grade != null
                      ? AppColors.gpaColor(course.gradePoints ?? 0).withValues(alpha: 0.1)
                      : AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: course.grade != null ? AppColors.gpaColor(course.gradePoints ?? 0) : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: (v) => ref.read(gpaProvider.notifier).updateCourseName(course.id, v),
                  decoration: InputDecoration(
                    hintText: 'Course ${index + 1}',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintStyle: TextStyle(color: AppColors.textTertiaryLight, fontSize: 14),
                  ),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (canDelete)
                GestureDetector(
                  onTap: () => ref.read(gpaProvider.notifier).removeCourse(course.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Credit Hours + Grade
          Row(
            children: [
              // Credit Hours
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: course.creditHours,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      style: Theme.of(context).textTheme.bodyMedium,
                      items: [1, 2, 3, 4, 5, 6].map((h) {
                        return DropdownMenuItem(value: h, child: Text('$h Credits'));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) ref.read(gpaProvider.notifier).updateCreditHours(course.id, v);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Grade
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: course.grade != null
                        ? AppColors.gpaColor(course.gradePoints ?? 0).withValues(alpha: 0.08)
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: course.grade != null
                        ? Border.all(color: AppColors.gpaColor(course.gradePoints ?? 0).withValues(alpha: 0.3))
                        : null,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: course.grade,
                      isExpanded: true,
                      isDense: true,
                      hint: const Text('Grade'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: course.grade != null ? FontWeight.w700 : FontWeight.w400,
                            color: course.grade != null ? AppColors.gpaColor(course.gradePoints ?? 0) : null,
                          ),
                      items: hecGrades.map((g) {
                        return DropdownMenuItem(
                          value: g.letter,
                          child: Text('${g.letter}  (${g.points.toStringAsFixed(1)})'),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          final grade = hecGrades.firstWhere((g) => g.letter == v);
                          ref.read(gpaProvider.notifier).updateGrade(course.id, grade.letter, grade.points);
                        }
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