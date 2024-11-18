import 'package:flutter/foundation.dart';
import 'package:senecard/services/user_cache_service.dart';

class QrStorageService {
  static QrStorageService? _instance;
  final UserCacheService _cacheService;
  
  QrStorageService._(this._cacheService);
  
  static Future<QrStorageService> initialize() async {
    if (_instance != null) return _instance!;
    
    try {
      final cacheService = await UserCacheService.initialize();
      _instance = QrStorageService._(cacheService);
      return _instance!;
    } catch (e) {
      print('Error initializing QrStorageService: $e');
      rethrow;
    }
  }

  Future<String?> getStoredUserId() async {
    try {
      final userId = await _cacheService.getCachedUserId();
      print('Retrieved stored user ID: $userId');
      return userId;
    } catch (e) {
      print('Error getting stored user ID: $e');
      return null;
    }
  }

  Future<void> storeUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        print('Warning: Attempted to store empty userId');
        return;
      }
      await _cacheService.cacheUserId(userId);
      print('Stored user ID: $userId');
    } catch (e) {
      print('Error storing user ID: $e');
      rethrow;
    }
  }

  Future<void> clearStoredUserId() async {
    try {
      await _cacheService.clearCache();
      print('Cleared stored user ID');
    } catch (e) {
      print('Error clearing stored user ID: $e');
      rethrow;
    }
  }

  Stream<String?> get userIdStream => _cacheService.userIdStream;
}