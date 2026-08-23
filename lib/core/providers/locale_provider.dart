import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_storage_service.dart';

/// Locale state — persisted in SharedPreferences
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_loadSavedLocale());

  static Locale _loadSavedLocale() {
    final code = LocalStorageService.locale;
    return Locale(code ?? 'en');
  }

  void setLocale(String languageCode) {
    LocalStorageService.setLocale(languageCode);
    state = Locale(languageCode);
  }

  void toggleLocale() {
    final next = state.languageCode == 'en' ? 'ur' : 'en';
    setLocale(next);
  }
}