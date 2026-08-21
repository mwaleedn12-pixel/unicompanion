import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

class UserTypeScreen extends ConsumerWidget {
  const UserTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingDataProvider);

    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingHeader(
            title: 'Who are you?',
            subtitle: 'This helps us personalize your experience',
          ),
          SelectableCard(
            icon: Icons.menu_book_rounded,
            title: 'FSC / College Student',
            subtitle: 'Exploring universities & admissions',
            isSelected: data.userType == AppConstants.userTypeFsc,
            onTap: () => ref.read(onboardingDataProvider.notifier).setUserType(AppConstants.userTypeFsc),
          ),
          const SizedBox(height: AppSpacing.base),
          SelectableCard(
            icon: Icons.school_rounded,
            title: 'University Student',
            subtitle: 'Managing academics & tracking progress',
            isSelected: data.userType == AppConstants.userTypeUniversity,
            onTap: () => ref.read(onboardingDataProvider.notifier).setUserType(AppConstants.userTypeUniversity),
          ),
        ],
      ),
    );
  }
}