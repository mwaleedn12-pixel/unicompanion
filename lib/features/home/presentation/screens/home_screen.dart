import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/home_provider.dart';
import '../widgets/home_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);

    return Scaffold(
      body: profileState.when(
        initial: () => const AppLoadingIndicator(),
        loading: () => const AppLoadingIndicator(message: 'Loading your dashboard...'),
        error: (msg) => AppErrorView(
          message: msg,
          onRetry: () => ref.read(userProfileProvider.notifier).loadProfile(),
        ),
        success: (profile) {
          return profile.isFscStudent
              ? _FscHomeView(profile: profile)
              : _UniHomeView(profile: profile);
        },
      ),
    );
  }
}

// ═══════════════════════ FSC STUDENT HOME ═══════════════════════
class _FscHomeView extends StatelessWidget {
  final UserProfile profile;
  const _FscHomeView({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Greeting
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${getGreeting()} 👋',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.firstNameGreeting,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    profile.firstNameGreeting[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Hero Banner
            InfoBanner(
              icon: Icons.search_rounded,
              title: 'Find Your Dream University',
              subtitle: 'Search & compare universities across Pakistan',
              color: AppColors.primary,
              actionText: 'Explore',
              onAction: () => context.go(RouteNames.explore),
            ),

            const SizedBox(height: 24),

            // Stats Row
            if (profile.matricPercentage != null || profile.fscPercentage != null)
              Row(
                children: [
                  if (profile.matricPercentage != null)
                    Expanded(
                      child: DashboardStatCard(
                        label: 'Matric',
                        value: '${profile.matricPercentage!.toStringAsFixed(1)}%',
                        icon: Icons.school_outlined,
                        color: AppColors.secondary,
                        subtitle: 'Percentage',
                      ),
                    ),
                  if (profile.matricPercentage != null && profile.fscPercentage != null)
                    const SizedBox(width: 12),
                  if (profile.fscPercentage != null)
                    Expanded(
                      child: DashboardStatCard(
                        label: 'FSC / A-Level',
                        value: '${profile.fscPercentage!.toStringAsFixed(1)}%',
                        icon: Icons.auto_graph_rounded,
                        color: AppColors.primary,
                        subtitle: profile.fscStream?.replaceAll('_', ' ').toUpperCase() ?? '',
                      ),
                    ),
                ],
              ),

            if (profile.matricPercentage != null || profile.fscPercentage != null)
              const SizedBox(height: 24),

            // Quick Actions
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                QuickActionCard(
                  icon: Icons.calculate_rounded,
                  title: 'Merit Calculator',
                  subtitle: 'Calculate aggregate',
                  color: AppColors.primary,
                  onTap: () => context.go('${RouteNames.tools}/merit'),
                ),
                QuickActionCard(
                  icon: Icons.checklist_rounded,
                  title: 'Eligibility Check',
                  subtitle: 'Am I eligible?',
                  color: AppColors.secondary,
                  onTap: () => context.go('${RouteNames.tools}/eligibility'),
                ),
                QuickActionCard(
                  icon: Icons.compare_arrows_rounded,
                  title: 'Compare Unis',
                  subtitle: 'Side by side',
                  color: AppColors.accent,
                  onTap: () => context.go(RouteNames.explore),
                ),
                QuickActionCard(
                  icon: Icons.card_giftcard_rounded,
                  title: 'Scholarships',
                  subtitle: 'Find funding',
                  color: AppColors.success,
                  onTap: () => context.go(RouteNames.explore),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Interests
            if (profile.careerInterests.isNotEmpty) ...[
              Text('Your Interests', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.careerInterests.take(6).map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      interest,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Tips Section
            Text('Getting Started', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            DeadlineCard(
              title: 'Explore Universities',
              subtitle: 'Browse 200+ universities',
              date: 'Start',
              icon: Icons.location_city_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            DeadlineCard(
              title: 'Take Career Quiz',
              subtitle: 'Find your best-fit career path',
              date: 'Try Now',
              icon: Icons.psychology_rounded,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 8),
            DeadlineCard(
              title: 'Calculate Your Merit',
              subtitle: 'See where you stand',
              date: 'Calculate',
              icon: Icons.calculate_rounded,
              color: AppColors.accent,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════ UNIVERSITY STUDENT HOME ═══════════════════════
class _UniHomeView extends StatelessWidget {
  final UserProfile profile;
  const _UniHomeView({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Greeting
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${getGreeting()} 👋',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.firstNameGreeting,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (profile.currentSemester != null)
                        Text(
                          'Semester ${profile.currentSemester}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
                        ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.secondarySurface,
                  child: Text(
                    profile.firstNameGreeting[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700, fontSize: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Academic Stats
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    label: 'CGPA',
                    value: '0.00',
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.primary,
                    subtitle: 'Add courses',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    label: 'Attendance',
                    value: '0%',
                    icon: Icons.fact_check_rounded,
                    color: AppColors.secondary,
                    subtitle: 'Track now',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    label: 'Credits Done',
                    value: '0',
                    icon: Icons.school_rounded,
                    color: AppColors.accent,
                    subtitle: 'of 130+',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    label: 'Semester',
                    value: '${profile.currentSemester ?? 1}',
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.info,
                    subtitle: 'Current',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                QuickActionCard(
                  icon: Icons.calculate_rounded,
                  title: 'GPA Calculator',
                  subtitle: 'Calculate semester GPA',
                  color: AppColors.primary,
                  onTap: () => context.go('${RouteNames.tools}/gpa'),
                ),
                QuickActionCard(
                  icon: Icons.auto_graph_rounded,
                  title: 'CGPA Calculator',
                  subtitle: 'Overall CGPA',
                  color: AppColors.secondary,
                  onTap: () => context.go('${RouteNames.tools}/cgpa'),
                ),
                QuickActionCard(
                  icon: Icons.fact_check_rounded,
                  title: 'Attendance',
                  subtitle: 'Track your classes',
                  color: AppColors.accent,
                  onTap: () => context.go('${RouteNames.tools}/attendance'),
                ),
                QuickActionCard(
                  icon: Icons.track_changes_rounded,
                  title: 'Target GPA',
                  subtitle: 'What do I need?',
                  color: AppColors.info,
                  onTap: () => context.go('${RouteNames.tools}/target-gpa'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Getting Started
            InfoBanner(
              icon: Icons.add_circle_outline_rounded,
              title: 'Add Your Courses',
              subtitle: 'Start tracking your semester courses & grades',
              color: AppColors.secondary,
              actionText: 'Add Now',
              onAction: () => context.go(RouteNames.track),
            ),

            const SizedBox(height: 16),

            // Tips
            Text('Tools & Resources', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            DeadlineCard(
              title: 'Grade Calculator',
              subtitle: 'Know your final grade before exams',
              date: 'Open',
              icon: Icons.grade_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            DeadlineCard(
              title: 'Degree Progress',
              subtitle: 'Track credits & completion',
              date: 'View',
              icon: Icons.pie_chart_rounded,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 8),
            DeadlineCard(
              title: 'Semester Planner',
              subtitle: 'Plan your upcoming courses',
              date: 'Plan',
              icon: Icons.event_note_rounded,
              color: AppColors.accent,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}