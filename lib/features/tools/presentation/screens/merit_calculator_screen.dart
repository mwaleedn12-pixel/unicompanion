import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/merit_provider.dart';

class MeritCalculatorScreen extends ConsumerWidget {
  const MeritCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meritProvider);

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
                  Expanded(child: Text('Merit Calculator', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                  TextButton.icon(
                    onPressed: () => ref.read(meritProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Result
                    _AggregateCard(state: state),
                    const SizedBox(height: 24),

                    // Formula Selector
                    Text('University Formula', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: universityFormulas.length,
                        itemBuilder: (context, i) {
                          final isSelected = state.selectedFormulaIndex == i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => ref.read(meritProvider.notifier).setFormula(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.dividerLight),
                                ),
                                child: Text(
                                  universityFormulas[i].name,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondaryLight),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Weightage Display
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _WeightChip(label: 'Matric', weight: state.isCustom ? state.customMatricWeight : state.formula.matricWeight),
                          _WeightChip(label: 'FSC', weight: state.isCustom ? state.customFscWeight : state.formula.fscWeight),
                          _WeightChip(label: 'Test', weight: state.isCustom ? state.customTestWeight : state.formula.testWeight),
                          if (state.formula.hafizBonus > 0) _WeightChip(label: 'Hafiz', weight: state.formula.hafizBonus),
                        ],
                      ),
                    ),

                    // Custom Weights
                    if (state.isCustom) ...[
                      const SizedBox(height: 16),
                      _CustomWeightSlider(label: 'Matric Weight', value: state.customMatricWeight, onChanged: (v) => ref.read(meritProvider.notifier).setCustomMatricWeight(v)),
                      _CustomWeightSlider(label: 'FSC Weight', value: state.customFscWeight, onChanged: (v) => ref.read(meritProvider.notifier).setCustomFscWeight(v)),
                      _CustomWeightSlider(label: 'Test Weight', value: state.customTestWeight, onChanged: (v) => ref.read(meritProvider.notifier).setCustomTestWeight(v)),
                    ],

                    const SizedBox(height: 24),

                    // Marks Input
                    Text('Enter Your Marks', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),

                    _MarksInput(label: 'Matric', icon: Icons.school_outlined, color: AppColors.secondary,
                      marks: state.matricMarks, total: state.matricTotal, pct: state.matricPercentage,
                      onMarksChanged: (v) => ref.read(meritProvider.notifier).setMatricMarks(v),
                      onTotalChanged: (v) => ref.read(meritProvider.notifier).setMatricTotal(v),
                    ),
                    const SizedBox(height: 10),
                    _MarksInput(label: 'FSC / A-Level', icon: Icons.menu_book_rounded, color: AppColors.primary,
                      marks: state.fscMarks, total: state.fscTotal, pct: state.fscPercentage,
                      onMarksChanged: (v) => ref.read(meritProvider.notifier).setFscMarks(v),
                      onTotalChanged: (v) => ref.read(meritProvider.notifier).setFscTotal(v),
                    ),
                    const SizedBox(height: 10),
                    _MarksInput(label: 'Entry Test', icon: Icons.quiz_rounded, color: AppColors.accent,
                      marks: state.testMarks, total: state.testTotal, pct: state.testPercentage,
                      onMarksChanged: (v) => ref.read(meritProvider.notifier).setTestMarks(v),
                      onTotalChanged: (v) => ref.read(meritProvider.notifier).setTestTotal(v),
                    ),

                    // Hafiz bonus
                    if (state.formula.hafizBonus > 0) ...[
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: Text('Hafiz-e-Quran', style: Theme.of(context).textTheme.titleSmall),
                        subtitle: Text('+${state.formula.hafizBonus}% bonus'),
                        value: state.isHafiz,
                        onChanged: (v) => ref.read(meritProvider.notifier).setHafiz(v),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],

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

class _AggregateCard extends StatelessWidget {
  final MeritState state;
  const _AggregateCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = !state.hasData ? const Color(0xFF8B5CF6) :
        state.aggregate >= 80 ? AppColors.success :
        state.aggregate >= 60 ? AppColors.primary : AppColors.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Text('Your Aggregate', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            state.hasData ? '${state.aggregate.toStringAsFixed(2)}%' : '0.00%',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 48),
          ),
          if (state.hasData) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(state.aggregateVerdict, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            ),
          ],
          if (!state.hasData)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Enter marks & select formula', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class _WeightChip extends StatelessWidget {
  final String label;
  final double weight;
  const _WeightChip({required this.label, required this.weight});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${weight.toInt()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
      ],
    );
  }
}

class _CustomWeightSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _CustomWeightSlider({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        Expanded(
          child: Slider(value: value, min: 0, max: 100, divisions: 100, onChanged: onChanged, activeColor: AppColors.primary),
        ),
        SizedBox(width: 40, child: Text('${value.toInt()}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
      ],
    );
  }
}

class _MarksInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double marks;
  final double total;
  final double pct;
  final ValueChanged<double> onMarksChanged;
  final ValueChanged<double> onTotalChanged;

  const _MarksInput({
    required this.label, required this.icon, required this.color,
    required this.marks, required this.total, required this.pct,
    required this.onMarksChanged, required this.onTotalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
              if (marks > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('${pct.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) { final val = double.tryParse(v); if (val != null) onMarksChanged(val); },
                    decoration: const InputDecoration(hintText: 'Obtained', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('/', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textTertiaryLight)),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: TextEditingController(text: total > 0 ? total.toInt().toString() : ''),
                    onChanged: (v) { final val = double.tryParse(v); if (val != null) onTotalChanged(val); },
                    decoration: const InputDecoration(hintText: 'Total', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}