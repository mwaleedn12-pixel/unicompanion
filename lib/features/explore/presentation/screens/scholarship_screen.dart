import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';

class ScholarshipScreen extends ConsumerStatefulWidget {
  const ScholarshipScreen({super.key});

  @override
  ConsumerState<ScholarshipScreen> createState() => _ScholarshipScreenState();
}

class _ScholarshipScreenState extends ConsumerState<ScholarshipScreen> {
  String _filter = 'all';
  List<Map<String, dynamic>> _scholarships = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final client = ref.read(supabaseClientProvider);
      var query = client.from('scholarships').select().eq('is_active', true);
      if (_filter != 'all') query = query.eq('type', _filter);
      final data = await query.order('name', ascending: true);
      setState(() { _scholarships = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) {
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Scholarships', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                ],
              ),
            ),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(label: 'All', selected: _filter == 'all', onTap: () { _filter = 'all'; _load(); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Need Based', selected: _filter == 'need_based', onTap: () { _filter = 'need_based'; _load(); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Merit Based', selected: _filter == 'merit_based', onTap: () { _filter = 'merit_based'; _load(); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Special', selected: _filter == 'special', onTap: () { _filter = 'special'; _load(); }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('${_scholarships.length} scholarships found', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _loading
                  ? const AppLoadingIndicator()
                  : _error != null
                      ? AppErrorView(message: _error!, onRetry: _load)
                      : _scholarships.isEmpty
                          ? const AppEmptyView(icon: Icons.card_giftcard_rounded, title: 'No scholarships found')
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _scholarships.length,
                              itemBuilder: (context, i) => _ScholarshipCard(data: _scholarships[i]),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.dividerLight),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondaryLight)),
      ),
    );
  }
}

class _ScholarshipCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ScholarshipCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final type = data['type'] ?? '';
    final isMerit = type == 'merit_based';
    final color = isMerit ? AppColors.primary : AppColors.secondary;
    final deadline = data['application_deadline'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'] ?? '', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text(data['provider'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(isMerit ? 'Merit' : 'Need', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoTag(icon: Icons.monetization_on_rounded, label: data['coverage'] ?? 'N/A', color: AppColors.success),
              const SizedBox(width: 8),
              if (deadline != null)
                _InfoTag(icon: Icons.calendar_today_rounded, label: 'Due: $deadline', color: AppColors.accent),
            ],
          ),
          if (data['eligibility_criteria'] != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(8)),
              child: Text(data['eligibility_criteria'], style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
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