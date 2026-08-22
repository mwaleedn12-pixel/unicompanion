class AssignmentModel {
  final String id;
  final String userId;
  final String? courseId;
  final String? semesterId;
  final String title;
  final String type; // assignment | quiz | exam | project
  final DateTime dueDate;
  final String priority; // low | medium | high
  final bool isCompleted;
  final double? weight;
  final String? notes;
  final String? courseName; // joined from user_courses for display

  const AssignmentModel({
    required this.id,
    required this.userId,
    this.courseId,
    this.semesterId,
    required this.title,
    this.type = 'assignment',
    required this.dueDate,
    this.priority = 'medium',
    this.isCompleted = false,
    this.weight,
    this.notes,
    this.courseName,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      semesterId: json['semester_id'],
      title: json['title'] ?? '',
      type: json['type'] ?? 'assignment',
      dueDate: DateTime.parse(json['due_date']),
      priority: json['priority'] ?? 'medium',
      isCompleted: json['is_completed'] ?? false,
      weight: json['weight'] == null ? null : (json['weight'] as num).toDouble(),
      notes: json['notes'],
      courseName: json['user_courses'] is Map ? json['user_courses']['name'] : null,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'course_id': courseId,
      'semester_id': semesterId,
      'title': title,
      'type': type,
      'due_date': dueDate.toIso8601String().split('T').first,
      'priority': priority,
      'is_completed': isCompleted,
      'weight': weight,
      'notes': notes,
    };
  }

  AssignmentModel copyWith({
    String? title,
    String? type,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    double? weight,
    String? notes,
    String? courseId,
  }) {
    return AssignmentModel(
      id: id,
      userId: userId,
      courseId: courseId ?? this.courseId,
      semesterId: semesterId,
      title: title ?? this.title,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      courseName: courseName,
    );
  }

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

  int get daysUntilDue {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return dueDate.difference(today).inDays;
  }
}