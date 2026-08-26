import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreRemoteDatasource {
  final SupabaseClient _client;

  ExploreRemoteDatasource(this._client);

  // ── Universities ──

  Future<List<Map<String, dynamic>>> getUniversities({
    String? search,
    String? type,
    String? sortBy,
  }) async {
    var query = _client.from('universities').select().eq('is_active', true);

    if (type != null && type != 'all') {
      query = query.eq('type', type);
    }

    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,short_name.ilike.%$search%');
    }

    // order() returns different type, so call it last and await directly
    final String orderColumn = sortBy == 'name' ? 'name' : 'ranking_national';
    return await query.order(orderColumn, ascending: true);
  }

  Future<Map<String, dynamic>> getUniversityById(String id) async {
    return await _client.from('universities').select().eq('id', id).single();
  }

  // ── Programs (Module 27 + 28) ──

  Future<List<Map<String, dynamic>>> getPrograms({
    String? search,
    String? field,
    String? degreeLevel,
    String? universityId,
  }) async {
    var query = _client
        .from('university_programs')
        .select('*, universities!inner(name, short_name, type)')
        .eq('is_active', true);

    if (field != null && field != 'all') {
      query = query.eq('field', field);
    }

    if (degreeLevel != null && degreeLevel != 'all') {
      query = query.eq('degree_level', degreeLevel);
    }

    if (universityId != null) {
      query = query.eq('university_id', universityId);
    }

    if (search != null && search.isNotEmpty) {
      query = query.ilike('name', '%$search%');
    }

    return await query.order('name', ascending: true);
  }

  Future<List<Map<String, dynamic>>> getProgramsByUniversity(String universityId) async {
    return await _client
        .from('university_programs')
        .select()
        .eq('university_id', universityId)
        .eq('is_active', true)
        .order('degree_level', ascending: true)
        .order('name', ascending: true);
  }

  // ── Campuses (Module 29) ──

  Future<List<Map<String, dynamic>>> getCampuses({
    String? universityId,
    String? city,
    String? search,
  }) async {
    var query = _client
        .from('campuses')
        .select('*, universities!inner(name, short_name)')
        .eq('is_active', true);

    if (universityId != null) {
      query = query.eq('university_id', universityId);
    }

    if (city != null && city != 'all') {
      query = query.eq('city', city);
    }

    if (search != null && search.isNotEmpty) {
      // Find matching university IDs first, then filter campuses
      final matchingUnis = await _client
          .from('universities')
          .select('id')
          .or('name.ilike.%$search%,short_name.ilike.%$search%');
      final uniIds = matchingUnis.map((u) => u['id'] as String).toList();
      if (uniIds.isEmpty) return [];
      query = query.inFilter('university_id', uniIds);
    }

    return await query
        .order('is_main_campus', ascending: false)
        .order('name', ascending: true);
  }

  Future<List<Map<String, dynamic>>> getCampusesByUniversity(String universityId) async {
    return await _client
        .from('campuses')
        .select()
        .eq('university_id', universityId)
        .eq('is_active', true)
        .order('is_main_campus', ascending: false)
        .order('name', ascending: true);
  }

  Future<List<String>> getCampusCities() async {
    final data = await _client
        .from('campuses')
        .select('city')
        .eq('is_active', true)
        .order('city', ascending: true);

    final cities = <String>{};
    for (final row in data) {
      if (row['city'] != null) cities.add(row['city'] as String);
    }
    return cities.toList();
  }
}