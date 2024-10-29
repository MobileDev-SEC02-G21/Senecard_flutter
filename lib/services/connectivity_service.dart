import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker = InternetConnectionChecker();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  Future<bool> hasInternetConnection() async {
    try {
      // Primero verificamos si hay una conexión de red
      final connectivityResult = await _connectivity.checkConnectivity();
      print('Connectivity result: $connectivityResult');
      
      if (connectivityResult == ConnectivityResult.none) {
        print('No network connectivity');
        return false;
      }

      // Luego verificamos si realmente hay acceso a internet
      final hasInternet = await _internetChecker.hasConnection;
      print('Internet access check result: $hasInternet');
      
      return hasInternet;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((status) {
      print('Connectivity status changed: $status');
      return status != ConnectivityResult.none;
    });
  }
}