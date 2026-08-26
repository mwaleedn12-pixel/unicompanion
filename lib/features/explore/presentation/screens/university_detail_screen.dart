import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/models/university_model.dart';
import '../providers/explore_provider.dart';
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
    final u = university;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)),
              child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimaryLight), onPressed: () => context.pop()),
            ),
          ),
          actions: [
            Padding(padding: const EdgeInsets.all(8), child: _BookmarkButton(universityId: u.id)),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: u.type == 'public' ? [AppColors.primary, AppColors.primaryLight] : [AppColors.secondary, AppColors.secondaryLight],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24)),
                      child: Center(child: Text(u.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28))),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(u.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    if (u.city != null) ...[
                      const SizedBox(height: 4),
                      Text(u.city!, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _InfoChip(icon: Icons.account_balance_rounded, label: u.typeLabel, color: u.type == 'public' ? AppColors.primary : AppColors.secondary),
                    if (u.rankingNational != null) _InfoChip(icon: Icons.emoji_events_rounded, label: 'Rank #${u.rankingNational}', color: AppColors.accent),
                    if (u.city != null) _InfoChip(icon: Icons.location_on_rounded, label: u.city!, color: AppColors.info),
                  ],
                ),

                if (u.affiliation != null) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'About'),
                  const SizedBox(height: 8),
                  _InfoBox(text: u.affiliation!),
                ],

                if (u.degreeLevels != null) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Degree Levels'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: u.degreeLevels!.split(' ').where((d) => d.trim().isNotEmpty).map((d) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
                      child: Text(d.trim(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    )).toList(),
                  ),
                ],

                // Departments & Programs — parsed into chips
                if (u.programsOffered != null) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Departments & Programs'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: _parseDepartments(u.programsOffered!).map((dept) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Flexible(child: Text(dept, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    )).toList(),
                  ),
                ],

                if (u.entryTest != null) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Entry Test'),
                  const SizedBox(height: 8),
                  _IconInfoBox(icon: Icons.quiz_rounded, color: AppColors.accent, text: u.entryTest!),
                ],

                if (u.meritFormula != null) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Merit Formula'),
                  const SizedBox(height: 8),
                  _IconInfoBox(icon: Icons.calculate_rounded, color: AppColors.primary, text: u.meritFormula!),
                ],

                if (u.eligibility != null) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Eligibility Criteria'),
                  const SizedBox(height: 8),
                  _InfoBox(text: u.eligibility!),
                ],

                if (u.feeStructure != null) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Fee Structure'),
                  const SizedBox(height: 8),
                  _IconInfoBox(icon: Icons.payments_rounded, color: AppColors.success, text: u.feeStructure!),
                ],

                if (u.admissionInfo != null || u.deadlines != null) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Admission 2026'),
                  const SizedBox(height: 8),
                  if (u.admissionInfo != null) _IconInfoBox(icon: Icons.calendar_today_rounded, color: AppColors.info, text: u.admissionInfo!),
                  if (u.deadlines != null) ...[
                    const SizedBox(height: 8),
                    _IconInfoBox(icon: Icons.alarm_rounded, color: AppColors.warning, text: 'Deadlines: ${u.deadlines!}'),
                  ],
                ],

                if (u.scholarshipsInfo != null) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Scholarships'),
                  const SizedBox(height: 8),
                  _IconInfoBox(icon: Icons.card_giftcard_rounded, color: AppColors.success, text: u.scholarshipsInfo!),
                ],

                const SizedBox(height: 20),
                _MoreInfoSection(university: u),

                const SizedBox(height: 20),
                UniversityReviewsSection(universityId: u.id),

                const SizedBox(height: 24),
                if (u.applyUrl != null)
                  _ActionButton(label: 'Apply Online', icon: Icons.send_rounded, url: u.applyUrl!, color: AppColors.primary),
                if (u.portalUrl != null) ...[
                  const SizedBox(height: 10),
                  _ActionButton(label: 'University Portal', icon: Icons.open_in_new_rounded, url: u.portalUrl!, color: AppColors.secondary),
                ],
                if (u.website != null) ...[
                  const SizedBox(height: 10),
                  _ActionButton(label: 'Visit Website', icon: Icons.language_rounded, url: u.website!, color: AppColors.info),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _parseDepartments(String raw) {
    final keywords = [
      'Computer Science', 'Software Engineering', 'Information Technology',
      'Electrical Engineering', 'Electronics Engineering', 'Telecommunication Engineering',
      'Civil Engineering', 'Mechanical Engineering', 'Chemical Engineering',
      'Biomedical Engineering', 'Environmental Engineering', 'Industrial Engineering',
      'Mechatronics', 'Architecture', 'Business Administration', 'Management Sciences',
      'Commerce', 'Economics', 'Accounting', 'Finance', 'Marketing',
      'Mathematics', 'Physics', 'Chemistry', 'Biology', 'Biotechnology',
      'Biosciences', 'Microbiology', 'Biochemistry', 'Zoology', 'Botany',
      'Environmental Sciences', 'Earth Sciences', 'Statistics',
      'English', 'Urdu', 'Islamic Studies', 'Pakistan Studies', 'History',
      'Political Science', 'International Relations', 'Sociology', 'Psychology',
      'Social Sciences', 'Education', 'Law', 'Journalism', 'Mass Communication',
      'Media Studies', 'Fine Arts', 'Design', 'Visual Arts', 'Textile Design',
      'Pharmacy', 'Pharm-D', 'MBBS', 'BDS', 'DPT', 'Nursing',
      'Medical Lab Technology', 'MLT', 'Health Sciences', 'Life Sciences',
      'Public Health', 'Nutrition', 'Physiotherapy', 'Public Administration',
      'Development Studies', 'Gender Studies', 'Anthropology',
      'Data Science', 'Artificial Intelligence', 'Cyber Security',
      'Aerospace Engineering', 'Mining Engineering', 'Petroleum Engineering',
      'Textile Engineering', 'Agricultural Engineering', 'Food Technology',
      'Veterinary Sciences', 'Agriculture', 'Forestry',
    ];

    List<String> found = [];
    String remaining = raw;

    keywords.sort((a, b) => b.length.compareTo(a.length));

    for (final kw in keywords) {
      if (remaining.toLowerCase().contains(kw.toLowerCase())) {
        found.add(kw);
        remaining = remaining.replaceFirst(RegExp(RegExp.escape(kw), caseSensitive: false), ' ');
      }
    }

    final parens = RegExp(r'\([^)]+\)').allMatches(raw);
    for (final m in parens) {
      final content = m.group(0)!;
      if (!found.any((f) => f.contains(content))) {
        found.add(content);
      }
    }

    if (found.isEmpty) return [raw];
    return found;
  }
}

class _MoreInfoSection extends StatefulWidget {
  final UniversityModel university;
  const _MoreInfoSection({required this.university});
  @override
  State<_MoreInfoSection> createState() => _MoreInfoSectionState();
}

class _MoreInfoSectionState extends State<_MoreInfoSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.university;
    final hasMore = u.facilities != null || u.hostelInfo != null || u.transportInfo != null || u.contactInfo != null || u.meritHistory != null || u.address != null;
    if (!hasMore) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text('More Information', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.textTertiaryLight),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 10),
          if (u.facilities != null) _DetailItem(icon: Icons.business_rounded, label: 'Facilities', value: u.facilities!),
          if (u.hostelInfo != null) _DetailItem(icon: Icons.hotel_rounded, label: 'Hostel', value: u.hostelInfo!),
          if (u.transportInfo != null) _DetailItem(icon: Icons.directions_bus_rounded, label: 'Transport', value: u.transportInfo!),
          if (u.meritHistory != null) _DetailItem(icon: Icons.history_rounded, label: 'Merit History', value: u.meritHistory!),
          if (u.address != null) _DetailItem(icon: Icons.place_rounded, label: 'Address', value: u.address!),
          if (u.contactInfo != null) _DetailItem(icon: Icons.phone_rounded, label: 'Contact', value: u.contactInfo!),
        ],
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailItem({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
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
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)),
      child: _busy
          ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
          : IconButton(
              icon: Icon(isShortlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded, color: isShortlisted ? AppColors.error : AppColors.textPrimaryLight),
              onPressed: () async {
                setState(() => _busy = true);
                try {
                  final ok = await ref.read(shortlistProvider.notifier).toggle(widget.universityId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? (isShortlisted ? 'Removed from shortlist' : 'Added to shortlist') : 'Failed'),
                      duration: const Duration(seconds: 1),
                    ));
                  }
                } catch (_) {} finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700));
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.6, color: AppColors.textSecondaryLight)),
    );
  }
}

class _IconInfoBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _IconInfoBox({required this.icon, required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5, color: AppColors.textSecondaryLight))),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String url;
  final Color color;
  const _ActionButton({required this.label, required this.icon, required this.url, required this.color});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 48,
      child: ElevatedButton.icon(
        onPressed: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      ),
    );
  }
}