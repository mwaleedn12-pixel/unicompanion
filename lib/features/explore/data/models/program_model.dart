class ProgramModel {
  final String id;
  final String universityId;
  final String name;
  final String degreeLevel;
  final String field;
  final double durationYears;
  final int? totalSemesters;
  final int? creditHours;
  final double? feePerSemester;
  final double? feeTotal;
  final String? admissionOpenDate;
  final String? admissionCloseDate;
  final String? eligibility;
  final int? seats;
  final bool isActive;

  // Joined from universities table (optional)
  final String? universityName;
  final String? universityShortName;
  final String? universityType;

  const ProgramModel({
    required this.id,
    required this.universityId,
    required this.name,
    required this.degreeLevel,
    required this.field,
    required this.durationYears,
    this.totalSemesters,
    this.creditHours,
    this.feePerSemester,
    this.feeTotal,
    this.admissionOpenDate,
    this.admissionCloseDate,
    this.eligibility,
    this.seats,
    this.isActive = true,
    this.universityName,
    this.universityShortName,
    this.universityType,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    // Handle joined university data
    final uni = json['universities'] as Map<String, dynamic>?;

    return ProgramModel(
      id: json['id'],
      universityId: json['university_id'] ?? '',
      name: json['name'] ?? '',
      degreeLevel: json['degree_level'] ?? 'bachelors',
      field: json['field'] ?? 'engineering',
      durationYears: (json['duration_years'] as num?)?.toDouble() ?? 4.0,
      totalSemesters: json['total_semesters'],
      creditHours: json['credit_hours'],
      feePerSemester: (json['fee_per_semester'] as num?)?.toDouble(),
      feeTotal: (json['fee_total'] as num?)?.toDouble(),
      admissionOpenDate: json['admission_open_date'],
      admissionCloseDate: json['admission_close_date'],
      eligibility: json['eligibility'],
      seats: json['seats'],
      isActive: json['is_active'] ?? true,
      universityName: uni?['name'],
      universityShortName: uni?['short_name'],
      universityType: uni?['type'],
    );
  }

  String get degreeLevelLabel {
    switch (degreeLevel) {
      case 'bachelors':
        return 'Bachelors';
      case 'masters':
        return 'Masters';
      case 'phd':
        return 'PhD';
      case 'diploma':
        return 'Diploma';
      default:
        return degreeLevel;
    }
  }

  String get fieldLabel {
    switch (field) {
      case 'engineering':
        return 'Engineering';
      case 'medical':
        return 'Medical';
      case 'business':
        return 'Business';
      case 'arts':
        return 'Arts & Humanities';
      case 'sciences':
        return 'Sciences';
      case 'law':
        return 'Law';
      case 'it':
        return 'IT & CS';
      default:
        return field;
    }
  }

  String get feeDisplay {
    if (feePerSemester == null) return 'N/A';
    if (feePerSemester! >= 1000000) {
      return 'PKR ${(feePerSemester! / 100000).toStringAsFixed(1)} Lac/sem';
    }
    return 'PKR ${_formatNumber(feePerSemester!)}/sem';
  }

  String get feeTotalDisplay {
    final total = feeTotal ?? (feePerSemester != null && totalSemesters != null ? feePerSemester! * totalSemesters! : null);
    if (total == null) return 'N/A';
    if (total >= 1000000) {
      return 'PKR ${(total / 100000).toStringAsFixed(1)} Lac total';
    }
    return 'PKR ${_formatNumber(total)} total';
  }

  String get durationDisplay {
    return durationYears == durationYears.roundToDouble()
        ? '${durationYears.toInt()} Years'
        : '${durationYears.toStringAsFixed(1)} Years';
  }

  String get admissionWindow {
    if (admissionOpenDate != null && admissionCloseDate != null) {
      return '$admissionOpenDate — $admissionCloseDate';
    }
    if (admissionOpenDate != null) return 'Opens $admissionOpenDate';
    return 'TBA';
  }

  static String _formatNumber(double n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    }
    return n.toStringAsFixed(0);
  }
}