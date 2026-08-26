import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/utils/app_haptics.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int d = 0;
    const step = 60;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Tools', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800))
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.05, end: 0, duration: 400.ms, curve: Curves.easeOut),
              const SizedBox(height: 4),
              Text('Academic calculators & utilities', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight))
                  .animate(delay: 80.ms)
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 24),

              // ── Section: Calculators ──
              Text('Calculators', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))
                  .animate(delay: (d += 150).ms)
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 12),

              _ToolCard(
                icon: Icons.calculate_rounded,
                title: 'GPA Calculator',
                subtitle: 'Calculate your semester GPA with any grading system',
                gradient: [AppColors.primary, AppColors.primaryLight],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/gpa'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),
              _ToolCard(
                icon: Icons.auto_graph_rounded,
                title: 'CGPA Calculator',
                subtitle: 'Calculate cumulative GPA across all semesters',
                gradient: [AppColors.secondary, AppColors.secondaryLight],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/cgpa'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),
              _ToolCard(
                icon: Icons.track_changes_rounded,
                title: 'Target GPA',
                subtitle: 'Find out what GPA you need this semester',
                gradient: [AppColors.info, const Color(0xFF93C5FD)],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/target-gpa'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),
              _ToolCard(
                icon: Icons.fact_check_rounded,
                title: 'Attendance Calculator',
                subtitle: 'Track attendance & know how many classes you can miss',
                gradient: [AppColors.accent, AppColors.accentLight],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/attendance'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),
              _ToolCard(
                icon: Icons.grade_rounded,
                title: 'Grade Calculator',
                subtitle: 'Know your grade before the final exam',
                gradient: [const Color(0xFFEC4899), const Color(0xFFF472B6)],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/grade'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),

              const SizedBox(height: 24),

              // ── Section: Admission Tools ──
              Text('Admission Tools', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 12),

              _ToolCard(
                icon: Icons.percent_rounded,
                title: 'Merit Calculator',
                subtitle: 'Calculate your aggregate for any university',
                gradient: [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/merit'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),
              _ToolCard(
                icon: Icons.verified_rounded,
                title: 'Eligibility Checker',
                subtitle: 'Check if you meet requirements for a program',
                gradient: [AppColors.success, const Color(0xFF86EFAC)],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/eligibility'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),
              _ToolCard(
                icon: Icons.compare_arrows_rounded,
                title: 'Compare Universities',
                subtitle: 'Side-by-side university comparison',
                gradient: [const Color(0xFF6366F1), const Color(0xFF818CF8)],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/compare'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),

              // ── #3 — Fee Comparison (NEW) ──
              _ToolCard(
                icon: Icons.bar_chart_rounded,
                title: 'Fee Comparison',
                subtitle: 'Compare fees across universities visually',
                gradient: [const Color(0xFF0891B2), const Color(0xFF67E8F9)],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/fee-compare'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),

              // ── #5 — Admission Probability (NEW) ──
              _ToolCard(
                icon: Icons.trending_up_rounded,
                title: 'Admission Probability',
                subtitle: 'Estimate your chances based on merit formula',
                gradient: [const Color(0xFFDC2626), const Color(0xFFF87171)],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/probability'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),

              const SizedBox(height: 24),

              // ── Section: Test & Match ──
              Text('Test & Match', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 12),

              _ToolCard(
                icon: Icons.quiz_rounded,
                title: 'Entry Test Prep',
                subtitle: 'Practice MCQs for ECAT, MDCAT, NET & more with timer',
                gradient: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/test-prep'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),
              _ToolCard(
                icon: Icons.hub_rounded,
                title: 'University Match',
                subtitle: 'Answer 5 questions and find your best-fit universities',
                gradient: [const Color(0xFF14B8A6), const Color(0xFF5EEAD4)],
                onTap: () { AppHaptics.light(); context.go('${RouteNames.tools}/match'); },
              )
                  .animate(delay: (d += step).ms)
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: gradient[0].withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: gradient[0].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: gradient[0]),
            ),
          ],
        ),
      ),
    );
  }
}