import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationsRemoteDatasource {
  final SupabaseClient _client;

  ApplicationsRemoteDatasource(this._client);

  static const _uniJoin = '*, universities(name, short_name, type, ranking_national)';

  // ── Shortlist ──
  Future<List<Map<String, dynamic>>> getShortlist(String userId) async {
    return await _client
        .from('user_shortlist')
        .select(_uniJoin)
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  Future<bool> isShortlisted(String userId, String universityId) async {
    final result = await _client
        .from('user_shortlist')
        .select('id')
        .eq('user_id', userId)
        .eq('university_id', universityId)
        .maybeSingle();
    return result != null;
  }

  Future<void> addToShortlist(String userId, String universityId, {String? notes}) async {
    await _client.from('user_shortlist').insert({
      'user_id': userId,
      'university_id': universityId,
      'notes': notes,
    });
  }

  Future<void> removeFromShortlist(String id) async {
    await _client.from('user_shortlist').delete().eq('id', id);
  }

  Future<void> removeFromShortlistByUniversity(String userId, String universityId) async {
    await _client.from('user_shortlist').delete().eq('user_id', userId).eq('university_id', universityId);
  }

  // ── Applications ──
  Future<List<Map<String, dynamic>>> getApplications(String userId) async {
    return await _client
        .from('user_applications')
        .select(_uniJoin)
        .eq('user_id', userId)
        .order('deadline', ascending: true);
  }

  Future<Map<String, dynamic>> createApplication(Map<String, dynamic> data) async {
    return await _client.from('user_applications').insert(data).select(_uniJoin).single();
  }

  Future<Map<String, dynamic>> updateApplication(String id, Map<String, dynamic> data) async {
    return await _client.from('user_applications').update(data).eq('id', id).select(_uniJoin).single();
  }

  Future<void> deleteApplication(String id) async {
    await _client.from('user_applications').delete().eq('id', id);
  }
}