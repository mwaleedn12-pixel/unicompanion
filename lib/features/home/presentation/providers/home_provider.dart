import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/ui_state.dart';

class UserProfile {
  final String id;
  final String fullName;
  final String userType;
  final double? matricPercentage;
  final double? fscPercentage;
  final String? fscStream;
  final String? preferredUniType;
  final String? budgetRange;
  final bool? needsHostel;
  final List<String> careerInterests;
  final List<String> degreeInterests;
  final int? currentSemester;
  final int? enrollmentYear;
  final String? avatarUrl;
  final int totalCreditsRequired;
  final int totalSemestersRequired;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.userType,
    this.matricPercentage,
    this.fscPercentage,
    this.fscStream,
    this.preferredUniType,
    this.budgetRange,
    this.needsHostel,
    this.careerInterests = const [],
    this.degreeInterests = const [],
    this.currentSemester,
    this.enrollmentYear,
    this.avatarUrl,
    this.totalCreditsRequired = 130,
    this.totalSemestersRequired = 8,
  });

  bool get isFscStudent => userType == 'fsc_student';
  bool get isUniversityStudent => userType == 'university_student';

  String get firstNameGreeting {
    if (fullName.isEmpty) return 'Student';
    return fullName.split(' ').first;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      userType: json['user_type'] ?? 'fsc_student',
      matricPercentage: json['matric_percentage']?.toDouble(),
      fscPercentage: json['fsc_percentage']?.toDouble(),
      fscStream: json['fsc_stream'],
      preferredUniType: json['preferred_uni_type'],
      budgetRange: json['budget_range'],
      needsHostel: json['needs_hostel'],
      careerInterests: List<String>.from(json['career_interests'] ?? []),
      degreeInterests: List<String>.from(json['degree_interests'] ?? []),
      currentSemester: json['current_semester'],
      enrollmentYear: json['enrollment_year'],
      avatarUrl: json['avatar_url'],
      totalCreditsRequired: json['total_credits_required'] ?? 130,
      totalSemestersRequired: json['total_semesters_required'] ?? 8,
    );
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UiState<UserProfile>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserProfileNotifier(client);
});

class UserProfileNotifier extends StateNotifier<UiState<UserProfile>> {
  final SupabaseClient _client;

  UserProfileNotifier(this._client) : super(const UiState.initial()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      state = const UiState.error('Not logged in');
      return;
    }

    state = const UiState.loading();
    try {
      final data = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        final user = _client.auth.currentUser!;
        state = UiState.success(UserProfile(
          id: user.id,
          fullName: user.userMetadata?['full_name'] ?? 'Student',
          userType: 'fsc_student',
        ));
      } else {
        state = UiState.success(UserProfile.fromJson(data));
      }
    } catch (e) {
      state = UiState.error('Failed to load profile: $e');
    }
  }
}

String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}