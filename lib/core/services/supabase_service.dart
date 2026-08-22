import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// THIS WAS THE BUG — now it watches authStateProvider so it rebuilds on login/logout
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider); // <-- yeh line zaroori hai, iske bina rebuild nahi hota
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser;
});

extension SupabaseTableExtensions on SupabaseClient {
  SupabaseQueryBuilder get universities => from('universities');
  SupabaseQueryBuilder get campuses => from('campuses');
  SupabaseQueryBuilder get programs => from('programs');
  SupabaseQueryBuilder get universityPrograms => from('university_programs');
  SupabaseQueryBuilder get meritFormulas => from('merit_formulas');
  SupabaseQueryBuilder get scholarships => from('scholarships');
  SupabaseQueryBuilder get careers => from('careers');
  SupabaseQueryBuilder get countries => from('countries');
  SupabaseQueryBuilder get cities => from('cities');
  SupabaseQueryBuilder get gradingSystems => from('grading_systems');
  SupabaseQueryBuilder get userProfiles => from('user_profiles');
  SupabaseQueryBuilder get userShortlist => from('user_shortlist');
  SupabaseQueryBuilder get userApplications => from('user_applications');
  SupabaseQueryBuilder get userSemesters => from('user_semesters');
  SupabaseQueryBuilder get userCourses => from('user_courses');
  SupabaseQueryBuilder get userAssignments => from('user_assignments');
  SupabaseQueryBuilder get courseAssessments => from('course_assessments');
}