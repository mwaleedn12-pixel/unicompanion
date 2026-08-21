import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/eligibility_provider.dart';

class EligibilityCheckerScreen extends ConsumerWidget {
  const EligibilityCheckerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eligibilityProvider);

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
                  Expanded(child: Text('Eligibility', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                  TextButton.icon(
                    onPressed: () => ref.read(eligibilityProvider.notifier).reset(),
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
                    // Summary Card
                    if (state.hasData)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.success, AppColors.success.withValues(alpha: 0.7)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(children: [
                              Text('${state.eligibleCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 36)),
                              Text('Eligible', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                            ]),
                            Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.3)),
                            Column(children: [
                              Text('${state.notEligibleCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 36)),
                              Text('Not Eligible', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                            ]),
                            Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.3)),
                            Column(children: [
                              Text('${state.results.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 36)),
                              Text('Total', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                            ]),
                          ],
                        ),
                      ),

                    if (!state.hasData)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.verified_rounded, color: Colors.white, size: 40),
                            const SizedBox(height: 10),
                            Text('Check Your Eligibility', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Enter your marks below', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Input Fields
                    Text('Your Marks', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),

                    _PercentageInput(label: 'Matric Percentage', icon: Icons.school_outlined, color: AppColors.secondary,
                      onChanged: (v) => ref.read(eligibilityProvider.notifier).setMatricPercentage(v)),
                    const SizedBox(height: 10),
                    _PercentageInput(label: 'FSC / A-Level Percentage', icon: Icons.menu_book_rounded, color: AppColors.primary,
                      onChanged: (v) => ref.read(eligibilityProvider.notifier).setFscPercentage(v)),

                    const SizedBox(height: 16),

                    // Stream
                    Text('Your Stream', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.fscStreams.entries.map((entry) {
                        final isSelected = state.stream == entry.key;
                        return GestureDetector(
                          onTap: () => ref.read(eligibilityProvider.notifier).setStream(entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.dividerLight),
                            ),
                            child: Text(entry.value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondaryLight)),
                          ),
                        );
                      }).toList(),
                    ),

                    // Results
                    if (state.hasData) ...[
                      const SizedBox(height: 24),
                      Text('Results', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      ...state.results.map((r) => _ResultCard(result: r)),
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

class _PercentageInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final ValueChanged<double> onChanged;

  const _PercentageInput({required this.label, required this.icon, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) { final val = double.tryParse(v); if (val != null) onChanged(val); },
              decoration: InputDecoration(hintText: label, border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10), suffixText: '%'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final EligibilityResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final p = result.program;
    final eligible = result.isEligible;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: eligible ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: eligible ? AppColors.successSurface : AppColors.errorSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(eligible ? Icons.check_circle_rounded : Icons.cancel_rounded, color: eligible ? AppColors.success : AppColors.error, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(p.university, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _MiniTag(label: 'Matric ${p.minMatric.toInt()}%', ok: result.matricOk),
                    _MiniTag(label: 'FSC ${p.minFsc.toInt()}%', ok: result.fscOk),
                    if (!result.streamOk) _MiniTag(label: 'Stream ✗', ok: false),
                    if (p.requiresTest) _MiniTag(label: p.testName ?? 'Test', ok: true, neutral: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final bool ok;
  final bool neutral;
  const _MiniTag({required this.label, required this.ok, this.neutral = false});

  @override
  Widget build(BuildContext context) {
    final color = neutral ? AppColors.info : (ok ? AppColors.success : AppColors.error);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}