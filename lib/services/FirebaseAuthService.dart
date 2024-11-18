
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
  String get currentUserId {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      throw StateError('No authenticated user found');
    }
    return userId;
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
      String imageUrl = await _uploadStoreImage(storeImage, name); // Aquí pasamos el segundo argumento

      // Crea un nuevo documento en la colección 'stores' en Firestore
      DocumentReference storeRef = await FirebaseFirestore.instance.collection('stores').add({
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
        // Log the business owner ID (user UID) to the console
        print('Business Owner ID: ${user.uid}');

        // Fetch the user's document from Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        String role = userDoc['role']; // Check if the 'role' field exists in Firestore

        // Verify role and retrieve storeId if the user is a businessOwner
        if (role == 'uniandesMember') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else if (role == 'businessOwner') {
          // Query Firestore for all stores and find the one associated with this businessOwner
          print('Attempting to query store with businessOwnerId: ${user.uid}');

          QuerySnapshot storeQuery = await _firestore.collection('stores').get();

          // Find the first document where 'businessOwnerId' matches user.uid
          var storeDoc = storeQuery.docs.cast<QueryDocumentSnapshot?>().firstWhere(
                (doc) => doc?['businessOwnerId'] == user.uid,
            orElse: () => null,
          );

          if (storeDoc != null) {
            String storeId = storeDoc.id;
            print('Retrieved Store ID: $storeId');

            // Navigate to OwnerPage with the dynamically retrieved storeId
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OwnerPage(storeId: storeId)),
            );
          } else {
            // Handle case where no store is found for this business owner
            print('No store found for this business owner.');
          }
        }
        return user;
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null; // Error handling
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