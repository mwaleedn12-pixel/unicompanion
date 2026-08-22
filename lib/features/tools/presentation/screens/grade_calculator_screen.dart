import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/grade_provider.dart';

class GradeCalculatorScreen extends ConsumerWidget {
  const GradeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradeProvider);

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
                  Expanded(child: Text('Grade Calculator', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                  TextButton.icon(
                    onPressed: () => ref.read(gradeProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _GradeResultCard(state: state),
                  const SizedBox(height: 16),

                  // Credit Hours + Lab Toggle
                  Container(
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
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.credit_score_rounded, size: 18, color: AppColors.primary)),
                            const SizedBox(width: 10),
                            Text('Credit Hours', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(10)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: state.creditHours,
                                  isDense: true,
                                  items: [1, 2, 3, 4, 5, 6].map((h) => DropdownMenuItem(value: h, child: Text('$h'))).toList(),
                                  onChanged: (v) { if (v != null) ref.read(gradeProvider.notifier).setCreditHours(v); },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.science_rounded, size: 18, color: AppColors.secondary)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Has Lab?', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  if (state.hasLab)
                                    Text('Theory: ${state.theoryCreditHours} Cr (${state.theoryWeight.toInt()}%) • Lab: ${state.labCreditHours} Cr (${state.labWeight.toInt()}%)',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                                ],
                              ),
                            ),
                            Switch(value: state.hasLab, onChanged: (v) => ref.read(gradeProvider.notifier).toggleLab(v), activeColor: AppColors.secondary),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Theory Section
                  _SectionHeader(
                    title: state.hasLab ? 'Theory (${state.theoryWeight.toInt()}%)' : 'Assessments',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.primary,
                    totalWeight: state.theoryTotalWeightage,
                    isValid: state.isTheoryWeightValid,
                  ),
                  const SizedBox(height: 10),

                  ...List.generate(state.theoryAssessments.length, (i) => _AssessmentCard(
                    assessment: state.theoryAssessments[i], index: i, canDelete: state.theoryAssessments.length > 1, isLab: false,
                  )),

                  _AddButton(label: 'Add Assessment', onTap: () => ref.read(gradeProvider.notifier).addTheoryAssessment(), color: AppColors.primary),

                  // Lab Section
                  if (state.hasLab) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(
                      title: 'Lab (${state.labWeight.toInt()}%)',
                      icon: Icons.science_rounded,
                      color: AppColors.secondary,
                      totalWeight: state.labTotalWeightage,
                      isValid: state.isLabWeightValid,
                    ),
                    const SizedBox(height: 10),

                    ...List.generate(state.labAssessments.length, (i) => _AssessmentCard(
                      assessment: state.labAssessments[i], index: i, canDelete: state.labAssessments.length > 1, isLab: true,
                    )),

                    _AddButton(label: 'Add Lab Assessment', onTap: () => ref.read(gradeProvider.notifier).addLabAssessment(), color: AppColors.secondary),
                  ],

                  // Target Section
                  if (state.hasResults) ...[
                    const SizedBox(height: 20),
                    _TargetSection(state: state),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeResultCard extends StatelessWidget {
  final GradeState state;
  const _GradeResultCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasData = state.hasResults;
    final grade = hasData ? state.currentGrade : '?';
    final pct = hasData ? state.overallPercentage : 0.0;
    final color = hasData ? _gradeColor(grade) : AppColors.info;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Grade', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                const SizedBox(height: 4),
                Text(grade, style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 52)),
                const SizedBox(height: 4),
                Text(hasData ? '${pct.toStringAsFixed(1)}% overall' : 'Enter your marks', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (state.hasLab && hasData)
            Column(
              children: [
                _MiniBox(label: 'Theory', value: '${state.theoryPercentage.toStringAsFixed(0)}%'),
                const SizedBox(height: 8),
                _MiniBox(label: 'Lab', value: '${state.labPercentage.toStringAsFixed(0)}%'),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  Text('${state.creditHours}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                  Text('Credits', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _gradeColor(String g) {
    if (g.startsWith('A')) return AppColors.success;
    if (g.startsWith('B')) return AppColors.primary;
    if (g.startsWith('C')) return AppColors.accent;
    return AppColors.error;
  }
}

class _MiniBox extends StatelessWidget {
  final String label;
  final String value;
  const _MiniBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double totalWeight;
  final bool isValid;
  const _SectionHeader({required this.title, required this.icon, required this.color, required this.totalWeight, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isValid ? AppColors.successSurface : AppColors.warningSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('${totalWeight.toInt()}% / 100%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isValid ? AppColors.success : AppColors.warning)),
        ),
      ],
    );
  }
}

class _AssessmentCard extends ConsumerWidget {
  final Assessment assessment;
  final int index;
  final bool canDelete;
  final bool isLab;
  const _AssessmentCard({required this.assessment, required this.index, required this.canDelete, required this.isLab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasData = assessment.hasData;
    final color = isLab ? AppColors.secondary : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: hasData ? color.withValues(alpha: 0.25) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: hasData ? color.withValues(alpha: 0.12) : AppColors.backgroundLight, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: hasData ? color : AppColors.textTertiaryLight)))),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: assessment.name)..selection = TextSelection.collapsed(offset: assessment.name.length),
                  onChanged: (v) => isLab ? ref.read(gradeProvider.notifier).updateLabName(assessment.id, v) : ref.read(gradeProvider.notifier).updateTheoryName(assessment.id, v),
                  decoration: InputDecoration(hintText: '${isLab ? "Lab " : ""}Assessment ${index + 1}', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, fillColor: Colors.transparent),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                width: 65, padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: TextEditingController(text: assessment.weightage > 0 ? assessment.weightage.toInt().toString() : ''),
                  onChanged: (v) { final val = double.tryParse(v); if (val != null) isLab ? ref.read(gradeProvider.notifier).updateLabWeight(assessment.id, val) : ref.read(gradeProvider.notifier).updateTheoryWeight(assessment.id, val); },
                  decoration: const InputDecoration(hintText: 'W%', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8), suffixText: '%'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accentDark),
                  textAlign: TextAlign.center,
                ),
              ),
              if (canDelete) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => isLab ? ref.read(gradeProvider.notifier).removeLabAssessment(assessment.id) : ref.read(gradeProvider.notifier).removeTheoryAssessment(assessment.id),
                  child: Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) { final val = double.tryParse(v); if (val != null) isLab ? ref.read(gradeProvider.notifier).updateLabObtained(assessment.id, val) : ref.read(gradeProvider.notifier).updateTheoryObtained(assessment.id, val); },
                  decoration: const InputDecoration(hintText: 'Obtained', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('/', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textTertiaryLight))),
              SizedBox(width: 80, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: TextEditingController(text: assessment.totalMarks > 0 ? assessment.totalMarks.toInt().toString() : ''),
                  onChanged: (v) { final val = double.tryParse(v); if (val != null) isLab ? ref.read(gradeProvider.notifier).updateLabTotal(assessment.id, val) : ref.read(gradeProvider.notifier).updateTheoryTotal(assessment.id, val); },
                  decoration: const InputDecoration(hintText: 'Total', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ))),
              if (hasData) ...[
                const SizedBox(width: 10),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('${assessment.percentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color))),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _AddButton({required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_circle_outline_rounded, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _TargetSection extends StatelessWidget {
  final GradeState state;
  const _TargetSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final targets = {'A (86%)': 86.0, 'A- (82%)': 82.0, 'B+ (78%)': 78.0, 'B (74%)': 74.0, 'B- (70%)': 70.0, 'C+ (66%)': 66.0};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withValues(alpha: 0.15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.flag_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('What You Need in Remaining', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
          const SizedBox(height: 14),
          ...targets.entries.map((e) {
            final needed = state.requiredForTarget(e.value);
            final possible = needed <= 100 && needed >= 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(e.key, style: Theme.of(context).textTheme.bodySmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: possible ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(possible ? '${needed.toStringAsFixed(0)}% needed' : 'Not possible', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: possible ? AppColors.success : AppColors.error)),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}