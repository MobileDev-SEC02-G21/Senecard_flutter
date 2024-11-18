// lib/view_models/customer/qr_page_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:senecard/services/analytics_service.dart';
import 'package:senecard/services/connectivity_service.dart';
import 'package:senecard/services/qr_storage_service.dart';

class QrPageViewModel extends ChangeNotifier {
  final String userId;
  final ConnectivityService _connectivityService = ConnectivityService();
  final QRAnalyticsService _analyticsService = QRAnalyticsService();
  late final QrStorageService _qrStorageService;
  
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String? _storedUserId;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String? get storedUserId => _storedUserId;

  QrPageViewModel({required this.userId}) {
    print('QrPageViewModel constructor - userId: $userId');
    initializeViewModel();
  }

  Future<void> initializeViewModel() async {
    try {
      print('Initializing QrPageViewModel services');
      _qrStorageService = await QrStorageService.initialize();
      await _initializeQR();
      _isInitialized = true;
      notifyListeners();
      print('QrPageViewModel initialization complete');
    } catch (e) {
      print('Error in QrPageViewModel initialization: $e');
      _hasError = true;
      _errorMessage = 'Error initializing QR services';
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _initializeQR() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Initializing QR for userId: $userId');
      _storedUserId = await _qrStorageService.getStoredUserId();
      
      if (_storedUserId == null || _storedUserId != userId) {
        final hasInternet = await _connectivityService.hasInternetConnection();
        
        if (!hasInternet) {
          throw Exception('No internet connection available');
        }

        await _qrStorageService.storeUserId(userId);
        _storedUserId = userId;
        print('Updated stored userId: $userId');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error in _initializeQR: $e');
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshQR() async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      _hasError = true;
      _errorMessage = 'No internet available to refresh the QR code';
      notifyListeners();
      return;
    }
    
    await _qrStorageService.clearStoredUserId();
    await _initializeQR();
  }

  Future<void> logQRRenderTime(int renderTimeMs) async {
    try {
      final hasInternet = await _connectivityService.hasInternetConnection();
      
      if (!hasInternet) {
        print('Skipping QR render time logging: No internet connection');
        return;
      }

      await _analyticsService.logQRRenderTime(
        userId: userId,
        renderTimeMs: renderTimeMs,
      );
      
      print('Logged QR render time: $renderTimeMs ms for user: $userId');
    } catch (e) {
      print('Error logging QR render time: $e');
    }
  }
}