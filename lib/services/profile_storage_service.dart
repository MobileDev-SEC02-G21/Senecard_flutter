import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileStorageService {
  static const String PROFILE_CACHE_KEY = 'profile_cache';
  static const Duration CACHE_DURATION = Duration(days: 1);
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DefaultCacheManager _cacheManager;
  final StreamController<Map<String, dynamic>> _profileController;
  
  static ProfileStorageService? _instance;
  
  ProfileStorageService._() 
    : _cacheManager = DefaultCacheManager(),
      _profileController = StreamController<Map<String, dynamic>>.broadcast();

  static Future<ProfileStorageService> initialize() async {
    if (_instance != null) return _instance!;
    
    try {
      _instance = ProfileStorageService._();
      return _instance!;
    } catch (e) {
      print('Error initializing ProfileStorageService: $e');
      rethrow;
    }
  }

  Stream<Map<String, dynamic>> get profileStream => _profileController.stream;

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

      final cacheKey = '${PROFILE_CACHE_KEY}_$userId';
      final encodedData = jsonEncode(profile);
      final bytes = Uint8List.fromList(utf8.encode(encodedData));

      await _cacheManager.putFile(
        cacheKey,
        bytes,
        maxAge: CACHE_DURATION,
        key: cacheKey,
      );

      _profileController.add(profile);
      print('Profile cached successfully for user: $userId');
    } catch (e) {
      print('Error caching profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getCachedProfile(String userId) async {
    try {
      if (userId.isEmpty) {
        print('Attempted to get cached profile with empty userId');
        return {};
      }

      final cacheKey = '${PROFILE_CACHE_KEY}_$userId';
      final fileInfo = await _cacheManager.getFileFromCache(cacheKey);
      
      if (fileInfo == null) {
        print('No cached profile found for user: $userId');
        return {};
      }

      if (fileInfo.validTill.isBefore(DateTime.now())) {
        print('Cached profile expired for user: $userId');
        await _cacheManager.removeFile(cacheKey);
        return {};
      }

      final String jsonString = await fileInfo.file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      print('Retrieved cached profile for user: $userId');
      _profileController.add(decoded);
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
      final cacheKey = '${PROFILE_CACHE_KEY}_$userId';
      await _cacheManager.removeFile(cacheKey);
      _profileController.add({});
      print('Profile cache cleared for user: $userId');
    } catch (e) {
      print('Error clearing profile cache: $e');
      rethrow;
    }
  }

  void dispose() {
    _profileController.close();
  }
}