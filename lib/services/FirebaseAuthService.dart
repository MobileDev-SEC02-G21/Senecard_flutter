
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senecard/views/pages/Owner/owner_page.dart';

import '../views/pages/Owner/business_info.dart';
import '../views/pages/customer/main_page.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Instancia de Firebase Storage
  // Obtener el ID del usuario actual
  String? get currentUserId => _auth.currentUser?.uid;

  // Método para registrar una tienda
  Future<DocumentReference> registerStore({
    required String storeName,
    required String address,
    required String category,
    required File storeImage,
    required String businessOwnerId,
  }) async {
    try {
      // Sube la imagen a Firebase Storage y obtén la URL
      String imageUrl = await _uploadStoreImage(storeImage, storeName); // Aquí pasamos el segundo argumento

      // Crea un nuevo documento en la colección 'stores' en Firestore
      DocumentReference storeRef = await FirebaseFirestore.instance.collection('stores').add({
        'storeName': storeName,
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
  Future<String> _uploadStoreImage(File storeImage, String storeName) async {
    try {
      // Crear la referencia de almacenamiento
      Reference ref = _storage.ref().child('stores_images').child('$storeName.jpg');

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
  Future<User?> registerWithEmailAndPassword(String email, String password, String name, String phone, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        // Create a document for the new user in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': name,
          'phone': phone,
          'role': role
        });
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in user with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Obtener los datos del usuario desde Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        String role = userDoc['role']; // Verifica que el campo 'role' esté en Firestore

        // Verificar el rol y navegar a la página correspondiente
        if (role == 'uniandesMember') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else if (role == 'businessOwner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OwnerPage(storeId: 'vpMbEwQvJ5SBjnzU1TGf')),
          );
        }

        return user;
      }
      return null; // Si el usuario es null
    } catch (e) {
      print(e.toString());
      return null; // Manejo de errores
    }
  }


  // Fetch user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      // Fetch the document for the user with the given uid
      DocumentSnapshot document = await _firestore.collection('users').doc(uid).get();
      return document;
    } catch (e) {
      print(e.toString());
      rethrow; // In case of failure, rethrow the error
    }
  }


}