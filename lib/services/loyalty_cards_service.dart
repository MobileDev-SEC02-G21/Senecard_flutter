import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class LoyaltyCardsService {
  static const String LOYALTY_CARDS_CACHE_KEY = 'cached_loyalty_cards';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static LoyaltyCardsService? _instance;
  final SharedPreferences _prefs;
  
  LoyaltyCardsService._(this._prefs);

  static Future<LoyaltyCardsService> initialize() async {
    if (_instance != null) return _instance!;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _instance = LoyaltyCardsService._(prefs);
      return _instance!;
    } catch (e) {
      print('Error initializing LoyaltyCardsService: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLoyaltyCards(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('loyaltyCards')
          .where('uniandesMemberId', isEqualTo: userId)
          .where('isCurrent', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final cards = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        await _cacheLoyaltyCards(cards);
        return cards;
      }
      return await _getCachedLoyaltyCards();
    } catch (e) {
      print('Error getting loyalty cards: $e');
      return await _getCachedLoyaltyCards();
    }
  }

  Future<void> _cacheLoyaltyCards(List<Map<String, dynamic>> cards) async {
    try {
      final encodedData = jsonEncode(cards);
      await _prefs.setString(LOYALTY_CARDS_CACHE_KEY, encodedData);
    } catch (e) {
      print('Error caching loyalty cards: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getCachedLoyaltyCards() async {
    try {
      final String? cachedData = _prefs.getString(LOYALTY_CARDS_CACHE_KEY);
      if (cachedData == null || cachedData.isEmpty) return [];
      
      List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting cached loyalty cards: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamLoyaltyCards(String userId) {
    return _firestore
        .collection('loyaltyCards')
        .where('uniandesMemberId', isEqualTo: userId)
        .where('isCurrent', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final cards = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();
          _cacheLoyaltyCards(cards);
          return cards;
        });
  }
}