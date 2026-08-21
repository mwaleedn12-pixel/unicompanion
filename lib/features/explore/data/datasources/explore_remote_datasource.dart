import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreRemoteDatasource {
  final SupabaseClient _client;

  ExploreRemoteDatasource(this._client);

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
}