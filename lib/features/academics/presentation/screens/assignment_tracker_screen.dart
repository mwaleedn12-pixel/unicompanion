import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/models/assignment_model.dart';
import '../providers/assignment_provider.dart';
import '../providers/semester_provider.dart';

class AssignmentTrackerScreen extends ConsumerStatefulWidget {
  const AssignmentTrackerScreen({super.key});

  @override
  ConsumerState<AssignmentTrackerScreen> createState() => _AssignmentTrackerScreenState();
}

class _AssignmentTrackerScreenState extends ConsumerState<AssignmentTrackerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assignmentsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAssignmentSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Assignments & Exams', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.when(
                initial: () => const AppLoadingIndicator(),
                loading: () => const AppLoadingIndicator(message: 'Loading assignments...'),
                error: (msg) => AppErrorView(message: msg, onRetry: () => ref.read(assignmentsProvider.notifier).load()),
                success: (assignments) => _buildContent(context, assignments),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<AssignmentModel> assignments) {
    final eventsByDay = <DateTime, List<AssignmentModel>>{};
    for (final a in assignments) {
      final day = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
      eventsByDay.putIfAbsent(day, () => []).add(a);
    }

    final selected = _selectedDay;
    final visibleList = selected != null
        ? (eventsByDay[DateTime(selected.year, selected.month, selected.day)] ?? [])
        : (assignments.where((a) => !a.isCompleted).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate)));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TableCalendar<AssignmentModel>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => _selectedDay != null && isSameDay(_selectedDay, day),
            eventLoader: (day) => eventsByDay[DateTime(day.year, day.month, day.day)] ?? [],
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
              selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = isSameDay(_selectedDay, selectedDay) ? null : selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selected != null ? DateFormat('MMM d, yyyy').format(selected) : 'Upcoming',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (selected != null)
              TextButton(onPressed: () => setState(() => _selectedDay = null), child: const Text('Show Upcoming')),
          ],
        ),
        const SizedBox(height: 12),

        if (visibleList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: AppEmptyView(
              icon: Icons.assignment_turned_in_outlined,
              title: selected != null ? 'Nothing due this day' : 'All caught up!',
              subtitle: selected != null ? null : 'No pending assignments or exams',
            ),
          )
        else
          ...visibleList.map((a) => _AssignmentCard(assignment: a)),

        const SizedBox(height: 80),
      ],
    );
  }

  void _showAddAssignmentSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    String type = 'assignment';
    String priority = 'medium';
    DateTime dueDate = DateTime.now().add(const Duration(days: 1));
    String? selectedCourseId;

    final semesters = ref.read(semestersProvider).dataOrNull ?? [];
    final allCourses = semesters.expand((s) => s.courses).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (sheetContext, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Assignment/Exam', style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Midterm Exam')),
                    const SizedBox(height: AppSpacing.base),

                    Text('Type', style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['assignment', 'quiz', 'exam', 'project'].map((t) {
                        final isSelected = type == t;
                        return ChoiceChip(
                          label: Text(t[0].toUpperCase() + t.substring(1)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => type = t),
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                          labelStyle: TextStyle(color: isSelected ? AppColors.primary : null, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    Text('Priority', style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['low', 'medium', 'high'].map((p) {
                        final isSelected = priority == p;
                        final color = p == 'high' ? AppColors.error : (p == 'medium' ? AppColors.warning : AppColors.success);
                        return ChoiceChip(
                          label: Text(p[0].toUpperCase() + p.substring(1)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => priority = p),
                          selectedColor: color.withValues(alpha: 0.15),
                          labelStyle: TextStyle(color: isSelected ? color : null, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    if (allCourses.isNotEmpty) ...[
                      Text('Course (optional)', style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedCourseId,
                        hint: const Text('None'),
                        items: allCourses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (v) => setState(() => selectedCourseId = v),
                      ),
                      const SizedBox(height: AppSpacing.base),
                    ],

                    Row(
                      children: [
                        Text('Due date', style: Theme.of(sheetContext).textTheme.bodyMedium),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: Text(DateFormat('MMM d, yyyy').format(dueDate)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: sheetContext,
                              initialDate: dueDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            );
                            if (picked != null) setState(() => dueDate = picked);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    PrimaryButton(
                      text: 'Add',
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;
                        String? courseSemesterId;
                        for (final c in allCourses) {
                          if (c.id == selectedCourseId) {
                            courseSemesterId = c.semesterId;
                            break;
                          }
                        }
                        final ok = await ref.read(assignmentsProvider.notifier).addAssignment(
                              title: titleController.text.trim(),
                              type: type,
                              dueDate: dueDate,
                              priority: priority,
                              courseId: selectedCourseId,
                              semesterId: courseSemesterId,
                            );
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                        if (context.mounted) {
                          ok ? context.showSuccessSnackBar('Added') : context.showSnackBar('Failed to add', isError: true);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AssignmentCard extends ConsumerWidget {
  final AssignmentModel assignment;
  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityColor = assignment.priority == 'high'
        ? AppColors.error
        : (assignment.priority == 'medium' ? AppColors.warning : AppColors.success);
    final typeIcon = switch (assignment.type) {
      'exam' => Icons.description_rounded,
      'quiz' => Icons.quiz_rounded,
      'project' => Icons.folder_rounded,
      _ => Icons.assignment_rounded,
    };

    return Dismissible(
      key: ValueKey(assignment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => ref.read(assignmentsProvider.notifier).deleteAssignment(assignment.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: assignment.isOverdue ? AppColors.error.withValues(alpha: 0.3) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: assignment.isCompleted,
              onChanged: (_) => ref.read(assignmentsProvider.notifier).toggleComplete(assignment),
              activeColor: AppColors.primary,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(typeIcon, color: priorityColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: assignment.isCompleted ? TextDecoration.lineThrough : null,
                          color: assignment.isCompleted ? AppColors.textTertiaryLight : null,
                        ),
                  ),
                  Text(
                    [
                      if (assignment.courseName != null) assignment.courseName!,
                      DateFormat('MMM d').format(assignment.dueDate),
                      if (assignment.isOverdue) 'Overdue' else if (assignment.daysUntilDue == 0) 'Today' else if (assignment.daysUntilDue == 1) 'Tomorrow',
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: assignment.isOverdue ? AppColors.error : AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}