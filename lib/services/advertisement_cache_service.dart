import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:senecard/models/advertisement.dart'; // Modelo de Advertisement

class AdvertisementCacheService {
  static const String CACHE_KEY = 'advertisements_cache'; // Clave única para el caché
  static const Duration CACHE_DURATION = Duration(days: 7); // Duración del caché

  static AdvertisementCacheService? _instance; // Singleton
  final DefaultCacheManager _cacheManager;

  AdvertisementCacheService._() : _cacheManager = DefaultCacheManager();

  /// Inicializa el servicio de caché como Singleton
  static Future<AdvertisementCacheService> initialize() async {
    _instance ??= AdvertisementCacheService._();
    return _instance!;
  }

  /// Guarda una lista de anuncios en el caché
  Future<void> cacheAdvertisements(List<Advertisement> advertisements) async {
    try {
      // Serializar la lista de anuncios a JSON
      final String adsJson = jsonEncode(advertisements.map((ad) => ad.toJson()).toList());

      // Convertir JSON a Uint8List
      final Uint8List bytes = Uint8List.fromList(adsJson.codeUnits);

      // Guardar en el caché
      await _cacheManager.putFile(
        CACHE_KEY,
        bytes,
        key: CACHE_KEY,
        maxAge: CACHE_DURATION,
      );
      print('Advertisements cached successfully.');
    } catch (e) {
      print('Error caching advertisements: $e');
      rethrow;
    }
  }

  /// Recupera la lista de anuncios desde el caché
  Future<List<Advertisement>> getCachedAdvertisements() async {
    try {
      // Intentar obtener el archivo del caché
      final fileInfo = await _cacheManager.getFileFromCache(CACHE_KEY);

      if (fileInfo == null) {
        print('No cached advertisements found.');
        return [];
      }

      // Verificar si el caché ha expirado
      if (fileInfo.validTill.isBefore(DateTime.now())) {
        print('Cached advertisements expired.');
        await _cacheManager.removeFile(CACHE_KEY);
        return [];
      }

      // Leer el contenido del archivo como string
      final String cachedJson = await fileInfo.file.readAsString();

      // Deserializar la lista de anuncios
      final List<dynamic> adsJson = jsonDecode(cachedJson);
      final List<Advertisement> advertisements = adsJson.map((ad) => Advertisement.fromJson(ad)).toList();

      print('Retrieved ${advertisements.length} advertisements from cache.');
      return advertisements;
    } catch (e) {
      print('Error retrieving advertisements from cache: $e');
      return [];
    }
  }

  /// Elimina el caché de anuncios
  Future<void> clearCache() async {
    try {
      await _cacheManager.removeFile(CACHE_KEY);
      print('Advertisements cache cleared.');
    } catch (e) {
      print('Error clearing advertisements cache: $e');
      rethrow;
    }
  }
}
