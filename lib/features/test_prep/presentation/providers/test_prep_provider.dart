import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';

// ── Model ──

class QuestionModel {
  final String id;
  final String testType;
  final String subject;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption; // a, b, c, d
  final String? explanation;
  final String difficulty;

  const QuestionModel({
    required this.id,
    required this.testType,
    required this.subject,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    this.explanation,
    this.difficulty = 'medium',
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      testType: json['test_type'],
      subject: json['subject'],
      question: json['question'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      correctOption: json['correct_option'],
      explanation: json['explanation'],
      difficulty: json['difficulty'] ?? 'medium',
    );
  }

  String optionText(String key) {
    switch (key) {
      case 'a': return optionA;
      case 'b': return optionB;
      case 'c': return optionC;
      case 'd': return optionD;
      default: return '';
    }
  }
}

// ── Test types config ──

class TestTypeInfo {
  final String key;
  final String label;
  final String fullName;
  final IconLabel icon;
  const TestTypeInfo(this.key, this.label, this.fullName, this.icon);
}

class IconLabel {
  final int codePoint;
  const IconLabel(this.codePoint);
}

const testTypes = [
  TestTypeInfo('ecat', 'ECAT', 'Engineering College Admission Test', IconLabel(0xe3d3)), // engineering
  TestTypeInfo('mdcat', 'MDCAT', 'Medical & Dental College Admission Test', IconLabel(0xe548)), // medical
  TestTypeInfo('net', 'NET', 'National Aptitude Test (NUST)', IconLabel(0xe80c)), // school
  TestTypeInfo('gat', 'GAT', 'Graduate Assessment Test', IconLabel(0xf06bb)), // quiz
  TestTypeInfo('nts', 'NTS', 'National Testing Service', IconLabel(0xe873)), // assignment
];

// ── Provider ──

final testQuestionsProvider = StateNotifierProvider.family<TestQuestionsNotifier, UiState<List<QuestionModel>>, String>(
  (ref, testType) {
    final client = ref.watch(supabaseClientProvider);
    return TestQuestionsNotifier(client, testType);
  },
);

/// Available subjects for a test type
final testSubjectsProvider = Provider.family<List<String>, String>((ref, testType) {
  final questions = ref.watch(testQuestionsProvider(testType)).dataOrNull ?? [];
  return questions.map((q) => q.subject).toSet().toList()..sort();
});

class TestQuestionsNotifier extends StateNotifier<UiState<List<QuestionModel>>> {
  final SupabaseClient _client;
  final String _testType;

  TestQuestionsNotifier(this._client, this._testType) : super(const UiState.initial());

  Future<void> load({String? subject, String? difficulty}) async {
    state = const UiState.loading();
    try {
      var query = _client.from('test_questions').select().eq('test_type', _testType);
      if (subject != null) query = query.eq('subject', subject);
      if (difficulty != null) query = query.eq('difficulty', difficulty);
      final data = await query.order('created_at');
      state = UiState.success(data.map<QuestionModel>((e) => QuestionModel.fromJson(e)).toList());
    } catch (e) {
      state = UiState.error('Failed to load questions: $e');
    }
  }
}

// ── Quiz Session State (local, not Supabase) ──

class QuizSessionState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final Map<int, String> answers; // index → selected option
  final bool isFinished;
  final int timeLeftSeconds;

  const QuizSessionState({
    required this.questions,
    this.currentIndex = 0,
    this.answers = const {},
    this.isFinished = false,
    this.timeLeftSeconds = 0,
  });

  QuestionModel get currentQuestion => questions[currentIndex];
  int get totalQuestions => questions.length;
  bool get isLastQuestion => currentIndex == totalQuestions - 1;
  String? get selectedAnswer => answers[currentIndex];

  int get correctCount {
    int count = 0;
    for (final entry in answers.entries) {
      if (entry.value == questions[entry.key].correctOption) count++;
    }
    return count;
  }

  double get scorePercentage => totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0;

  QuizSessionState copyWith({
    int? currentIndex,
    Map<int, String>? answers,
    bool? isFinished,
    int? timeLeftSeconds,
  }) {
    return QuizSessionState(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isFinished: isFinished ?? this.isFinished,
      timeLeftSeconds: timeLeftSeconds ?? this.timeLeftSeconds,
    );
  }
}