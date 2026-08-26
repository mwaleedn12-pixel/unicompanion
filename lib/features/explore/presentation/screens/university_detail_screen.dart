import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/models/university_model.dart';
import '../../data/models/program_model.dart';
import '../../data/models/campus_model.dart';
import '../providers/explore_provider.dart';
import '../providers/review_provider.dart';
import '../../../applications/presentation/providers/shortlist_provider.dart';
import '../widgets/university_reviews_section.dart';

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

class _DetailBody extends ConsumerWidget {
  final UniversityModel university;
  const _DetailBody({required this.university});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(universityProgramsProvider(university.id));
    final campusesAsync = ref.watch(universityCampusesProvider(university.id));
    final avgRating = ref.watch(universityRatingProvider(university.id));

    return CustomScrollView(
      slivers: [
        // ── Hero Header ──
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
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: _BookmarkButton(universityId: university.id),
            ),
          ],
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

        // ── Content ──
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

                // Programs
                Text('Programs Offered', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),

                programsAsync.when(
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2))),
                  error: (e, _) => _PlaceholderBox(text: 'Could not load programs'),
                  data: (programs) {
                    if (programs.isEmpty) {
                      return _PlaceholderBox(text: 'No programs listed yet');
                    }

                    final grouped = <String, List<ProgramModel>>{};
                    for (final p in programs) {
                      grouped.putIfAbsent(p.degreeLevel, () => []).add(p);
                    }

                    return Column(
                      children: grouped.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                _levelHeader(entry.key),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            ...entry.value.map((p) => _ProgramTile(program: p)),
                            const SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Campuses
                Text('Campuses', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),

                campusesAsync.when(
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2))),
                  error: (e, _) => _PlaceholderBox(text: 'Could not load campuses'),
                  data: (campuses) {
                    if (campuses.isEmpty) {
                      return _PlaceholderBox(text: 'No campus info yet');
                    }
                    return Column(
                      children: campuses.map((c) => _CampusTile(campus: c)).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Student Reviews section (inline)
                UniversityReviewsSection(universityId: university.id),

                const SizedBox(height: 16),

                // ── #2 — Reviews & Ratings button (NEW) ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AppHaptics.light();
                      context.push('/reviews/${university.id}?name=${Uri.encodeComponent(university.name)}');
                    },
                    icon: const Icon(Icons.rate_review_rounded, size: 20),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Reviews & Ratings'),
                        if (avgRating > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9A24B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFC9A24B)),
                                const SizedBox(width: 2),
                                Text(
                                  avgRating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFC9A24B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _levelHeader(String level) {
    switch (level) {
      case 'bachelors': return '🎓 Bachelors Programs';
      case 'masters': return '📚 Masters Programs';
      case 'phd': return '🔬 PhD Programs';
      case 'diploma': return '📋 Diploma Programs';
      default: return level;
    }
  }
}

class _BookmarkButton extends ConsumerStatefulWidget {
  final String universityId;
  const _BookmarkButton({required this.universityId});

  @override
  ConsumerState<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends ConsumerState<_BookmarkButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final isShortlisted = ref.watch(isShortlistedProvider(widget.universityId));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _busy
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : IconButton(
              icon: Icon(
                isShortlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                color: isShortlisted ? AppColors.error : AppColors.textPrimaryLight,
              ),
              onPressed: () async {
                AppHaptics.tap();
                setState(() => _busy = true);
                try {
                  final ok = await ref.read(shortlistProvider.notifier).toggle(widget.universityId);
                  if (mounted) {
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isShortlisted ? 'Removed from shortlist' : 'Added to shortlist'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed — check your connection'), duration: Duration(seconds: 2)),
                      );
                    }
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Something went wrong'), duration: Duration(seconds: 2)),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
            ),
    );
  }
}

class _ProgramTile extends StatefulWidget {
  final ProgramModel program;
  const _ProgramTile({required this.program});

  @override
  State<_ProgramTile> createState() => _ProgramTileState();
}

class _ProgramTileState extends State<_ProgramTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.program;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              AppHaptics.light();
              setState(() => _expanded = !_expanded);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(p.feeDisplay, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success)),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.textTertiaryLight),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _DetailRow(label: 'Duration', value: p.durationDisplay),
                  if (p.creditHours != null) _DetailRow(label: 'Credit Hours', value: '${p.creditHours}'),
                  if (p.totalSemesters != null) _DetailRow(label: 'Semesters', value: '${p.totalSemesters}'),
                  _DetailRow(label: 'Fee/Semester', value: p.feeDisplay),
                  _DetailRow(label: 'Total Fee (est.)', value: p.feeTotalDisplay),
                  if (p.seats != null) _DetailRow(label: 'Seats', value: '${p.seats}'),
                  if (p.admissionOpenDate != null)
                    _DetailRow(label: 'Admission', value: p.admissionWindow),
                  if (p.eligibility != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.infoSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.info),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p.eligibility!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusTile extends StatelessWidget {
  final CampusModel campus;
  const _CampusTile({required this.campus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: campus.isMainCampus ? AppColors.primarySurface : AppColors.secondarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  campus.isMainCampus ? Icons.account_balance_rounded : Icons.location_city_rounded,
                  color: campus.isMainCampus ? AppColors.primary : AppColors.secondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campus.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textTertiaryLight),
                        const SizedBox(width: 3),
                        Text(campus.city, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ],
                ),
              ),
              if (campus.isMainCampus)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Main', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
            ],
          ),
          if (campus.description != null) ...[
            const SizedBox(height: 8),
            Text(
              campus.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4, color: AppColors.textSecondaryLight),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: campus.facilities.map((f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successSurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${f.emoji} ${f.label}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
              ),
            )).toList(),
          ),
          if (campus.studentCount != null || campus.establishedYear != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (campus.studentCount != null)
                  Text(campus.studentCountDisplay, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight, fontSize: 11)),
                if (campus.studentCount != null && campus.establishedYear != null)
                  const Text(' · ', style: TextStyle(color: AppColors.textTertiaryLight)),
                if (campus.establishedYear != null)
                  Text('Est. ${campus.establishedYear}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight, fontSize: 11)),
              ],
            ),
          ],
        ],
      ),
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

class _PlaceholderBox extends StatelessWidget {
  final String text;
  const _PlaceholderBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Center(
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiaryLight)),
      ),
    );
  }
}