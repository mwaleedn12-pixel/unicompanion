import 'package:flutter_riverpod/flutter_riverpod.dart';

class GpaCourse {
  final String id;
  String name;
  int creditHours;
  String? grade;
  double? gradePoints;

  GpaCourse({
    required this.id,
    this.name = '',
    this.creditHours = 3,
    this.grade,
    this.gradePoints,
  });

  GpaCourse copyWith({String? name, int? creditHours, String? grade, double? gradePoints}) {
    return GpaCourse(
      id: id,
      name: name ?? this.name,
      creditHours: creditHours ?? this.creditHours,
      grade: grade ?? this.grade,
      gradePoints: gradePoints ?? this.gradePoints,
    );
  }
}

class GradeOption {
  final String letter;
  final double points;

  const GradeOption(this.letter, this.points);
}

class GpaState {
  final List<GpaCourse> courses;
  final int selectedGradingSystem;

  const GpaState({this.courses = const [], this.selectedGradingSystem = 0});

  GpaState copyWith({List<GpaCourse>? courses, int? selectedGradingSystem}) {
    return GpaState(
      courses: courses ?? this.courses,
      selectedGradingSystem: selectedGradingSystem ?? this.selectedGradingSystem,
    );
  }

  double get totalCreditHours {
    return courses.where((c) => c.gradePoints != null).fold(0.0, (sum, c) => sum + c.creditHours);
  }

  double get totalGradePoints {
    return courses.where((c) => c.gradePoints != null).fold(0.0, (sum, c) => sum + (c.creditHours * c.gradePoints!));
  }

  double get gpa {
    if (totalCreditHours == 0) return 0;
    return totalGradePoints / totalCreditHours;
  }

  bool get hasResults => courses.any((c) => c.gradePoints != null);
}

// ── Grading Systems ──
const gradingSystems = [
  'HEC Standard (4.0)',
  'NUST (4.0)',
  'FAST (4.0)',
  'Custom (4.0)',
];

const hecGrades = [
  GradeOption('A', 4.0),
  GradeOption('A-', 3.7),
  GradeOption('B+', 3.3),
  GradeOption('B', 3.0),
  GradeOption('B-', 2.7),
  GradeOption('C+', 2.3),
  GradeOption('C', 2.0),
  GradeOption('C-', 1.7),
  GradeOption('D+', 1.3),
  GradeOption('D', 1.0),
  GradeOption('F', 0.0),
];

// ── Provider ──
final gpaProvider = StateNotifierProvider<GpaNotifier, GpaState>((ref) {
  return GpaNotifier();
});

class GpaNotifier extends StateNotifier<GpaState> {
  GpaNotifier() : super(GpaState(courses: _defaultCourses()));

  static List<GpaCourse> _defaultCourses() {
    return List.generate(5, (i) => GpaCourse(id: 'course_$i'));
  }

  void addCourse() {
    final newId = 'course_${DateTime.now().millisecondsSinceEpoch}';
    state = state.copyWith(courses: [...state.courses, GpaCourse(id: newId)]);
  }

  void removeCourse(String id) {
    if (state.courses.length <= 1) return;
    state = state.copyWith(courses: state.courses.where((c) => c.id != id).toList());
  }

  void updateCourseName(String id, String name) {
    state = state.copyWith(
      courses: state.courses.map((c) => c.id == id ? c.copyWith(name: name) : c).toList(),
    );
  }

  void updateCreditHours(String id, int hours) {
    state = state.copyWith(
      courses: state.courses.map((c) => c.id == id ? c.copyWith(creditHours: hours) : c).toList(),
    );
  }

  void updateGrade(String id, String grade, double gradePoints) {
    state = state.copyWith(
      courses: state.courses.map((c) => c.id == id ? c.copyWith(grade: grade, gradePoints: gradePoints) : c).toList(),
    );
  }

  void setGradingSystem(int index) {
    state = state.copyWith(selectedGradingSystem: index);
  }

  void reset() {
    state = GpaState(courses: _defaultCourses());
  }
}