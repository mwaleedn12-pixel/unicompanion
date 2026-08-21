import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/models/university_model.dart';
import '../providers/explore_provider.dart';

class UniversityDetailScreen extends ConsumerWidget {
  final String universityId;

  const UniversityDetailScreen({super.key, required this.universityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniAsync = ref.watch(universityDetailProvider(universityId));

    return Scaffold(
      body: uniAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorView(message: 'Failed to load: $e'),
        data: (university) {
          if (university == null) return const AppErrorView(message: 'University not found');
          return _DetailBody(university: university);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final UniversityModel university;
  const _DetailBody({required this.university});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero Header
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimaryLight),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: university.type == 'public'
                      ? [AppColors.primary, AppColors.primaryLight]
                      : [AppColors.secondary, AppColors.secondaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          university.initials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        university.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Info Row
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.account_balance_rounded,
                      label: university.typeLabel,
                      color: university.type == 'public' ? AppColors.primary : AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    if (university.rankingNational != null)
                      _InfoChip(
                        icon: Icons.emoji_events_rounded,
                        label: 'Rank #${university.rankingNational}',
                        color: AppColors.accent,
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // About
                if (university.description != null) ...[
                  Text('About', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      university.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6, color: AppColors.textSecondaryLight),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Website Button
                if (university.website != null)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(university.website!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 20),
                      label: const Text('Visit Website'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Placeholder sections
                _ComingSoonSection(title: 'Programs Offered', icon: Icons.menu_book_rounded),
                const SizedBox(height: 12),
                _ComingSoonSection(title: 'Fee Structure', icon: Icons.payments_rounded),
                const SizedBox(height: 12),
                _ComingSoonSection(title: 'Admission Dates', icon: Icons.calendar_month_rounded),
                const SizedBox(height: 12),
                _ComingSoonSection(title: 'Scholarships', icon: Icons.card_giftcard_rounded),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _ComingSoonSection extends StatelessWidget {
  final String title;
  final IconData icon;
  const _ComingSoonSection({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Coming Soon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentDark)),
          ),
        ],
      ),
    );
  }
}