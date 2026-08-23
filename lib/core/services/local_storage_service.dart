import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyUserType = 'user_type';
  static const _keyThemeMode = 'theme_mode';
  static const _keyRemindersEnabled = 'reminders_enabled';

  static bool get isOnboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;
  static Future<void> setOnboardingComplete(bool value) => _prefs.setBool(_keyOnboardingComplete, value);

  static String? get userType => _prefs.getString(_keyUserType);
  static Future<void> setUserType(String type) => _prefs.setString(_keyUserType, type);
  static Future<void> clearUserType() => _prefs.remove(_keyUserType);

  static int get themeMode => _prefs.getInt(_keyThemeMode) ?? 0;
  static Future<void> setThemeMode(int index) => _prefs.setInt(_keyThemeMode, index);

  static bool get remindersEnabled => _prefs.getBool(_keyRemindersEnabled) ?? true;
  static Future<void> setRemindersEnabled(bool value) => _prefs.setBool(_keyRemindersEnabled, value);

  static Future<void> clear() => _prefs.clear();
}