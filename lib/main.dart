import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; 
import 'package:senecard/firebase_options.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/views/pages/senecard.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Crear una única instancia del ViewModel
  final mainViewModel = MainPageViewmodel();

  runApp(
    // Usar ChangeNotifierProvider.value para mantener la misma instancia
    ChangeNotifierProvider.value(
      value: mainViewModel,
      child: const Senecard(),
    ),
  );
}
