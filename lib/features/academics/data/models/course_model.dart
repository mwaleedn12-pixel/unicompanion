class CourseModel {
  final String id;
  final String userId;
  final String semesterId;
  final String name;
  final String? code;
  final int creditHours;
  final String? grade;
  final double? gradePoints;

  const CourseModel({
    required this.id,
    required this.userId,
    required this.semesterId,
    required this.name,
    this.code,
    this.creditHours = 3,
    this.grade,
    this.gradePoints,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      userId: json['user_id'],
      semesterId: json['semester_id'],
      name: json['name'] ?? '',
      code: json['code'],
      creditHours: json['credit_hours'] ?? 3,
      grade: json['grade'],
      gradePoints: json['grade_points'] == null ? null : (json['grade_points'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'semester_id': semesterId,
      'name': name,
      if (code != null && code!.isNotEmpty) 'code': code,
      'credit_hours': creditHours,
      'grade': grade,
      'grade_points': gradePoints,
    };
  }

  CourseModel copyWith({
    String? name,
    String? code,
    int? creditHours,
    String? grade,
    double? gradePoints,
  }) {
    return CourseModel(
      id: id,
      userId: userId,
      semesterId: semesterId,
      name: name ?? this.name,
      code: code ?? this.code,
      creditHours: creditHours ?? this.creditHours,
      grade: grade ?? this.grade,
      gradePoints: gradePoints ?? this.gradePoints,
    );
  }
}