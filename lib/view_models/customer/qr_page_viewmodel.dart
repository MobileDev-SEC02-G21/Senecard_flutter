import 'package:flutter/material.dart';
import 'package:senecard/services/FireStoreService.dart';

class QrPageViewModel extends ChangeNotifier {
  String _userId = "https://www.youtube.com/watch?v=xvFZjo5Pg0";
  final FirestoreService _firestoreService = FirestoreService();

  String get userId => _userId;

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  Future<void> logQrRenderTime() async {
    // Captura el tiempo inicial antes de renderizar
    final startTime = DateTime.now();

    // Simulación de alguna carga o proceso
    await Future.delayed(const Duration(milliseconds: 500)); // Puedes ajustar esto según sea necesario.

    // Captura el tiempo final después de renderizar
    final endTime = DateTime.now();
    final renderTime = endTime.difference(startTime).inMilliseconds;

    // Guarda el tiempo de renderizado en Firestore
    await _firestoreService.logQrRenderTime(_userId, startTime, endTime, renderTime);
  }
  
}