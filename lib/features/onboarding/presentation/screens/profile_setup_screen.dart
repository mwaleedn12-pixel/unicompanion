import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _matricController = TextEditingController();
  final _fscController = TextEditingController();

  @override
  void dispose() {
    _matricController.dispose();
    _fscController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingDataProvider);
    final isFsc = data.userType == AppConstants.userTypeFsc;

    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingHeader(
            title: isFsc ? 'Your Academics' : 'University Info',
            subtitle: isFsc
                ? 'Tell us about your marks & preferences'
                : 'Tell us about your current studies',
          ),

          if (isFsc) ..._buildFscFields(context, ref, data),
          if (!isFsc) ..._buildUniFields(context, ref, data),
        ],
      ),
    );
  }

  List<Widget> _buildFscFields(BuildContext context, WidgetRef ref, OnboardingData data) {
    return [
      // Matric Percentage
      TextFormField(
        controller: _matricController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Matric / O-Level Percentage', suffixText: '%'),
        onChanged: (v) {
          final val = double.tryParse(v);
          if (val != null) ref.read(onboardingDataProvider.notifier).setMatricPercentage(val);
        },
      ),
      const SizedBox(height: AppSpacing.base),

      // FSC Percentage
      TextFormField(
        controller: _fscController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'FSC / A-Level Percentage (if available)', suffixText: '%'),
        onChanged: (v) {
          final val = double.tryParse(v);
          if (val != null) ref.read(onboardingDataProvider.notifier).setFscPercentage(val);
        },
      ),
      const SizedBox(height: AppSpacing.xl),

      // FSC Stream
      Text('Your Stream', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: AppConstants.fscStreams.entries.map((entry) {
          final isSelected = data.fscStream == entry.key;
          return InterestChip(
            label: entry.value,
            isSelected: isSelected,
            onTap: () => ref.read(onboardingDataProvider.notifier).setFscStream(entry.key),
          );
        }).toList(),
      ),
      const SizedBox(height: AppSpacing.xl),

      // University Type Preference
      Text('Preferred University Type', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          InterestChip(label: 'Public', isSelected: data.preferredUniType == 'public', onTap: () => ref.read(onboardingDataProvider.notifier).setPreferredUniType('public')),
          InterestChip(label: 'Private', isSelected: data.preferredUniType == 'private', onTap: () => ref.read(onboardingDataProvider.notifier).setPreferredUniType('private')),
          InterestChip(label: 'Any', isSelected: data.preferredUniType == 'any', onTap: () => ref.read(onboardingDataProvider.notifier).setPreferredUniType('any')),
        ],
      ),
      const SizedBox(height: AppSpacing.xl),

      // Budget
      Text('Budget Range', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          InterestChip(label: 'Low (< 1 Lac/sem)', isSelected: data.budgetRange == 'low', onTap: () => ref.read(onboardingDataProvider.notifier).setBudgetRange('low')),
          InterestChip(label: 'Medium (1-3 Lac)', isSelected: data.budgetRange == 'medium', onTap: () => ref.read(onboardingDataProvider.notifier).setBudgetRange('medium')),
          InterestChip(label: 'High (3+ Lac)', isSelected: data.budgetRange == 'high', onTap: () => ref.read(onboardingDataProvider.notifier).setBudgetRange('high')),
        ],
      ),
      const SizedBox(height: AppSpacing.xl),

      // Hostel
      SwitchListTile(
        title: Text('Need Hostel?', style: Theme.of(context).textTheme.titleMedium),
        subtitle: const Text('Do you need on-campus accommodation?'),
        value: data.needsHostel ?? false,
        onChanged: (v) => ref.read(onboardingDataProvider.notifier).setNeedsHostel(v),
        contentPadding: EdgeInsets.zero,
      ),
    ];
  }

  List<Widget> _buildUniFields(BuildContext context, WidgetRef ref, OnboardingData data) {
    return [
      // Current Semester
      TextFormField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Current Semester'),
        onChanged: (v) {
          final val = int.tryParse(v);
          if (val != null) ref.read(onboardingDataProvider.notifier).setCurrentSemester(val);
        },
      ),
      const SizedBox(height: AppSpacing.base),

      // Enrollment Year
      TextFormField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Enrollment Year', hintText: 'e.g. 2023'),
        onChanged: (v) {
          final val = int.tryParse(v);
          if (val != null) ref.read(onboardingDataProvider.notifier).setEnrollmentYear(val);
        },
      ),
      const SizedBox(height: AppSpacing.base),

      // Note about university selection
      Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'You can select your university and program from the Explore section after setup.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}