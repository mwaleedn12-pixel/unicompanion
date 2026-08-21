import 'package:flutter_riverpod/flutter_riverpod.dart';

class TargetGpaState {
  final double currentCgpa;
  final int completedCredits;
  final double targetCgpa;
  final int semesterCredits;

  const TargetGpaState({
    this.currentCgpa = 0,
    this.completedCredits = 0,
    this.targetCgpa = 3.0,
    this.semesterCredits = 15,
  });

  TargetGpaState copyWith({double? currentCgpa, int? completedCredits, double? targetCgpa, int? semesterCredits}) {
    return TargetGpaState(
      currentCgpa: currentCgpa ?? this.currentCgpa,
      completedCredits: completedCredits ?? this.completedCredits,
      targetCgpa: targetCgpa ?? this.targetCgpa,
      semesterCredits: semesterCredits ?? this.semesterCredits,
    );
  }

  bool get hasData => currentCgpa > 0 && completedCredits > 0;

  /// Required GPA this semester to achieve target CGPA
  double get requiredGpa {
    if (!hasData || semesterCredits == 0) return 0;
    final totalCredits = completedCredits + semesterCredits;
    final totalPointsNeeded = targetCgpa * totalCredits;
    final currentPoints = currentCgpa * completedCredits;
    final needed = (totalPointsNeeded - currentPoints) / semesterCredits;
    return needed;
  }

  bool get isAchievable => requiredGpa <= 4.0 && requiredGpa >= 0;
  bool get isImpossible => requiredGpa > 4.0;
  bool get isAlreadyAchieved => requiredGpa <= 0;

  /// What CGPA will you get with different semester GPAs
  double cgpaWith(double semGpa) {
    if (completedCredits == 0 && semesterCredits == 0) return 0;
    final totalCredits = completedCredits + semesterCredits;
    final totalPoints = (currentCgpa * completedCredits) + (semGpa * semesterCredits);
    return totalPoints / totalCredits;
  }

  /// Maximum possible CGPA (if you get 4.0 this semester)
  double get maxPossibleCgpa => cgpaWith(4.0);

  /// Minimum possible CGPA (if you get 0.0 this semester)
  double get minPossibleCgpa => cgpaWith(0.0);

  String get verdict {
    if (!hasData) return '';
    if (isAlreadyAchieved) return 'You\'ve already exceeded your target! 🎉';
    if (isImpossible) return 'Target not achievable this semester. Consider adjusting your goal.';
    if (requiredGpa >= 3.8) return 'Very challenging — you need near-perfect grades 💪';
    if (requiredGpa >= 3.5) return 'Challenging but doable with consistent effort 📚';
    if (requiredGpa >= 3.0) return 'Achievable with good performance 👍';
    return 'Easily achievable — keep it up! ✨';
  }
}

final targetGpaProvider = StateNotifierProvider<TargetGpaNotifier, TargetGpaState>((ref) {
  return TargetGpaNotifier();
});

class TargetGpaNotifier extends StateNotifier<TargetGpaState> {
  TargetGpaNotifier() : super(const TargetGpaState());

  void setCurrentCgpa(double val) {
    if (val < 0 || val > 4.0) return;
    state = state.copyWith(currentCgpa: val);
  }

  void setCompletedCredits(int val) {
    if (val < 0) return;
    state = state.copyWith(completedCredits: val);
  }

  void setTargetCgpa(double val) {
    if (val < 0 || val > 4.0) return;
    state = state.copyWith(targetCgpa: val);
  }

  void setSemesterCredits(int val) {
    if (val < 1) return;
    state = state.copyWith(semesterCredits: val);
  }

  void reset() => state = const TargetGpaState();
}