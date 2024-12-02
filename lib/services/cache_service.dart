import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/models/advertisement.dart';

class CacheService {
  static const String STORES_CACHE_KEY = 'cached_stores';
  static const String ADS_CACHE_KEY = 'cached_advertisements';
  static const Duration CACHE_DURATION = Duration(days: 1);

  static CacheService? _instance;
  final DefaultCacheManager _cacheManager;

  CacheService._() : _cacheManager = DefaultCacheManager();

  static Future<CacheService> initialize() async {
    if (_instance != null) return _instance!;

    try {
      _instance = CacheService._();
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
        return storeMap;
      }).toList();
      
      final encodedData = jsonEncode(storesData);
      final bytes = Uint8List.fromList(encodedData.codeUnits);
      
      await _cacheManager.putFile(
        STORES_CACHE_KEY,
        bytes,
        key: STORES_CACHE_KEY,
        maxAge: CACHE_DURATION,
      );
      print('Stores cached successfully');
    } catch (e) {
      print('Error caching stores: $e');
    }
  }

  Future<void> cacheAdvertisements(List<Advertisement> ads) async {
    try {
      print('Caching ${ads.length} advertisements...');
      final availableAds = ads.where((ad) => ad.available).toList();
      final adsData = availableAds.map((ad) {
        final adMap = ad.toFirestore();
        adMap['id'] = ad.id;
        return adMap;
      }).toList();
      
      final encodedData = jsonEncode(adsData);
      final bytes = Uint8List.fromList(encodedData.codeUnits);
      
      await _cacheManager.putFile(
        ADS_CACHE_KEY,
        bytes,
        key: ADS_CACHE_KEY,
        maxAge: CACHE_DURATION,
      );
      print('Advertisements cached successfully');
    } catch (e) {
      print('Error caching advertisements: $e');
    }
  }

  Future<List<Store>> getCachedStores() async {
    try {
      print('Getting cached stores...');
      final fileInfo = await _cacheManager.getFileFromCache(STORES_CACHE_KEY);
      
      if (fileInfo == null) {
        print('No cached stores found');
        return [];
      }

      if (fileInfo.validTill.isBefore(DateTime.now())) {
        print('Cached stores expired');
        await _cacheManager.removeFile(STORES_CACHE_KEY);
        return [];
      }

      final cachedJson = await fileInfo.file.readAsString();
      final List<dynamic> storesJson = jsonDecode(cachedJson);
      
      final stores = storesJson.map((storeData) {
        final String id = storeData['id'];
        storeData.remove('id');
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
      final fileInfo = await _cacheManager.getFileFromCache(ADS_CACHE_KEY);
      
      if (fileInfo == null) {
        print('No cached advertisements found');
        return [];
      }

      if (fileInfo.validTill.isBefore(DateTime.now())) {
        print('Cached advertisements expired');
        await _cacheManager.removeFile(ADS_CACHE_KEY);
        return [];
      }

      final cachedJson = await fileInfo.file.readAsString();
      final List<dynamic> adsJson = jsonDecode(cachedJson);
      
      final ads = adsJson.map((adData) {
        final String id = adData['id'];
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
      await _cacheManager.emptyCache();
      print('Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}