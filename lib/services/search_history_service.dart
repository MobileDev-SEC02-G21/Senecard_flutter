import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchHistoryService {
  static const String SEARCH_HISTORY_KEY = 'search_history';
  static const int MAX_HISTORY_ITEMS = 5;

  static SearchHistoryService? _instance;
  final SharedPreferences _prefs;

  SearchHistoryService._(this._prefs);

  static Future<SearchHistoryService> initialize() async {
    if (_instance != null) return _instance!;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _instance = SearchHistoryService._(prefs);
      return _instance!;
    } catch (e) {
      print('Error initializing SearchHistoryService: $e');
      rethrow;
    }
  }

  Future<List<String>> getSearchHistory() async {
    try {
      final String? historyJson = _prefs.getString(SEARCH_HISTORY_KEY);
      if (historyJson == null) return [];
      
      List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.cast<String>();
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  Future<void> addSearchQuery(String query) async {
    try {
      if (query.trim().isEmpty) return;
      
      List<String> history = await getSearchHistory();
      
      history.remove(query);
      history.insert(0, query);

      if (history.length > MAX_HISTORY_ITEMS) {
        history = history.sublist(0, MAX_HISTORY_ITEMS);
      }
      
      await _prefs.setString(SEARCH_HISTORY_KEY, jsonEncode(history));
    } catch (e) {
      print('Error adding search query: $e');
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      await _prefs.remove(SEARCH_HISTORY_KEY);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  Future<void> removeSearchQuery(String query) async {
    try {
      List<String> history = await getSearchHistory();
      history.remove(query);
      await _prefs.setString(SEARCH_HISTORY_KEY, jsonEncode(history));
    } catch (e) {
      print('Error removing search query: $e');
    }
  }
}