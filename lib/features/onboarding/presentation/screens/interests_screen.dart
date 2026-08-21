import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

class InterestsScreen extends ConsumerWidget {
  const InterestsScreen({super.key});

  static const _careerInterests = [
    'Software Engineering',
    'Data Science',
    'Artificial Intelligence',
    'Cybersecurity',
    'Medicine',
    'Dentistry',
    'Pharmacy',
    'Civil Engineering',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Business & Finance',
    'Accounting',
    'Marketing',
    'Law',
    'Media & Journalism',
    'Architecture',
    'Graphic Design',
    'Teaching',
    'Psychology',
    'Agriculture',
  ];

  static const _degreeInterests = [
    'Computer Science',
    'Software Engineering',
    'Information Technology',
    'Data Science',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'MBBS',
    'BDS',
    'Pharm-D',
    'BBA',
    'MBA',
    'Accounting & Finance',
    'Economics',
    'Law (LLB)',
    'Mass Communication',
    'Psychology',
    'English Literature',
    'Islamic Studies',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biotechnology',
    'Architecture',
    'Fine Arts',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingDataProvider);

    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingHeader(
            title: 'Your Interests',
            subtitle: 'Select fields you\'re interested in (pick as many as you like)',
          ),

          // Career Interests
          Text('Career Interests', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _careerInterests.map((interest) {
              return InterestChip(
                label: interest,
                isSelected: data.careerInterests.contains(interest),
                onTap: () => ref.read(onboardingDataProvider.notifier).toggleCareerInterest(interest),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Degree Interests
          Text('Degree Interests', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _degreeInterests.map((interest) {
              return InterestChip(
                label: interest,
                isSelected: data.degreeInterests.contains(interest),
                onTap: () => ref.read(onboardingDataProvider.notifier).toggleDegreeInterest(interest),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}