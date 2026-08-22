import 'course_model.dart';

class SemesterModel {
  final String id;
  final String userId;
  final String name;
  final int semesterNumber;
  final bool isCompleted;
  final double? gpa;
  final double totalCreditHours;
  final List<CourseModel> courses;

  const SemesterModel({
    required this.id,
    required this.userId,
    required this.name,
    this.semesterNumber = 1,
    this.isCompleted = false,
    this.gpa,
    this.totalCreditHours = 0,
    this.courses = const [],
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json, {List<CourseModel> courses = const []}) {
    return SemesterModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      semesterNumber: json['semester_number'] ?? 1,
      isCompleted: json['is_completed'] ?? false,
      gpa: json['gpa'] == null ? null : (json['gpa'] as num).toDouble(),
      totalCreditHours: (json['total_credit_hours'] as num?)?.toDouble() ?? 0,
      courses: courses,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'semester_number': semesterNumber,
      'is_completed': isCompleted,
      'gpa': gpa,
      'total_credit_hours': totalCreditHours,
    };
  }

  SemesterModel copyWith({
    String? name,
    int? semesterNumber,
    bool? isCompleted,
    double? gpa,
    double? totalCreditHours,
    List<CourseModel>? courses,
  }) {
    return SemesterModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      isCompleted: isCompleted ?? this.isCompleted,
      gpa: gpa ?? this.gpa,
      totalCreditHours: totalCreditHours ?? this.totalCreditHours,
      courses: courses ?? this.courses,
    );
  }

  /// Live GPA computed from courses that already have grades assigned.
  double get computedGpa {
    final graded = courses.where((c) => c.gradePoints != null);
    final totalHours = graded.fold(0.0, (sum, c) => sum + c.creditHours);
    if (totalHours == 0) return 0;
    final totalPoints = graded.fold(0.0, (sum, c) => sum + (c.creditHours * c.gradePoints!));
    return totalPoints / totalHours;
  }

  double get computedCreditHours => courses.fold(0.0, (sum, c) => sum + c.creditHours);
}