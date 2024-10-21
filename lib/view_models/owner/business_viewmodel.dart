import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusinessInfoViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String storeName = '';
  String category = '';
  String ownerName = '';
  String ownerEmail = '';
  String storeAddress = '';
  bool isLoading = true;

  // Método para obtener los datos del negocio
  Future<void> fetchStoreData(String storeId) async {
    try {
      isLoading = true;
      notifyListeners();

      // Obtener los datos de la tienda
      DocumentSnapshot storeSnapshot = await _firestore.collection('stores').doc(storeId).get();

      if (storeSnapshot.exists) {
        Map<String, dynamic> storeData = storeSnapshot.data() as Map<String, dynamic>;

        storeName = storeData['name'] ?? 'Unknown Store';
        category = storeData['category'] ?? 'Unknown Category';
        storeAddress = storeData['address'] ?? 'Unknown Address';

        // Obtener el businessOwnerId de la tienda
        String businessOwnerId = storeData['businessOwnerId'] ?? '';

        // Obtener los datos del dueño del negocio si existe
        if (businessOwnerId.isNotEmpty) {
          DocumentSnapshot ownerSnapshot = await _firestore.collection('users').doc(businessOwnerId).get();
          if (ownerSnapshot.exists) {
            Map<String, dynamic> ownerData = ownerSnapshot.data() as Map<String, dynamic>;
            ownerName = ownerData['name'] ?? 'Unknown Owner';
            ownerEmail = ownerData['email'] ?? 'Unknown Email';
          }
        }
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching store data: $e');
      isLoading = false;
      notifyListeners();
    }
  }
}
