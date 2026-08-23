import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../academics/presentation/providers/semester_provider.dart';
import '../../../academics/presentation/providers/assignment_provider.dart';
import '../../../applications/presentation/providers/application_provider.dart';
import '../../../applications/presentation/providers/shortlist_provider.dart';

class ParentModeScreen extends ConsumerWidget {
  const ParentModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: profileState.when(
          initial: () => const AppLoadingIndicator(),
          loading: () => const AppLoadingIndicator(message: 'Loading...'),
          error: (msg) => AppErrorView(message: msg),
          success: (profile) {
            final isFsc = profile.isFscStudent;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Parent Dashboard', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                            Text('${profile.fullName}\'s progress', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
                        child: Text(isFsc ? 'FSC Student' : 'University', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Student Info Card
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
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 10),
                        Text(profile.fullName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                        Text(profile.isFscStudent ? 'FSC Student' : 'University Student', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (isFsc) ..._fscParentView(context, ref),
                  if (!isFsc) ..._uniParentView(context, ref),

                  const SizedBox(height: 24),

                  // Info note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
                        const SizedBox(width: 10),
                        Expanded(child: Text('This is a read-only view of your child\'s academic data. All data is synced from their UniCompanion account.', style: TextStyle(fontSize: 12, color: AppColors.info, height: 1.4))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _fscParentView(BuildContext context, WidgetRef ref) {
    final appsState = ref.watch(applicationsProvider);
    final apps = appsState.dataOrNull ?? [];
    final shortlist = ref.watch(shortlistProvider).dataOrNull ?? [];
    final upcomingDeadlines = ref.watch(upcomingDeadlinesProvider);

    final applied = apps.where((a) => a.isApplied).length;
    final accepted = apps.where((a) => a.isAccepted).length;

    return [
      _SectionHeader(title: '📊 Application Overview'),
      const SizedBox(height: 12),
      Row(children: [
        _StatCard(value: '${apps.length}', label: 'Total Apps', color: AppColors.primary),
        const SizedBox(width: 10),
        _StatCard(value: '$applied', label: 'Applied', color: AppColors.accent),
        const SizedBox(width: 10),
        _StatCard(value: '$accepted', label: 'Accepted', color: AppColors.success),
      ]),
      const SizedBox(height: 20),

      _SectionHeader(title: '📅 Upcoming Deadlines'),
      const SizedBox(height: 12),
      if (upcomingDeadlines.isEmpty)
        _EmptyBox(text: 'No upcoming deadlines')
      else
        ...upcomingDeadlines.take(5).map((a) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: a.isDeadlineSoon ? AppColors.warning.withValues(alpha: 0.3) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
          ),
          child: Row(children: [
            Icon(Icons.event_rounded, size: 18, color: a.isDeadlineSoon ? AppColors.warning : AppColors.accent),
            const SizedBox(width: 10),
            Expanded(child: Text(a.universityName, style: Theme.of(context).textTheme.bodyMedium)),
            Text(DateFormat('MMM d').format(a.deadline!), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: a.isDeadlineSoon ? AppColors.warning : AppColors.textSecondaryLight)),
          ]),
        )),

      const SizedBox(height: 20),
      _SectionHeader(title: '🎓 Shortlisted Universities (${shortlist.length})'),
      const SizedBox(height: 12),
      if (shortlist.isEmpty)
        _EmptyBox(text: 'No universities shortlisted yet')
      else
        ...shortlist.take(6).map((s) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
          ),
          child: Row(children: [
            Icon(Icons.school_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(s.universityName, style: Theme.of(context).textTheme.bodyMedium)),
            if (s.universityRanking != null) Text('#${s.universityRanking}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiaryLight)),
          ]),
        )),
    ];
  }

  List<Widget> _uniParentView(BuildContext context, WidgetRef ref) {
    final semState = ref.watch(semestersProvider);
    final semesters = semState.dataOrNull ?? [];
    final upcoming = ref.watch(upcomingAssignmentsProvider);

    final completedSems = semesters.where((s) => s.isCompleted).length;
    final totalCourses = semesters.fold<int>(0, (sum, s) => sum + s.courses.length);

    // Calculate CGPA
    double cgpa = 0;
    int totalCredits = 0;
    for (final s in semesters.where((s) => s.isCompleted)) {
      final semCredits = s.courses.fold<int>(0, (sum, c) => sum + c.creditHours);
      cgpa += s.computedGpa * semCredits;
      totalCredits += semCredits;
    }
    if (totalCredits > 0) cgpa /= totalCredits;

    return [
      _SectionHeader(title: '📊 Academic Overview'),
      const SizedBox(height: 12),
      Row(children: [
        _StatCard(value: cgpa > 0 ? cgpa.toStringAsFixed(2) : '--', label: 'CGPA', color: AppColors.primary),
        const SizedBox(width: 10),
        _StatCard(value: '$completedSems', label: 'Semesters', color: AppColors.accent),
        const SizedBox(width: 10),
        _StatCard(value: '$totalCourses', label: 'Courses', color: AppColors.success),
      ]),
      const SizedBox(height: 20),

      _SectionHeader(title: '📚 Semester History'),
      const SizedBox(height: 12),
      if (semesters.isEmpty)
        _EmptyBox(text: 'No semesters added yet')
      else
        ...semesters.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: s.isCompleted ? AppColors.successSurface : AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
              child: Icon(s.isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded, color: s.isCompleted ? AppColors.success : AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text('${s.courses.length} courses', style: TextStyle(fontSize: 12, color: AppColors.textTertiaryLight)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(s.computedGpa > 0 ? 'GPA ${s.computedGpa.toStringAsFixed(2)}' : '--', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gpaColor(s.computedGpa))),
              Text(s.isCompleted ? 'Completed' : 'In Progress', style: TextStyle(fontSize: 10, color: s.isCompleted ? AppColors.success : AppColors.textTertiaryLight)),
            ]),
          ]),
        )),

      const SizedBox(height: 20),
      _SectionHeader(title: '📅 Upcoming Due (${upcoming.length})'),
      const SizedBox(height: 12),
      if (upcoming.isEmpty)
        _EmptyBox(text: 'No upcoming assignments')
      else
        ...upcoming.take(5).map((a) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: a.isOverdue ? AppColors.error.withValues(alpha: 0.3) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
          ),
          child: Row(children: [
            Icon(a.isOverdue ? Icons.warning_rounded : Icons.assignment_rounded, size: 18, color: a.isOverdue ? AppColors.error : AppColors.accent),
            const SizedBox(width: 10),
            Expanded(child: Text(a.title, style: Theme.of(context).textTheme.bodyMedium)),
            Text(DateFormat('MMM d').format(a.dueDate), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: a.isOverdue ? AppColors.error : AppColors.textSecondaryLight)),
          ]),
        )),
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ]),
    ),
  );
}

class _EmptyBox extends StatelessWidget {
  final String text;
  const _EmptyBox({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: TextStyle(color: AppColors.textTertiaryLight), textAlign: TextAlign.center),
  );
}