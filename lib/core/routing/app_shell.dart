import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/feature_tour.dart';

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // GlobalKeys for tour targets
  final _homeKey = GlobalKey();
  final _exploreKey = GlobalKey();
  final _toolsKey = GlobalKey();
  final _trackKey = GlobalKey();
  final _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Show tour after the first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTourIfNeeded();
    });
  }

  Future<void> _showTourIfNeeded() async {
    if (!mounted) return;
    // Small delay so the home screen loads fully
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    FeatureTour.showIfFirstTime(context, 'main_nav_tour', [
      TourStep(
        targetKey: _homeKey,
        title: 'Home Dashboard',
        description: 'Your personalized academic dashboard with stats, quick actions, and recommendations.',
        icon: Icons.home_rounded,
        color: AppColors.primary,
      ),
      TourStep(
        targetKey: _exploreKey,
        title: 'Explore Universities',
        description: 'Browse 268+ Pakistani universities, compare programs, fees, and campuses.',
        icon: Icons.explore_rounded,
        color: AppColors.secondary,
      ),
      TourStep(
        targetKey: _toolsKey,
        title: 'Academic Tools',
        description: 'GPA, CGPA, merit, attendance and grade calculators — all in one place.',
        icon: Icons.build_rounded,
        color: AppColors.accent,
      ),
      TourStep(
        targetKey: _trackKey,
        title: 'Track Progress',
        description: 'Track your applications, semesters, courses, assignments, and deadlines.',
        icon: Icons.checklist_rounded,
        color: AppColors.info,
      ),
      TourStep(
        targetKey: _profileKey,
        title: 'Your Profile',
        description: 'Manage settings, dark mode, language, and view your academic info.',
        icon: Icons.person_rounded,
        color: const Color(0xFF8B5CF6),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            key: _homeKey,
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            key: _exploreKey,
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            key: _toolsKey,
            icon: const Icon(Icons.build_outlined),
            selectedIcon: const Icon(Icons.build_rounded),
            label: 'Tools',
          ),
          NavigationDestination(
            key: _trackKey,
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist_rounded),
            label: 'Track',
          ),
          NavigationDestination(
            key: _profileKey,
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}