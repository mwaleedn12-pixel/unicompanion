import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/university_model.dart';
import '../providers/explore_provider.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  UniversityModel? uni1;
  UniversityModel? uni2;

  @override
  Widget build(BuildContext context) {
    final uniState = ref.watch(universitiesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Compare', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Selectors
                    Row(
                      children: [
                        Expanded(child: _UniSelector(
                          label: 'University 1',
                          selected: uni1,
                          color: AppColors.primary,
                          universities: uniState.dataOrNull ?? [],
                          onSelected: (u) => setState(() => uni1 = u),
                        )),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('VS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textTertiaryLight)),
                        ),
                        Expanded(child: _UniSelector(
                          label: 'University 2',
                          selected: uni2,
                          color: AppColors.secondary,
                          universities: uniState.dataOrNull ?? [],
                          onSelected: (u) => setState(() => uni2 = u),
                        )),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (uni1 != null && uni2 != null) ...[
                      _CompareRow(label: 'Type', val1: uni1!.typeLabel, val2: uni2!.typeLabel, icon: Icons.account_balance_rounded),
                      _CompareRow(label: 'Ranking', val1: uni1!.rankingNational != null ? '#${uni1!.rankingNational}' : 'N/A', val2: uni2!.rankingNational != null ? '#${uni2!.rankingNational}' : 'N/A', icon: Icons.emoji_events_rounded,
                        better1: (uni1!.rankingNational ?? 999) < (uni2!.rankingNational ?? 999),
                        better2: (uni2!.rankingNational ?? 999) < (uni1!.rankingNational ?? 999)),
                      _CompareRow(label: 'Short Name', val1: uni1!.shortName, val2: uni2!.shortName, icon: Icons.label_rounded),
                      _CompareRow(label: 'Website', val1: uni1!.website != null ? '✓' : '✗', val2: uni2!.website != null ? '✓' : '✗', icon: Icons.language_rounded),

                      const SizedBox(height: 20),

                      // Description comparison
                      Text('About', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _DescCard(uni: uni1!, color: AppColors.primary)),
                          const SizedBox(width: 12),
                          Expanded(child: _DescCard(uni: uni2!, color: AppColors.secondary)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.infoSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
                            const SizedBox(width: 8),
                            Expanded(child: Text('More comparison fields (fees, programs, deadlines) will be available as data is added.', style: TextStyle(fontSize: 12, color: AppColors.info))),
                          ],
                        ),
                      ),
                    ],

                    if (uni1 == null || uni2 == null)
                      Container(
                        margin: const EdgeInsets.only(top: 40),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.compare_arrows_rounded, size: 48, color: AppColors.textTertiaryLight),
                            const SizedBox(height: 12),
                            Text('Select Two Universities', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Pick universities above to see a side-by-side comparison', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UniSelector extends StatelessWidget {
  final String label;
  final UniversityModel? selected;
  final Color color;
  final List<UniversityModel> universities;
  final ValueChanged<UniversityModel> onSelected;

  const _UniSelector({required this.label, required this.selected, required this.color, required this.universities, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected != null ? color.withValues(alpha: 0.08) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected != null ? color.withValues(alpha: 0.3) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: selected != null ? color : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: selected != null
                    ? Text(selected!.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))
                    : Icon(Icons.add_rounded, color: AppColors.textTertiaryLight, size: 24),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selected?.shortName ?? label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (selected == null)
              Text('Tap to select', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select University', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: universities.length,
                itemBuilder: (_, i) {
                  final uni = universities[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Text(uni.initials, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    title: Text(uni.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('${uni.typeLabel} • #${uni.rankingNational ?? "N/A"}'),
                    onTap: () {
                      onSelected(uni);
                      Navigator.pop(ctx);
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

class _CompareRow extends StatelessWidget {
  final String label;
  final String val1;
  final String val2;
  final IconData icon;
  final bool better1;
  final bool better2;

  const _CompareRow({required this.label, required this.val1, required this.val2, required this.icon, this.better1 = false, this.better2 = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(val1, style: TextStyle(fontSize: 13, fontWeight: better1 ? FontWeight.w800 : FontWeight.w500, color: better1 ? AppColors.success : null), textAlign: TextAlign.center),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: AppColors.textTertiaryLight),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          Expanded(
            child: Text(val2, style: TextStyle(fontSize: 13, fontWeight: better2 ? FontWeight.w800 : FontWeight.w500, color: better2 ? AppColors.success : null), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _DescCard extends StatelessWidget {
  final UniversityModel uni;
  final Color color;
  const _DescCard({required this.uni, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Text(
        uni.description ?? 'No description available',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}