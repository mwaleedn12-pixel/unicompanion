import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/application_model.dart';
import '../providers/application_provider.dart';
import '../providers/shortlist_provider.dart';

class ApplicationTrackerScreen extends ConsumerWidget {
  const ApplicationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(applicationsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddApplicationSheet(context, ref),
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
                    child: Text('Application Tracker', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.when(
                initial: () => const AppLoadingIndicator(),
                loading: () => const AppLoadingIndicator(message: 'Loading applications...'),
                error: (msg) => AppErrorView(message: msg, onRetry: () => ref.read(applicationsProvider.notifier).load()),
                success: (applications) {
                  if (applications.isEmpty) {
                    return AppEmptyView(
                      icon: Icons.checklist_rounded,
                      title: 'No Applications Yet',
                      subtitle: 'Add a university application to start tracking its status and deadline',
                      action: PrimaryButton(
                        text: 'Add Application',
                        icon: Icons.add_rounded,
                        onPressed: () => _showAddApplicationSheet(context, ref),
                      ),
                    );
                  }

                  // Group by status stage for a simple kanban-style scroll
                  final grouped = <String, List<ApplicationModel>>{};
                  for (final a in applications) {
                    grouped.putIfAbsent(a.status, () => []).add(a);
                  }
                  final orderedStatuses = AppConstants.applicationStatuses.keys.where((s) => grouped.containsKey(s)).toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                    children: [
                      for (final status in orderedStatuses) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 10),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: _statusColor(status), shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(
                                AppConstants.applicationStatuses[status] ?? status,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 6),
                              Text('(${grouped[status]!.length})', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)),
                            ],
                          ),
                        ),
                        ...grouped[status]!.map((a) => _ApplicationCard(application: a)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'selected': return AppColors.success;
      case 'rejected':
      case 'withdrawn': return AppColors.error;
      case 'applied':
      case 'test_taken':
      case 'interview': return AppColors.primary;
      default: return AppColors.textTertiaryLight;
    }
  }

  void _showAddApplicationSheet(BuildContext context, WidgetRef ref) {
    final shortlist = ref.read(shortlistProvider).dataOrNull ?? [];
    final programController = TextEditingController();
    String? selectedUniversityId = shortlist.isNotEmpty ? shortlist.first.universityId : null;
    String status = 'interested';
    DateTime? deadline;

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
                    Text('Add Application', style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.lg),

                    if (shortlist.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.warningSurface, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warning),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Shortlist a university from Explore first to track its application.', style: TextStyle(fontSize: 13, color: AppColors.warning))),
                          ],
                        ),
                      )
                    else ...[
                      Text('University', style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedUniversityId,
                        items: shortlist.map((s) => DropdownMenuItem(value: s.universityId, child: Text(s.universityName, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setState(() => selectedUniversityId = v),
                      ),
                      const SizedBox(height: AppSpacing.base),

                      TextField(controller: programController, decoration: const InputDecoration(labelText: 'Program (optional)', hintText: 'e.g. BS Computer Science')),
                      const SizedBox(height: AppSpacing.base),

                      Text('Status', style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.applicationStatuses.entries.map((entry) {
                          final isSelected = status == entry.key;
                          final color = _statusColor(entry.key);
                          return ChoiceChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            onSelected: (_) => setState(() => status = entry.key),
                            selectedColor: color.withValues(alpha: 0.15),
                            labelStyle: TextStyle(color: isSelected ? color : null, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, fontSize: 12),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.base),

                      Row(
                        children: [
                          Text('Deadline (optional)', style: Theme.of(sheetContext).textTheme.bodyMedium),
                          const Spacer(),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_today_rounded, size: 16),
                            label: Text(deadline != null ? DateFormat('MMM d, yyyy').format(deadline!) : 'Set date'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: sheetContext,
                                initialDate: DateTime.now().add(const Duration(days: 30)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                              );
                              if (picked != null) setState(() => deadline = picked);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      PrimaryButton(
                        text: 'Add Application',
                        onPressed: selectedUniversityId == null
                            ? null
                            : () async {
                                final ok = await ref.read(applicationsProvider.notifier).addApplication(
                                      universityId: selectedUniversityId!,
                                      programName: programController.text.trim().isEmpty ? null : programController.text.trim(),
                                      status: status,
                                      deadline: deadline,
                                    );
                                if (sheetContext.mounted) Navigator.pop(sheetContext);
                                if (context.mounted) {
                                  ok ? context.showSuccessSnackBar('Application added') : context.showSnackBar('Failed to add application', isError: true);
                                }
                              },
                      ),
                    ],
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

class _ApplicationCard extends ConsumerWidget {
  final ApplicationModel application;
  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ApplicationTrackerScreen._statusColor(application.status);

    return Dismissible(
      key: ValueKey(application.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => ref.read(applicationsProvider.notifier).deleteApplication(application.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: application.isDeadlineSoon ? AppColors.warning.withValues(alpha: 0.4) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.account_balance_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application.universityName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  if (application.programName != null)
                    Text(application.programName!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                  if (application.deadline != null)
                    Text(
                      'Deadline: ${DateFormat('MMM d, yyyy').format(application.deadline!)}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: application.isDeadlineSoon ? AppColors.warning : AppColors.textTertiaryLight),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onSelected: (newStatus) => ref.read(applicationsProvider.notifier).updateStatus(application, newStatus),
              itemBuilder: (context) => AppConstants.applicationStatuses.entries
                  .map((e) => PopupMenuItem(value: e.key, child: Text('Move to ${e.value}')))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}