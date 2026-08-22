import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/models/campus_model.dart';
import '../providers/explore_provider.dart';

class CampusScreen extends ConsumerWidget {
  const CampusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campusesState = ref.watch(campusesProvider);
    final cityFilter = ref.watch(campusCityFilterProvider);
    final citiesAsync = ref.watch(campusCitiesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Campus Profiles',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── City Filter ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _CityChip(
                    label: 'All Cities',
                    selected: cityFilter == 'all',
                    onTap: () => ref.read(campusCityFilterProvider.notifier).state = 'all',
                  ),
                  const SizedBox(width: 8),
                  ...citiesAsync.when(
                    data: (cities) => cities.map((city) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CityChip(
                        label: city,
                        selected: cityFilter == city,
                        onTap: () => ref.read(campusCityFilterProvider.notifier).state = city,
                      ),
                    )),
                    loading: () => [const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))],
                    error: (_, __) => [const Text('Error loading cities')],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Count ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: campusesState.when(
                initial: () => const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                success: (campuses) => Text(
                  '${campuses.length} campuses',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight),
                ),
                error: (_) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 8),

            // ── List ──
            Expanded(
              child: campusesState.when(
                initial: () => const AppLoadingIndicator(),
                loading: () => const AppLoadingIndicator(),
                error: (msg) => AppErrorView(
                  message: msg,
                  onRetry: () => ref.invalidate(campusesProvider),
                ),
                success: (campuses) {
                  if (campuses.isEmpty) {
                    return const AppEmptyView(
                      icon: Icons.location_city_rounded,
                      title: 'No campuses found',
                      subtitle: 'Try a different city filter',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: campuses.length,
                    itemBuilder: (context, i) => _CampusCard(campus: campuses[i]),
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

class _CityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CityChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.secondary : AppColors.dividerLight),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondaryLight),
        ),
      ),
    );
  }
}

class _CampusCard extends StatelessWidget {
  final CampusModel campus;
  const _CampusCard({required this.campus});

  @override
  Widget build(BuildContext context) {
    final color = campus.isMainCampus ? AppColors.primary : AppColors.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    campus.isMainCampus ? Icons.account_balance_rounded : Icons.location_city_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campus.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (campus.universityShortName != null) ...[
                            Text(
                              campus.universityShortName!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: color),
                            ),
                            const Text(' · ', style: TextStyle(color: AppColors.textTertiaryLight)),
                          ],
                          Icon(Icons.location_on_rounded, size: 13, color: AppColors.textTertiaryLight),
                          const SizedBox(width: 2),
                          Text(
                            campus.city,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (campus.isMainCampus)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Main',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  children: [
                    if (campus.studentCount != null)
                      _MiniStat(icon: Icons.people_rounded, label: campus.studentCountDisplay, color: AppColors.info),
                    if (campus.studentCount != null && campus.establishedYear != null)
                      const SizedBox(width: 8),
                    if (campus.establishedYear != null)
                      _MiniStat(icon: Icons.calendar_today_rounded, label: 'Est. ${campus.establishedYear}', color: AppColors.accent),
                  ],
                ),

                if (campus.description != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    campus.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5, color: AppColors.textSecondaryLight),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (campus.address != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.pin_drop_rounded, size: 13, color: AppColors.textTertiaryLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          campus.address!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Facilities grid
                Text(
                  'Facilities',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: campus.facilities
                      .map((f) => _FacilityBadge(facility: f))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniStat({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _FacilityBadge extends StatelessWidget {
  final FacilityItem facility;
  const _FacilityBadge({required this.facility});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(facility.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            facility.label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
          ),
        ],
      ),
    );
  }
}