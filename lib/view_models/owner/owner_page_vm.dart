import 'package:flutter/material.dart';
import 'package:senecard/services/FireStoreService.dart';
import 'package:senecard/models/purchase.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/models/advertisement.dart';

class OwnerPageViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();  

  
  int customersScannedToday = 0;
  double storeRating = 0.0;
  int activeAdvertisements = 0;

  bool _isLoading = true;  
  bool get isLoading => _isLoading;

  OwnerPageViewModel() {
    
  }

  
  Future<void> initializeData(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchCustomersScannedToday(storeId),  
        fetchStoreRating(storeId),            
        fetchActiveAdvertisements(storeId),   
      ]);
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> fetchCustomersScannedToday(String storeId) async {
    try {
      
      List<String> loyaltyCardIds = await _firestoreService.getLoyaltyCardIdsByStore(storeId);

      if (loyaltyCardIds.isEmpty) {
        customersScannedToday = 0;
        notifyListeners();
        return;
      }

      
      final String today = DateTime.now().toIso8601String().split('T').first;

      
      customersScannedToday = await _firestoreService.getPurchasesByLoyaltyCardIdsAndDate(loyaltyCardIds, today);

      print('Number of customers scanned today: $customersScannedToday');
    } catch (e) {
      print('Error fetching customers scanned today: $e');
    }
    notifyListeners();
  }

  
  Future<void> fetchStoreRating(String storeId) async {
    try {
      
      storeRating = await _firestoreService.getStoreRating(storeId);

      print('Store rating: $storeRating');
    } catch (e) {
      print('Error fetching store rating: $e');
    }
    notifyListeners();
  }

  
  Future<void> fetchActiveAdvertisements(String storeId) async {
    try {
      
      activeAdvertisements = await _firestoreService.getActiveAdvertisements(storeId);

      print('Active advertisements: $activeAdvertisements');
    } catch (e) {
      print('Error fetching active advertisements: $e');
    }
    notifyListeners();
  }
}
