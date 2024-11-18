import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class ProfileStorageService {
  static const String PROFILE_CACHE_KEY = 'cached_profile';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs;
  
  ProfileStorageService._(this._prefs);

  static Future<ProfileStorageService> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return ProfileStorageService._(prefs);
    } catch (e) {
      print('Error initializing ProfileStorageService: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfile(String? userId) async {
    if (userId == null || userId.isEmpty) {
      print('Invalid userId provided to getProfile');
      return {};
    }

    try {
      print('Getting profile for user: $userId');
      
      // Primero intentar obtener del caché
      final cachedProfile = await _getCachedProfile(userId);
      if (cachedProfile.isNotEmpty) {
        print('Found cached profile for user: $userId');
        // Intentar actualizar desde Firestore en segundo plano
        _updateFromFirestore(userId);
        return cachedProfile;
      }

      // Si no hay caché, intentar obtener de Firestore
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        await _cacheProfile(userId, data);
        print('Retrieved and cached Firestore profile for user: $userId');
        return data;
      }

      print('No profile found for user: $userId');
      return {};
    } catch (e) {
      print('Error getting profile: $e');
      return await _getCachedProfile(userId);
    }
  }

  Future<void> _updateFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        await _cacheProfile(userId, data);
        print('Updated cache from Firestore for user: $userId');
      }
    } catch (e) {
      print('Error updating from Firestore: $e');
    }
  }

  Future<void> _cacheProfile(String userId, Map<String, dynamic> profile) async {
    try {
      if (userId.isEmpty) {
        print('Attempted to cache profile with empty userId');
        return;
      }

      final key = '${PROFILE_CACHE_KEY}_$userId';
      final encodedData = jsonEncode(profile);
      await _prefs.setString(key, encodedData);
      print('Profile cached successfully for user: $userId');
    } catch (e) {
      print('Error caching profile: $e');
    }
  }

  Future<Map<String, dynamic>> _getCachedProfile(String userId) async {
    try {
      if (userId.isEmpty) {
        print('Attempted to get cached profile with empty userId');
        return {};
      }

      final key = '${PROFILE_CACHE_KEY}_$userId';
      final String? cachedData = _prefs.getString(key);
      
      if (cachedData == null || cachedData.isEmpty) {
        print('No cached profile found for user: $userId');
        return {};
      }
      
      final decoded = jsonDecode(cachedData) as Map<String, dynamic>;
      print('Retrieved cached profile for user: $userId');
      return decoded;
    } catch (e) {
      print('Error getting cached profile: $e');
      return {};
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    if (userId.isEmpty) {
      print('Attempted to update profile with empty userId');
      throw Exception('Invalid userId');
    }

    try {
      print('Updating profile for user: $userId');
      await _firestore.collection('users').doc(userId).update(data);
      await _cacheProfile(userId, data);
      print('Profile updated successfully for user: $userId');
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> clearProfile(String userId) async {
    if (userId.isEmpty) {
      print('Attempted to clear profile with empty userId');
      return;
    }

    try {
      final key = '${PROFILE_CACHE_KEY}_$userId';
      await _prefs.remove(key);
      print('Profile cache cleared for user: $userId');
    } catch (e) {
      print('Error clearing profile cache: $e');
    }
  }
}