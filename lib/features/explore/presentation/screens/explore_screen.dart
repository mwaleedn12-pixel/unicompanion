import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/explore_provider.dart';
import '../widgets/explore_widgets.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uniState = ref.watch(universitiesProvider);
    final filter = ref.watch(exploreFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ── fade + slide
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explore', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Find your dream university', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.05, end: 0, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 16),

            // ── Search bar ── fade + slide down
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(exploreFilterProvider.notifier).state = filter.copyWith(search: value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search universities...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiaryLight),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(exploreFilterProvider.notifier).state = filter.copyWith(search: '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            )
                .animate(delay: 100.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOut),

            const SizedBox(height: 12),

            // ── Quick buttons row 1 ── stagger
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _QuickButton(icon: Icons.card_giftcard_rounded, label: 'Scholarships', color: AppColors.success, onTap: () => context.go('/scholarships'))),
                  const SizedBox(width: 10),
                  Expanded(child: _QuickButton(icon: Icons.psychology_rounded, label: 'Career Quiz', color: AppColors.primary, onTap: () => context.go('/career-quiz'))),
                ],
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOut),

            const SizedBox(height: 8),

            // ── Quick buttons row 2 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _QuickButton(icon: Icons.menu_book_rounded, label: 'Programs', color: AppColors.accentDark, bgColor: AppColors.accentSurface, onTap: () => context.go('/programs'))),
                  const SizedBox(width: 10),
                  Expanded(child: _QuickButton(icon: Icons.location_city_rounded, label: 'Campuses', color: AppColors.secondaryDark, bgColor: AppColors.secondarySurface, onTap: () => context.go('/campuses'))),
                ],
              ),
            )
                .animate(delay: 280.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOut),

            const SizedBox(height: 8),

            // ── Quick buttons row 3 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _QuickButton(icon: Icons.smart_toy_rounded, label: 'AI Help', color: const Color(0xFF8B5CF6), bgColor: const Color(0xFFF3E8FF), onTap: () => context.go(RouteNames.aiAssistant))),
                  const SizedBox(width: 8),
                  Expanded(child: _QuickButton(icon: Icons.work_rounded, label: 'Jobs', color: const Color(0xFF0891B2), bgColor: const Color(0xFFE0F7FA), onTap: () => context.go(RouteNames.jobs))),
                  const SizedBox(width: 8),
                  Expanded(child: _QuickButton(icon: Icons.forum_rounded, label: 'Community', color: const Color(0xFFEA580C), bgColor: const Color(0xFFFFF3E0), onTap: () => context.go(RouteNames.community))),
                ],
              ),
            )
                .animate(delay: 360.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOut),

            const SizedBox(height: 12),

            // ── Filter chips ── slide in from right
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  FilterChipButton(label: 'All', isSelected: filter.type == 'all', onTap: () => ref.read(exploreFilterProvider.notifier).state = filter.copyWith(type: 'all')),
                  const SizedBox(width: 8),
                  FilterChipButton(label: 'Public', isSelected: filter.type == 'public', onTap: () => ref.read(exploreFilterProvider.notifier).state = filter.copyWith(type: 'public')),
                  const SizedBox(width: 8),
                  FilterChipButton(label: 'Private', isSelected: filter.type == 'private', onTap: () => ref.read(exploreFilterProvider.notifier).state = filter.copyWith(type: 'private')),
                  const SizedBox(width: 16),
                  Container(width: 1, height: 24, color: AppColors.dividerLight),
                  const SizedBox(width: 16),
                  FilterChipButton(label: '🏆 By Ranking', isSelected: filter.sortBy == 'ranking', onTap: () => ref.read(exploreFilterProvider.notifier).state = filter.copyWith(sortBy: 'ranking')),
                  const SizedBox(width: 8),
                  FilterChipButton(label: 'A-Z', isSelected: filter.sortBy == 'name', onTap: () => ref.read(exploreFilterProvider.notifier).state = filter.copyWith(sortBy: 'name')),
                ],
              ),
            )
                .animate(delay: 420.ms)
                .fadeIn(duration: 350.ms)
                .slideX(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOut),

            const SizedBox(height: 12),

            // ── Count label ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: uniState.when(
                initial: () => const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_) => const SizedBox.shrink(),
                success: (list) => Text('${list.length} universities found', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)),
              ),
            )
                .animate(delay: 480.ms)
                .fadeIn(duration: 300.ms),

            const SizedBox(height: 8),

            // ── University list ──
            Expanded(
              child: uniState.when(
                initial: () => const AppLoadingIndicator(),
                loading: () => const AppLoadingIndicator(message: 'Loading universities...'),
                error: (msg) => AppErrorView(message: msg),
                success: (universities) {
                  if (universities.isEmpty) {
                    return const AppEmptyView(icon: Icons.school_outlined, title: 'No universities found', subtitle: 'Try a different search or filter');
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: universities.length,
                    itemBuilder: (context, index) {
                      final uni = universities[index];
                      return UniversityCard(
                        university: uni,
                        onTap: () => context.push('/explore/university/${uni.id}'),
                      )
                          .animate()
                          .fadeIn(duration: 350.ms, delay: (index.clamp(0, 8) * 50).ms)
                          .slideY(begin: 0.05, end: 0, duration: 350.ms, delay: (index.clamp(0, 8) * 50).ms, curve: Curves.easeOut);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact quick-action button for explore grid
class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? bgColor;
  final VoidCallback onTap;

  const _QuickButton({required this.icon, required this.label, required this.color, this.bgColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = bgColor ?? color.withValues(alpha: 0.08);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}