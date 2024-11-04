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
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Método para registrar una tienda
  Future<DocumentReference> registerStore({
    required String name,
    required String address,
    required String category,
    required File storeImage,
    required String businessOwnerId,
  }) async {
    try {
      String imageUrl = await _uploadStoreImage(storeImage, name);
      DocumentReference storeRef = await FirebaseFirestore.instance.collection('stores').add({
        'name': name,
        'address': address,
        'category': category,
        'imageUrl': imageUrl,
        'businessOwnerId': businessOwnerId,
        'rating': 0,
      });
      return storeRef;
    } catch (e) {
      print('Error al registrar la tienda: $e');
      rethrow;
    }
  }

  // Método auxiliar para subir la imagen a Firebase Storage
  Future<String> _uploadStoreImage(File storeImage, String name) async {
    try {
      Reference ref = _storage.ref().child('stores_images').child('$name.jpg');
      UploadTask uploadTask = ref.putFile(storeImage);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Sign up user with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password, String name, String phone, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
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
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        String role = userDoc['role'];

        if (role == 'uniandesMember') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else if (role == 'businessOwner') {
          // Realiza una consulta en la colección stores para obtener el storeId
          QuerySnapshot storeSnapshot = await _firestore
              .collection('stores')
              .where('businessOwnerId', isEqualTo: user.uid)
              .limit(1)
              .get();

          if (storeSnapshot.docs.isNotEmpty) {
            String storeId = storeSnapshot.docs.first.id;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OwnerPage(storeId: storeId)),
            );
          } else {
            print('No se encontró una tienda para este usuario.');
          }
        }

        return user;
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Fetch user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      DocumentSnapshot document = await _firestore.collection('users').doc(uid).get();
      return document;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}