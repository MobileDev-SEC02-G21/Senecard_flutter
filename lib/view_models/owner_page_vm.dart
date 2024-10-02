import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/purchase.dart';

class OwnerPageViewModel extends ChangeNotifier {
  int customersScannedToday = 0;  // Número de clientes escaneados hoy

  // Método para obtener el número de compras filtrado por storeId y date
  Future<void> fetchCustomersScannedToday(String storeId) async {
    try {
      // Obtener la fecha actual en formato 'YYYY-MM-DD'
      final String today = DateTime.now().toIso8601String().split('T').first;

      // Consulta en Firestore filtrada por storeId y la fecha
      final querySnapshot = await FirebaseFirestore.instance
          .collection('purchases')
          .where('storeId', isEqualTo: storeId)
          .where('date', isEqualTo: today)  // Filtrar por la fecha actual
          .get();

      // El número de documentos en la consulta es el número de clientes escaneados
      customersScannedToday = querySnapshot.docs.length;
      notifyListeners();  // Notificar a la vista que hay cambios
    } catch (e) {
      print('Error fetching purchases: $e');
    }
  }
}
