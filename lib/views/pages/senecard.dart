import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:senecard/utils/app_localizations.dart';
import 'package:senecard/view_models/customer/settings_viewmodel.dart';
import 'package:senecard/views/pages/customer/main_page.dart';
import 'loginpages/introLogin.dart';

class SenecardTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 255, 122, 40),
    ),
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F8FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color.fromARGB(255, 240, 245, 250),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 255, 122, 40),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey[900],
    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.grey[850],
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
    ),
  );
}

class Senecard extends StatefulWidget {
  const Senecard({super.key});
  @override
  State<Senecard> createState() => _SenecardState();
}

class _SenecardState extends State<Senecard> {
  Key _appKey = UniqueKey();

  void _rebuildApp() {
    setState(() {
      _appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SenecardApp(
      key: _appKey,
      onSettingsChanged: _rebuildApp,
    );
  }
}

class _SenecardApp extends StatelessWidget {
  final VoidCallback onSettingsChanged;

  const _SenecardApp({
    super.key,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settings, _) {
        if (settings.needsRebuild) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onSettingsChanged();
            settings.clearRebuildFlag();
          });
        }

        return MaterialApp(
          title: 'Senecard',
          theme: SenecardTheme.lightTheme,
          darkTheme: SenecardTheme.darkTheme,
          themeMode:
              settings.darkThemeEnabled ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          locale: Locale(settings.selectedLanguage),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          home: FutureBuilder<bool>(
            future: settings.getShouldNavigateToMain(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                // Limpiar el flag y navegar a MainPage
                settings.clearNavigationState();
                return const MainPage();
              }
              return const IntroScreen();
            },
          ),
        );
      },
    );
  }
}
