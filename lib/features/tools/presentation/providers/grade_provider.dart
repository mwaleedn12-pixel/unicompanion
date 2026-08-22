import 'package:flutter_riverpod/flutter_riverpod.dart';

class Assessment {
  final String id;
  String name;
  double weightage;
  double totalMarks;
  double obtainedMarks;

  Assessment({required this.id, this.name = '', this.weightage = 0, this.totalMarks = 100, this.obtainedMarks = 0});

  Assessment copyWith({String? name, double? weightage, double? totalMarks, double? obtainedMarks}) {
    return Assessment(id: id, name: name ?? this.name, weightage: weightage ?? this.weightage, totalMarks: totalMarks ?? this.totalMarks, obtainedMarks: obtainedMarks ?? this.obtainedMarks);
  }

  double get percentage => totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0;
  double get weightedScore => percentage * weightage / 100;
  bool get hasData => obtainedMarks > 0 && totalMarks > 0 && weightage > 0;
}

class GradeState {
  final int creditHours;
  final bool hasLab;
  final List<Assessment> theoryAssessments;
  final List<Assessment> labAssessments;

  const GradeState({
    this.creditHours = 3,
    this.hasLab = false,
    this.theoryAssessments = const [],
    this.labAssessments = const [],
  });

  GradeState copyWith({int? creditHours, bool? hasLab, List<Assessment>? theoryAssessments, List<Assessment>? labAssessments}) {
    return GradeState(
      creditHours: creditHours ?? this.creditHours,
      hasLab: hasLab ?? this.hasLab,
      theoryAssessments: theoryAssessments ?? this.theoryAssessments,
      labAssessments: labAssessments ?? this.labAssessments,
    );
  }

  // Lab is always 1 credit, theory = remaining
  int get theoryCreditHours => hasLab ? creditHours - 1 : creditHours;
  int get labCreditHours => hasLab ? 1 : 0;
  double get theoryWeight => hasLab ? (theoryCreditHours / creditHours) * 100 : 100;
  double get labWeight => hasLab ? (labCreditHours / creditHours) * 100 : 0;

  double get theoryTotalWeightage => theoryAssessments.fold(0.0, (s, a) => s + a.weightage);
  double get labTotalWeightage => labAssessments.fold(0.0, (s, a) => s + a.weightage);
  bool get isTheoryWeightValid => (theoryTotalWeightage - 100).abs() < 0.1;
  bool get isLabWeightValid => !hasLab || (labTotalWeightage - 100).abs() < 0.1;

  double get theoryPercentage {
    final filled = theoryAssessments.where((a) => a.hasData);
    if (filled.isEmpty) return 0;
    final usedW = filled.fold(0.0, (s, a) => s + a.weightage);
    if (usedW == 0) return 0;
    final weighted = filled.fold(0.0, (s, a) => s + a.weightedScore);
    return weighted / usedW * 100;
  }

  double get labPercentage {
    final filled = labAssessments.where((a) => a.hasData);
    if (filled.isEmpty) return 0;
    final usedW = filled.fold(0.0, (s, a) => s + a.weightage);
    if (usedW == 0) return 0;
    final weighted = filled.fold(0.0, (s, a) => s + a.weightedScore);
    return weighted / usedW * 100;
  }

  double get overallPercentage {
    if (!hasLab) return theoryPercentage;
    final hasTheoryData = theoryAssessments.any((a) => a.hasData);
    final hasLabData = labAssessments.any((a) => a.hasData);
    if (!hasTheoryData && !hasLabData) return 0;
    double total = 0;
    double weight = 0;
    if (hasTheoryData) { total += theoryPercentage * theoryWeight / 100; weight += theoryWeight; }
    if (hasLabData) { total += labPercentage * labWeight / 100; weight += labWeight; }
    return weight > 0 ? total / weight * 100 : 0;
  }

  bool get hasResults => theoryAssessments.any((a) => a.hasData) || labAssessments.any((a) => a.hasData);

  String get currentGrade => _pctToGrade(overallPercentage);

  double requiredForTarget(double targetPct) {
    final theoryFilled = theoryAssessments.where((a) => a.hasData);
    final theoryRemaining = theoryAssessments.where((a) => !a.hasData);
    final remainW = theoryRemaining.fold(0.0, (s, a) => s + a.weightage);
    if (remainW == 0) return 0;
    final earned = theoryFilled.fold(0.0, (s, a) => s + a.weightedScore);
    final needed = (targetPct - earned) / remainW * 100;
    return needed;
  }

  String _pctToGrade(double pct) {
    if (pct >= 86) return 'A';
    if (pct >= 82) return 'A-';
    if (pct >= 78) return 'B+';
    if (pct >= 74) return 'B';
    if (pct >= 70) return 'B-';
    if (pct >= 66) return 'C+';
    if (pct >= 62) return 'C';
    if (pct >= 58) return 'C-';
    if (pct >= 54) return 'D+';
    if (pct >= 50) return 'D';
    return 'F';
  }
}

final gradeProvider = StateNotifierProvider<GradeNotifier, GradeState>((ref) => GradeNotifier());

class GradeNotifier extends StateNotifier<GradeState> {
  GradeNotifier() : super(GradeState(theoryAssessments: _defaultTheory(), labAssessments: _defaultLab()));

  static List<Assessment> _defaultTheory() => [
    Assessment(id: 't_quizzes', name: 'Quizzes', weightage: 15),
    Assessment(id: 't_assign', name: 'Assignments', weightage: 10),
    Assessment(id: 't_mid', name: 'Midterm', weightage: 25),
    Assessment(id: 't_final', name: 'Final Exam', weightage: 50),
  ];

  static List<Assessment> _defaultLab() => [
    Assessment(id: 'l_tasks', name: 'Lab Tasks', weightage: 30),
    Assessment(id: 'l_mid', name: 'Lab Midterm', weightage: 20),
    Assessment(id: 'l_final', name: 'Lab Final', weightage: 30),
    Assessment(id: 'l_project', name: 'Lab Project', weightage: 20),
  ];

  void setCreditHours(int v) => state = state.copyWith(creditHours: v < 1 ? 1 : v);
  void toggleLab(bool v) => state = state.copyWith(hasLab: v);

  // Theory
  void addTheoryAssessment() {
    state = state.copyWith(theoryAssessments: [...state.theoryAssessments, Assessment(id: 't_${DateTime.now().millisecondsSinceEpoch}')]);
  }
  void removeTheoryAssessment(String id) {
    if (state.theoryAssessments.length <= 1) return;
    state = state.copyWith(theoryAssessments: state.theoryAssessments.where((a) => a.id != id).toList());
  }
  void updateTheoryName(String id, String v) => state = state.copyWith(theoryAssessments: state.theoryAssessments.map((a) => a.id == id ? a.copyWith(name: v) : a).toList());
  void updateTheoryWeight(String id, double v) => state = state.copyWith(theoryAssessments: state.theoryAssessments.map((a) => a.id == id ? a.copyWith(weightage: v) : a).toList());
  void updateTheoryTotal(String id, double v) => state = state.copyWith(theoryAssessments: state.theoryAssessments.map((a) => a.id == id ? a.copyWith(totalMarks: v) : a).toList());
  void updateTheoryObtained(String id, double v) => state = state.copyWith(theoryAssessments: state.theoryAssessments.map((a) => a.id == id ? a.copyWith(obtainedMarks: v) : a).toList());

  // Lab
  void addLabAssessment() {
    state = state.copyWith(labAssessments: [...state.labAssessments, Assessment(id: 'l_${DateTime.now().millisecondsSinceEpoch}')]);
  }
  void removeLabAssessment(String id) {
    if (state.labAssessments.length <= 1) return;
    state = state.copyWith(labAssessments: state.labAssessments.where((a) => a.id != id).toList());
  }
  void updateLabName(String id, String v) => state = state.copyWith(labAssessments: state.labAssessments.map((a) => a.id == id ? a.copyWith(name: v) : a).toList());
  void updateLabWeight(String id, double v) => state = state.copyWith(labAssessments: state.labAssessments.map((a) => a.id == id ? a.copyWith(weightage: v) : a).toList());
  void updateLabTotal(String id, double v) => state = state.copyWith(labAssessments: state.labAssessments.map((a) => a.id == id ? a.copyWith(totalMarks: v) : a).toList());
  void updateLabObtained(String id, double v) => state = state.copyWith(labAssessments: state.labAssessments.map((a) => a.id == id ? a.copyWith(obtainedMarks: v) : a).toList());

  void reset() => state = GradeState(theoryAssessments: _defaultTheory(), labAssessments: _defaultLab());
}