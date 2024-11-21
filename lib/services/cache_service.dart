import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/models/advertisement.dart';

class CacheService {
  static const String STORES_CACHE_KEY = 'cached_stores';
  static const String ADS_CACHE_KEY = 'cached_advertisements';
  static const String LAST_CACHE_TIME_KEY = 'last_cache_time';
  static const Duration CACHE_DURATION = Duration(hours: 24);

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

  Future<void> cacheStores(List<Store> stores) async {
    try {
      print('Caching ${stores.length} stores...');
      final storesData = stores.map((store) {
        final storeMap = store.toFirestore();
        storeMap['id'] = store.id;
        storeMap['image_url'] = store.image;
      }).toList();
      final encodedData = jsonEncode(storesData);
      await _prefs.setString(STORES_CACHE_KEY, encodedData);
      await _updateCacheTimestamp();
      print('Stores cached successfully');
    } catch (e) {
      print('Error caching stores: $e');
    }
  }

  Future<void> cacheAdvertisements(List<Advertisement> ads) async {
    try {
      print('Caching ${ads.length} advertisements...');
      // Solo guardamos los anuncios disponibles
      final availableAds = ads.where((ad) => ad.available).toList();
      final adsData =
          availableAds.map((ad) => ad.toFirestore()..['id'] = ad.id).toList();
      final encodedData = jsonEncode(adsData);
      await _prefs.setString(ADS_CACHE_KEY, encodedData);
      await _updateCacheTimestamp();
      print('Advertisements cached successfully');
    } catch (e) {
      print('Error caching advertisements: $e');
    }
  }

  Future<List<Store>> getCachedStores() async {
    try {
      print('Getting cached stores...');
      final String? cachedData = _prefs.getString(STORES_CACHE_KEY);
      if (cachedData == null || cachedData.isEmpty) {
        print('No cached stores found');
        return [];
      }

      final List<dynamic> storesJson = jsonDecode(cachedData);
      final stores = storesJson.map((storeData) {
        final String id = storeData['id'] ?? '';
        final String imageUrl = storeData['image_url'] ?? '';
        storeData.remove('id');
        storeData.remove('image_url');
         storeData['image'] = imageUrl;
        return Store.fromFirestore(storeData, id);
      }).toList();

      print('Retrieved ${stores.length} cached stores');
      return stores;
    } catch (e) {
      print('Error getting cached stores: $e');
      return [];
    }
  }

  Future<List<Advertisement>> getCachedAdvertisements() async {
    try {
      print('Getting cached advertisements...');
      final String? cachedData = _prefs.getString(ADS_CACHE_KEY);
      if (cachedData == null || cachedData.isEmpty) {
        print('No cached advertisements found');
        return [];
      }

      final List<dynamic> adsJson = jsonDecode(cachedData);
      final ads = adsJson.map((adData) {
        final String id = adData['id'] ?? '';
        adData.remove('id');
        return Advertisement.fromFirestore(adData, id);
      }).toList();

      print('Retrieved ${ads.length} cached advertisements');
      return ads;
    } catch (e) {
      print('Error getting cached advertisements: $e');
      return [];
    }
  }

  Future<void> _updateCacheTimestamp() async {
    try {
      await _prefs.setString(
          LAST_CACHE_TIME_KEY, DateTime.now().toIso8601String());
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

  Future<void> clearCache() async {
    try {
      print('Clearing cache...');
      await _prefs.clear();
      print('Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
