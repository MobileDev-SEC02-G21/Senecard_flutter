import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class UserCacheService {
  static const String CACHE_KEY = 'user_cache';
  static const Duration CACHE_DURATION = Duration(days: 7);
  
  static UserCacheService? _instance;
  final DefaultCacheManager _cacheManager;
  final StreamController<String?> _userIdController;
  
  UserCacheService._() 
    : _cacheManager = DefaultCacheManager(),
      _userIdController = StreamController<String?>.broadcast();

  static Future<UserCacheService> initialize() async {
    if (_instance != null) return _instance!;
    
    _instance = UserCacheService._();
    return _instance!;
  }

  Stream<String?> get userIdStream => _userIdController.stream;

  Future<String?> getCachedUserId() async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(CACHE_KEY);
      if (fileInfo == null) {
        print('No cached user ID found');
        return null;
      }

      if (fileInfo.validTill.isBefore(DateTime.now())) {
        print('Cached user ID expired');
        await _cacheManager.removeFile(CACHE_KEY);
        return null;
      }

      final userId = await fileInfo.file.readAsString();
      print('Retrieved cached user ID: $userId');
      _userIdController.add(userId);
      return userId;
    } catch (e) {
      print('Error getting cached user ID: $e');
      return null;
    }
  }

  Future<void> cacheUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        print('Warning: Attempted to cache empty userId');
        return;
      }

      // Convertir el string a Uint8List
      final Uint8List bytes = Uint8List.fromList(userId.codeUnits);
      
      await _cacheManager.putFile(
        CACHE_KEY,
        bytes,
        maxAge: CACHE_DURATION,
        key: CACHE_KEY,
      );
      
      _userIdController.add(userId);
      print('Successfully cached user ID: $userId');
    } catch (e) {
      print('Error caching user ID: $e');
      rethrow;
    }
  }

  Future<void> clearCache() async {
    try {
      await _cacheManager.removeFile(CACHE_KEY);
      _userIdController.add(null);
      print('User ID cache cleared');
    } catch (e) {
      print('Error clearing user ID cache: $e');
      rethrow;
    }
  }

  void dispose() {
    _userIdController.close();
  }
}