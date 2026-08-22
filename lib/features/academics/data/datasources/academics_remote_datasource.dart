import 'package:supabase_flutter/supabase_flutter.dart';

class AcademicsRemoteDatasource {
  final SupabaseClient _client;

  AcademicsRemoteDatasource(this._client);

  // ── Semesters ──
  Future<List<Map<String, dynamic>>> getSemesters(String userId) async {
    return await _client.from('user_semesters').select().eq('user_id', userId).order('semester_number', ascending: true);
  }

  Future<Map<String, dynamic>> createSemester(Map<String, dynamic> data) async {
    return await _client.from('user_semesters').insert(data).select().single();
  }

  Future<Map<String, dynamic>> updateSemester(String id, Map<String, dynamic> data) async {
    return await _client.from('user_semesters').update(data).eq('id', id).select().single();
  }

  Future<void> deleteSemester(String id) async {
    await _client.from('user_semesters').delete().eq('id', id);
  }

  // ── Courses ──
  Future<List<Map<String, dynamic>>> getCourses(String userId, {String? semesterId}) async {
    var query = _client.from('user_courses').select().eq('user_id', userId);
    if (semesterId != null) query = query.eq('semester_id', semesterId);
    return await query.order('created_at', ascending: true);
  }

  Future<Map<String, dynamic>> createCourse(Map<String, dynamic> data) async {
    return await _client.from('user_courses').insert(data).select().single();
  }

  Future<Map<String, dynamic>> updateCourse(String id, Map<String, dynamic> data) async {
    return await _client.from('user_courses').update(data).eq('id', id).select().single();
  }

  Future<void> deleteCourse(String id) async {
    await _client.from('user_courses').delete().eq('id', id);
  }

  // ── Assignments ──
  Future<List<Map<String, dynamic>>> getAssignments(String userId) async {
    return await _client
        .from('user_assignments')
        .select('*, user_courses(name)')
        .eq('user_id', userId)
        .order('due_date', ascending: true);
  }

  Future<Map<String, dynamic>> createAssignment(Map<String, dynamic> data) async {
    return await _client.from('user_assignments').insert(data).select('*, user_courses(name)').single();
  }

  Future<Map<String, dynamic>> updateAssignment(String id, Map<String, dynamic> data) async {
    return await _client.from('user_assignments').update(data).eq('id', id).select('*, user_courses(name)').single();
  }

  Future<void> deleteAssignment(String id) async {
    await _client.from('user_assignments').delete().eq('id', id);
  }

  Future<Map<String, dynamic>> toggleAssignmentComplete(String id, bool isCompleted) async {
    return await _client.from('user_assignments').update({'is_completed': isCompleted}).eq('id', id).select('*, user_courses(name)').single();
  }
}