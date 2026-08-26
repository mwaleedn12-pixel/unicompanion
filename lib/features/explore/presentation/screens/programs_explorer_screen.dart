import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';

// ── Providers ──

final _fieldFilter = StateProvider<String>((ref) => 'all');

final _allProgramNamesProvider = FutureProvider<List<_ProgramEntry>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final data = await client.from('university_programs').select('name, field, degree_level').eq('is_active', true);

  // Group by name, count universities
  final map = <String, _ProgramEntry>{};
  for (final row in data) {
    final name = (row['name'] as String).trim();
    if (name.isEmpty || name.length < 3) continue;
    final key = name.toLowerCase();
    if (map.containsKey(key)) {
      map[key]!.count++;
    } else {
      map[key] = _ProgramEntry(name: name, field: row['field'] ?? 'engineering', level: row['degree_level'] ?? 'bachelors', count: 1);
    }
  }

  final list = map.values.toList();
  list.sort((a, b) => b.count.compareTo(a.count)); // most offered first
  return list;
});

final _filteredProgramNames = Provider<List<_ProgramEntry>>((ref) {
  final all = ref.watch(_allProgramNamesProvider).valueOrNull ?? [];
  final field = ref.watch(_fieldFilter);
  if (field == 'all') return all;
  return all.where((p) => p.field == field).toList();
});

// Universities offering a specific program
final _programUnisProvider = FutureProvider.family<List<_UniOffer>, String>((ref, programName) async {
  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('university_programs')
      .select('fee_per_semester, fee_total, duration_years, degree_level, universities!inner(id, name, short_name, type, city, ranking_national)')
      .ilike('name', programName)
      .eq('is_active', true)
      .order('name');

  return data.map<_UniOffer>((row) {
    final uni = row['universities'] as Map<String, dynamic>;
    return _UniOffer(
      uniId: uni['id'],
      uniName: uni['name'] ?? '',
      uniShort: uni['short_name'] ?? '',
      uniType: uni['type'] ?? 'public',
      city: uni['city'],
      ranking: uni['ranking_national'],
      feePerSem: (row['fee_per_semester'] as num?)?.toDouble(),
      feeTotal: (row['fee_total'] as num?)?.toDouble(),
      duration: (row['duration_years'] as num?)?.toDouble() ?? 4,
      level: row['degree_level'] ?? 'bachelors',
    );
  }).toList()
    ..sort((a, b) => (a.ranking ?? 999).compareTo(b.ranking ?? 999));
});

class _ProgramEntry {
  final String name;
  final String field;
  final String level;
  int count;
  _ProgramEntry({required this.name, required this.field, required this.level, required this.count});
}

class _UniOffer {
  final String uniId, uniName, uniShort, uniType, level;
  final String? city;
  final int? ranking;
  final double? feePerSem, feeTotal;
  final double duration;
  _UniOffer({required this.uniId, required this.uniName, required this.uniShort, required this.uniType, this.city, this.ranking, this.feePerSem, this.feeTotal, required this.duration, required this.level});

  String get feeDisplay {
    if (feePerSem == null) return 'Fee: N/A';
    return 'PKR ${(feePerSem! / 1000).toStringAsFixed(0)}K/sem';
  }
  String get totalDisplay {
    if (feeTotal == null) return '';
    if (feeTotal! >= 1000000) return '${(feeTotal! / 100000).toStringAsFixed(1)} Lac total';
    return 'PKR ${(feeTotal! / 1000).toStringAsFixed(0)}K total';
  }
}

// ── Screen ──

class ProgramsExplorerScreen extends ConsumerWidget {
  const ProgramsExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(_allProgramNamesProvider);
    final filtered = ref.watch(_filteredProgramNames);
    final field = ref.watch(_fieldFilter);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                    const SizedBox(width: 4),
                    Text('Programs Explorer', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            // Field filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FieldChip(label: 'All Fields', value: 'all', icon: Icons.apps_rounded, selected: field, onTap: (v) => ref.read(_fieldFilter.notifier).state = v),
                      _FieldChip(label: 'IT & CS', value: 'it', icon: Icons.computer_rounded, selected: field, onTap: (v) => ref.read(_fieldFilter.notifier).state = v),
                      _FieldChip(label: 'Engineering', value: 'engineering', icon: Icons.engineering_rounded, selected: field, onTap: (v) => ref.read(_fieldFilter.notifier).state = v),
                      _FieldChip(label: 'Business', value: 'business', icon: Icons.business_center_rounded, selected: field, onTap: (v) => ref.read(_fieldFilter.notifier).state = v),
                      _FieldChip(label: 'Sciences', value: 'sciences', icon: Icons.science_rounded, selected: field, onTap: (v) => ref.read(_fieldFilter.notifier).state = v),
                      _FieldChip(label: 'Medical', value: 'medical', icon: Icons.local_hospital_rounded, selected: field, onTap: (v) => ref.read(_fieldFilter.notifier).state = v),
                      _FieldChip(label: 'Law', value: 'law', icon: Icons.gavel_rounded, selected: field, onTap: (v) => ref.read(_fieldFilter.notifier).state = v),
                      _FieldChip(label: 'Arts', value: 'arts', icon: Icons.palette_rounded, selected: field, onTap: (v) => ref.read(_fieldFilter.notifier).state = v),
                    ],
                  ),
                ),
              ),
            ),

            // Count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text('${filtered.length} programs', style: TextStyle(fontSize: 12, color: AppColors.textTertiaryLight)),
              ),
            ),

            // Programs list
            programsAsync.when(
              loading: () => const SliverFillRemaining(child: AppLoadingIndicator(message: 'Loading programs...')),
              error: (e, _) => SliverFillRemaining(child: AppErrorView(message: '$e')),
              data: (_) {
                if (filtered.isEmpty) {
                  return const SliverFillRemaining(child: AppEmptyView(icon: Icons.menu_book_outlined, title: 'No programs found', subtitle: 'Try a different field'));
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _ProgramTile(program: filtered[i]),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

// ── Program Tile (expands to show universities) ──

class _ProgramTile extends ConsumerStatefulWidget {
  final _ProgramEntry program;
  const _ProgramTile({required this.program});

  @override
  ConsumerState<_ProgramTile> createState() => _ProgramTileState();
}

class _ProgramTileState extends ConsumerState<_ProgramTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.program;
    final color = _fieldColor(p.field);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _expanded ? color.withValues(alpha: 0.3) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          // Program name row
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_fieldIcon(p.field), size: 20, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${p.count} ${p.count == 1 ? 'university' : 'universities'} offering', style: TextStyle(fontSize: 12, color: AppColors.textTertiaryLight)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(p.count.toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                  ),
                  const SizedBox(width: 8),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20, color: AppColors.textTertiaryLight),
                ],
              ),
            ),
          ),

          // Expanded: universities list
          if (_expanded) _UniversitiesForProgram(programName: p.name),
        ],
      ),
    );
  }

  Color _fieldColor(String f) {
    switch (f) {
      case 'it': return AppColors.primary;
      case 'engineering': return const Color(0xFFEA580C);
      case 'business': return const Color(0xFF0891B2);
      case 'medical': return AppColors.error;
      case 'sciences': return AppColors.success;
      case 'law': return const Color(0xFF8B5CF6);
      case 'arts': return AppColors.accent;
      default: return AppColors.primary;
    }
  }

  IconData _fieldIcon(String f) {
    switch (f) {
      case 'it': return Icons.computer_rounded;
      case 'engineering': return Icons.engineering_rounded;
      case 'business': return Icons.business_center_rounded;
      case 'medical': return Icons.local_hospital_rounded;
      case 'sciences': return Icons.science_rounded;
      case 'law': return Icons.gavel_rounded;
      case 'arts': return Icons.palette_rounded;
      default: return Icons.menu_book_rounded;
    }
  }
}

class _UniversitiesForProgram extends ConsumerWidget {
  final String programName;
  const _UniversitiesForProgram({required this.programName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unisAsync = ref.watch(_programUnisProvider(programName));

    return unisAsync.when(
      loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (e, _) => Padding(padding: const EdgeInsets.all(14), child: Text('Error loading universities', style: TextStyle(color: AppColors.error))),
      data: (unis) {
        if (unis.isEmpty) {
          return const Padding(padding: EdgeInsets.all(14), child: Text('No universities found', style: TextStyle(color: AppColors.textTertiaryLight)));
        }
        return Column(
          children: [
            const Divider(height: 1),
            ...unis.map((u) => InkWell(
              onTap: () => context.push('/explore/university/${u.uniId}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: u.uniType == 'public' ? AppColors.primarySurface : AppColors.secondarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(
                        u.uniShort.isNotEmpty ? u.uniShort.substring(0, u.uniShort.length > 2 ? 2 : u.uniShort.length) : u.uniName.substring(0, 2),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: u.uniType == 'public' ? AppColors.primary : AppColors.secondary),
                      )),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.uniName, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Row(
                            children: [
                              Text(u.uniType == 'public' ? 'Public' : 'Private', style: TextStyle(fontSize: 10, color: u.uniType == 'public' ? AppColors.primary : AppColors.secondary)),
                              if (u.city != null) ...[
                                const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.textTertiaryLight)),
                                Text(u.city!, style: const TextStyle(fontSize: 10, color: AppColors.textTertiaryLight)),
                              ],
                              if (u.ranking != null) ...[
                                const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.textTertiaryLight)),
                                Text('#${u.ranking}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiaryLight)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(u.feeDisplay, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: u.feePerSem != null ? AppColors.success : AppColors.textTertiaryLight)),
                        if (u.totalDisplay.isNotEmpty) Text(u.totalDisplay, style: const TextStyle(fontSize: 9, color: AppColors.textTertiaryLight)),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textTertiaryLight),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }
}

class _FieldChip extends StatelessWidget {
  final String label, value, selected;
  final IconData icon;
  final Function(String) onTap;
  const _FieldChip({required this.label, required this.value, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondaryLight),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimaryLight)),
            ],
          ),
        ),
      ),
    );
  }
}