import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/models/program_model.dart';
import '../providers/explore_provider.dart';

class ProgramsExplorerScreen extends ConsumerStatefulWidget {
  const ProgramsExplorerScreen({super.key});

  @override
  ConsumerState<ProgramsExplorerScreen> createState() => _ProgramsExplorerScreenState();
}

class _ProgramsExplorerScreenState extends ConsumerState<ProgramsExplorerScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearch(String value) {
    ref.read(programFilterProvider.notifier).state =
        ref.read(programFilterProvider).copyWith(search: value);
  }

  void _updateField(String field) {
    ref.read(programFilterProvider.notifier).state =
        ref.read(programFilterProvider).copyWith(field: field);
  }

  void _updateLevel(String level) {
    ref.read(programFilterProvider.notifier).state =
        ref.read(programFilterProvider).copyWith(degreeLevel: level);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(programFilterProvider);
    final programsState = ref.watch(programsProvider);

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
                      'Programs Explorer',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                controller: _searchController,
                onChanged: _updateSearch,
                decoration: InputDecoration(
                  hintText: 'Search programs...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: filter.search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _updateSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.dividerLight.withValues(alpha: 0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.dividerLight.withValues(alpha: 0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Field Filters ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(label: 'All Fields', selected: filter.field == 'all', onTap: () => _updateField('all')),
                  const SizedBox(width: 8),
                  _FilterChip(label: '💻 IT & CS', selected: filter.field == 'it', onTap: () => _updateField('it')),
                  const SizedBox(width: 8),
                  _FilterChip(label: '⚙️ Engineering', selected: filter.field == 'engineering', onTap: () => _updateField('engineering')),
                  const SizedBox(width: 8),
                  _FilterChip(label: '📊 Business', selected: filter.field == 'business', onTap: () => _updateField('business')),
                  const SizedBox(width: 8),
                  _FilterChip(label: '🔬 Sciences', selected: filter.field == 'sciences', onTap: () => _updateField('sciences')),
                  const SizedBox(width: 8),
                  _FilterChip(label: '⚖️ Law', selected: filter.field == 'law', onTap: () => _updateField('law')),
                  const SizedBox(width: 8),
                  _FilterChip(label: '🏥 Medical', selected: filter.field == 'medical', onTap: () => _updateField('medical')),
                  const SizedBox(width: 8),
                  _FilterChip(label: '🎨 Arts', selected: filter.field == 'arts', onTap: () => _updateField('arts')),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Degree Level Filters ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _LevelChip(label: 'All Levels', selected: filter.degreeLevel == 'all', onTap: () => _updateLevel('all')),
                  const SizedBox(width: 8),
                  _LevelChip(label: 'Bachelors', selected: filter.degreeLevel == 'bachelors', onTap: () => _updateLevel('bachelors')),
                  const SizedBox(width: 8),
                  _LevelChip(label: 'Masters', selected: filter.degreeLevel == 'masters', onTap: () => _updateLevel('masters')),
                  const SizedBox(width: 8),
                  _LevelChip(label: 'PhD', selected: filter.degreeLevel == 'phd', onTap: () => _updateLevel('phd')),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Count ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: programsState.when(
                initial: () => const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                success: (programs) => Text(
                  '${programs.length} programs found',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight),
                ),
                error: (_) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 8),

            // ── List ──
            Expanded(
              child: programsState.when(
                initial: () => const AppLoadingIndicator(),
                loading: () => const AppLoadingIndicator(),
                error: (msg) => AppErrorView(
                  message: msg,
                  onRetry: () => ref.invalidate(programsProvider),
                ),
                success: (programs) {
                  if (programs.isEmpty) {
                    return const AppEmptyView(
                      icon: Icons.menu_book_rounded,
                      title: 'No programs found',
                      subtitle: 'Try adjusting your filters',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: programs.length,
                    itemBuilder: (context, i) => _ProgramCard(program: programs[i]),
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

// ── Filter Chips ──

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.dividerLight),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondaryLight),
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LevelChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.secondary : AppColors.dividerLight),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textTertiaryLight),
        ),
      ),
    );
  }
}

// ── Program Card ──

class _ProgramCard extends StatelessWidget {
  final ProgramModel program;
  const _ProgramCard({required this.program});

  Color get _fieldColor {
    switch (program.field) {
      case 'it':
        return AppColors.primary;
      case 'engineering':
        return AppColors.accent;
      case 'business':
        return AppColors.secondary;
      case 'sciences':
        return const Color(0xFF8B5CF6);
      case 'law':
        return const Color(0xFFEC4899);
      case 'medical':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData get _fieldIcon {
    switch (program.field) {
      case 'it':
        return Icons.computer_rounded;
      case 'engineering':
        return Icons.engineering_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'sciences':
        return Icons.science_rounded;
      case 'law':
        return Icons.gavel_rounded;
      case 'medical':
        return Icons.local_hospital_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _fieldColor.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + name + level badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_fieldColor, _fieldColor.withValues(alpha: 0.7)]),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_fieldIcon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    if (program.universityShortName != null || program.universityName != null)
                      Text(
                        program.universityShortName ?? program.universityName ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _fieldColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  program.degreeLevelLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _fieldColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Info tags row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoTag(icon: Icons.schedule_rounded, label: program.durationDisplay, color: AppColors.info),
              _InfoTag(icon: Icons.monetization_on_rounded, label: program.feeDisplay, color: AppColors.success),
              if (program.seats != null)
                _InfoTag(icon: Icons.people_rounded, label: '${program.seats} seats', color: AppColors.accent),
              if (program.creditHours != null)
                _InfoTag(icon: Icons.book_rounded, label: '${program.creditHours} CH', color: AppColors.secondary),
            ],
          ),

          // Admission window
          if (program.admissionOpenDate != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.accentDark),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Admission: ${program.admissionWindow}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentDark),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Eligibility
          if (program.eligibility != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.textTertiaryLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      program.eligibility!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4, color: AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoTag({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
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