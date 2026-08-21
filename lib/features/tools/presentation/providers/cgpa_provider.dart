import 'package:flutter_riverpod/flutter_riverpod.dart';

class SemesterEntry {
  final String id;
  String name;
  double gpa;
  int creditHours;

  SemesterEntry({
    required this.id,
    this.name = '',
    this.gpa = 0,
    this.creditHours = 15,
  });

  SemesterEntry copyWith({String? name, double? gpa, int? creditHours}) {
    return SemesterEntry(
      id: id,
      name: name ?? this.name,
      gpa: gpa ?? this.gpa,
      creditHours: creditHours ?? this.creditHours,
    );
  }

  bool get hasData => gpa > 0;
}

class CgpaState {
  final List<SemesterEntry> semesters;

  const CgpaState({this.semesters = const []});

  CgpaState copyWith({List<SemesterEntry>? semesters}) {
    return CgpaState(semesters: semesters ?? this.semesters);
  }

  double get totalCredits {
    return semesters.where((s) => s.hasData).fold(0.0, (sum, s) => sum + s.creditHours);
  }

  double get totalWeightedPoints {
    return semesters.where((s) => s.hasData).fold(0.0, (sum, s) => sum + (s.gpa * s.creditHours));
  }

  double get cgpa {
    if (totalCredits == 0) return 0;
    return totalWeightedPoints / totalCredits;
  }

  bool get hasResults => semesters.any((s) => s.hasData);

  int get completedSemesters => semesters.where((s) => s.hasData).length;
}

final cgpaProvider = StateNotifierProvider<CgpaNotifier, CgpaState>((ref) {
  return CgpaNotifier();
});

class CgpaNotifier extends StateNotifier<CgpaState> {
  CgpaNotifier() : super(CgpaState(semesters: _defaultSemesters()));

  static List<SemesterEntry> _defaultSemesters() {
    return List.generate(4, (i) => SemesterEntry(
      id: 'sem_$i',
      name: 'Semester ${i + 1}',
    ));
  }

  void addSemester() {
    final count = state.semesters.length;
    state = state.copyWith(semesters: [
      ...state.semesters,
      SemesterEntry(id: 'sem_${DateTime.now().millisecondsSinceEpoch}', name: 'Semester ${count + 1}'),
    ]);
  }

  void removeSemester(String id) {
    if (state.semesters.length <= 1) return;
    state = state.copyWith(semesters: state.semesters.where((s) => s.id != id).toList());
  }

  void updateName(String id, String name) {
    state = state.copyWith(
      semesters: state.semesters.map((s) => s.id == id ? s.copyWith(name: name) : s).toList(),
    );
  }

  void updateGpa(String id, double gpa) {
    state = state.copyWith(
      semesters: state.semesters.map((s) => s.id == id ? s.copyWith(gpa: gpa) : s).toList(),
    );
  }

  void updateCredits(String id, int credits) {
    state = state.copyWith(
      semesters: state.semesters.map((s) => s.id == id ? s.copyWith(creditHours: credits) : s).toList(),
    );
  }

  void reset() {
    state = CgpaState(semesters: _defaultSemesters());
  }
}