import 'package:flutter/material.dart';
import 'package:senecard/services/analytics_service.dart';
import 'package:senecard/services/notifications_service.dart';
import 'package:senecard/services/user_preferences_service.dart';
import 'package:senecard/services/FirebaseAuthService.dart';

class SettingsViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final LanguageAnalyticsService _languageAnalytics = LanguageAnalyticsService();
  final UserPreferencesService _preferencesService;
  final NotificationsService _notificationsService;
  final String userRole;

  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en';
  bool _darkThemeEnabled = false;
  bool _isLoading = true;
  bool _needsRebuild = false;
  bool get needsRebuild => _needsRebuild;

  void clearRebuildFlag() {
    _needsRebuild = false;
  }


  SettingsViewModel({
    required this.userRole,
    required UserPreferencesService preferencesService,
    required NotificationsService notificationsService,
  })  : _preferencesService = preferencesService,
        _notificationsService = notificationsService {
    _loadPreferences();
  }

  bool get notificationsEnabled => _notificationsEnabled;
  String get selectedLanguage => _selectedLanguage;
  bool get darkThemeEnabled => _darkThemeEnabled;
  bool get isLoading => _isLoading;
  bool get showNotificationsSetting => userRole == 'uniandesMember';

  Future<void> _loadPreferences() async {
    try {
      _isLoading = true;
      notifyListeners();

      _notificationsEnabled =
          await _preferencesService.getNotificationsEnabled();
      _selectedLanguage = await _preferencesService.getLanguage();
      _darkThemeEnabled = await _preferencesService.getDarkThemeEnabled();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading preferences: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled == value) return;

    _notificationsEnabled = value;
    await _preferencesService.setNotificationsEnabled(value);
    if (value) {
      await _notificationsService.subscribeToNewAds();
    } else {
      await _notificationsService.unsubscribeFromNewAds();
    }
    notifyListeners();
  }

  void initializeSettings({
    required bool darkThemeEnabled,
    required String selectedLanguage,
  }) {
    _darkThemeEnabled = darkThemeEnabled;
    _selectedLanguage = selectedLanguage;
    notifyListeners();
  }

  Future<void> setDarkThemeEnabled(bool value) async {
    if (_darkThemeEnabled == value) return;
    _darkThemeEnabled = value;
    await _preferencesService.setDarkThemeEnabled(value);
    _needsRebuild = true;
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_selectedLanguage == languageCode) return;
    _selectedLanguage = languageCode;
    await _preferencesService.setLanguage(languageCode);
    
    // Log language change if user is authenticated
    if (_authService.currentUserId != null) {
      await _languageAnalytics.logLanguageChange(
        userId: _authService.currentUserId!,
        language: languageCode
      );
    }
    
    _needsRebuild = true;
    notifyListeners();
  }

  Future<void> saveNavigationState() async {
    await _preferencesService.setShouldNavigateToMain(true);
  }

  Future<bool> getShouldNavigateToMain() async {
    return _preferencesService.getShouldNavigateToMain();
  }

  Future<void> clearNavigationState() async {
    await _preferencesService.setShouldNavigateToMain(false);
  }

  Future<void> refresh() async {
    await _loadPreferences();
  }
}
