import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../academics/presentation/providers/semester_provider.dart';
import '../../../academics/presentation/providers/assignment_provider.dart';
import '../../../academics/data/models/semester_model.dart';

class TrackScreen extends ConsumerWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType = LocalStorageService.userType ?? AppConstants.userTypeFsc;
    final isFsc = userType == AppConstants.userTypeFsc;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Track', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                isFsc ? 'Track your applications & deadlines' : 'Track your courses & academics',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 24),

              if (isFsc) ..._fscTrackContent(context),
              if (!isFsc) ..._uniTrackContent(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _fscTrackContent(BuildContext context) {
    return [
      // Application Stats
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            const Icon(Icons.checklist_rounded, color: Colors.white, size: 36),
            const SizedBox(height: 10),
            Text('Application Tracker', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Track your university applications', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatBubble(value: '0', label: 'Applied'),
                _StatBubble(value: '0', label: 'Shortlisted'),
                _StatBubble(value: '0', label: 'Accepted'),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),

      Text('Upcoming Deadlines', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),

      _EmptyStateCard(
        icon: Icons.calendar_today_rounded,
        title: 'No Deadlines Yet',
        subtitle: 'Shortlist universities from Explore tab to see their deadlines here',
        color: AppColors.accent,
      ),

      const SizedBox(height: 16),

      Text('My Shortlist', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),

      _EmptyStateCard(
        icon: Icons.bookmark_outline_rounded,
        title: 'No Universities Shortlisted',
        subtitle: 'Go to Explore and save universities you\'re interested in',
        color: AppColors.primary,
      ),

      const SizedBox(height: 32),
    ];
  }

  List<Widget> _uniTrackContent(BuildContext context, WidgetRef ref) {
    final semestersState = ref.watch(semestersProvider);
    final semesters = semestersState.dataOrNull ?? [];
    final upcomingAssignments = ref.watch(upcomingAssignmentsProvider);
    final totalCredits = ref.watch(totalCompletedCreditsProvider);

    final courseCount = semesters.fold<int>(0, (sum, s) => sum + s.courses.length);
    SemesterModel? currentSemester;
    for (final s in semesters) {
      if (!s.isCompleted) {
        currentSemester = s;
        break;
      }
    }

    // Degree assumed at 130 credits unless the student has already exceeded it.
    const degreeTotalCredits = 130.0;
    final progressPct = (totalCredits / degreeTotalCredits).clamp(0.0, 1.0);

    return [
      // Semester Overview
      GestureDetector(
        onTap: () => context.push('/track/semesters'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondaryLight]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 36),
              const SizedBox(height: 10),
              Text('Semester Tracker', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Track courses, grades & assignments', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatBubble(value: '$courseCount', label: 'Courses'),
                  _StatBubble(value: '${upcomingAssignments.length}', label: 'Assignments'),
                  _StatBubble(value: currentSemester != null ? currentSemester.computedGpa.toStringAsFixed(2) : '--', label: 'Current GPA'),
                ],
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 24),

      Text('Current Courses', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),

      if (currentSemester == null || currentSemester.courses.isEmpty)
        GestureDetector(
          onTap: () => context.push('/track/semesters'),
          child: _EmptyStateCard(
            icon: Icons.book_outlined,
            title: 'No Courses Added',
            subtitle: 'Add your semester courses to track grades and attendance',
            color: AppColors.primary,
            actionLabel: 'Add Now',
          ),
        )
      else
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              ...currentSemester.courses.take(4).map((c) => ListTile(
                    dense: true,
                    leading: Icon(Icons.book_rounded, color: c.grade != null ? AppColors.gpaColor(c.gradePoints ?? 0) : AppColors.textTertiaryLight, size: 20),
                    title: Text(c.name, style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Text(c.grade ?? '--', style: TextStyle(fontWeight: FontWeight.w700, color: c.grade != null ? AppColors.gpaColor(c.gradePoints ?? 0) : AppColors.textTertiaryLight)),
                  )),
              TextButton(onPressed: () => context.push('/track/semesters'), child: const Text('Manage Semesters & Courses')),
            ],
          ),
        ),

      const SizedBox(height: 16),

      Text('Upcoming Due', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),

      if (upcomingAssignments.isEmpty)
        GestureDetector(
          onTap: () => context.push('/track/assignments'),
          child: _EmptyStateCard(
            icon: Icons.assignment_outlined,
            title: 'No Assignments Yet',
            subtitle: 'Add assignments, quizzes and exams to keep track of due dates',
            color: AppColors.accent,
            actionLabel: 'Add Now',
          ),
        )
      else
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              ...upcomingAssignments.take(4).map((a) => ListTile(
                    dense: true,
                    leading: Icon(
                      a.type == 'exam' ? Icons.description_rounded : (a.type == 'quiz' ? Icons.quiz_rounded : Icons.assignment_rounded),
                      color: a.isOverdue ? AppColors.error : AppColors.accent,
                      size: 20,
                    ),
                    title: Text(a.title, style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Text(
                      DateFormat('MMM d').format(a.dueDate),
                      style: TextStyle(fontWeight: FontWeight.w600, color: a.isOverdue ? AppColors.error : AppColors.textSecondaryLight, fontSize: 12),
                    ),
                  )),
              TextButton(onPressed: () => context.push('/track/assignments'), child: const Text('View All Assignments')),
            ],
          ),
        ),

      const SizedBox(height: 16),

      Text('Degree Progress', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Credits Completed', style: Theme.of(context).textTheme.titleSmall),
                Text('${totalCredits.toInt()} / ${degreeTotalCredits.toInt()}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressPct,
                minHeight: 10,
                backgroundColor: AppColors.primarySurface,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text('${(progressPct * 100).toStringAsFixed(0)}% Complete', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),

      const SizedBox(height: 32),
    ];
  }
}

class _StatBubble extends StatelessWidget {
  final String value;
  final String label;
  const _StatBubble({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? actionLabel;
  const _EmptyStateCard({required this.icon, required this.title, required this.subtitle, required this.color, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(actionLabel!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ),
          ],
        ],
      ),
    );
  }
}