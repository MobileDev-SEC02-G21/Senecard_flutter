import 'package:shared_preferences/shared_preferences.dart';

class QrStorageService {
  static QrStorageService? instance;
  static const String USER_QR_KEY = 'stored_user_qr';
  
  QrStorageService._();
  
  static Future<QrStorageService> initialize() async {
    if (instance != null) return instance!;
    instance = QrStorageService._();
    return instance!;
  }

  Future<String?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString(USER_QR_KEY);
    print('Retrieved stored user ID: $storedId'); // Debug log
    return storedId;
  }

  Future<void> storeUserId(String userId) async {
    if (userId.isEmpty) {
      print('Warning: Attempted to store empty userId');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_QR_KEY, userId);
    print('Stored user ID: $userId'); // Debug log
  }

  Future<void> clearStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(USER_QR_KEY);
    print('Cleared stored user ID'); // Debug log
  }
}