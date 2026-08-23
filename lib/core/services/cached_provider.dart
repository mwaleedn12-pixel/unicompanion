import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/utils/ui_state.dart';
import '../../data/models/university_model.dart';

/// Drop-in replacement for the universities loading logic.
/// Tries network first → caches result. Falls back to cache if network fails.
///
/// Usage: In your existing explore_provider.dart, replace the load() body
/// of your UniversitiesNotifier with the pattern shown here.
///
/// This file shows the mixin pattern — apply it to any Supabase list provider.

mixin CachedListLoader<T> {
  /// Fetch from Supabase, cache the raw JSON, return parsed models.
  /// If network fails, try loading from cache.
  Future<List<T>> loadWithCache({
    required SupabaseClient client,
    required String table,
    required String cacheKey,
    required T Function(Map<String, dynamic>) fromJson,
    String? orderBy,
    Map<String, dynamic>? filters,
    Duration maxAge = const Duration(hours: 6),
  }) async {
    try {
      // Try network first
      var query = client.from(table).select();
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }
      if (orderBy != null) {
        query = query.order(orderBy);
      }

      final data = await query;
      final list = (data as List).cast<Map<String, dynamic>>();

      // Cache the raw JSON
      await CacheService.saveList(cacheKey, list);

      return list.map(fromJson).toList();
    } catch (networkError) {
      // Network failed — try cache
      final cached = CacheService.loadList(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached.map(fromJson).toList();
      }

      // No cache either — rethrow
      throw networkError;
    }
  }
}

/// Example: CachedUniversitiesNotifier
/// Replace your existing UniversitiesNotifier with this to get offline support.
class CachedUniversitiesNotifier extends StateNotifier<UiState<List<UniversityModel>>> with CachedListLoader<UniversityModel> {
  final SupabaseClient _client;

  CachedUniversitiesNotifier(this._client) : super(const UiState.initial());

  Future<void> load() async {
    state = const UiState.loading();
    try {
      final list = await loadWithCache(
        client: _client,
        table: 'universities',
        cacheKey: CacheService.keyUniversities,
        fromJson: (json) => UniversityModel.fromJson(json),
        orderBy: 'ranking_national',
      );
      state = UiState.success(list);
    } catch (e) {
      state = UiState.error('Failed to load universities: $e');
    }
  }
}

// ──────────────────────────────────────────────────
// HOW TO APPLY TO OTHER PROVIDERS:
// ──────────────────────────────────────────────────
//
// 1. Add `with CachedListLoader<YourModel>` to your notifier class
// 2. Replace the Supabase fetch call with:
//
//    final list = await loadWithCache(
//      client: _client,
//      table: 'your_table',
//      cacheKey: 'your_cache_key',
//      fromJson: (json) => YourModel.fromJson(json),
//    );
//
// That's it — network-first, auto-cache, offline fallback.
// ──────────────────────────────────────────────────