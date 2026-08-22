class ApplicationModel {
  final String id;
  final String userId;
  final String universityId;
  final String? programName;
  final String status; // interested | preparing | applied | test_taken | interview | selected | rejected | withdrawn
  final DateTime? deadline;
  final DateTime? appliedDate;
  final String? notes;
  final DateTime createdAt;

  // Joined from universities table for display
  final String universityName;
  final String? universityShortName;
  final String universityType;

  const ApplicationModel({
    required this.id,
    required this.userId,
    required this.universityId,
    this.programName,
    this.status = 'interested',
    this.deadline,
    this.appliedDate,
    this.notes,
    required this.createdAt,
    required this.universityName,
    this.universityShortName,
    this.universityType = 'public',
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final uni = json['universities'] as Map<String, dynamic>?;
    return ApplicationModel(
      id: json['id'],
      userId: json['user_id'],
      universityId: json['university_id'],
      programName: json['program_name'],
      status: json['status'] ?? 'interested',
      deadline: json['deadline'] == null ? null : DateTime.parse(json['deadline']),
      appliedDate: json['applied_date'] == null ? null : DateTime.parse(json['applied_date']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      universityName: uni?['name'] ?? 'Unknown University',
      universityShortName: uni?['short_name'],
      universityType: uni?['type'] ?? 'public',
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'university_id': universityId,
      'program_name': programName,
      'status': status,
      'deadline': deadline?.toIso8601String().split('T').first,
      'applied_date': appliedDate?.toIso8601String().split('T').first,
      'notes': notes,
    };
  }

  ApplicationModel copyWith({
    String? programName,
    String? status,
    DateTime? deadline,
    DateTime? appliedDate,
    String? notes,
  }) {
    return ApplicationModel(
      id: id,
      userId: userId,
      universityId: universityId,
      programName: programName ?? this.programName,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      appliedDate: appliedDate ?? this.appliedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      universityName: universityName,
      universityShortName: universityShortName,
      universityType: universityType,
    );
  }

  bool get isAccepted => status == 'selected';
  bool get isRejected => status == 'rejected' || status == 'withdrawn';
  bool get isApplied => status == 'applied' || status == 'test_taken' || status == 'interview' || isAccepted;

  int? get daysUntilDeadline {
    if (deadline == null) return null;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return deadline!.difference(today).inDays;
  }

  bool get isDeadlineSoon => daysUntilDeadline != null && daysUntilDeadline! >= 0 && daysUntilDeadline! <= 14;
  bool get isDeadlinePassed => daysUntilDeadline != null && daysUntilDeadline! < 0;
}