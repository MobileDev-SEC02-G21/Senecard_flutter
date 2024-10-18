import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para obtener información del QR escaneado
  Future<Map<String, dynamic>> getQrInfo(String userId, String storeId) async {
    try {
      // Obtener el nombre del usuario por su userId
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();

      if (!userSnapshot.exists) {
        throw Exception("User not found");
      }

      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      String name = userData['name'] ?? 'Unknown';

      // Obtener la cantidad de loyaltyCards que tiene el usuario en esa tienda
      QuerySnapshot loyaltyCardsSnapshot = await _firestore
          .collection('loyaltyCards')
          .where('uniandesMemberId', isEqualTo: userId)
          .where('storeId', isEqualTo: storeId)
          .get();

      // Contar la cantidad de tarjetas de lealtad (cardsRedeemed)
      int cardsRedeemed = loyaltyCardsSnapshot.size;

      if (loyaltyCardsSnapshot.docs.isEmpty) {
        throw Exception("No loyalty card found for this user and store");
      }

      DocumentSnapshot loyaltyCard = loyaltyCardsSnapshot.docs.first;

      // Extraer los puntos y el máximo de puntos de la loyaltyCard
      Map<String, dynamic> loyaltyCardData = loyaltyCard.data() as Map<String, dynamic>;
      int points = loyaltyCardData['points'] ?? 0;
      int maxPoints = loyaltyCardData['maxPoints'] ?? 10;
      bool canRedeem = points >= maxPoints;

      return {
        'name': name,
        'points': points,
        'maxPoints': maxPoints,
        'cardsRedeemed': cardsRedeemed,  // Agregar cardsRedeemed
        'canRedeem': canRedeem,
      };
    } catch (e) {
      print('Error fetching QR info: $e');
      throw e;
    }
  }

  // Método para hacer un sello y agregar un punto a la loyaltyCard del usuario
  Future<void> makeStamp(String userId, String storeId) async {
    try {
      // Buscar la loyaltyCard que coincida con userId y storeId
      QuerySnapshot loyaltyCardsSnapshot = await _firestore
          .collection('loyaltyCards')
          .where('uniandesMemberId', isEqualTo: userId)
          .where('storeId', isEqualTo: storeId)
          .limit(1)
          .get();

      if (loyaltyCardsSnapshot.docs.isEmpty) {
        throw Exception("No loyalty card found for this user and store");
      }

      DocumentSnapshot loyaltyCard = loyaltyCardsSnapshot.docs.first;

      // Obtener los puntos actuales
      int points = (loyaltyCard.data() as Map<String, dynamic>)['points'] ?? 0;

      // Sumar 1 a los puntos actuales
      points += 1;

      // Actualizar la tarjeta de lealtad con los nuevos puntos
      await _firestore.collection('loyaltyCards').doc(loyaltyCard.id).update({
        'points': points,
      });

      print("Stamp added successfully.");
      notifyListeners();
    } catch (e) {
      print("Error adding stamp: $e");
      throw e;
    }
  }
}
