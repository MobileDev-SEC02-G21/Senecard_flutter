import 'package:flutter/material.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/models/advertisement.dart';
import 'package:senecard/services/search_history_service.dart';

class SearchViewModel extends ChangeNotifier {
  final List<Store> stores;
  final List<Advertisement> ads;
  final SearchHistoryService _searchHistoryService;
  
  List<String> _searchHistory = [];
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  SearchViewModel({
    required this.stores,
    required this.ads,
    required SearchHistoryService searchHistoryService,
  }) : _searchHistoryService = searchHistoryService {
    _initializeHistory();
  }

  List<String> get searchHistory => _searchHistory;
  List<dynamic> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> _initializeHistory() async {
    _isLoading = true;
    notifyListeners();
    
    _searchHistory = await _searchHistoryService.getSearchHistory();
    
    _isLoading = false;
    notifyListeners();
  }

  // Método para realizar búsqueda sin guardar en historial
  Future<void> searchOnly(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    if (query.isEmpty) {
      _searchResults = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Search in stores
    final matchingStores = stores.where((store) =>
        store.name.toLowerCase().contains(query.toLowerCase()) ||
        store.category.toLowerCase().contains(query.toLowerCase())).toList();

    // Search in ads
    final matchingAds = ads.where((ad) =>
        ad.title.toLowerCase().contains(query.toLowerCase()) ||
        ad.description.toLowerCase().contains(query.toLowerCase())).toList();

    // Combine results
    _searchResults = [...matchingStores, ...matchingAds];

    _isLoading = false;
    notifyListeners();
  }

  // Método para guardar en historial
  Future<void> saveToHistory(String query) async {
    if (query.trim().isEmpty) return;
    await _searchHistoryService.addSearchQuery(query);
    await _initializeHistory();
  }

  Future<void> removeFromHistory(String query) async {
    await _searchHistoryService.removeSearchQuery(query);
    await _initializeHistory();
  }

  Future<void> clearHistory() async {
    await _searchHistoryService.clearSearchHistory();
    await _initializeHistory();
  }

  String getItemTitle(dynamic item) {
    if (item is Store) {
      return item.name;
    } else if (item is Advertisement) {
      return item.title;
    }
    return '';
  }

  String getItemSubtitle(dynamic item) {
    if (item is Store) {
      return item.category;
    } else if (item is Advertisement) {
      final store = stores.firstWhere(
        (s) => s.id == item.storeId,
        orElse: () => Store(
          id: '',
          name: 'Unknown Store',
          address: '',
          category: '',
          rating: 0,
          image: '',
          businessOwnerId: '',
          schedule: {},
        ),
      );
      return store.name;
    }
    return '';
  }

  String getItemImage(dynamic item) {
    if (item is Store) {
      return item.image;
    } else if (item is Advertisement) {
      return item.image;
    }
    return '';
  }

  bool isStore(dynamic item) => item is Store;
}