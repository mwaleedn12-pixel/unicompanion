import 'package:flutter_riverpod/flutter_riverpod.dart';

class EligibilityProgram {
  final String name;
  final String university;
  final double minMatric;
  final double minFsc;
  final List<String> requiredStreams;
  final bool requiresTest;
  final String? testName;

  const EligibilityProgram({
    required this.name,
    required this.university,
    this.minMatric = 60,
    this.minFsc = 60,
    this.requiredStreams = const [],
    this.requiresTest = false,
    this.testName,
  });
}

const samplePrograms = [
  EligibilityProgram(name: 'BS Computer Science', university: 'NUST', minMatric: 60, minFsc: 60, requiredStreams: ['pre_engineering', 'ics'], requiresTest: true, testName: 'NET'),
  EligibilityProgram(name: 'BS Electrical Engineering', university: 'NUST', minMatric: 60, minFsc: 60, requiredStreams: ['pre_engineering'], requiresTest: true, testName: 'NET'),
  EligibilityProgram(name: 'BS Computer Science', university: 'FAST', minMatric: 60, minFsc: 60, requiredStreams: ['pre_engineering', 'ics'], requiresTest: true, testName: 'NU Test'),
  EligibilityProgram(name: 'BS Computer Science', university: 'COMSATS', minMatric: 50, minFsc: 50, requiredStreams: ['pre_engineering', 'ics'], requiresTest: true, testName: 'NTS'),
  EligibilityProgram(name: 'BS Software Engineering', university: 'UET', minMatric: 60, minFsc: 60, requiredStreams: ['pre_engineering'], requiresTest: true, testName: 'ECAT'),
  EligibilityProgram(name: 'BBA', university: 'LUMS', minMatric: 70, minFsc: 70, requiredStreams: [], requiresTest: true, testName: 'LCAT'),
  EligibilityProgram(name: 'MBBS', university: 'AKU', minMatric: 70, minFsc: 80, requiredStreams: ['pre_medical'], requiresTest: true, testName: 'AKU Test'),
  EligibilityProgram(name: 'BS Computer Science', university: 'GIKI', minMatric: 60, minFsc: 60, requiredStreams: ['pre_engineering', 'ics'], requiresTest: true, testName: 'GIKI Test'),
  EligibilityProgram(name: 'BS Computer Science', university: 'Air University', minMatric: 50, minFsc: 50, requiredStreams: ['pre_engineering', 'ics'], requiresTest: true, testName: 'AU Test'),
  EligibilityProgram(name: 'BBA', university: 'IBA', minMatric: 60, minFsc: 60, requiredStreams: [], requiresTest: true, testName: 'IBA Test'),
  EligibilityProgram(name: 'BS Computer Science', university: 'PIEAS', minMatric: 60, minFsc: 80, requiredStreams: ['pre_engineering'], requiresTest: true, testName: 'PIEAS Test'),
  EligibilityProgram(name: 'BS Computer Science', university: 'Bahria', minMatric: 50, minFsc: 50, requiredStreams: ['pre_engineering', 'ics'], requiresTest: false),
];

class EligibilityResult {
  final EligibilityProgram program;
  final bool matricOk;
  final bool fscOk;
  final bool streamOk;
  final bool isEligible;

  const EligibilityResult({required this.program, required this.matricOk, required this.fscOk, required this.streamOk, required this.isEligible});
}

class EligibilityState {
  final double matricPercentage;
  final double fscPercentage;
  final String stream;
  final List<EligibilityResult> results;

  const EligibilityState({this.matricPercentage = 0, this.fscPercentage = 0, this.stream = '', this.results = const []});

  EligibilityState copyWith({double? matricPercentage, double? fscPercentage, String? stream, List<EligibilityResult>? results}) {
    return EligibilityState(
      matricPercentage: matricPercentage ?? this.matricPercentage,
      fscPercentage: fscPercentage ?? this.fscPercentage,
      stream: stream ?? this.stream,
      results: results ?? this.results,
    );
  }

  bool get hasData => matricPercentage > 0 && fscPercentage > 0 && stream.isNotEmpty;
  int get eligibleCount => results.where((r) => r.isEligible).length;
  int get notEligibleCount => results.where((r) => !r.isEligible).length;
}

final eligibilityProvider = StateNotifierProvider<EligibilityNotifier, EligibilityState>((ref) {
  return EligibilityNotifier();
});

class EligibilityNotifier extends StateNotifier<EligibilityState> {
  EligibilityNotifier() : super(const EligibilityState());

  void setMatricPercentage(double v) {
    state = state.copyWith(matricPercentage: v);
    _check();
  }

  void setFscPercentage(double v) {
    state = state.copyWith(fscPercentage: v);
    _check();
  }

  void setStream(String v) {
    state = state.copyWith(stream: v);
    _check();
  }

  void _check() {
    if (!state.hasData) return;
    final results = samplePrograms.map((p) {
      final matricOk = state.matricPercentage >= p.minMatric;
      final fscOk = state.fscPercentage >= p.minFsc;
      final streamOk = p.requiredStreams.isEmpty || p.requiredStreams.contains(state.stream);
      return EligibilityResult(program: p, matricOk: matricOk, fscOk: fscOk, streamOk: streamOk, isEligible: matricOk && fscOk && streamOk);
    }).toList();
    state = state.copyWith(results: results);
  }

  void reset() => state = const EligibilityState();
}