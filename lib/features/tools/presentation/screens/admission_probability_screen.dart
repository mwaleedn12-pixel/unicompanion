import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_haptics.dart';

/// Admission Probability Calculator
/// Takes user's marks + university merit formula to show admission chance %.
class AdmissionProbabilityScreen extends StatefulWidget {
  const AdmissionProbabilityScreen({super.key});

  @override
  State<AdmissionProbabilityScreen> createState() => _AdmissionProbabilityScreenState();
}

class _AdmissionProbabilityScreenState extends State<AdmissionProbabilityScreen> {
  final _matricController = TextEditingController();
  final _fscController = TextEditingController();
  final _testController = TextEditingController();

  String _selectedFormula = 'nust'; // Default
  double? _aggregate;
  String? _probabilityLabel;
  Color? _probabilityColor;
  double? _probabilityPercent;

  // Merit formula presets
  static const _formulas = {
    'nust': _FormulaPreset(
      name: 'NUST',
      fullName: 'National University of Sciences & Technology',
      testWeight: 75, fscWeight: 15, matricWeight: 10,
      testLabel: 'NET Score',
      historicalCutoffs: {'Engineering': 78, 'Computing': 72, 'Business': 65, 'Sciences': 60},
    ),
    'pieas': _FormulaPreset(
      name: 'PIEAS',
      fullName: 'Pakistan Institute of Engineering & Applied Sciences',
      testWeight: 60, fscWeight: 25, matricWeight: 15,
      testLabel: 'PIEAS Entry Test Percentile',
      historicalCutoffs: {'Engineering': 80, 'Computing': 75, 'Sciences': 70},
    ),
    'fast': _FormulaPreset(
      name: 'FAST-NUCES',
      fullName: 'National University of Computer & Emerging Sciences',
      testWeight: 70, fscWeight: 20, matricWeight: 10,
      testLabel: 'NAT Score',
      historicalCutoffs: {'CS': 70, 'Engineering': 65, 'Business': 55},
    ),
    'comsats': _FormulaPreset(
      name: 'COMSATS',
      fullName: 'COMSATS University Islamabad',
      testWeight: 50, fscWeight: 30, matricWeight: 20,
      testLabel: 'NTS/NAT Score',
      historicalCutoffs: {'CS': 65, 'Engineering': 60, 'Business': 50},
    ),
    'giki': _FormulaPreset(
      name: 'GIKI',
      fullName: 'GIK Institute of Engineering Sciences',
      testWeight: 80, fscWeight: 12, matricWeight: 8,
      testLabel: 'GIKI Entry Test',
      historicalCutoffs: {'Engineering': 75},
    ),
    'uet': _FormulaPreset(
      name: 'UET',
      fullName: 'University of Engineering & Technology',
      testWeight: 70, fscWeight: 20, matricWeight: 10,
      testLabel: 'ECAT Score',
      historicalCutoffs: {'CS': 72, 'Electrical': 75, 'Mechanical': 70, 'Civil': 65},
    ),
  };

  void _calculate() {
    final matric = double.tryParse(_matricController.text);
    final fsc = double.tryParse(_fscController.text);
    final test = double.tryParse(_testController.text);

    if (matric == null || fsc == null || test == null) return;
    if (matric < 0 || matric > 100 || fsc < 0 || fsc > 100 || test < 0 || test > 100) return;

    AppHaptics.tap();

    final formula = _formulas[_selectedFormula]!;
    final aggregate = (test * formula.testWeight / 100) +
        (fsc * formula.fscWeight / 100) +
        (matric * formula.matricWeight / 100);

    // Calculate probability based on historical cutoffs
    final cutoffs = formula.historicalCutoffs.values.toList();
    final avgCutoff = cutoffs.reduce((a, b) => a + b) / cutoffs.length;
    final lowestCutoff = cutoffs.reduce((a, b) => a < b ? a : b);

    double probability;
    String label;
    Color color;

    if (aggregate >= avgCutoff + 5) {
      probability = 90 + ((aggregate - avgCutoff - 5) / 10 * 10).clamp(0, 9);
      label = 'Excellent Chance';
      color = AppColors.success;
    } else if (aggregate >= avgCutoff) {
      probability = 70 + ((aggregate - avgCutoff) / 5 * 20).clamp(0, 19);
      label = 'Good Chance';
      color = const Color(0xFF22C55E);
    } else if (aggregate >= lowestCutoff) {
      probability = 40 + ((aggregate - lowestCutoff) / (avgCutoff - lowestCutoff) * 30).clamp(0, 29);
      label = 'Moderate Chance';
      color = AppColors.warning;
    } else if (aggregate >= lowestCutoff - 5) {
      probability = 15 + ((aggregate - lowestCutoff + 5) / 5 * 25).clamp(0, 24);
      label = 'Low Chance';
      color = const Color(0xFFF97316);
    } else {
      probability = (aggregate / lowestCutoff * 15).clamp(0, 14);
      label = 'Very Low Chance';
      color = AppColors.error;
    }

    setState(() {
      _aggregate = aggregate;
      _probabilityPercent = probability.clamp(0, 99);
      _probabilityLabel = label;
      _probabilityColor = color;
    });
  }

  @override
  void dispose() {
    _matricController.dispose();
    _fscController.dispose();
    _testController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formula = _formulas[_selectedFormula]!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Admission Probability', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                ],
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: -0.05, end: 0, duration: 350.ms),

              const SizedBox(height: 4),
              Text('Estimate your chances based on merit', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight))
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 24),

              // ── University selector ──
              Text('Select University', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _formulas.entries.map((e) {
                    final selected = _selectedFormula == e.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          AppHaptics.selection();
                          setState(() => _selectedFormula = e.key);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: selected ? AppColors.primary : AppColors.dividerLight),
                          ),
                          child: Text(
                            e.value.name,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondaryLight),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 8),
              Text(formula.fullName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)),
              const SizedBox(height: 4),
              Text(
                'Formula: ${formula.testWeight}% ${formula.testLabel} + ${formula.fscWeight}% FSC + ${formula.matricWeight}% Matric',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 24),

              // ── Input fields ──
              _InputField(label: 'Matriculation %', controller: _matricController, hint: 'e.g. 85'),
              const SizedBox(height: 14),
              _InputField(label: 'FSC / A-Level %', controller: _fscController, hint: 'e.g. 78'),
              const SizedBox(height: 14),
              _InputField(label: '${formula.testLabel} %', controller: _testController, hint: 'e.g. 72'),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _calculate,
                  child: const Text('Calculate Probability'),
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 350.ms),

              const SizedBox(height: 24),

              // ── Result ──
              if (_aggregate != null && _probabilityPercent != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF1C2B4A), const Color(0xFF10192E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      Text('Your Aggregate', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        _aggregate!.toStringAsFixed(2),
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 20),

                      // Probability gauge
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: _probabilityPercent! / 100,
                                strokeWidth: 10,
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(_probabilityColor!),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_probabilityPercent!.toStringAsFixed(0)}%',
                                  style: TextStyle(color: _probabilityColor, fontSize: 32, fontWeight: FontWeight.w800),
                                ),
                                Text('chance', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _probabilityColor!.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _probabilityLabel!,
                          style: TextStyle(color: _probabilityColor, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Cutoff hints
                      Text('Historical Cutoffs (approx)', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: formula.historicalCutoffs.entries.map((e) {
                          final above = _aggregate! >= e.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (above ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${e.key}: ${e.value}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: above ? AppColors.success : Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  const _InputField({required this.label, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.dividerLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.dividerLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixText: '%',
          ),
        ),
      ],
    );
  }
}

class _FormulaPreset {
  final String name;
  final String fullName;
  final int testWeight;
  final int fscWeight;
  final int matricWeight;
  final String testLabel;
  final Map<String, int> historicalCutoffs;

  const _FormulaPreset({
    required this.name,
    required this.fullName,
    required this.testWeight,
    required this.fscWeight,
    required this.matricWeight,
    required this.testLabel,
    required this.historicalCutoffs,
  });
}