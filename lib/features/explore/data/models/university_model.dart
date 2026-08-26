class UniversityModel {
  final String id;
  final String name;
  final String shortName;
  final String type;
  final String? logoUrl;
  final String? website;
  final String? description;
  final int? rankingNational;
  final bool isActive;

  // New fields from 268-university seed
  final String? city;
  final String? address;
  final String? affiliation;
  final String? degreeLevels;
  final String? programsOffered;
  final String? entryTest;
  final String? meritFormula;
  final String? eligibility;
  final String? meritHistory;
  final String? facilities;
  final String? hostelInfo;
  final String? transportInfo;
  final String? feeStructure;
  final String? admissionInfo;
  final String? deadlines;
  final String? scholarshipsInfo;
  final String? applyUrl;
  final String? portalUrl;
  final String? contactInfo;
  final String? sectorDetail;

  const UniversityModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    this.logoUrl,
    this.website,
    this.description,
    this.rankingNational,
    this.isActive = true,
    this.city,
    this.address,
    this.affiliation,
    this.degreeLevels,
    this.programsOffered,
    this.entryTest,
    this.meritFormula,
    this.eligibility,
    this.meritHistory,
    this.facilities,
    this.hostelInfo,
    this.transportInfo,
    this.feeStructure,
    this.admissionInfo,
    this.deadlines,
    this.scholarshipsInfo,
    this.applyUrl,
    this.portalUrl,
    this.contactInfo,
    this.sectorDetail,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'],
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      type: json['type'] ?? 'public',
      logoUrl: json['logo_url'],
      website: json['website'],
      description: json['description'],
      rankingNational: json['ranking_national'],
      isActive: json['is_active'] ?? true,
      city: json['city'],
      address: json['address'],
      affiliation: json['affiliation'],
      degreeLevels: json['degree_levels'],
      programsOffered: json['programs_offered'],
      entryTest: json['entry_test'],
      meritFormula: json['merit_formula'],
      eligibility: json['eligibility'],
      meritHistory: json['merit_history'],
      facilities: json['facilities'],
      hostelInfo: json['hostel_info'],
      transportInfo: json['transport_info'],
      feeStructure: json['fee_structure'],
      admissionInfo: json['admission_info'],
      deadlines: json['deadlines'],
      scholarshipsInfo: json['scholarships_info'],
      applyUrl: json['apply_url'],
      portalUrl: json['portal_url'],
      contactInfo: json['contact_info'],
      sectorDetail: json['sector_detail'],
    );
  }

  String get typeLabel {
    switch (type) {
      case 'public': return 'Public';
      case 'private': return 'Private';
      case 'semi_government': return 'Semi-Govt';
      default: return type;
    }
  }

  String get initials {
    if (shortName.isNotEmpty) return shortName;
    return name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
  }
}