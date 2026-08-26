import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

            // ── Greeting ── fade + slide
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
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.0, 0.0),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      delay: 200.ms,
                      curve: Curves.easeOutBack,
                    ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.05, end: 0, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // ── Banner ── slide up + fade
            InfoBanner(
              icon: Icons.search_rounded,
              title: 'Find Your Dream University',
              subtitle: 'Search & compare universities across Pakistan',
              color: AppColors.primary,
              actionText: 'Explore',
              onAction: () => context.go(RouteNames.explore),
            )
                .animate(delay: 150.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // ── Stats row ──
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
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

            if (profile.matricPercentage != null || profile.fscPercentage != null)
              const SizedBox(height: 24),

            // ── Quick Actions header ──
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge)
                .animate(delay: 400.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 12),

            // ── Quick Actions grid ── stagger each card
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 165,
              ),
              children: [
                QuickActionCard(
                  icon: Icons.calculate_rounded,
                  title: 'Merit Calculator',
                  subtitle: 'Calculate aggregate',
                  color: AppColors.primary,
                  onTap: () => context.go('${RouteNames.tools}/merit'),
                )
                    .animate(delay: 450.ms)
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOut),
                QuickActionCard(
                  icon: Icons.checklist_rounded,
                  title: 'Eligibility Check',
                  subtitle: 'Am I eligible?',
                  color: AppColors.secondary,
                  onTap: () => context.go('${RouteNames.tools}/eligibility'),
                )
                    .animate(delay: 530.ms)
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOut),
                QuickActionCard(
                  icon: Icons.compare_arrows_rounded,
                  title: 'Compare Unis',
                  subtitle: 'Side by side',
                  color: AppColors.accent,
                  onTap: () => context.go('${RouteNames.tools}/compare'),
                )
                    .animate(delay: 610.ms)
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOut),
                QuickActionCard(
                  icon: Icons.card_giftcard_rounded,
                  title: 'Scholarships',
                  subtitle: 'Find funding',
                  color: AppColors.success,
                  onTap: () => context.go(RouteNames.explore),
                )
                    .animate(delay: 690.ms)
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOut),
              ],
            ),

            const SizedBox(height: 24),

            // ── Interests ──
            if (profile.careerInterests.isNotEmpty) ...[
              Text('Your Interests', style: Theme.of(context).textTheme.titleLarge)
                  .animate(delay: 750.ms)
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.careerInterests.take(6).toList().asMap().entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                    ),
                  )
                      .animate(delay: (800 + entry.key * 60).ms)
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.1, end: 0, duration: 300.ms);
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // ── Getting Started ──
            Text('Getting Started', style: Theme.of(context).textTheme.titleLarge)
                .animate(delay: 850.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 12),
            DeadlineCard(
              title: 'Explore Universities',
              subtitle: 'Browse 200+ universities',
              date: 'Start',
              icon: Icons.location_city_rounded,
              color: AppColors.primary,
            )
                .animate(delay: 900.ms)
                .fadeIn(duration: 350.ms)
                .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
            const SizedBox(height: 8),
            DeadlineCard(
              title: 'Take Career Quiz',
              subtitle: 'Find your best-fit career path',
              date: 'Try Now',
              icon: Icons.psychology_rounded,
              color: AppColors.secondary,
            )
                .animate(delay: 970.ms)
                .fadeIn(duration: 350.ms)
                .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
            const SizedBox(height: 8),
            DeadlineCard(
              title: 'Calculate Your Merit',
              subtitle: 'See where you stand',
              date: 'Calculate',
              icon: Icons.calculate_rounded,
              color: AppColors.accent,
            )
                .animate(delay: 1040.ms)
                .fadeIn(duration: 350.ms)
                .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

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

            // ── Greeting ──
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
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.0, 0.0),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      delay: 200.ms,
                      curve: Curves.easeOutBack,
                    ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.05, end: 0, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // ── Stats row 1 ──
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
            )
                .animate(delay: 150.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 12),

            // ── Stats row 2 ──
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
            )
                .animate(delay: 250.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // ── Quick Actions header ──
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge)
                .animate(delay: 350.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 12),

            // ── Quick Actions grid ──
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 165,
              ),
              children: [
                QuickActionCard(
                  icon: Icons.calculate_rounded,
                  title: 'GPA Calculator',
                  subtitle: 'Calculate semester GPA',
                  color: AppColors.primary,
                  onTap: () => context.go('${RouteNames.tools}/gpa'),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOut),
                QuickActionCard(
                  icon: Icons.auto_graph_rounded,
                  title: 'CGPA Calculator',
                  subtitle: 'Overall CGPA',
                  color: AppColors.secondary,
                  onTap: () => context.go('${RouteNames.tools}/cgpa'),
                )
                    .animate(delay: 480.ms)
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOut),
                QuickActionCard(
                  icon: Icons.fact_check_rounded,
                  title: 'Attendance',
                  subtitle: 'Track your classes',
                  color: AppColors.accent,
                  onTap: () => context.go('${RouteNames.tools}/attendance'),
                )
                    .animate(delay: 560.ms)
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOut),
                QuickActionCard(
                  icon: Icons.track_changes_rounded,
                  title: 'Target GPA',
                  subtitle: 'What do I need?',
                  color: AppColors.info,
                  onTap: () => context.go('${RouteNames.tools}/target-gpa'),
                )
                    .animate(delay: 640.ms)
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOut),
              ],
            ),

            const SizedBox(height: 24),

            // ── Add courses banner ──
            InfoBanner(
              icon: Icons.add_circle_outline_rounded,
              title: 'Add Your Courses',
              subtitle: 'Start tracking your semester courses & grades',
              color: AppColors.secondary,
              actionText: 'Add Now',
              onAction: () => context.go(RouteNames.track),
            )
                .animate(delay: 700.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 16),

            // ── Tools & Resources ──
            Text('Tools & Resources', style: Theme.of(context).textTheme.titleLarge)
                .animate(delay: 800.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 12),

            DeadlineCard(
              title: 'Grade Calculator',
              subtitle: 'Know your final grade before exams',
              date: 'Open',
              icon: Icons.grade_rounded,
              color: AppColors.primary,
            )
                .animate(delay: 850.ms)
                .fadeIn(duration: 350.ms)
                .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
            const SizedBox(height: 8),
            DeadlineCard(
              title: 'Degree Progress',
              subtitle: 'Track credits & completion',
              date: 'View',
              icon: Icons.pie_chart_rounded,
              color: AppColors.secondary,
            )
                .animate(delay: 920.ms)
                .fadeIn(duration: 350.ms)
                .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
            const SizedBox(height: 8),
            DeadlineCard(
              title: 'Semester Planner',
              subtitle: 'Plan your upcoming courses',
              date: 'Plan',
              icon: Icons.event_note_rounded,
              color: AppColors.accent,
            )
                .animate(delay: 990.ms)
                .fadeIn(duration: 350.ms)
                .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}