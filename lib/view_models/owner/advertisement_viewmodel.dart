import 'package:flutter/material.dart';
import 'package:senecard/models/advertisement.dart'; // Modelo del Advertisement
import 'package:senecard/services/FireStoreService.dart';
import 'package:senecard/services/advertisement_cache_service.dart'; // Nuevo servicio de caché
import 'package:firebase_storage/firebase_storage.dart'; // Importa Firebase Storage
import 'dart:io';

class AdvertisementViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService(); // Instancia del servicio Firestore
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance; // Instancia de Firebase Storage
  AdvertisementCacheService? _cacheService; // Servicio de caché
  List<Advertisement> _advertisements = []; // Lista de anuncios

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Advertisement> get advertisements => _advertisements; // Getter para acceder a los anuncios

  AdvertisementViewModel() {
    _initializeCacheService(); // Inicializamos el servicio de caché
  }

  Future<void> _initializeCacheService() async {
    _cacheService = await AdvertisementCacheService.initialize();
  }

  Future<void> _ensureCacheServiceInitialized() async {
    if (_cacheService == null) {
      _cacheService = await AdvertisementCacheService.initialize();
    }
  }

  // Método para escuchar los cambios en los anuncios filtrados por storeId
  void fetchAdvertisements(String storeId) async {
    _isLoading = true;

    // Usar Future.delayed para esperar que el árbol de widgets esté completamente construido
    Future.delayed(Duration.zero, () async {
      notifyListeners();

      try {
        // Asegurar que _cacheService esté inicializado
        await _ensureCacheServiceInitialized();

        // Cargar anuncios desde el caché si están disponibles
        await _loadAdvertisementsFromCache();

        // Escuchar al stream de anuncios desde Firestore filtrados por storeId
        _firestoreService.getAdvertisementsByStore(storeId).listen((advertisementList) async {
          _advertisements = advertisementList; // Actualizamos la lista local
          _isLoading = false;
          notifyListeners(); // Notificamos los cambios para actualizar la vista

          // Guardar anuncios en el caché
          await _saveAdvertisementsToCache();
          print('Fetched ${_advertisements.length} advertisements for store $storeId.');
        });
      } catch (e) {
        _isLoading = false;
        print('Error fetching advertisements: $e');
      }
    });
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
        title: description, // Usamos la descripción como título
        description: description,
        image: imageUrl,
        startDate: DateTime.now().toIso8601String(), // Fecha actual
        endDate: null, // No definimos una fecha de fin por ahora
        available: true, // El anuncio está disponible por defecto
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
      await _saveAdvertisementsToCache(); // Actualizar caché
      notifyListeners(); // Notificar los cambios
    } catch (e) {
      print('Error deleting advertisement: $e');
    }
  }

  // Método para guardar los anuncios en el caché
  Future<void> _saveAdvertisementsToCache() async {
    try {
      await _ensureCacheServiceInitialized();
      await _cacheService!.cacheAdvertisements(_advertisements);
    } catch (e) {
      print('Error saving advertisements to cache: $e');
    }
  }

  // Método para cargar los anuncios desde el caché
  Future<void> _loadAdvertisementsFromCache() async {
    try {
      await _ensureCacheServiceInitialized();
      final cachedAdvertisements = await _cacheService!.getCachedAdvertisements();
      if (cachedAdvertisements.isNotEmpty) {
        _advertisements = cachedAdvertisements;
        print('Loaded ${_advertisements.length} advertisements from cache.');
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading advertisements from cache: $e');
    }
  }
}
