import 'package:flutter/material.dart';
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
            ),

            const SizedBox(height: 16),

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
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.go('/scholarships'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.card_giftcard_rounded, size: 18, color: AppColors.success),
                              const SizedBox(width: 6),
                              Text('Scholarships', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Material(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.go('/career-quiz'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.psychology_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text('Career Quiz', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Row 2: Programs + Campuses
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: AppColors.accentSurface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.go('/programs'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book_rounded, size: 18, color: AppColors.accentDark),
                              const SizedBox(width: 6),
                              Text('Programs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accentDark)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Material(
                      color: AppColors.secondarySurface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.go('/campuses'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_city_rounded, size: 18, color: AppColors.secondaryDark),
                              const SizedBox(width: 6),
                              Text('Campuses', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryDark)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

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
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: uniState.when(
                initial: () => const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_) => const SizedBox.shrink(),
                success: (list) => Text('${list.length} universities found', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)),
              ),
            ),

            const SizedBox(height: 8),

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
                      );
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