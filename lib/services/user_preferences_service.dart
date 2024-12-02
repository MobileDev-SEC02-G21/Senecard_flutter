import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String NOTIFICATIONS_KEY = 'notifications_enabled';
  static const String LANGUAGE_KEY = 'selected_language';
  static const String THEME_KEY = 'dark_theme_enabled';
  static const String NAVIGATION_STATE_KEY = 'should_navigate_main';

  static UserPreferencesService? _instance;
  final SharedPreferences _prefs;

  UserPreferencesService._(this._prefs);

  static Future<UserPreferencesService> initialize() async {
    if (_instance != null) return _instance!;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _instance = UserPreferencesService._(prefs);
      return _instance!;
    } catch (e) {
      print('Error initializing UserPreferencesService: $e');
      rethrow;
    }
  }

  // Notificaciones
  Future<bool> getNotificationsEnabled() async {
    return _prefs.getBool(NOTIFICATIONS_KEY) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(NOTIFICATIONS_KEY, value);
  }

  // Idioma
  Future<String> getLanguage() async {
    return _prefs.getString(LANGUAGE_KEY) ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    final success = await _prefs.setString(LANGUAGE_KEY, languageCode);
    print('Language preference saved: $languageCode (success: $success)');
  }

  // Tema
  Future<bool> getDarkThemeEnabled() async {
    return _prefs.getBool(THEME_KEY) ?? false;
  }

  Future<void> setDarkThemeEnabled(bool value) async {
    final success = await _prefs.setBool(THEME_KEY, value);
    print('Dark theme preference saved: $value (success: $success)');
  }

  Future<void> setShouldNavigateToMain(bool value) async {
    await _prefs.setBool(NAVIGATION_STATE_KEY, value);
  }

  Future<bool> getShouldNavigateToMain() async {
    return _prefs.getBool(NAVIGATION_STATE_KEY) ?? false;
  }
}