import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';
import 'user_type_screen.dart';
import 'profile_setup_screen.dart';
import 'interests_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final data = ref.read(onboardingDataProvider);

    // Validate current page
    if (_currentPage == 0 && data.userType.isEmpty) {
      context.showSnackBar('Please select who you are', isError: true);
      return;
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() async {
    final data = ref.read(onboardingDataProvider);
    final success = await ref.read(saveOnboardingProvider.notifier).saveProfile(data);

    if (success && mounted) {
      context.go(RouteNames.home);
    } else if (mounted) {
      final error = ref.read(saveOnboardingProvider).when(
            initial: () => '',
            loading: () => '',
            success: (_) => '',
            error: (msg) => msg,
          );
      if (error.isNotEmpty) context.showSnackBar(error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(saveOnboardingProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: _previousPage,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: StepIndicator(
                      totalSteps: _totalPages,
                      currentStep: _currentPage,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Skip onboarding — save minimal profile
                      ref.read(onboardingDataProvider.notifier).setUserType(AppConstants.userTypeFsc);
                      _finishOnboarding();
                    },
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [
                  UserTypeScreen(),
                  ProfileSetupScreen(),
                  InterestsScreen(),
                ],
              ),
            ),

            // Bottom Button
            Padding(
              padding: AppSpacing.screenPaddingAll,
              child: PrimaryButton(
                text: _currentPage == _totalPages - 1 ? 'Get Started' : 'Continue',
                isLoading: saveState.isLoading,
                onPressed: _nextPage,
                icon: _currentPage == _totalPages - 1 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}