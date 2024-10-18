import 'package:flutter/material.dart';
import 'package:senecard/services/FireStoreService.dart';
import 'package:senecard/views/elements/customer/verticalList/advertisementElement.dart';
import 'package:senecard/views/elements/customer/verticalList/storeElement.dart';

class OffersPageViewModel extends ChangeNotifier {
  List<StoreElement> _stores = [];
  List<AdvertisementElement> _advertisements = [];
  final FirestoreService _firestoreService = FirestoreService();

  List<StoreElement> get stores => _stores;
  List<AdvertisementElement> get advertisements => _advertisements;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  OffersPageViewModel() {
    print('OffersPageViewModel constructor called');
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchStores(),
        fetchAdvertisements(),
      ]);
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStores() async {
    try {
      final storeList = await _firestoreService.getStores().first;
      storeList.sort((a, b) => (b.rating).compareTo(a.rating));
      print('Received store list. Count: ${storeList.length}');
      _stores = storeList.map((store) {
        print('Creating StoreElement for: ${store.name}');
        return StoreElement(
          storeName: store.name,
          rating: store.rating,
          // Add other necessary properties here
        );
      }).toList();
      print('Updated _stores. New count: ${_stores.length}');
    } catch (e) {
      print('Error fetching stores: $e');
    }
  }

  Future<void> fetchAdvertisements() async {
    // For now, we'll use the test data
    _advertisements = [
      const AdvertisementElement(
          image: "https://media.istockphoto.com/id/1270770086/photo/commercial-buildings-view-from-low-angle.jpg?s=612x612&w=0&k=20&c=auL9cSRdLJjujIhq7anW0wZi_j-1EzFpv6OhvSBMQQY="),
      const AdvertisementElement(
          image: "https://media.istockphoto.com/id/1270770086/photo/commercial-buildings-view-from-low-angle.jpg?s=612x612&w=0&k=20&c=auL9cSRdLJjujIhq7anW0wZi_j-1EzFpv6OhvSBMQQY="),
      const AdvertisementElement(
          image: "https://media.istockphoto.com/id/1270770086/photo/commercial-buildings-view-from-low-angle.jpg?s=612x612&w=0&k=20&c=auL9cSRdLJjujIhq7anW0wZi_j-1EzFpv6OhvSBMQQY="),
    ];
    notifyListeners();
  }
}