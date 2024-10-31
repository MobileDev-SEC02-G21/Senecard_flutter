import 'dart:async';
import 'package:flutter/material.dart';
import 'package:senecard/models/advertisement.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/services/FireStoreService.dart';
import 'package:senecard/services/cache_service.dart';
import 'package:senecard/services/connectivity_service.dart';

class MainPageViewmodel extends ChangeNotifier {
  // State
  final String _userId = "1Lp1RRd1uo11fgfIsFMU";
  String _screenWidget = 'offers-screen';
  bool _searchBarVisible = true;
  Icon _icon = const Icon(Icons.menu);
  bool _buttonMenu = true;

  // Data
  List<Store> _stores = [];
  List<Advertisement> _advertisements = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isOnline = true;

  // Subscriptions
  bool _subscriptionsActive = false;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _storesSubscription;
  StreamSubscription? _advertisementsSubscription;
  Timer? _periodicTimer;

  final FirestoreService _firestoreService = FirestoreService();
  late final CacheService _cacheService;
  final ConnectivityService _connectivityService = ConnectivityService();

  // Getters
  // Getters que devuelven copias inmutables
  List<Store> get stores => List.unmodifiable(_stores);
  List<Advertisement> get advertisements => List.unmodifiable(_advertisements);
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isOnline => _isOnline;
  String get screenWidget => _screenWidget;
  bool get searchBarVisible => _searchBarVisible;
  Icon get icon => _icon;
  bool get buttonMenu => _buttonMenu;


  static bool _instanceExists = false;
  bool _initialized = false;

  MainPageViewmodel() {
    if (_instanceExists) {
      print('WARNING: Multiple instances of MainPageViewModel being created!');
    }
    _instanceExists = true;
    print('MainPageViewModel constructor called');
    _initializeOnce();
  }

  Future<void> _initializeOnce() async {
    if (_initialized) {
      print('MainPageViewModel already initialized, skipping');
      return;
    }

    print('Starting MainPageViewModel initialization');
    _initialized = true;
    await _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      print('Initializing services...');
      _cacheService = await CacheService.initialize();
      
      // Configurar el listener de conectividad una sola vez
      _setupConnectivityListener();
      
      // Inicializar datos
      await _initializeData();
      
      // Configurar el timer de actualización de caché
      _startPeriodicCacheUpdate();
      
      print('Services initialized successfully');
    } catch (e) {
      print('Error in _initializeServices: $e');
      _hasError = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((hasConnectivity) async {
      print('Connectivity changed. Has connectivity: $hasConnectivity');
      
      final wasOffline = !_isOnline;
      _isOnline = hasConnectivity;
      
      if (hasConnectivity && wasOffline) {
        print('Recovering from offline state, refreshing data...');
        _isLoading = true;
        notifyListeners();
        
        // Cancelar suscripciones existentes antes de crear nuevas
        await _cancelExistingSubscriptions();
        
        // Recargar datos
        await _setupStreamSubscriptions();
      } else if (!hasConnectivity) {
        print('Device went offline, loading from cache...');
        await _loadFromCache();
      }
      
      notifyListeners();
    });
  }

  Future<void> _cancelExistingSubscriptions() async {
    print('Canceling existing subscriptions...');
    await _storesSubscription?.cancel();
    await _advertisementsSubscription?.cancel();
    _storesSubscription = null;
    _advertisementsSubscription = null;
  }

  void _startPeriodicCacheUpdate() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      if (await _cacheService.hasInternetConnection()) {
        await _fetchAndCacheData();
      }
    });
  }

  Future<void> _fetchAndCacheData() async {
    if (!_isOnline) return;

    try {
      print('Fetching and caching data...');

      // Obtener datos más recientes
      final storesFuture = _firestoreService.getStores().first;
      final adsFuture = _firestoreService.getAdvertisements().first;

      final results = await Future.wait([storesFuture, adsFuture]);

      final newStores = results[0] as List<Store>;
      final newAds = results[1] as List<Advertisement>;

      // Actualizar datos en memoria
      _stores = newStores..sort((a, b) => b.rating.compareTo(a.rating));
      _advertisements = newAds;

      // Actualizar caché
      await Future.wait([
        _cacheService.cacheStores(_stores),
        _cacheService.cacheAdvertisements(_advertisements)
      ]);

      _hasError = false;
      _isLoading = false;
      notifyListeners();

      print('Data fetched and cached successfully');
    } catch (e) {
      print('Error in _fetchAndCacheData: $e');
      // Si falla el fetch, intentamos cargar desde caché
      await _loadFromCache();
    }
  }

  Future<void> _initializeData() async {
    print('Initializing data...');
    _isLoading = true;
    notifyListeners();

    try {
      final hasInternet = await _cacheService.hasInternetConnection();
      _isOnline = hasInternet;

      if (hasInternet) {
        await _setupStreamSubscriptions();
        await _fetchAndCacheData();
      } else {
        await _loadFromCache();
      }
    } catch (e) {
      print('Error in _initializeData: $e');
      _hasError = true;
      await _loadFromCache();
    }
  }

  Future<void> _setupStreamSubscriptions() async {
    if (_subscriptionsActive) {
      print('Subscriptions already active, skipping setup');
      return;
    }

    print('Setting up stream subscriptions...');
    await _cancelExistingSubscriptions();

    try {
      _subscriptionsActive = true;

      // Suscripción a stores
      _storesSubscription = _firestoreService.getStores().listen(
        (stores) {
          print('Received ${stores.length} stores');
          if (!_subscriptionsActive) return;
          
          _stores = List<Store>.from(stores)
            ..sort((a, b) => b.rating.compareTo(a.rating));
          
          if (_isOnline) {
            _cacheService.cacheStores(_stores);
          }
          
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          print('Error in stores stream: $error');
          if (!_subscriptionsActive) return;
          _loadFromCache();
        },
      );

      // Suscripción a advertisements
      _advertisementsSubscription = _firestoreService.getAdvertisements().listen(
        (advertisements) {
          print('Received ${advertisements.length} advertisements');
          if (!_subscriptionsActive) return;
          
          _advertisements = List<Advertisement>.from(advertisements);
          
          if (_isOnline) {
            _cacheService.cacheAdvertisements(_advertisements);
          }
          
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          print('Error in advertisements stream: $error');
          if (!_subscriptionsActive) return;
          _loadFromCache();
        },
      );
    } catch (e) {
      print('Error setting up stream subscriptions: $e');
      _subscriptionsActive = false;
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      print('Loading data from cache...');
      _isLoading = true;
      notifyListeners();

      final cachedStores = await _cacheService.getCachedStores();
      final cachedAds = await _cacheService.getCachedAdvertisements();
      
      print('Loaded from cache: ${cachedStores.length} stores, ${cachedAds.length} ads');
      
      // Solo actualizamos los datos si tenemos algo en el caché
      if (cachedStores.isNotEmpty) {
        _stores = cachedStores;
      }
      if (cachedAds.isNotEmpty) {
        _advertisements = cachedAds;
      }
      
      // Marcamos error solo si ambas listas están vacías
      _hasError = cachedStores.isEmpty && cachedAds.isEmpty;
      
    } catch (e) {
      print('Error loading from cache: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onRefresh() async {
    print('Manual refresh requested');
    if (!_isOnline) {
      print('Cannot refresh: device is offline');
      return;
    }

    _isLoading = true;
    notifyListeners();

    await _cancelExistingSubscriptions();
    await _setupStreamSubscriptions();
  }

  // Navigation methods
  void startOver() {
    _screenWidget = 'offers-screen';
    _searchBarVisible = true;
    _icon = const Icon(Icons.menu);
    _buttonMenu = true;
    notifyListeners();
  }

  void switchQRScreen() {
    _screenWidget = 'qr-screen';
    _searchBarVisible = false;
    _icon = const Icon(Icons.arrow_back_ios_new);
    _buttonMenu = false;
    notifyListeners();
  }

  void switchStoresScreen() {
    _isLoading = false;
    _screenWidget = 'stores-screen';
    _searchBarVisible = true;
    _icon = const Icon(Icons.arrow_back_ios_new);
    _buttonMenu = false;
    notifyListeners();
  }

  void switchAdvertisementScreen() {
    _isLoading = false;
    _screenWidget = 'ads-screen';
    _searchBarVisible = true;
    _icon = const Icon(Icons.arrow_back_ios_new);
    _buttonMenu = false;
    notifyListeners();
  }

  @override
  void dispose() {
    print('Disposing MainPageViewModel');
    _instanceExists = false;
    _initialized = false;
    _subscriptionsActive = false;
    _periodicTimer?.cancel();
    _connectivitySubscription?.cancel();
    _storesSubscription?.cancel();
    _advertisementsSubscription?.cancel();
    super.dispose();
  }
}
