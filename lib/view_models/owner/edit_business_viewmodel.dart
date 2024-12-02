import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:senecard/models/store.dart';

class EditBusinessViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Store? store; // Instancia del modelo Store
  bool isLoading = false;
  bool _shouldNotify = true; // Flag para controlar notificaciones

  // Método para cargar los datos del negocio
  Future<void> fetchStoreData(String storeId) async {
    _shouldNotify = false; // Evitar notificaciones prematuras
    isLoading = true;

    try {
      // Obtener los datos del negocio desde Firestore
      DocumentSnapshot storeSnapshot =
      await _firestore.collection('stores').doc(storeId).get();

      if (storeSnapshot.exists) {
        // Convertir los datos en una instancia del modelo Store
        store = Store.fromFirestore(
          storeSnapshot.data() as Map<String, dynamic>,
          storeSnapshot.id,
        );
      } else {
        print('Store not found.');
      }
    } catch (e) {
      print('Error fetching store data: $e');
    } finally {
      isLoading = false;
      _shouldNotify = true;
      notifyListeners(); // Notificar solo al final
    }
  }

  // Método para actualizar los datos del negocio
  Future<void> updateBusiness(String storeId, {String? name, String? address, File? image}) async {
    if (store == null) {
      print('Store data is not available to update.');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> updatedData = {};

      if (name != null && name.isNotEmpty) {
        updatedData['name'] = name;
        store = store!.copyWith(name: name);
      }

      if (address != null && address.isNotEmpty) {
        updatedData['address'] = address;
        store = store!.copyWith(address: address);
      }

      // Subir imagen si se proporciona
      if (image != null) {
        final storageRef = _storage.ref().child('store_images/$storeId.jpg');
        final uploadTask = await storageRef.putFile(image);
        final imageUrl = await uploadTask.ref.getDownloadURL();
        updatedData['image'] = imageUrl;
        store = store!.copyWith(image: imageUrl);
      }

      // Actualizar los datos en Firestore
      if (updatedData.isNotEmpty) {
        await _firestore.collection('stores').doc(storeId).update(updatedData);
        print('Business updated successfully.');
      }
    } catch (e) {
      print('Error updating business: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para eliminar el negocio y los anuncios relacionados
  Future<void> deleteBusiness(String storeId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Eliminar los anuncios relacionados
      final advertisements = await _firestore
          .collection('advertisements')
          .where('storeId', isEqualTo: storeId)
          .get();

      for (var ad in advertisements.docs) {
        await ad.reference.delete();
      }

      // Eliminar la imagen asociada en Firebase Storage
      final storageRef = _storage.ref().child('store_images/$storeId.jpg');
      await storageRef.delete().catchError((e) {
        print('Error deleting image: $e'); // Manejar errores si la imagen no existe
      });

      // Eliminar la tienda de Firestore
      await _firestore.collection('stores').doc(storeId).delete();

      store = null; // Resetear el modelo Store
      print('Business and related advertisements deleted successfully.');
    } catch (e) {
      print('Error deleting business: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    // Notificar solo si está permitido
    if (_shouldNotify) {
      super.notifyListeners();
    }
  }
}