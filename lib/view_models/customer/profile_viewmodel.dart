import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senecard/services/connectivity_service.dart';
import 'package:senecard/services/profile_storage_service.dart';
import 'package:senecard/utils/validators.dart';

class ProfileViewModel extends ChangeNotifier {
  final ConnectivityService _connectivityService = ConnectivityService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileStorageService _storageService;
  final String userId;

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isOnline = true;
  String _editName = '';
  String _editEmail = '';
  String _editPhone = '';
  String _name = '';
  String _email = '';
  String _phone = '';
  String _errorMessage = '';
  bool _hasError = false;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  
  var storageService;

  String? get nameError => _nameError;
  String? get emailError => _emailError;
  String? get phoneError => _phoneError;

  bool get isFormValid =>
      _nameError == null &&
      _emailError == null &&
      _phoneError == null &&
      _editName.isNotEmpty &&
      _editEmail.isNotEmpty &&
      _editPhone.isNotEmpty;

  ProfileViewModel({
    required this.userId,
    required ProfileStorageService storageService,
  }) : _storageService = storageService {
    if (!FirebaseAuth.instance.currentUser!.uid.isNotEmpty ?? false) {
      throw StateError('ProfileViewModel initialized without valid authentication');
    }
    print('Initializing ProfileViewModel with userId: $userId');
    if (userId.isEmpty) {
      print('Warning: Empty userId provided to ProfileViewModel');
      _errorMessage = 'Invalid user session';
      _hasError = true;
      _isLoading = false;
      notifyListeners();
    } else {
      _initializeServices();
    }
  }

  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  bool get isOnline => _isOnline;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get errorMessage => _errorMessage;

  void startEditing() {
    _editName = _name;
    _editEmail = _email;
    _editPhone = _phone;
    _isEditing = true;
    notifyListeners();
  }

  void validateName(String value) {
    _editName = value;
    _nameError = Validators.validateName(value);
    notifyListeners();
  }

  void validateEmail(String value) {
    _editEmail = value;
    _emailError = Validators.validateEmail(value);
    notifyListeners();
  }

  void validatePhone(String value) {
    _editPhone = value;
    _phoneError = Validators.validatePhone(value);
    notifyListeners();
  }

  Future<void> _initializeServices() async {
    await _initializeConnectivity();
    await _loadUserData();
  }

  Future<void> _initializeConnectivity() async {
    _isOnline = await _connectivityService.hasInternetConnection();
    _connectivityService.onConnectivityChanged.listen((hasConnectivity) {
      _isOnline = hasConnectivity;
      if (hasConnectivity) {
        _loadUserData();
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (userId.isEmpty) {
      _errorMessage = 'No user ID available';
      _hasError = true;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final userData = await _storageService.getProfile(userId);
      
      if (userData.isEmpty) {
        _errorMessage = 'No user data found';
        _hasError = true;
      } else {
        _name = userData['name'] ?? '';
        _email = userData['email'] ?? '';
        _phone = userData['phone'] ?? '';
        _hasError = false;
        _errorMessage = '';
      }

    } catch (e) {
      print('Error loading user data: $e');
      _errorMessage = 'Error loading user data';
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile() async {
    if (!_isOnline) {
      _errorMessage = 'No internet connection available';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final updatedData = {
        'name': _editName,
        'email': _editEmail,
        'phone': _editPhone,
      };

      await _storageService.updateProfile(userId, updatedData);

      _name = _editName;
      _email = _editEmail;
      _phone = _editPhone;
      _isEditing = false;
      _errorMessage = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      _errorMessage = 'Error updating profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void cancelEditing() {
    _isEditing = false;
    _nameError = null;
    _emailError = null;
    _phoneError = null;
    notifyListeners();
  }

  void retryLoading() {
    _loadUserData();
  }

  void toggleEditMode() {
    if (!_isOnline) {
      _errorMessage = 'No internet connection available';
      notifyListeners();
      return;
    }
    _isEditing = !_isEditing;
    notifyListeners();
  }
}