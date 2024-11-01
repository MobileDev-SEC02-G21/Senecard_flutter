import 'dart:async';
import 'package:flutter/material.dart';
import 'package:senecard/models/advertisement.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/services/FireStoreService.dart';
import 'package:senecard/services/FirebaseAuthService.dart';
import 'package:senecard/services/cache_service.dart';
import 'package:senecard/services/connectivity_service.dart';

class MainPageViewmodel extends ChangeNotifier {

  final String _userId = FirebaseAuthService().currentUserId??'';
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

  // Services
  final FirestoreService _firestoreService = FirestoreService();
  late final CacheService _cacheService;
  final ConnectivityService _connectivityService = ConnectivityService();

  // Control flags
  bool _isInitialized = false;
  bool _isRefreshing = false;

  // Getters
  List<Store> get stores => List.unmodifiable(_stores);
  List<Advertisement> get advertisements => List.unmodifiable(_advertisements);
  String get userId => _userId;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isOnline => _isOnline;
  String get screenWidget => _screenWidget;
  bool get searchBarVisible => _searchBarVisible;
  Icon get icon => _icon;
  bool get buttonMenu => _buttonMenu;

  // Subscriptions
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _storesSubscription;
  StreamSubscription? _advertisementsSubscription;
  Timer? _periodicTimer;

  MainPageViewmodel() {
    _initializeOnce();
  }

  Future<void> _initializeOnce() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      _cacheService = await CacheService.initialize();
      await _initializeConnectivity();
      await _initializeData();
      _startPeriodicCacheUpdate();
    } catch (e) {
      print('Error in initialization: $e');
      _handleError();
    }
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

  Future<void> _initializeConnectivity() async {
    _isOnline = await _connectivityService.hasInternetConnection();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen(
      (hasConnectivity) async {
        final wasOffline = !_isOnline;
        _isOnline = hasConnectivity;

        if (hasConnectivity && wasOffline && !_isRefreshing) {
          await refreshData();
        }
        notifyListeners();
      },
    );
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isOnline) {
        await _setupStreamSubscriptions();
      } else {
        await _loadFromCache();
      }
    } catch (e) {
      print('Error in data initialization: $e');
      await _loadFromCache();
    }
  }

  Future<void> refreshData() async {
    if (!_isOnline || _isRefreshing) return;

    try {
      _isRefreshing = true;
      _isLoading = true;
      notifyListeners();

      await _cancelSubscriptions();
      await _setupStreamSubscriptions();
      
      _isLoading = false;
      _hasError = false;
    } catch (e) {
      print('Error refreshing data: $e');
      _handleError();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> _setupStreamSubscriptions() async {
    await _cancelSubscriptions();

    _storesSubscription = _firestoreService.getStores().listen(
      (newStores) {
        _stores = newStores..sort((a, b) => b.rating.compareTo(a.rating));
        _cacheService.cacheStores(_stores);
        _updateLoadingState();
      },
      onError: (e) async {
        print('Error in stores stream: $e');
        await _loadFromCache();
      },
    );

    _advertisementsSubscription = _firestoreService.getAdvertisements().listen(
      (newAds) {
        _advertisements = newAds;
        _cacheService.cacheAdvertisements(_advertisements);
        _updateLoadingState();
      },
      onError: (e) async {
        print('Error in advertisements stream: $e');
        await _loadFromCache();
      },
    );
  }

  void _updateLoadingState() {
    if (_stores.isNotEmpty || _advertisements.isNotEmpty) {
      _isLoading = false;
      _hasError = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final cachedStores = await _cacheService.getCachedStores();
      final cachedAds = await _cacheService.getCachedAdvertisements();

      if (cachedStores.isNotEmpty) _stores = cachedStores;
      if (cachedAds.isNotEmpty) _advertisements = cachedAds;

      _hasError = cachedStores.isEmpty && cachedAds.isEmpty;
    } catch (e) {
      print('Error loading from cache: $e');
      _handleError();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleError() {
    _hasError = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _cancelSubscriptions() async {
    await _storesSubscription?.cancel();
    await _advertisementsSubscription?.cancel();
    _storesSubscription = null;
    _advertisementsSubscription = null;
  }

  void _startPeriodicCacheUpdate() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      if (_isOnline && !_isRefreshing) {
        await refreshData();
      }
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _connectivitySubscription?.cancel();
    _cancelSubscriptions();
    _isInitialized = false;
    super.dispose();
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

}
