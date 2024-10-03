import 'package:flutter/material.dart';
import 'package:senecard/views/elements/customer/verticalList/advertisementElement.dart';
import 'package:senecard/views/elements/customer/verticalList/storeElement.dart';

class OffersPageViewModel extends ChangeNotifier {
  List<StoreElement> _stores = [];
  List<AdvertisementElement> _advertisements = [];

  List<StoreElement> get stores => _stores;
  List<AdvertisementElement> get advertisements => _advertisements;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  OffersPageViewModel() {
    // Initialize with test data
    _initializeTestData();
  }

  void _initializeTestData() {
    _stores = [
      const StoreElement(storeName: "Prueba 1", rating: 5),
      const StoreElement(storeName: "Prueba 2", rating: 3),
      const StoreElement(storeName: "Prueba 3", rating: 2),
      const StoreElement(storeName: "Prueba 4", rating: 1),
      const StoreElement(storeName: "Prueba 5", rating: 4),
    ];

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

  Future<void> fetchStores() async {
    // TODO: Implement fetching stores from the database
    notifyListeners();
  }

  Future<void> fetchAdvertisements() async {
    // TODO: Implement fetching advertisements from the database
    notifyListeners();
  }
}