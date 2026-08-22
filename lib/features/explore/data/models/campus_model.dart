class CampusModel {
  final String id;
  final String universityId;
  final String name;
  final String city;
  final String? address;
  final bool hasHostel;
  final bool hasTransport;
  final bool hasLibrary;
  final bool hasSports;
  final bool hasLabs;
  final bool hasCafeteria;
  final bool hasMosque;
  final bool hasMedical;
  final int? studentCount;
  final int? establishedYear;
  final String? description;
  final bool isMainCampus;
  final bool isActive;

  // Joined from universities table (optional)
  final String? universityName;
  final String? universityShortName;

  const CampusModel({
    required this.id,
    required this.universityId,
    required this.name,
    required this.city,
    this.address,
    this.hasHostel = false,
    this.hasTransport = false,
    this.hasLibrary = true,
    this.hasSports = false,
    this.hasLabs = true,
    this.hasCafeteria = true,
    this.hasMosque = true,
    this.hasMedical = false,
    this.studentCount,
    this.establishedYear,
    this.description,
    this.isMainCampus = false,
    this.isActive = true,
    this.universityName,
    this.universityShortName,
  });

  factory CampusModel.fromJson(Map<String, dynamic> json) {
    final uni = json['universities'] as Map<String, dynamic>?;

    return CampusModel(
      id: json['id'],
      universityId: json['university_id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      address: json['address'],
      hasHostel: json['has_hostel'] ?? false,
      hasTransport: json['has_transport'] ?? false,
      hasLibrary: json['has_library'] ?? true,
      hasSports: json['has_sports'] ?? false,
      hasLabs: json['has_labs'] ?? true,
      hasCafeteria: json['has_cafeteria'] ?? true,
      hasMosque: json['has_mosque'] ?? true,
      hasMedical: json['has_medical'] ?? false,
      studentCount: json['student_count'],
      establishedYear: json['established_year'],
      description: json['description'],
      isMainCampus: json['is_main_campus'] ?? false,
      isActive: json['is_active'] ?? true,
      universityName: uni?['name'],
      universityShortName: uni?['short_name'],
    );
  }

  List<FacilityItem> get facilities {
    final list = <FacilityItem>[];
    if (hasHostel) list.add(FacilityItem.hostel);
    if (hasTransport) list.add(FacilityItem.transport);
    if (hasLibrary) list.add(FacilityItem.library);
    if (hasSports) list.add(FacilityItem.sports);
    if (hasLabs) list.add(FacilityItem.labs);
    if (hasCafeteria) list.add(FacilityItem.cafeteria);
    if (hasMosque) list.add(FacilityItem.mosque);
    if (hasMedical) list.add(FacilityItem.medical);
    return list;
  }

  String get studentCountDisplay {
    if (studentCount == null) return 'N/A';
    if (studentCount! >= 1000) {
      return '${(studentCount! / 1000).toStringAsFixed(1)}K students';
    }
    return '$studentCount students';
  }
}

enum FacilityItem {
  hostel('Hostel', '🏠'),
  transport('Transport', '🚌'),
  library('Library', '📚'),
  sports('Sports', '⚽'),
  labs('Labs', '🔬'),
  cafeteria('Cafeteria', '🍽️'),
  mosque('Mosque', '🕌'),
  medical('Medical', '🏥');

  final String label;
  final String emoji;
  const FacilityItem(this.label, this.emoji);
}