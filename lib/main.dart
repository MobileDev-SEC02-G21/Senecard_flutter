import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa firebase_core
import 'package:provider/provider.dart';           // Importa provider
import 'package:senecard/firebase_options.dart';
import 'package:senecard/view_models/owner/business_viewmodel.dart';
import 'package:senecard/view_models/owner/qr_viewmodel.dart';
import 'package:senecard/views/pages/Owner/business_info.dart';
import 'package:senecard/views/pages/senecard.dart'; // Importa la página principal de Senecard
import 'package:senecard/view_models/owner/owner_page_vm.dart'; // Importa el ViewModel de Owner
import 'package:senecard/view_models/owner/advertisement_viewmodel.dart'; // Importa el ViewModel de Advertisement

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform
    ); // Inicializa Firebase y maneja errores potenciales
  } catch (e) {
    // Maneja errores si Firebase falla al inicializar
    print('Firebase initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OwnerPageViewModel()), // Proveedor de OwnerPageViewModel
        ChangeNotifierProvider(create: (context) => AdvertisementViewModel()), // Proveedor de AdvertisementViewModel
        ChangeNotifierProvider(create: (context) => QrViewModel()), // Proveedor de AdvertisementViewModel
        ChangeNotifierProvider(create: (context) => BusinessInfoViewModel()), // Proveedor de AdvertisementViewModel


        // Puedes agregar otros ViewModels o Providers aquí si es necesario
      ],
      child: const Senecard(), // Tu widget principal
    ),
  );
}
