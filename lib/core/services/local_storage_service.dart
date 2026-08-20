import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyUserType = 'user_type';
  static const _keyThemeMode = 'theme_mode';

  static bool get isOnboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;
  static Future<void> setOnboardingComplete(bool value) => _prefs.setBool(_keyOnboardingComplete, value);

  static String? get userType => _prefs.getString(_keyUserType);
  static Future<void> setUserType(String type) => _prefs.setString(_keyUserType, type);

  static int get themeMode => _prefs.getInt(_keyThemeMode) ?? 0;
  static Future<void> setThemeMode(int index) => _prefs.setInt(_keyThemeMode, index);

  static Future<void> clear() => _prefs.clear();
}