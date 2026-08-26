import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/common_widgets.dart';

class FeeComparisonScreen extends ConsumerStatefulWidget {
  const FeeComparisonScreen({super.key});

  @override
  ConsumerState<FeeComparisonScreen> createState() => _FeeComparisonScreenState();
}

class _FeeComparisonScreenState extends ConsumerState<FeeComparisonScreen> {
  List<_UniOption> _allUnis = [];
  final List<_UniOption> _selected = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    final data = await Supabase.instance.client
        .from('universities')
        .select('id, name, short_name, fee_structure')
        .not('fee_structure', 'is', null)
        .order('name');

    setState(() {
      _allUnis = data.map((u) => _UniOption(
        id: u['id'] as String,
        name: u['short_name'] ?? u['name'] ?? '',
        fullName: u['name'] ?? '',
        feeText: u['fee_structure'] ?? '',
        fee: _parseFee(u['fee_structure'] ?? ''),
      )).where((u) => u.fee > 0).toList();
      _loading = false;
    });
  }

  static int _parseFee(String feeText) {
    // Extract first number that looks like a fee (e.g. "Rs. 90,000" → 90000)
    final matches = RegExp(r'[\d,]+').allMatches(feeText.replaceAll(' ', ''));
    for (final m in matches) {
      final num = int.tryParse(m.group(0)!.replaceAll(',', ''));
      if (num != null && num >= 10000) return num;
    }
    return 0;
  }

  void _addUni(_UniOption uni) {
    if (_selected.length >= 4) return;
    if (_selected.any((s) => s.id == uni.id)) return;
    AppHaptics.light();
    setState(() => _selected.add(uni));
  }

  void _removeUni(String id) {
    AppHaptics.light();
    setState(() => _selected.removeWhere((s) => s.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final barColors = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.info];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Header
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Fee Comparison', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: -0.05, end: 0, duration: 350.ms),

              const SizedBox(height: 4),
              Text('Select 2–4 universities to compare fees', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight))
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 20),

              // ── University picker ──
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                Autocomplete<_UniOption>(
                  optionsBuilder: (value) {
                    if (value.text.isEmpty) return const Iterable.empty();
                    return _allUnis.where((u) =>
                        u.fullName.toLowerCase().contains(value.text.toLowerCase()) ||
                        u.name.toLowerCase().contains(value.text.toLowerCase()));
                  },
                  displayStringForOption: (u) => u.fullName,
                  onSelected: (u) {
                    _addUni(u);
                    // Clear the text field
                    Future.microtask(() => FocusScope.of(context).unfocus());
                  },
                  fieldViewBuilder: (ctx, controller, focusNode, onSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Search university to add...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.dividerLight)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.dividerLight)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        isDense: true,
                      ),
                    );
                  },
                ),

              const SizedBox(height: 12),

              // ── Selected chips ──
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selected.asMap().entries.map((e) {
                  final color = barColors[e.key % barColors.length];
                  return Container(
                    padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(e.value.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeUni(e.value.id),
                          child: Icon(Icons.close_rounded, size: 18, color: color),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ── Bar Chart ──
              if (_selected.length >= 2) ...[
                Text('Fee per Semester (PKR)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))
                    .animate()
                    .fadeIn(duration: 300.ms),
                const SizedBox(height: 16),

                SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (_selected.map((s) => s.fee.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              'Rs ${_formatNum(rod.toY.toInt())}',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= _selected.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _selected[i].name,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).toStringAsFixed(0)}K',
                                style: TextStyle(fontSize: 10, color: AppColors.textTertiaryLight),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 50000,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.dividerLight,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _selected.asMap().entries.map((e) {
                        final color = barColors[e.key % barColors.length];
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.fee.toDouble(),
                              color: color,
                              width: 32,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: (_selected.map((s) => s.fee.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2),
                                color: color.withValues(alpha: 0.06),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 24),

                // ── Fee details table ──
                Text('Fee Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                ...(_selected.asMap().entries.map((e) {
                  final color = barColors[e.key % barColors.length];
                  final u = e.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(u.name[0], style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(u.feeText, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Text('Rs ${_formatNum(u.fee)}', style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 15)),
                      ],
                    ),
                  )
                      .animate(delay: (e.key * 80).ms)
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.05, end: 0, duration: 300.ms);
                })),
              ] else if (_selected.length == 1) ...[
                Center(
                  child: Text('Add at least 1 more university to compare', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiaryLight)),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)} Lakh';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)},${(n % 1000).toString().padLeft(3, '0')}';
    return '$n';
  }
}

class _UniOption {
  final String id;
  final String name;
  final String fullName;
  final String feeText;
  final int fee;

  const _UniOption({required this.id, required this.name, required this.fullName, required this.feeText, required this.fee});
}