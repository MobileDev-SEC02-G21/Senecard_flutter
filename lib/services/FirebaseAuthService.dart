import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/services/cache_service.dart';
import 'package:senecard/services/profile_storage_service.dart';
import 'package:senecard/services/qr_storage_service.dart';
import 'package:senecard/services/search_history_service.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/views/pages/Owner/owner_page.dart';
import '../views/pages/customer/main_page.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Instancia de Firebase Storage
  // Obtener el ID del usuario actual
  String? get currentUserId {
    final user = _auth.currentUser;
    return user?.uid;
  }

  bool get isAuthenticated => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;

  // Método para registrar una tienda
  Future<DocumentReference> registerStore({
    required String name,
    required String address,
    required String category,
    required File storeImage,
    required String businessOwnerId,
  }) async {
    try {
      // Sube la imagen a Firebase Storage y obtén la URL
      String imageUrl = await _uploadStoreImage(
          storeImage, name); // Aquí pasamos el segundo argumento

      // Crea un nuevo documento en la colección 'stores' en Firestore
      DocumentReference storeRef =
          await FirebaseFirestore.instance.collection('stores').add({
        'name': name,
        'address': address,
        'category': category,
        'imageUrl': imageUrl,
        'businessOwnerId': businessOwnerId,
        'rating': 0, // Puedes cambiar esto o añadir más campos si es necesario
      });

      return storeRef; // Devolver el DocumentReference
    } catch (e) {
      print('Error al registrar la tienda: $e');
      rethrow; // Propagar el error para que pueda manejarse en la UI
    }
  }

  // Método auxiliar para subir la imagen a Firebase Storage
  Future<String> _uploadStoreImage(File storeImage, String name) async {
    try {
      // Crear la referencia de almacenamiento
      Reference ref = _storage.ref().child('stores_images').child('$name.jpg');

      // Subir el archivo a Firebase Storage
      UploadTask uploadTask = ref.putFile(storeImage);

      // Esperar a que la carga termine y obtener la URL de descarga
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl; // Retornar la URL de la imagen
    } catch (e) {
      print('Error uploading image: $e');
      rethrow; // Rethrow para manejar el error en la UI
    }
  }

  // Sign up user with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password,
      String name, String phone, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        // Create a document for the new user in Firestore
        await _firestore.collection('users').doc(user.uid).set(
            {'email': user.email, 'name': name, 'phone': phone, 'role': role});
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      
      if (_auth.currentUser != null) {
        await signOut();
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        print('User signed in successfully. ID: ${user.uid}');
        Provider.of<MainPageViewmodel>(context, listen: false).updateUserId(user.uid);

        // Fetch the user's document from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          print('User document not found in Firestore');
          await _auth.signOut();
          return null;
        }

        String role = userDoc['role'];

        if (!context.mounted) return null;

        if (role == 'uniandesMember') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else if (role == 'businessOwner') {
          print('Querying store for business owner: ${user.uid}');

          // Optimizamos la query para buscar solo el store específico
          QuerySnapshot storeQuery = await _firestore
              .collection('stores')
              .where('businessOwnerId', isEqualTo: user.uid)
              .limit(1)
              .get();

          if (storeQuery.docs.isNotEmpty) {
            String storeId = storeQuery.docs.first.id;
            print('Retrieved Store ID: $storeId');

            if (!context.mounted) return null;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => OwnerPage(storeId: storeId)),
            );
          } else {
            print('No store found for business owner: ${user.uid}');
          }
        }
        return user;
      }
      return null;
    } catch (e) {
      print('Error during sign in: $e');
      return null;
    }
  }

  // Fetch user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      // Fetch the document for the user with the given uid
      DocumentSnapshot document =
          await _firestore.collection('users').doc(uid).get();
      return document;
    } catch (e) {
      print(e.toString());
      rethrow; // In case of failure, rethrow the error
    }
  }

  Future<void> signOut() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Limpiar todas las cachés primero
        await _clearAllCache(userId);
      }

      // Luego hacer el signOut de Firebase
      await _auth.signOut();
      print('Successfully signed out and cleared cache');
    } catch (e) {
      print('Error during sign out: $e');
      // Intentar el signOut de Firebase incluso si falló la limpieza de caché
      await _auth.signOut();
    }
  }

// Agregar este método privado para limpiar cachés
  Future<void> _clearAllCache(String userId) async {
    try {
      final cacheService = await CacheService.initialize();
      final profileStorage = await ProfileStorageService.initialize();
      final qrStorage = await QrStorageService.initialize();
      final searchHistory = await SearchHistoryService.initialize();

      await Future.wait([
        cacheService.clearCache(),
        profileStorage.clearProfile(userId),
        qrStorage.clearStoredUserId(),
        searchHistory.clearSearchHistory(),
      ]);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
