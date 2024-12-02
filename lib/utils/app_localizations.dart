import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = {
    'en': {
      'settings': 'Settings',
      'notifications': 'Notifications',
      'language': 'Language',
      'theme': 'Theme',
      'darkMode': 'Dark Mode',
      'english': 'English',
      'spanish': 'Spanish',
      'notificationsDescription': 'Receive notifications for new advertisements',
      'themeDescription': 'Switch between light and dark theme',
      'languageDescription': 'Change application language',
    },
    'es': {
      'settings': 'Configuración',
      'notifications': 'Notificaciones',
      'language': 'Idioma',
      'theme': 'Tema',
      'darkMode': 'Modo Oscuro',
      'english': 'Inglés',
      'spanish': 'Español',
      'notificationsDescription': 'Recibir notificaciones de nuevos anuncios',
      'themeDescription': 'Cambiar entre tema claro y oscuro',
      'languageDescription': 'Cambiar el idioma de la aplicación',
    },
  };

  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get spanish => _localizedValues[locale.languageCode]!['spanish']!;
  String get notificationsDescription => _localizedValues[locale.languageCode]!['notificationsDescription']!;
  String get themeDescription => _localizedValues[locale.languageCode]!['themeDescription']!;
  String get languageDescription => _localizedValues[locale.languageCode]!['languageDescription']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}