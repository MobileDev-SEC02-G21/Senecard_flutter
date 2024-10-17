import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return user; // User successfully signed in
    } catch (e) {
      print(e.toString());
      return null; // Failed to sign in
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