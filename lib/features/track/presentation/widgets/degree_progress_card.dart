import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../academics/presentation/providers/semester_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

const int kDefaultTotalCredits = 130;
const int kDefaultTotalSemesters = 8;
const int kSemesterLengthMonths = 5;

class DegreeProgressCard extends ConsumerWidget {
  const DegreeProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.dataOrNull;

    final creditsEarned = ref.watch(totalCompletedCreditsProvider);
    final totalRequired = profile?.totalCreditsRequired ?? kDefaultTotalCredits;
    final totalSemesters = profile?.totalSemestersRequired ?? kDefaultTotalSemesters;

    final semestersState = ref.watch(semestersProvider);
    final completedSemesterCount = (semestersState.dataOrNull ?? const []).where((s) => s.isCompleted).length;

    final creditsRemaining = (totalRequired - creditsEarned).clamp(0, 1 << 30).toInt();
    final progressFraction = totalRequired == 0 ? 0.0 : (creditsEarned / totalRequired).clamp(0.0, 1.0);
    final semestersRemaining = (totalSemesters - completedSemesterCount).clamp(0, 1 << 30);
    final now = DateTime.now();
    final estimatedGradDate = DateTime(now.year, now.month + semestersRemaining * kSemesterLengthMonths, now.day);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Credits Completed', style: Theme.of(context).textTheme.titleSmall),
              Row(
                children: [
                  Text(
                    '${creditsEarned.toInt()} / $totalRequired',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showConfigSheet(context, ref, totalRequired, totalSemesters),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.tune_rounded, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 10,
              backgroundColor: AppColors.primarySurface,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progressFraction * 100).toStringAsFixed(0)}% Complete', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatTile(label: 'Credits Left', value: '$creditsRemaining')),
              Expanded(child: _StatTile(label: 'Semesters Left', value: '$semestersRemaining')),
              Expanded(child: _StatTile(label: 'Est. Graduation', value: _formatDate(estimatedGradDate))),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.year}';
  }

  void _showConfigSheet(BuildContext context, WidgetRef ref, int currentTotalCredits, int currentTotalSemesters) {
    final creditsController = TextEditingController(text: '$currentTotalCredits');
    final semestersController = TextEditingController(text: '$currentTotalSemesters');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configure Degree Plan', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: creditsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total credits required for your program', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: semestersController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total semesters in your program', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final totalCredits = int.tryParse(creditsController.text) ?? kDefaultTotalCredits;
                  final totalSemesters = int.tryParse(semestersController.text) ?? kDefaultTotalSemesters;

                  final navigator = Navigator.of(ctx);
                  final messenger = ScaffoldMessenger.of(context);

                  final ok = await ref.read(profileActionProvider.notifier).updateProfile({
                    'total_credits_required': totalCredits,
                    'total_semesters_required': totalSemesters,
                  });

                  if (ok) {
                    await ref.read(userProfileProvider.notifier).loadProfile();
                  }

                  navigator.pop();
                  if (!ok) {
                    messenger.showSnackBar(const SnackBar(content: Text('Failed to save — please try again.')));
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}