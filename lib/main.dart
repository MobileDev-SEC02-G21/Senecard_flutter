import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:senecard/firebase_options.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/view_models/owner/edit_business_viewmodel.dart';
import 'package:senecard/view_models/owner/owner_page_vm.dart';
import 'package:senecard/views/pages/senecard.dart';
import 'package:senecard/view_models/owner/advertisement_viewmodel.dart';
import 'package:senecard/view_models/owner/business_viewmodel.dart';
import 'package:senecard/view_models/owner/qr_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MainPageViewmodel(),
        ),
        ChangeNotifierProvider(
          create: (_) => OwnerPageViewModel(),
        ),
        ChangeNotifierProvider(
            create: (_) => AdvertisementViewModel()
        ),
        ChangeNotifierProvider(
            create: (_) => BusinessInfoViewModel()
        ),
        ChangeNotifierProvider(
            create: (_) => QrViewModel()
        ),
        ChangeNotifierProvider(
            create: (_) => EditBusinessViewModel()
        ),
      ],
      child: const Senecard(),
    ),
  );
}