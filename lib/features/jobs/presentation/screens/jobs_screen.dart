import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/jobs_provider.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _searchC = TextEditingController();

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsProvider);
    final filtered = ref.watch(filteredJobsProvider);
    final filter = ref.watch(jobFilterProvider);
    final fields = ref.watch(jobFieldsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Jobs & Internships', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text('Find opportunities matching your field', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
            ),
            const SizedBox(height: 14),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchC,
                onChanged: (v) => ref.read(jobFilterProvider.notifier).state = filter.copyWith(search: v),
                decoration: InputDecoration(
                  hintText: 'Search jobs, companies...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiaryLight),
                  suffixIcon: _searchC.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () { _searchC.clear(); ref.read(jobFilterProvider.notifier).state = filter.copyWith(search: ''); })
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Type filter
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(label: 'All', isSelected: filter.type == null, onTap: () => ref.read(jobFilterProvider.notifier).state = filter.copyWith(type: null)),
                  _FilterChip(label: '🎓 Internship', isSelected: filter.type == 'internship', onTap: () => ref.read(jobFilterProvider.notifier).state = JobFilter(type: 'internship', field: filter.field, search: filter.search)),
                  _FilterChip(label: '💼 Full-Time', isSelected: filter.type == 'full_time', onTap: () => ref.read(jobFilterProvider.notifier).state = JobFilter(type: 'full_time', field: filter.field, search: filter.search)),
                  _FilterChip(label: '🏠 Remote', isSelected: filter.type == 'remote', onTap: () => ref.read(jobFilterProvider.notifier).state = JobFilter(type: 'remote', field: filter.field, search: filter.search)),
                  _FilterChip(label: '⏰ Part-Time', isSelected: filter.type == 'part_time', onTap: () => ref.read(jobFilterProvider.notifier).state = JobFilter(type: 'part_time', field: filter.field, search: filter.search)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Field filter
            if (fields.isNotEmpty)
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _FieldChip(label: 'All Fields', isSelected: filter.field == null, onTap: () => ref.read(jobFilterProvider.notifier).state = filter.copyWith(field: null)),
                    ...fields.map((f) => _FieldChip(label: f, isSelected: filter.field == f, onTap: () => ref.read(jobFilterProvider.notifier).state = JobFilter(type: filter.type, field: f, search: filter.search))),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('${filtered.length} ${filtered.length == 1 ? 'opportunity' : 'opportunities'} found', style: TextStyle(fontSize: 12, color: AppColors.textTertiaryLight)),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: jobsState.when(
                initial: () => const AppLoadingIndicator(),
                loading: () => const AppLoadingIndicator(message: 'Loading jobs...'),
                error: (msg) => AppErrorView(message: msg, onRetry: () => ref.read(jobsProvider.notifier).load()),
                success: (_) {
                  if (filtered.isEmpty) {
                    return const AppEmptyView(icon: Icons.work_off_rounded, title: 'No jobs found', subtitle: 'Try a different filter or search');
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _JobCard(job: filtered[i]),
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

class _JobCard extends StatefulWidget {
  final JobModel job;
  const _JobCard({required this.job});

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    final color = _typeColor(j.jobType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: j.isDeadlinePassed ? AppColors.error.withValues(alpha: 0.2) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_typeIcon(j.jobType), color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(j.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(j.company, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(j.typeLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.location_on_rounded, size: 12, color: AppColors.textTertiaryLight),
                            const SizedBox(width: 2),
                            Text(j.location, style: const TextStyle(fontSize: 11, color: AppColors.textTertiaryLight)),
                            if (j.deadline != null) ...[
                              const Spacer(),
                              Text(
                                j.isDeadlinePassed ? 'Expired' : '${j.daysLeft}d left',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: j.isDeadlinePassed ? AppColors.error : j.daysLeft! < 14 ? AppColors.warning : AppColors.textTertiaryLight),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20, color: AppColors.textTertiaryLight),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  if (j.salaryRange != null) ...[
                    Row(children: [
                      Icon(Icons.payments_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(j.salaryRange!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                    ]),
                    const SizedBox(height: 8),
                  ],
                  if (j.description != null) ...[
                    Text(j.description!, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 8),
                  ],
                  if (j.requirements != null) ...[
                    Text('Requirements', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(j.requirements!, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 8),
                  ],
                  if (j.deadline != null) ...[
                    Row(children: [
                      Icon(Icons.event_rounded, size: 14, color: AppColors.textTertiaryLight),
                      const SizedBox(width: 6),
                      Text('Deadline: ${DateFormat('MMM d, yyyy').format(j.deadline!)}', style: TextStyle(fontSize: 12, color: j.isDeadlinePassed ? AppColors.error : AppColors.textSecondaryLight)),
                    ]),
                    const SizedBox(height: 10),
                  ],
                  if (j.applyUrl != null && !j.isDeadlinePassed)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(j.applyUrl!);
                          if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const Text('Apply Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Color _typeColor(String t) {
    switch (t) {
      case 'internship': return AppColors.primary;
      case 'full_time': return AppColors.success;
      case 'part_time': return AppColors.accent;
      case 'remote': return AppColors.info;
      case 'contract': return AppColors.secondary;
      default: return AppColors.primary;
    }
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'internship': return Icons.school_rounded;
      case 'full_time': return Icons.work_rounded;
      case 'part_time': return Icons.access_time_rounded;
      case 'remote': return Icons.home_work_rounded;
      case 'contract': return Icons.description_rounded;
      default: return Icons.work_outline_rounded;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimaryLight)),
        ),
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FieldChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.secondary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
          ),
          child: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, color: isSelected ? AppColors.secondary : AppColors.textSecondaryLight)),
        ),
      ),
    );
  }
}