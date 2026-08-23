import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/test_prep_provider.dart';
import 'quiz_session_screen.dart';

class TestPrepScreen extends ConsumerStatefulWidget {
  const TestPrepScreen({super.key});

  @override
  ConsumerState<TestPrepScreen> createState() => _TestPrepScreenState();
}

class _TestPrepScreenState extends ConsumerState<TestPrepScreen> {
  String? _selectedType;
  String? _selectedSubject;
  int _questionCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Entry Test Prep', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text('Practice MCQs for entry tests', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
              ),
              const SizedBox(height: 24),

              // ── Test Type Selection ──
              Text('Select Test', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: testTypes.map((t) {
                  final isSelected = _selectedType == t.key;
                  final color = _typeColor(t.key);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = t.key;
                        _selectedSubject = null;
                      });
                      // Load questions to get subjects
                      ref.read(testQuestionsProvider(t.key).notifier).load();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? color : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12), width: isSelected ? 2 : 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t.label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isSelected ? color : AppColors.textPrimaryLight)),
                          const SizedBox(height: 4),
                          Text(t.fullName, style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight), textAlign: TextAlign.center, maxLines: 2),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (_selectedType != null) ...[
                const SizedBox(height: 24),

                // ── Subject Selection ──
                Text('Select Subject', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                Consumer(
                  builder: (context, ref, _) {
                    final subjects = ref.watch(testSubjectsProvider(_selectedType!));
                    final questionsState = ref.watch(testQuestionsProvider(_selectedType!));

                    if (questionsState.isLoading) {
                      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2)));
                    }

                    if (subjects.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.warningSurface, borderRadius: BorderRadius.circular(12)),
                        child: Text('No questions available for this test yet.', style: TextStyle(color: AppColors.warning, fontSize: 13)),
                      );
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SubjectChip(label: 'All Subjects', isSelected: _selectedSubject == null, onTap: () => setState(() => _selectedSubject = null)),
                        ...subjects.map((s) => _SubjectChip(label: s, isSelected: _selectedSubject == s, onTap: () => setState(() => _selectedSubject = s))),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Question Count ──
                Text('Number of Questions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                Row(
                  children: [5, 10, 15, 20].map((n) {
                    final isSelected = _questionCount == n;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text('$n'),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _questionCount = n),
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, color: isSelected ? AppColors.primary : null),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // ── Start Quiz Button ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _startQuiz,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Practice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _typeColor(_selectedType!),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuiz() {
    final allQuestions = ref.read(testQuestionsProvider(_selectedType!)).dataOrNull ?? [];
    var filtered = allQuestions;
    if (_selectedSubject != null) {
      filtered = allQuestions.where((q) => q.subject == _selectedSubject).toList();
    }

    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No questions available')));
      return;
    }

    // Shuffle and take requested count
    filtered.shuffle();
    final selected = filtered.take(_questionCount).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizSessionScreen(
          questions: selected,
          testLabel: testTypes.firstWhere((t) => t.key == _selectedType).label,
          subject: _selectedSubject ?? 'All Subjects',
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'ecat': return AppColors.primary;
      case 'mdcat': return AppColors.secondary;
      case 'net': return AppColors.accent;
      case 'gat': return AppColors.info;
      case 'nts': return AppColors.success;
      default: return AppColors.primary;
    }
  }
}

class _SubjectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _SubjectChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimaryLight)),
      ),
    );
  }
}