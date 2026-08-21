import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceState {
  final int totalClasses;
  final int attendedClasses;
  final int upcomingClasses;
  final double targetPercentage;

  const AttendanceState({
    this.totalClasses = 0,
    this.attendedClasses = 0,
    this.upcomingClasses = 0,
    this.targetPercentage = 75,
  });

  AttendanceState copyWith({int? totalClasses, int? attendedClasses, int? upcomingClasses, double? targetPercentage}) {
    return AttendanceState(
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      upcomingClasses: upcomingClasses ?? this.upcomingClasses,
      targetPercentage: targetPercentage ?? this.targetPercentage,
    );
  }

  bool get hasData => totalClasses > 0;

  double get currentPercentage {
    if (totalClasses == 0) return 0;
    return (attendedClasses / totalClasses) * 100;
  }

  int get missedClasses => totalClasses - attendedClasses;

  /// How many more classes can you miss and still meet target?
  int get canMiss {
    if (totalClasses == 0) return 0;
    final total = totalClasses + upcomingClasses;
    final required = (targetPercentage / 100 * total).ceil();
    final canSkip = (attendedClasses + upcomingClasses) - required;
    return canSkip < 0 ? 0 : canSkip;
  }

  /// How many of the upcoming classes must you attend to reach target?
  int get mustAttend {
    if (totalClasses == 0 || upcomingClasses == 0) return 0;
    final total = totalClasses + upcomingClasses;
    final required = (targetPercentage / 100 * total).ceil();
    final need = required - attendedClasses;
    if (need <= 0) return 0;
    if (need > upcomingClasses) return upcomingClasses;
    return need;
  }

  /// Is target achievable even if you attend all upcoming?
  bool get isTargetAchievable {
    if (totalClasses == 0) return true;
    final total = totalClasses + upcomingClasses;
    final maxPossible = ((attendedClasses + upcomingClasses) / total) * 100;
    return maxPossible >= targetPercentage;
  }

  /// Percentage if you attend ALL upcoming
  double get bestCasePercentage {
    final total = totalClasses + upcomingClasses;
    if (total == 0) return 0;
    return ((attendedClasses + upcomingClasses) / total) * 100;
  }

  /// Percentage if you miss ALL upcoming
  double get worstCasePercentage {
    final total = totalClasses + upcomingClasses;
    if (total == 0) return 0;
    return (attendedClasses / total) * 100;
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier();
});

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier() : super(const AttendanceState());

  void setTotalClasses(int val) {
    if (val < 0) return;
    state = state.copyWith(
      totalClasses: val,
      attendedClasses: state.attendedClasses > val ? val : null,
    );
  }

  void setAttendedClasses(int val) {
    if (val < 0 || val > state.totalClasses) return;
    state = state.copyWith(attendedClasses: val);
  }

  void setUpcomingClasses(int val) {
    if (val < 0) return;
    state = state.copyWith(upcomingClasses: val);
  }

  void setTargetPercentage(double val) {
    if (val < 0 || val > 100) return;
    state = state.copyWith(targetPercentage: val);
  }

  void reset() {
    state = const AttendanceState();
  }
}