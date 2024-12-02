import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:senecard/firebase_options.dart';
import 'package:senecard/services/notifications_service.dart';
import 'package:senecard/services/user_preferences_service.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/view_models/customer/settings_viewmodel.dart';
import 'package:senecard/view_models/owner/owner_page_vm.dart';
import 'package:senecard/views/pages/senecard.dart';
import 'package:senecard/view_models/owner/advertisement_viewmodel.dart';
import 'package:senecard/view_models/owner/business_viewmodel.dart';
import 'package:senecard/view_models/owner/qr_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar cache y configuración de imágenes
  await DefaultCacheManager().emptyCache();
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Inicializar servicios
  final preferencesService = await UserPreferencesService.initialize();
  final notificationsService = await NotificationsService.initialize(preferencesService);

  // Cargar las preferencias iniciales
  final initialDarkMode = await preferencesService.getDarkThemeEnabled();
  final initialLanguage = await preferencesService.getLanguage();
    
  runApp(
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MainPageViewmodel()),
          ChangeNotifierProvider(create: (_) => OwnerPageViewModel()),
          ChangeNotifierProvider(create: (_) => AdvertisementViewModel()),
          ChangeNotifierProvider(create: (_) => BusinessInfoViewModel()),
          ChangeNotifierProvider(create: (_) => QrViewModel()),
          ChangeNotifierProvider(
            create: (_) => SettingsViewModel(
              userRole: 'uniandesMember',
              preferencesService: preferencesService,
              notificationsService: notificationsService,
            )..initializeSettings(  // Inicializar con valores guardados
              darkThemeEnabled: initialDarkMode,
              selectedLanguage: initialLanguage,
            ),
          ),
        ],
        child: const Senecard(),
      ),
    ),
  );
}