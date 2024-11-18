import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  
  bool _isLoading = true;
  bool _isEditing = false;
  String _name = '';
  String _email = '';
  String _phone = '';
  String _errorMessage = '';

  ProfileViewModel({required this.userId}) {
    _loadUserData();
  }

  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get errorMessage => _errorMessage;

  Future<void> _loadUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final DocumentSnapshot userDoc = 
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _name = data['name'] ?? '';
        _email = data['email'] ?? '';
        _phone = data['phone'] ?? '';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading user data';
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'email': email,
        'phone': phone,
      });

      _name = name;
      _email = email;
      _phone = phone;
      _isEditing = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}