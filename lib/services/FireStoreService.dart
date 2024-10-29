// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/models/advertisement.dart';
import 'package:senecard/models/purchase.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch stores
  Stream<List<Store>> getStores() {
    return _firestore.collection('stores').snapshots().map((snapshot) {
      print('Firestore snapshot received. Document count: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        print('Store data: ${doc.data()}');
        return Store.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Fetch advertisements (unchanged)
  Stream<List<Advertisement>> getAdvertisements() {
    print('Starting advertisements query');
    
    // Primero, obtener todos los documentos sin filtro para debug
    _firestore.collection('advertisements').get().then((snapshot) {
      print('Total advertisements in collection (unfiltered): ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('Advertisement document: ${doc.id}');
        print('Advertisement data: ${doc.data()}');
        print('Available value: ${doc.data()['available']}');
        print('Available value type: ${doc.data()['available'].runtimeType}');
      }
    });

    // La query original con filtro
    return _firestore
        .collection('advertisements')
        .where('available', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          print('Firestore filtered advertisements query executed.');
          print('Filtered document count: ${snapshot.docs.length}');
          
          final advertisements = snapshot.docs.map((doc) {
            print('Processing filtered advertisement:');
            print('  ID: ${doc.id}');
            print('  Data: ${doc.data()}');
            print('  Available value: ${doc.data()['available']}');
            
            return Advertisement.fromFirestore(doc.data(), doc.id);
          }).toList();
          
          print('Processed ${advertisements.length} available advertisements');
          return advertisements;
        });
  }

  // Método para obtener anuncios filtrados por storeId
  Stream<List<Advertisement>> getAdvertisementsByStore(String storeId) {
    return _firestore.collection('advertisements')
        .where('storeId', isEqualTo: storeId) // Filtra por el storeId
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Advertisement.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }


  // Add a new store
  Future<void> addStore(Store store) {
    return _firestore.collection('stores').add(store.toFirestore());
  }

  // Update a store
  Future<void> updateStore(Store store) {
    return _firestore
        .collection('stores')
        .doc(store.id)
        .update(store.toFirestore());
  }

  // Delete a store
  Future<void> deleteStore(String storeId) {
    return _firestore.collection('stores').doc(storeId).delete();
  }

  // Add a new advertisement
  Future<void> addAdvertisement(Advertisement ad) {
    return _firestore.collection('advertisements').add(ad.toFirestore());
  }

  // Update an advertisement
  Future<void> updateAdvertisement(Advertisement ad) {
    return _firestore
        .collection('advertisements')
        .doc(ad.id)
        .update(ad.toFirestore());
  }

  // Delete an advertisement
  Future<void> deleteAdvertisement(String adId) {
    return _firestore.collection('advertisements').doc(adId).delete();
  }

  Future<void> logQrRenderTime(
      String userId, DateTime startTime, DateTime endTime, int renderTime) {
    return _firestore.collection('qr_render_times').add({
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
      'renderTime': renderTime,
    });
  }

  // NEW: Get loyaltyCardIds associated with a specific store
  Future<List<String>> getLoyaltyCardIdsByStore(String storeId) async {
    try {
      final loyaltyCardsQuery = await _firestore
          .collection('loyaltyCards')
          .where('storeId', isEqualTo: storeId)
          .get();

      // Return the list of loyaltyCardIds
      return loyaltyCardsQuery.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching loyalty cards for store: $e');
      return [];
    }
  }

  // NEW: Get the number of purchases made today by loyaltyCardId and date
  Future<int> getPurchasesByLoyaltyCardIdsAndDate(List<String> loyaltyCardIds, String date) async {
    try {
      final purchasesQuery = await _firestore
          .collection('purchases')
          .where('loyaltyCardId', whereIn: loyaltyCardIds)
          .where('date', isEqualTo: date)
          .get();

      // Return the count of purchases
      return purchasesQuery.docs.length;
    } catch (e) {
      print('Error fetching purchases by loyaltyCardIds and date: $e');
      return 0;
    }
  }

  // NEW: Get store rating by storeId
  Future<double> getStoreRating(String storeId) async {
    try {
      final storeDoc = await _firestore.collection('stores').doc(storeId).get();

      if (storeDoc.exists) {
        final store = Store.fromFirestore(storeDoc.data() as Map<String, dynamic>, storeDoc.id);
        return store.rating;
      } else {
        return 0.0;  // If store doesn't exist or no rating, return 0
      }
    } catch (e) {
      print('Error fetching store rating: $e');
      return 0.0;
    }
  }

  // NEW: Get active advertisements count by storeId
  Future<int> getActiveAdvertisements(String storeId) async {
    try {
      final advertisementsQuery = await _firestore
          .collection('advertisements')
          .where('storeId', isEqualTo: storeId)
          .where('available', isEqualTo: true)
          .get();

      // Return the count of active advertisements
      return advertisementsQuery.docs.length;
    } catch (e) {
      print('Error fetching active advertisements: $e');
      return 0;
    }
  }
}
