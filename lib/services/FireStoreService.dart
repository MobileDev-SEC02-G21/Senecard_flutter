// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senecard/models/store.dart';
import 'package:senecard/models/advertisement.dart';

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
    return _firestore.collection('advertisements').snapshots().map((snapshot) {
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
}
