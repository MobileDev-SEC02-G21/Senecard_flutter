import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa firebase_core
import 'package:provider/provider.dart';           // Importa provider
import 'package:senecard/views/pages/senecard.dart';
import 'package:senecard/view_models/owner_page_vm.dart'; // Importa el ViewModel

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OwnerPageViewModel()),
        // Puedes agregar más ViewModels aquí si es necesario
      ],
      child: const Senecard(),
    ),
  );
}
