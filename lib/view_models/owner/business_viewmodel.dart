import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    isLoading = true;
    notifyListeners();

    // Primero intenta cargar datos desde el caché
    await _loadStoreDataFromCache();

    try {
      // Obtener los datos de la tienda desde Firestore
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

        // Guardar los datos en caché después de obtenerlos de Firestore
        await _saveStoreDataToCache();
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching store data: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para guardar los datos en el caché
  Future<void> _saveStoreDataToCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> storeData = {
      'storeName': storeName,
      'category': category,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'storeAddress': storeAddress,
    };
    await prefs.setString('cachedStoreData', jsonEncode(storeData));
    print('Store data saved to cache.');
  }

  // Método para cargar los datos desde el caché
  Future<void> _loadStoreDataFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cachedStoreData');
    if (cachedData != null) {
      Map<String, dynamic> storeData = jsonDecode(cachedData);
      storeName = storeData['storeName'] ?? 'Unknown Store';
      category = storeData['category'] ?? 'Unknown Category';
      ownerName = storeData['ownerName'] ?? 'Unknown Owner';
      ownerEmail = storeData['ownerEmail'] ?? 'Unknown Email';
      storeAddress = storeData['storeAddress'] ?? 'Unknown Address';
      print('Loaded store data from cache.');
      notifyListeners();
    }
  }
}
