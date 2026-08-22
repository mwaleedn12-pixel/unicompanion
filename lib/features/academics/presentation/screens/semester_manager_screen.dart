import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../tools/presentation/providers/gpa_provider.dart' show hecGrades;
import '../../data/models/semester_model.dart';
import '../../data/models/course_model.dart';
import '../providers/semester_provider.dart';

class SemesterManagerScreen extends ConsumerWidget {
  const SemesterManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(semestersProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Semester & Courses', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    onPressed: () => _showAddSemesterSheet(context, ref),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.when(
                initial: () => const AppLoadingIndicator(),
                loading: () => const AppLoadingIndicator(message: 'Loading semesters...'),
                error: (msg) => AppErrorView(message: msg, onRetry: () => ref.read(semestersProvider.notifier).load()),
                success: (semesters) {
                  if (semesters.isEmpty) {
                    return AppEmptyView(
                      icon: Icons.school_outlined,
                      title: 'No Semesters Yet',
                      subtitle: 'Add your first semester to start tracking courses and grades',
                      action: PrimaryButton(
                        text: 'Add Semester',
                        icon: Icons.add_rounded,
                        onPressed: () => _showAddSemesterSheet(context, ref),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: semesters.length,
                    itemBuilder: (context, index) => _SemesterCard(semester: semesters[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSemesterSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    int semesterNumber = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (sheetContext, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Semester', style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Semester name', hintText: 'e.g. Fall 2026'),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Row(
                    children: [
                      Text('Semester number', style: Theme.of(sheetContext).textTheme.bodyMedium),
                      const Spacer(),
                      DropdownButton<int>(
                        value: semesterNumber,
                        items: List.generate(12, (i) => i + 1).map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                        onChanged: (v) => setState(() => semesterNumber = v ?? 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: 'Add Semester',
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) return;
                      final ok = await ref.read(semestersProvider.notifier).addSemester(nameController.text.trim(), semesterNumber);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      if (context.mounted) {
                        ok ? context.showSuccessSnackBar('Semester added') : context.showSnackBar('Failed to add semester', isError: true);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SemesterCard extends ConsumerWidget {
  final SemesterModel semester;
  const _SemesterCard({required this.semester});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpa = semester.isCompleted ? (semester.gpa ?? 0) : semester.computedGpa;
    final color = semester.isCompleted ? AppColors.gpaColor(gpa) : AppColors.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.school_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(semester.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        '${semester.courses.length} courses · ${semester.computedCreditHours.toInt()} credits',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(gpa > 0 ? gpa.toStringAsFixed(2) : '--', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: color)),
                    Text('GPA', style: TextStyle(fontSize: 10, color: AppColors.textTertiaryLight)),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (value) {
                    if (value == 'complete') {
                      ref.read(semestersProvider.notifier).toggleSemesterCompleted(semester);
                    } else if (value == 'delete') {
                      _confirmDelete(context, ref);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'complete', child: Text(semester.isCompleted ? 'Mark Ongoing' : 'Mark Completed')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete Semester')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ...semester.courses.map((course) => _CourseRow(course: course, semester: semester)),
                GestureDetector(
                  onTap: () => _showAddCourseSheet(context, ref, semester.id),
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text('Add Course', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Semester?'),
        content: Text('This will remove "${semester.name}" and all its courses. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(semestersProvider.notifier).deleteSemester(semester.id);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAddCourseSheet(BuildContext context, WidgetRef ref, String semesterId) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    int creditHours = 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (sheetContext, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Course', style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Course name', hintText: 'e.g. Data Structures')),
                  const SizedBox(height: AppSpacing.base),
                  TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Course code (optional)', hintText: 'e.g. CS201')),
                  const SizedBox(height: AppSpacing.base),
                  Row(
                    children: [
                      Text('Credit hours', style: Theme.of(sheetContext).textTheme.bodyMedium),
                      const Spacer(),
                      DropdownButton<int>(
                        value: creditHours,
                        items: [1, 2, 3, 4, 5, 6].map((h) => DropdownMenuItem(value: h, child: Text('$h Credits'))).toList(),
                        onChanged: (v) => setState(() => creditHours = v ?? 3),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: 'Add Course',
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) return;
                      final ok = await ref.read(semestersProvider.notifier).addCourse(
                            semesterId: semesterId,
                            name: nameController.text.trim(),
                            code: codeController.text.trim().isEmpty ? null : codeController.text.trim(),
                            creditHours: creditHours,
                          );
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      if (context.mounted) {
                        ok ? context.showSuccessSnackBar('Course added') : context.showSnackBar('Failed to add course', isError: true);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _CourseRow extends ConsumerWidget {
  final CourseModel course;
  final SemesterModel semester;
  const _CourseRow({required this.course, required this.semester});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${course.code != null ? '${course.code} · ' : ''}${course.creditHours} credits',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: course.grade != null ? AppColors.gpaColor(course.gradePoints ?? 0).withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: course.grade != null ? AppColors.gpaColor(course.gradePoints ?? 0).withValues(alpha: 0.3) : AppColors.dividerLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: course.grade,
                hint: const Text('Grade', style: TextStyle(fontSize: 12)),
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: course.grade != null ? AppColors.gpaColor(course.gradePoints ?? 0) : AppColors.textPrimaryLight,
                ),
                items: hecGrades.map((g) => DropdownMenuItem(value: g.letter, child: Text(g.letter))).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  final grade = hecGrades.firstWhere((g) => g.letter == v);
                  ref.read(semestersProvider.notifier).updateCourseGrade(course, grade.letter, grade.points);
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 16, color: AppColors.textTertiaryLight),
            onPressed: () => ref.read(semestersProvider.notifier).deleteCourse(course.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}