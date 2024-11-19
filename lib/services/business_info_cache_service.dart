import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class BusinessInfoCacheService {
  static const String CACHE_KEY = 'business_info_cache'; // Clave única para el caché
  static const Duration CACHE_DURATION = Duration(days: 7); // Duración del caché

  static BusinessInfoCacheService? _instance; // Singleton
  final DefaultCacheManager _cacheManager;

  BusinessInfoCacheService._() : _cacheManager = DefaultCacheManager();

  /// Inicializa el servicio como Singleton
  static Future<BusinessInfoCacheService> initialize() async {
    _instance ??= BusinessInfoCacheService._();
    return _instance!;
  }

  /// Guarda los datos del negocio en el caché
  Future<void> cacheBusinessInfo(Map<String, dynamic> businessInfo) async {
    try {
      // Serializar los datos a JSON
      final String jsonData = jsonEncode(businessInfo);

      // Convertir JSON a Uint8List
      final Uint8List bytes = Uint8List.fromList(jsonData.codeUnits);

      // Guardar en el caché
      await _cacheManager.putFile(
        CACHE_KEY,
        bytes,
        key: CACHE_KEY,
        maxAge: CACHE_DURATION,
      );
      print('Business info cached successfully.');
    } catch (e) {
      print('Error caching business info: $e');
      rethrow;
    }
  }

  /// Recupera los datos del negocio desde el caché
  Future<Map<String, dynamic>?> getCachedBusinessInfo() async {
    try {
      // Intentar obtener el archivo del caché
      final fileInfo = await _cacheManager.getFileFromCache(CACHE_KEY);

      if (fileInfo == null) {
        print('No cached business info found.');
        return null;
      }

      // Verificar si el caché ha expirado
      if (fileInfo.validTill.isBefore(DateTime.now())) {
        print('Cached business info expired.');
        await _cacheManager.removeFile(CACHE_KEY);
        return null;
      }

      // Leer el contenido del archivo como string
      final String cachedJson = await fileInfo.file.readAsString();

      // Deserializar los datos
      final Map<String, dynamic> businessInfo = jsonDecode(cachedJson);
      print('Retrieved business info from cache.');
      return businessInfo;
    } catch (e) {
      print('Error retrieving business info from cache: $e');
      return null;
    }
  }

  /// Elimina los datos del caché
  Future<void> clearCache() async {
    try {
      await _cacheManager.removeFile(CACHE_KEY);
      print('Business info cache cleared.');
    } catch (e) {
      print('Error clearing business info cache: $e');
      rethrow;
    }
  }
}
