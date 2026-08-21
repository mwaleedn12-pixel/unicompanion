import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/ui_state.dart';

// ── Onboarding State Model ──
class OnboardingData {
  final String userType;
  final String fullName;
  final double? matricPercentage;
  final double? fscPercentage;
  final String? fscStream;
  final String? preferredUniType;
  final String? budgetRange;
  final bool? needsHostel;
  final List<String> careerInterests;
  final List<String> degreeInterests;
  // University student fields
  final String? currentUniversityId;
  final String? currentProgramId;
  final int? currentSemester;
  final int? enrollmentYear;

  const OnboardingData({
    this.userType = '',
    this.fullName = '',
    this.matricPercentage,
    this.fscPercentage,
    this.fscStream,
    this.preferredUniType,
    this.budgetRange,
    this.needsHostel,
    this.careerInterests = const [],
    this.degreeInterests = const [],
    this.currentUniversityId,
    this.currentProgramId,
    this.currentSemester,
    this.enrollmentYear,
  });

  OnboardingData copyWith({
    String? userType,
    String? fullName,
    double? matricPercentage,
    double? fscPercentage,
    String? fscStream,
    String? preferredUniType,
    String? budgetRange,
    bool? needsHostel,
    List<String>? careerInterests,
    List<String>? degreeInterests,
    String? currentUniversityId,
    String? currentProgramId,
    int? currentSemester,
    int? enrollmentYear,
  }) {
    return OnboardingData(
      userType: userType ?? this.userType,
      fullName: fullName ?? this.fullName,
      matricPercentage: matricPercentage ?? this.matricPercentage,
      fscPercentage: fscPercentage ?? this.fscPercentage,
      fscStream: fscStream ?? this.fscStream,
      preferredUniType: preferredUniType ?? this.preferredUniType,
      budgetRange: budgetRange ?? this.budgetRange,
      needsHostel: needsHostel ?? this.needsHostel,
      careerInterests: careerInterests ?? this.careerInterests,
      degreeInterests: degreeInterests ?? this.degreeInterests,
      currentUniversityId: currentUniversityId ?? this.currentUniversityId,
      currentProgramId: currentProgramId ?? this.currentProgramId,
      currentSemester: currentSemester ?? this.currentSemester,
      enrollmentYear: enrollmentYear ?? this.enrollmentYear,
    );
  }
}

// ── Onboarding Data Provider ──
final onboardingDataProvider =
    StateNotifierProvider<OnboardingDataNotifier, OnboardingData>((ref) {
  return OnboardingDataNotifier();
});

class OnboardingDataNotifier extends StateNotifier<OnboardingData> {
  OnboardingDataNotifier() : super(const OnboardingData());

  void setUserType(String type) => state = state.copyWith(userType: type);
  void setFullName(String name) => state = state.copyWith(fullName: name);
  void setMatricPercentage(double val) => state = state.copyWith(matricPercentage: val);
  void setFscPercentage(double val) => state = state.copyWith(fscPercentage: val);
  void setFscStream(String stream) => state = state.copyWith(fscStream: stream);
  void setPreferredUniType(String type) => state = state.copyWith(preferredUniType: type);
  void setBudgetRange(String range) => state = state.copyWith(budgetRange: range);
  void setNeedsHostel(bool val) => state = state.copyWith(needsHostel: val);
  void setCurrentSemester(int sem) => state = state.copyWith(currentSemester: sem);
  void setEnrollmentYear(int year) => state = state.copyWith(enrollmentYear: year);

  void toggleCareerInterest(String interest) {
    final list = List<String>.from(state.careerInterests);
    list.contains(interest) ? list.remove(interest) : list.add(interest);
    state = state.copyWith(careerInterests: list);
  }

  void toggleDegreeInterest(String interest) {
    final list = List<String>.from(state.degreeInterests);
    list.contains(interest) ? list.remove(interest) : list.add(interest);
    state = state.copyWith(degreeInterests: list);
  }
}

// ── Save Onboarding Provider ──
final saveOnboardingProvider =
    StateNotifierProvider<SaveOnboardingNotifier, UiState<void>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SaveOnboardingNotifier(client);
});

class SaveOnboardingNotifier extends StateNotifier<UiState<void>> {
  final SupabaseClient _client;

  SaveOnboardingNotifier(this._client) : super(const UiState.initial());

  Future<bool> saveProfile(OnboardingData data) async {
    state = const UiState.loading();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = const UiState.error('User not found. Please login again.');
        return false;
      }

      final profileData = {
        'id': userId,
        'full_name': data.fullName.isNotEmpty
            ? data.fullName
            : _client.auth.currentUser?.userMetadata?['full_name'] ?? '',
        'user_type': data.userType,
        'matric_percentage': data.matricPercentage,
        'fsc_percentage': data.fscPercentage,
        'fsc_stream': data.fscStream,
        'preferred_uni_type': data.preferredUniType,
        'budget_range': data.budgetRange,
        'needs_hostel': data.needsHostel,
        'career_interests': data.careerInterests,
        'degree_interests': data.degreeInterests,
        'current_university_id': data.currentUniversityId,
        'current_program_id': data.currentProgramId,
        'current_semester': data.currentSemester,
        'enrollment_year': data.enrollmentYear,
        'onboarding_completed': true,
      };

      await _client.from('user_profiles').upsert(profileData);
      await LocalStorageService.setOnboardingComplete(true);
      await LocalStorageService.setUserType(data.userType);

      state = const UiState.success(null);
      return true;
    } catch (e) {
      state = UiState.error('Failed to save profile: $e');
      return false;
    }
  }
}