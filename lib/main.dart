import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa firebase_core
import 'package:provider/provider.dart';           // Importa provider
import 'package:senecard/views/pages/senecard.dart';
import 'package:senecard/view_models/owner_page_vm.dart'; // Importa el ViewModel

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures everything is set up before Firebase initializes

  try {
    await Firebase.initializeApp(); // Initialize Firebase and handle potential errors
  } catch (e) {
    // Handle errors if Firebase fails to initialize
    print('Firebase initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OwnerPageViewModel()),
        // Add other ViewModels or Providers here if necessary
      ],
      child: const Senecard(),
    ),
  );
}

