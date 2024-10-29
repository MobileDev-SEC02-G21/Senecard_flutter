import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/models/advertisement.dart';

class CacheService {
  static const String STORES_CACHE_KEY = 'cached_stores';
  static const String ADS_CACHE_KEY = 'cached_advertisements';
  static const String LAST_CACHE_TIME_KEY = 'last_cache_time';
  static const Duration CACHE_DURATION = Duration(hours: 1);
  static const int CACHE_LIMIT = 3;
  
  static CacheService? _instance;
  final SharedPreferences _prefs;
  
  CacheService._(this._prefs);

  static Future<CacheService> initialize() async {
    if (_instance != null) return _instance!;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _instance = CacheService._(prefs);
      return _instance!;
    } catch (e) {
      print('Error initializing CacheService: $e');
      rethrow;
    }
  }

  Future<bool> hasValidCache() async {
    try {
      final lastCacheTime = _prefs.getString(LAST_CACHE_TIME_KEY);
      if (lastCacheTime == null) return false;
      
      final lastUpdate = DateTime.parse(lastCacheTime);
      return DateTime.now().difference(lastUpdate) < CACHE_DURATION;
    } catch (e) {
      print('Error checking cache validity: $e');
      return false;
    }
  }

  Future<bool> shouldUpdateCache() async {
    try {
      if (!await hasValidCache()) return true;
      return await hasInternetConnection();
    } catch (e) {
      print('Error checking if cache should update: $e');
      return true;
    }
  }

  Future<void> cacheTopStores(List<Store> stores) async {
    try {
      final topStores = stores
          .take(CACHE_LIMIT)
          .map((store) => store.toFirestore())
          .toList();
      await _prefs.setString(STORES_CACHE_KEY, jsonEncode(topStores));
      await _updateCacheTimestamp();
    } catch (e) {
      print('Error caching stores: $e');
    }
  }

  Future<void> cacheTopAdvertisements(List<Advertisement> ads) async {
    try {
      final topAds = ads
          .where((ad) => ad.available)
          .take(CACHE_LIMIT)
          .map((ad) => ad.toFirestore())
          .toList();
      await _prefs.setString(ADS_CACHE_KEY, jsonEncode(topAds));
      await _updateCacheTimestamp();
    } catch (e) {
      print('Error caching advertisements: $e');
    }
  }

  Future<List<Store>> getCachedStores() async {
    try {
      final String? cachedData = _prefs.getString(STORES_CACHE_KEY);
      if (cachedData == null) return [];
      
      final List<dynamic> storesJson = jsonDecode(cachedData);
      return storesJson.asMap().entries.map((entry) => 
        Store.fromFirestore(entry.value, 'cached_${entry.key}')).toList();
    } catch (e) {
      print('Error getting cached stores: $e');
      return [];
    }
  }

  Future<List<Advertisement>> getCachedAdvertisements() async {
    try {
      final String? cachedData = _prefs.getString(ADS_CACHE_KEY);
      if (cachedData == null) return [];
      
      final List<dynamic> adsJson = jsonDecode(cachedData);
      return adsJson.asMap().entries.map((entry) => 
        Advertisement.fromFirestore(entry.value, 'cached_${entry.key}')).toList();
    } catch (e) {
      print('Error getting cached advertisements: $e');
      return [];
    }
  }

  Future<void> _updateCacheTimestamp() async {
    try {
      await _prefs.setString(LAST_CACHE_TIME_KEY, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error updating cache timestamp: $e');
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking internet connection: $e');
      return false;
    }
  }
}