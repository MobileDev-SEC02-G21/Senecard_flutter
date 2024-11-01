import 'package:flutter/material.dart';
import 'package:senecard/services/FireStoreService.dart';

class QrPageViewModel extends ChangeNotifier {
  final String userId;
  final FirestoreService _firestoreService = FirestoreService();

  QrPageViewModel({required this.userId});

  Future<void> logQrRenderTime() async {
    // Captura el tiempo inicial antes de renderizar
    final startTime = DateTime.now();

    // Simulación de alguna carga o proceso
    await Future.delayed(const Duration(
        milliseconds: 500)); // Puedes ajustar esto según sea necesario.

    // Captura el tiempo final después de renderizar
    final endTime = DateTime.now();
    final renderTime = endTime.difference(startTime).inMilliseconds;

    // Guarda el tiempo de renderizado en Firestore
    await _firestoreService.logQrRenderTime(
        userId, startTime, endTime, renderTime);
  }
}
