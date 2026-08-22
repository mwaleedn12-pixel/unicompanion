import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class _QuizQuestion {
  final String question;
  final List<_QuizOption> options;
  const _QuizQuestion({required this.question, required this.options});
}

class _QuizOption {
  final String text;
  final List<String> tags;
  const _QuizOption({required this.text, required this.tags});
}

const _questions = [
  _QuizQuestion(question: 'What do you enjoy doing the most?', options: [
    _QuizOption(text: 'Solving puzzles & coding', tags: ['Software Engineering', 'Data Science', 'AI']),
    _QuizOption(text: 'Helping people with health', tags: ['Medicine', 'Pharmacy', 'Psychology']),
    _QuizOption(text: 'Building & designing things', tags: ['Civil Engineering', 'Architecture', 'Mechanical Engineering']),
    _QuizOption(text: 'Managing money & business', tags: ['Business', 'Accounting', 'Economics']),
  ]),
  _QuizQuestion(question: 'What subject do you find most interesting?', options: [
    _QuizOption(text: 'Mathematics & Logic', tags: ['Software Engineering', 'Data Science', 'Electrical Engineering']),
    _QuizOption(text: 'Biology & Chemistry', tags: ['Medicine', 'Pharmacy', 'Biotechnology']),
    _QuizOption(text: 'Physics & Mechanics', tags: ['Mechanical Engineering', 'Civil Engineering', 'Electrical Engineering']),
    _QuizOption(text: 'English & Communication', tags: ['Law', 'Media', 'Psychology']),
  ]),
  _QuizQuestion(question: 'Where do you see yourself working?', options: [
    _QuizOption(text: 'Tech company or startup', tags: ['Software Engineering', 'Data Science', 'AI', 'Cybersecurity']),
    _QuizOption(text: 'Hospital or clinic', tags: ['Medicine', 'Pharmacy', 'Psychology']),
    _QuizOption(text: 'Office or bank', tags: ['Business', 'Accounting', 'Economics', 'Law']),
    _QuizOption(text: 'Construction site or lab', tags: ['Civil Engineering', 'Mechanical Engineering', 'Architecture']),
  ]),
  _QuizQuestion(question: 'What kind of problems excite you?', options: [
    _QuizOption(text: 'Making technology smarter', tags: ['AI', 'Data Science', 'Software Engineering']),
    _QuizOption(text: 'Curing diseases', tags: ['Medicine', 'Pharmacy', 'Biotechnology']),
    _QuizOption(text: 'Designing infrastructure', tags: ['Civil Engineering', 'Architecture']),
    _QuizOption(text: 'Growing businesses', tags: ['Business', 'Marketing', 'Economics']),
  ]),
  _QuizQuestion(question: 'Pick your ideal work style:', options: [
    _QuizOption(text: 'Working on a laptop, remote', tags: ['Software Engineering', 'Data Science', 'AI', 'Cybersecurity']),
    _QuizOption(text: 'Face-to-face with people', tags: ['Medicine', 'Law', 'Psychology', 'Teaching']),
    _QuizOption(text: 'Hands-on, practical work', tags: ['Mechanical Engineering', 'Electrical Engineering', 'Architecture']),
    _QuizOption(text: 'Leading teams & making decisions', tags: ['Business', 'Marketing', 'Economics']),
  ]),
];

class CareerQuizScreen extends StatefulWidget {
  const CareerQuizScreen({super.key});

  @override
  State<CareerQuizScreen> createState() => _CareerQuizScreenState();
}

class _CareerQuizScreenState extends State<CareerQuizScreen> {
  int _current = 0;
  final Map<int, int> _answers = {};
  bool _showResults = false;

  void _selectOption(int optionIndex) {
    setState(() {
      _answers[_current] = optionIndex;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (_current < _questions.length - 1) {
        setState(() => _current++);
      } else {
        setState(() => _showResults = true);
      }
    });
  }

  List<MapEntry<String, int>> _getResults() {
    final Map<String, int> scores = {};
    for (final entry in _answers.entries) {
      final question = _questions[entry.key];
      final option = question.options[entry.value];
      for (final tag in option.tags) {
        scores[tag] = (scores[tag] ?? 0) + 1;
      }
    }
    final sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(6).toList();
  }

  void _restart() {
    setState(() { _current = 0; _answers.clear(); _showResults = false; });
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(child: Text('Career Quiz', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                  if (_showResults)
                    TextButton.icon(
                      onPressed: _restart,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retake'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondaryLight),
                    ),
                ],
              ),
            ),

            Expanded(
              child: _showResults ? _buildResults(context) : _buildQuiz(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz(BuildContext context) {
    final q = _questions[_current];
    final progress = (_current + 1) / _questions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Text('${_current + 1}/${_questions.length}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: AppColors.primarySurface, valueColor: const AlwaysStoppedAnimation(AppColors.primary)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Text(q.question, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),

          const SizedBox(height: 24),

          ...List.generate(q.options.length, (i) {
            final selected = _answers[_current] == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _selectOption(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primarySurface : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.15), width: selected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: selected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                              : Text('${String.fromCharCode(65 + i)}', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text(q.options[i].text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500))),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final results = _getResults();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Top Result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Column(
              children: [
                const Icon(Icons.psychology_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text('Your Top Career Match', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
                const SizedBox(height: 6),
                Text(results.isNotEmpty ? results[0].key : 'N/A', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text('${((results.isNotEmpty ? results[0].value : 0) / _questions.length * 100).toInt()}% match', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Align(alignment: Alignment.centerLeft, child: Text('All Matches', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
          const SizedBox(height: 14),

          ...results.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            final pct = (r.value / _questions.length * 100).toInt();
            final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.info, AppColors.success, const Color(0xFF8B5CF6)];
            final color = colors[i % colors.length];

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
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text('#${i + 1}', style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r.key, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('$pct%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}