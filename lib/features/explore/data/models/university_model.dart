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
    return name.split(' ').take(2).map((w) => w[0]).join().toUpperCase();
  }
}