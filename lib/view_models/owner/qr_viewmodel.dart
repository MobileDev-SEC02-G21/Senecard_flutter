import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<Map<String, dynamic>> getQrInfo(String userId, String storeId) async {
    try {
      
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(userId).get();

      if (!userSnapshot.exists) {
        throw Exception("User not found");
      }

      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      String name = userData['name'] ?? 'Unknown';

      
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

      
      Map<String, dynamic> loyaltyCardData = loyaltyCard.data() as Map<String, dynamic>;
      int points = loyaltyCardData['points'] ?? 0;
      int maxPoints = loyaltyCardData['maxPoints'] ?? 10; 
      int currentStamps = loyaltyCardData['currentStamps'] ?? 0;
      bool canRedeem = currentStamps >= maxPoints;

      return {
        'name': name,
        'points': points,
        'maxPoints': maxPoints,
        'currentStamps': currentStamps,
        'canRedeem': canRedeem,
      };
    } catch (e) {
      print('Error fetching QR info: $e');
      throw e;
    }
  }
}
