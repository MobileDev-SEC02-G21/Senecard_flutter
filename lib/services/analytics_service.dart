import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senecard/services/connectivity_service.dart';

class QRAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String COLLECTION_NAME = 'AnalyticsBusinessQuestions/sprint2/businessQuestionQR';

  Future<void> logQRRenderTime({
    required String userId,
    required int renderTimeMs,
  }) async {
    try {
      // Verificar conectividad antes de intentar subir datos
      final hasInternet = await _connectivityService.hasInternetConnection();
      
      if (!hasInternet) {
        print('Skipping QR analytics logging: No internet connection');
        return;
      }

      await _firestore.collection(COLLECTION_NAME).add({
        'userId': userId,
        'qr_rtime': renderTimeMs,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Successfully logged QR render time: $renderTimeMs ms for user: $userId');
    } catch (e) {
      print('Error logging QR analytics: $e');
    }
  }
}

class LanguageAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService = ConnectivityService();
  static const String COLLECTION_NAME = 'AnalyticsBusinessQuestions/sprint4/businessQuestion5';

  Future<void> logLanguageChange({
    required String userId,
    required String language,
  }) async {
    try {
      final hasInternet = await _connectivityService.hasInternetConnection();
      
      if (!hasInternet) {
        print('Skipping language analytics logging: No internet connection');
        return;
      }

      await _firestore.collection(COLLECTION_NAME).add({
        'userId': userId,
        'lan': language,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Successfully logged language change to $language for user: $userId');
    } catch (e) {
      print('Error logging language analytics: $e');
    }
  }
}