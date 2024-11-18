import 'package:flutter/material.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/services/connectivity_service.dart';
import 'package:senecard/services/loyalty_cards_service.dart';

class LoyaltyCardsViewModel extends ChangeNotifier {
  final String userId;
  final List<Store> stores;
  final LoyaltyCardsService _loyaltyCardsService;
  final ConnectivityService _connectivityService = ConnectivityService();
  
  bool _isLoading = true;
  bool _hasError = false;
  bool _isOnline = true;
  List<Map<String, dynamic>> _loyaltyCards = [];

  LoyaltyCardsViewModel({
    required this.userId,
    required this.stores,
    required LoyaltyCardsService loyaltyCardsService,
  }) : _loyaltyCardsService = loyaltyCardsService {
    _initialize();
  }

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isOnline => _isOnline;
  List<Map<String, dynamic>> get loyaltyCards => _loyaltyCards;

  Future<void> _initialize() async {
    await _initializeConnectivity();
    await _loadLoyaltyCards();
  }

  Future<void> _initializeConnectivity() async {
    _isOnline = await _connectivityService.hasInternetConnection();
    _connectivityService.onConnectivityChanged.listen((hasConnectivity) {
      _isOnline = hasConnectivity;
      if (hasConnectivity) {
        _loadLoyaltyCards();
      }
      notifyListeners();
    });
  }

  Future<void> _loadLoyaltyCards() async {
    try {
      _isLoading = true;
      notifyListeners();

      _loyaltyCards = await _loyaltyCardsService.getLoyaltyCards(userId);
      _hasError = false;
    } catch (e) {
      print('Error loading loyalty cards: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (!_isOnline) return;
    await _loadLoyaltyCards();
  }

  Store getStoreForCard(Map<String, dynamic> card) {
    final storeId = card['storeId'] as String;
    try {
      return stores.firstWhere((s) => s.id == storeId);
    } catch (e) {
      // Si no encontramos la tienda, devolvemos una tienda por defecto
      return Store(
        id: storeId,
        name: 'Store Not Available',
        address: 'Address not available',
        category: '',
        rating: 0,
        image: '',
        businessOwnerId: '',
        schedule: {},
      );
    }
  }
}