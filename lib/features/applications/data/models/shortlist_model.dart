class ShortlistModel {
  final String id;
  final String userId;
  final String universityId;
  final String? notes;
  final DateTime createdAt;

  // Joined from universities table for display
  final String universityName;
  final String? universityShortName;
  final String universityType;
  final int? universityRanking;

  const ShortlistModel({
    required this.id,
    required this.userId,
    required this.universityId,
    this.notes,
    required this.createdAt,
    required this.universityName,
    this.universityShortName,
    this.universityType = 'public',
    this.universityRanking,
  });

  factory ShortlistModel.fromJson(Map<String, dynamic> json) {
    final uni = json['universities'] as Map<String, dynamic>?;
    return ShortlistModel(
      id: json['id'],
      userId: json['user_id'],
      universityId: json['university_id'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      universityName: uni?['name'] ?? 'Unknown University',
      universityShortName: uni?['short_name'],
      universityType: uni?['type'] ?? 'public',
      universityRanking: uni?['ranking_national'],
    );
  }

  String get initials {
    if (universityShortName != null && universityShortName!.isNotEmpty) return universityShortName!;
    return universityName.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
  }
}