import 'dart:async';

import 'package:flutter/material.dart';
import 'package:senecard/models/advertisement.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/services/FireStoreService.dart';
import 'package:senecard/services/cache_service.dart';
import 'package:senecard/services/connectivity_service.dart';
import 'package:senecard/views/elements/customer/verticalList/advertisementElement.dart';
import 'package:senecard/views/elements/customer/verticalList/storeElement.dart';

class OffersPageViewModel extends ChangeNotifier {
  List<StoreElement> _stores = [];
  List<AdvertisementElement> _advertisements = [];
  final FirestoreService _firestoreService = FirestoreService();
  late final CacheService _cacheService;
  Timer? _periodicTimer;

  bool _isLoading = true;
  bool _hasError = false;
  bool _isOnline = true;

  List<Store> _allStores = [];
  List<Advertisement> _allAdvertisements = [];

  List<StoreElement> get stores => _stores;
  List<AdvertisementElement> get advertisements => _advertisements;
  List<Store> get allstores => _allStores;
  List<Advertisement> get alladvertisements => _allAdvertisements;
  List<Store> _cachedStoresList = [];

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isOnline => _isOnline;
  bool _isInitialized = false;

  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription? _connectivitySubscription;

  OffersPageViewModel() {
    print('OffersPageViewModel constructor called');
    _initializeServices();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((hasConnectivity) {
      print('Connectivity changed. Has connectivity: $hasConnectivity');
      if (hasConnectivity && !_isOnline) {
        _isOnline = true;
        _initializeData();
      } else if (!hasConnectivity && _isOnline) {
        _isOnline = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    if (_isInitialized) return;

    try {
      print('Initializing services...');
      _cacheService = await CacheService.initialize();
      _isInitialized = true;
      await _initializeData();
      _startPeriodicCacheUpdate();
    } catch (e) {
      print('Error in _initializeServices: $e');
      _hasError = true;
      notifyListeners();
    }
  }

  void _startPeriodicCacheUpdate() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      if (await _cacheService.hasInternetConnection()) {
        await _fetchAndCacheData();
      }
    });
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Checking internet connection...');
      final hasInternet = await _cacheService.hasInternetConnection();
      print('Has internet: $hasInternet');
      _isOnline = hasInternet;

      print('Has internet: $hasInternet');
      print('Should update cache: ${await _cacheService.shouldUpdateCache()}');

      if (hasInternet) {
        print('Fetching data from network...');
        await _fetchAndCacheData();
      } else {
        print('Loading from cache...');
        await _loadFromCache();
      }
    } catch (e) {
      print('Error in _initializeData: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAndCacheData() async {
    try {
      print('Starting to fetch data...');
      
      // Obtener datos
      final storesFuture = _firestoreService.getStores().first;
      final adsFuture = _firestoreService.getAdvertisements().first;
      
      final results = await Future.wait([storesFuture, adsFuture]);
      
      _allStores = results[0] as List<Store>;
      _allAdvertisements = results[1] as List<Advertisement>;

      print('Fetched stores count: ${_allStores.length}');
      print('Fetched ads count: ${_allAdvertisements.length}');

      // Ordenar tiendas por rating
      _allStores.sort((a, b) => b.rating.compareTo(a.rating));
      
      // Primero actualizar las tiendas
      _updateStoreElements(_allStores);
      
      // Luego actualizar los anuncios (asegurando que tenemos las tiendas disponibles)
      _updateAdvertisementElements(_allAdvertisements);
      
      // Cachear datos si es necesario
      if (_isOnline) {
        await _cacheService.cacheTopStores(_allStores);
        await _cacheService.cacheTopAdvertisements(_allAdvertisements);
      }

      _hasError = false;
      notifyListeners();
    } catch (e) {
      print('Error in _fetchAndCacheData: $e');
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final cachedStores = await _cacheService.getCachedStores();
      final cachedAds = await _cacheService.getCachedAdvertisements();
      
      if (cachedStores.isEmpty && cachedAds.isEmpty) {
        _hasError = true;
      } else {
        _cachedStoresList = cachedStores;
        // Aseguramos que los índices sean únicos incluso al cargar desde caché
        _updateStoreElements(cachedStores);
        _updateAdvertisementElements(cachedAds);
      }
    } catch (e) {
      print('Error loading from cache: $e');
      _hasError = true;
    }
  }

  void _updateStoreElements(List<Store> stores) {
    _stores = stores.asMap().entries.map((entry) {
      final store = entry.value;
      final index = entry.key;
      return StoreElement(
        // Creamos una key única combinando id y posición
        key: ValueKey('store_${store.id}_$index'),
        storeId: store.id,
        storeName: store.name,
        rating: store.rating,
        schedule: store.schedule,
      );
    }).toList();
  }

  void _updateAdvertisementElements(List<Advertisement> ads) {
    print('Updating advertisement elements. Total ads: ${ads.length}');
    
    final Map<String, Map<dynamic, dynamic>> storeSchedules = {
      for (var store in _allStores.isEmpty ? _cachedStoresList : _allStores) 
        store.id: store.schedule
    };
    
    print('Store schedules map created for ${storeSchedules.length} stores');
    
    final availableAds = ads.where((ad) => ad.available).toList();
    print('Available ads count: ${availableAds.length}');

    _advertisements = availableAds.asMap().entries.map((entry) {
      final ad = entry.value;
      final index = entry.key;
      print('Creating advertisement element for: ${ad.title}');
      
      return AdvertisementElement(
        // Creamos una key única combinando id y posición
        key: ValueKey('ad_${ad.id}_$index'),
        image: ad.image,
        available: ad.available,
        endDate: ad.endDate,
        startDate: ad.startDate,
        storeId: ad.storeId,
        title: ad.title,
        storeSchedule: storeSchedules[ad.storeId] ?? {},
      );
    }).toList();

    print('Created ${_advertisements.length} advertisement elements');
  }

  List<StoreElement> getMoreStores() {
    if (!_isOnline) return [];
    return _allStores
        .map((store) => StoreElement(
              storeId: store.id,
              storeName: store.name,
              rating: store.rating,
              schedule: store.schedule,
            ))
        .toList();
  }

  List<AdvertisementElement> getMoreAdvertisements() {
    if (!_isOnline) return [];
    return _allAdvertisements
        .where((ad) => ad.available)
        .map((ad) => AdvertisementElement(
              image: ad.image,
              available: ad.available,
              endDate: ad.endDate,
              startDate: ad.startDate,
              storeId: ad.storeId,
              title: ad.title,
              storeSchedule: _allStores
                  .firstWhere((store) => store.id == ad.storeId)
                  .schedule,
            ))
        .toList();
  }
  Future<void> refreshData() async {
    print('Manual refresh requested');
    await _initializeData();
  }
}
