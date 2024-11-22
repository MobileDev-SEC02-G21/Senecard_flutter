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

      // Obtener las tarjetas de lealtad del usuario en esta tienda
      QuerySnapshot loyaltyCardsSnapshot = await _firestore
          .collection('loyaltyCards')
          .where('uniandesMemberId', isEqualTo: userId)
          .where('storeId', isEqualTo: storeId)
          .get();

      // Si no se encuentra ninguna tarjeta, crear una nueva
      if (loyaltyCardsSnapshot.docs.isEmpty) {
        print("No loyalty card found. Creating a new one for userId: $userId, storeId: $storeId");

        DocumentReference newCardRef = await _firestore.collection('loyaltyCards').add({
          'isCurrent': true,
          'maxPoints': 10,
          'points': 0,
          'storeId': storeId,
          'uniandesMemberId': userId,
        });

        print("New loyalty card created with ID: ${newCardRef.id}");

        // Retornar la información de la nueva tarjeta
        return {
          'name': name,
          'points': 5, // Puntos iniciales
          'maxPoints': 10,
          'cardsRedeemed': 0, // Nueva tarjeta, sin tarjetas redimidas
          'canRedeem': false, // No puede redimir aún
        };
      }

      // Si se encuentra una tarjeta, continuar con el proceso normal
      DocumentSnapshot loyaltyCard = loyaltyCardsSnapshot.docs.first;

      // Extraer los datos de la tarjeta encontrada
      Map<String, dynamic> loyaltyCardData = loyaltyCard.data() as Map<String, dynamic>;
      int points = loyaltyCardData['points'] ?? 0;
      int maxPoints = loyaltyCardData['maxPoints'] ?? 10;
      bool canRedeem = points >= maxPoints;

      return {
        'name': name,
        'points': points,
        'maxPoints': maxPoints,
        'cardsRedeemed': loyaltyCardsSnapshot.size,
        'canRedeem': canRedeem,
      };
    } catch (e) {
      print('Error fetching QR info: $e');
      throw e;
    }
  }


  Future<void> redeemLoyaltyCard(String userId, String storeId) async {
    try {
      // Buscar la loyaltyCard que coincida con userId y storeId
      QuerySnapshot loyaltyCardsSnapshot = await _firestore
          .collection('loyaltyCards')
          .where('uniandesMemberId', isEqualTo: userId)
          .where('storeId', isEqualTo: storeId)
          .where('isCurrent', isEqualTo: true) // Asegurarse de que sea la tarjeta actual
          .limit(1)
          .get();

      if (loyaltyCardsSnapshot.docs.isEmpty) {
        throw Exception("No loyalty card found for this user and store");
      }

      DocumentSnapshot loyaltyCard = loyaltyCardsSnapshot.docs.first;

      // Cambiar la tarjeta actual a no actual (current: false)
      await _firestore.collection('loyaltyCards').doc(loyaltyCard.id).update({
        'current': false,
      });

      // Obtener datos relevantes de la tarjeta de lealtad actual
      Map<String, dynamic> loyaltyCardData = loyaltyCard.data() as Map<String, dynamic>;
      int maxPoints = loyaltyCardData['maxPoints'] ?? 10;
      String uniandesMemberId = loyaltyCardData['uniandesMemberId'];

      // Crear una nueva tarjeta de lealtad con los mismos atributos, pero reiniciando los puntos
      await _firestore.collection('loyaltyCards').add({
        'current': true,
        'maxPoints': maxPoints,
        'points': 0, // Puntos reiniciados
        'storeId': storeId,
        'uniandesMemberId': uniandesMemberId,
      });

      print("Loyalty card redeemed and new loyalty card created successfully.");
      notifyListeners();
    } catch (e) {
      print("Error redeeming loyalty card: $e");
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

      // Crear un nuevo documento de compra en la colección 'purchases'
      await _firestore.collection('purchases').add({
        'date': DateTime.now().toIso8601String().split('T').first,  // Fecha actual
        'isEligible': true,
        'loyaltyCardId': loyaltyCard.id,  // ID de la tarjeta de lealtad
        'rating': 5,  // Puedes ajustar esto según las necesidades
      });

      print("Stamp added and purchase recorded successfully.");
      notifyListeners();
    } catch (e) {
      print("Error adding stamp and recording purchase: $e");
      throw e;
    }
  }

}
