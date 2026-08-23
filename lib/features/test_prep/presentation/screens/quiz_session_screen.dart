import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/test_prep_provider.dart';

class QuizSessionScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final String testLabel;
  final String subject;

  const QuizSessionScreen({
    super.key,
    required this.questions,
    required this.testLabel,
    required this.subject,
  });

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  late QuizSessionState _state;
  Timer? _timer;
  late int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.questions.length * 60; // 1 min per question
    _state = QuizSessionState(questions: widget.questions, timeLeftSeconds: _totalSeconds);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_state.timeLeftSeconds <= 1) {
        t.cancel();
        setState(() => _state = _state.copyWith(isFinished: true, timeLeftSeconds: 0));
      } else {
        setState(() => _state = _state.copyWith(timeLeftSeconds: _state.timeLeftSeconds - 1));
      }
    });
  }

  void _selectAnswer(String option) {
    if (_state.isFinished || _state.selectedAnswer != null) return;
    final newAnswers = Map<int, String>.from(_state.answers)..[_state.currentIndex] = option;
    setState(() => _state = _state.copyWith(answers: newAnswers));
  }

  void _next() {
    if (_state.isLastQuestion) {
      _timer?.cancel();
      setState(() => _state = _state.copyWith(isFinished: true));
    } else {
      setState(() => _state = _state.copyWith(currentIndex: _state.currentIndex + 1));
    }
  }

  void _skipQuestion() {
    if (_state.isLastQuestion) {
      _timer?.cancel();
      setState(() => _state = _state.copyWith(isFinished: true));
    } else {
      setState(() => _state = _state.copyWith(currentIndex: _state.currentIndex + 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state.isFinished) return _buildResults(context);
    return _buildQuiz(context);
  }

  Widget _buildQuiz(BuildContext context) {
    final q = _state.currentQuestion;
    final answered = _state.selectedAnswer != null;
    final isCorrect = answered && _state.selectedAnswer == q.correctOption;
    final minutes = _state.timeLeftSeconds ~/ 60;
    final seconds = _state.timeLeftSeconds % 60;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => _showExitDialog(context),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('${_state.currentIndex + 1} / ${_state.totalQuestions}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_state.currentIndex + 1) / _state.totalQuestions,
                            minHeight: 5,
                            backgroundColor: AppColors.dividerLight,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _state.timeLeftSeconds < 60 ? AppColors.errorSurface : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer_rounded, size: 14, color: _state.timeLeftSeconds < 60 ? AppColors.error : AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _state.timeLeftSeconds < 60 ? AppColors.error : AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject + difficulty
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)),
                          child: Text(q.subject, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _diffColor(q.difficulty).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(q.difficulty.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _diffColor(q.difficulty))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question
                    Text(q.question, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.4)),
                    const SizedBox(height: 20),

                    // Options
                    ...['a', 'b', 'c', 'd'].map((key) {
                      final text = q.optionText(key);
                      final isSelected = _state.selectedAnswer == key;
                      final isCorrectOption = q.correctOption == key;

                      Color bgColor = Theme.of(context).colorScheme.surface;
                      Color borderColor = Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);
                      Color textColor = AppColors.textPrimaryLight;

                      if (answered) {
                        if (isCorrectOption) {
                          bgColor = AppColors.successSurface;
                          borderColor = AppColors.success;
                          textColor = AppColors.success;
                        } else if (isSelected && !isCorrectOption) {
                          bgColor = AppColors.errorSurface;
                          borderColor = AppColors.error;
                          textColor = AppColors.error;
                        }
                      } else if (isSelected) {
                        bgColor = AppColors.primarySurface;
                        borderColor = AppColors.primary;
                      }

                      return GestureDetector(
                        onTap: () => _selectAnswer(key),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: (isSelected || (answered && isCorrectOption)) ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: (isSelected || (answered && isCorrectOption)) ? borderColor.withValues(alpha: 0.2) : AppColors.dividerLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: answered && isCorrectOption
                                      ? Icon(Icons.check_rounded, size: 16, color: AppColors.success)
                                      : answered && isSelected && !isCorrectOption
                                          ? Icon(Icons.close_rounded, size: 16, color: AppColors.error)
                                          : Text(key.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: textColor))),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Explanation (after answering)
                    if (answered && q.explanation != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.infoSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.info),
                            const SizedBox(width: 8),
                            Expanded(child: Text(q.explanation!, style: TextStyle(fontSize: 13, color: AppColors.info, height: 1.4))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  if (!answered)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _skipQuestion,
                        child: const Text('Skip'),
                      ),
                    ),
                  if (!answered) const SizedBox(width: 12),
                  Expanded(
                    flex: answered ? 1 : 0,
                    child: SizedBox(
                      width: answered ? double.infinity : 0,
                      height: 48,
                      child: answered
                          ? ElevatedButton(
                              onPressed: _next,
                              child: Text(_state.isLastQuestion ? 'See Results' : 'Next'),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final score = _state.scorePercentage;
    final correct = _state.correctCount;
    final total = _state.totalQuestions;
    final answered = _state.answers.length;
    final skipped = total - answered;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Score circle
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: score >= 70 ? [AppColors.success, const Color(0xFF86EFAC)] : score >= 40 ? [AppColors.accent, AppColors.accentLight] : [AppColors.error, const Color(0xFFFCA5A5)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(color: (score >= 70 ? AppColors.success : AppColors.error).withValues(alpha: 0.3), blurRadius: 20)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${score.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                    Text('$correct / $total', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                score >= 70 ? 'Excellent!' : score >= 40 ? 'Good Effort!' : 'Keep Practicing!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text('${widget.testLabel} · ${widget.subject}', style: TextStyle(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 24),

              // Stats
              Row(
                children: [
                  _StatTile(label: 'Correct', value: '$correct', color: AppColors.success),
                  const SizedBox(width: 10),
                  _StatTile(label: 'Wrong', value: '${answered - correct}', color: AppColors.error),
                  const SizedBox(width: 10),
                  _StatTile(label: 'Skipped', value: '$skipped', color: AppColors.textTertiaryLight),
                ],
              ),
              const SizedBox(height: 24),

              // Review answers
              Text('Review Answers', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              ...List.generate(total, (i) {
                final q = _state.questions[i];
                final userAnswer = _state.answers[i];
                final wasCorrect = userAnswer == q.correctOption;
                final wasSkipped = userAnswer == null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: wasSkipped ? AppColors.dividerLight : wasCorrect ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: wasSkipped ? AppColors.dividerLight : wasCorrect ? AppColors.successSurface : AppColors.errorSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: wasSkipped
                              ? Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiaryLight))
                              : Icon(wasCorrect ? Icons.check_rounded : Icons.close_rounded, size: 16, color: wasCorrect ? AppColors.success : AppColors.error),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(q.question, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      if (!wasSkipped && !wasCorrect) ...[
                        const SizedBox(width: 6),
                        Text(q.correctOption.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Tests'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Restart with same questions reshuffled
                        setState(() {
                          final reshuffled = List<QuestionModel>.from(widget.questions)..shuffle();
                          _totalSeconds = reshuffled.length * 60;
                          _state = QuizSessionState(questions: reshuffled, timeLeftSeconds: _totalSeconds);
                          _timer?.cancel();
                          _startTimer();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit Practice?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continue')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Quit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'easy': return AppColors.success;
      case 'hard': return AppColors.error;
      default: return AppColors.accent;
    }
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}