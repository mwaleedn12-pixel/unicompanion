import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service.dart';

/// Lightweight offline cache using SharedPreferences.
/// Stores JSON strings for universities, programs, scholarships, jobs.
/// No extra dependency needed — uses existing SharedPreferences.
class CacheService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Cache keys ──
  static const _prefix = 'cache_';
  static const keyUniversities = 'universities';
  static const keyScholarships = 'scholarships';
  static const keyJobs = 'jobs';
  static const keyPrograms = 'programs';

  /// Save a list of maps to cache
  static Future<void> saveList(String key, List<Map<String, dynamic>> data) async {
    await _prefs.setString('$_prefix$key', jsonEncode(data));
    await LocalStorageService.setLastCacheTime(key);
  }

  /// Load cached list (returns null if no cache)
  static List<Map<String, dynamic>>? loadList(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  /// Check if cache exists and is fresh
  static bool hasFreshCache(String key, {Duration maxAge = const Duration(hours: 6)}) {
    final data = _prefs.getString('$_prefix$key');
    if (data == null) return false;
    return !LocalStorageService.isCacheStale(key, maxAge: maxAge);
  }

  /// Load from cache if fresh, otherwise return null (caller should fetch from network)
  static List<Map<String, dynamic>>? loadIfFresh(String key, {Duration maxAge = const Duration(hours: 6)}) {
    if (!hasFreshCache(key, maxAge: maxAge)) return null;
    return loadList(key);
  }

  /// Clear a specific cache
  static Future<void> clearKey(String key) async {
    await _prefs.remove('$_prefix$key');
  }

  /// Clear all caches
  static Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}