import 'package:flutter/material.dart';
import 'package:senecard/models/advertisement.dart';  // Modelo del Advertisement
import 'package:senecard/services/FireStoreService.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Importa Firebase Storage
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AdvertisementViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();  // Instancia del servicio Firestore
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;  // Instancia de Firebase Storage
  List<Advertisement> _advertisements = [];  // Lista de anuncios

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Advertisement> get advertisements => _advertisements;  // Getter para acceder a los anuncios

  AdvertisementViewModel() {
    // No llamamos a fetch aquí porque necesitamos el storeId
  }

  // Método para escuchar los cambios en los anuncios filtrados por storeId
  void fetchAdvertisements(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cargar anuncios desde el caché si están disponibles
      await _loadAdvertisementsFromCache();

      // Escuchamos al stream de anuncios desde Firestore filtrados por storeId
      _firestoreService.getAdvertisementsByStore(storeId).listen((advertisementList) {
        _advertisements = advertisementList;  // Actualizamos la lista local
        _isLoading = false;
        notifyListeners();  // Notificamos los cambios para actualizar la vista

        // Guardar anuncios en el caché
        _saveAdvertisementsToCache();
        print('Fetched ${_advertisements.length} advertisements for store $storeId.');
      });
    } catch (e) {
      _isLoading = false;
      print('Error fetching advertisements: $e');
    }
  }

  // Método para crear un nuevo anuncio
  Future<void> createAdvertisement({
    required String storeId,
    required String description,
    required File image,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Subir la imagen a Firebase Storage
      String imageUrl = await _uploadImage(image);

      // 2. Crear el nuevo anuncio
      Advertisement newAd = Advertisement(
        id: '', // Se generará automáticamente al guardar en Firestore
        storeId: storeId,
        title: description,  // Usamos la descripción como título
        description: description,
        image: imageUrl,
        startDate: DateTime.now().toIso8601String(),  // Fecha actual
        endDate: null,  // No definimos una fecha de fin por ahora
        available: true,  // El anuncio está disponible por defecto
      );

      // 3. Guardar el anuncio en Firestore
      await _firestoreService.addAdvertisement(newAd);

      _isLoading = false;
      notifyListeners();
      print('Advertisement created successfully');
    } catch (e) {
      _isLoading = false;
      print('Error creating advertisement: $e');
    }
  }

  // Método privado para subir la imagen a Firebase Storage
  Future<String> _uploadImage(File image) async {
    try {
      // Nombre único para la imagen basada en el tiempo actual
      String fileName = 'advertisements/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Referencia al almacenamiento en Firebase
      Reference storageRef = _firebaseStorage.ref().child(fileName);

      // Subimos la imagen al almacenamiento
      await storageRef.putFile(image);

      // Obtenemos la URL pública de la imagen
      String imageUrl = await storageRef.getDownloadURL();
      print('Image uploaded to Firebase Storage: $imageUrl');

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  // Método para eliminar un anuncio
  Future<void> removeAdvertisement(int index) async {
    try {
      final advertisementId = _advertisements[index].id; // Obtener el ID del anuncio
      await _firestoreService.deleteAdvertisement(advertisementId); // Eliminar de Firestore
      _advertisements.removeAt(index); // Eliminar localmente de la lista
      _saveAdvertisementsToCache(); // Actualizar caché
      notifyListeners(); // Notificar los cambios
    } catch (e) {
      print('Error deleting advertisement: $e');
    }
  }

  // Método para guardar los anuncios en el caché
  Future<void> _saveAdvertisementsToCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> adJsonList = _advertisements.map((ad) => jsonEncode(ad.toJson())).toList();
    await prefs.setStringList('cachedAdvertisements', adJsonList);
    print('Advertisements saved to cache.');
  }

  // Método para cargar los anuncios desde el caché
  Future<void> _loadAdvertisementsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? adJsonList = prefs.getStringList('cachedAdvertisements');

    if (adJsonList != null) {
      _advertisements = adJsonList.map((adJson) => Advertisement.fromJson(jsonDecode(adJson))).toList();
      print('Loaded ${_advertisements.length} advertisements from cache.');
      _isLoading = false;
      notifyListeners();
    }
  }
}
