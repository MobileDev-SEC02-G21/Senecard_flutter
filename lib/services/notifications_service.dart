import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:senecard/services/user_preferences_service.dart';

class NotificationChannels {
  static const defaultChannel = AndroidNotificationChannel(
    'default_channel',
    'Default Channel',
    description: 'Default notification channel',
    importance: Importance.high,
  );
}

class NotificationsService {
  static NotificationsService? _instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final UserPreferencesService _preferencesService;

  bool _initialized = false;

  NotificationsService._(this._preferencesService);

  static Future<NotificationsService> initialize(UserPreferencesService preferencesService) async {
    if (_instance != null) return _instance!;
    
    final instance = NotificationsService._(preferencesService);
    await instance._init();
    _instance = instance;
    return instance;
  }

  Future<void> _init() async {
    if (_initialized) return;

    // Crear canal de notificaciones en Android
    const AndroidNotificationChannel channel = NotificationChannels.defaultChannel;
    
    await _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    // Configurar notificaciones locales
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await _requestPermissions();

    // Configurar manejo de mensajes
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final notificationsEnabled = await _preferencesService.getNotificationsEnabled();
    print('Notifications enabled: $notificationsEnabled'); // Debug

    if (notificationsEnabled) {
      final status = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('Permission status: ${status.authorizationStatus}'); // Debug
      
      if (status.authorizationStatus == AuthorizationStatus.authorized) {
        await subscribeToNewAds();
      }
    } else {
      await unsubscribeFromNewAds();
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    if (!await _preferencesService.getNotificationsEnabled()) return;

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationChannels.defaultChannel.id,
            NotificationChannels.defaultChannel.name,
            channelDescription: NotificationChannels.defaultChannel.description,
            icon: android?.smallIcon,
            importance: NotificationChannels.defaultChannel.importance,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> subscribeToNewAds() async {
    if (await _preferencesService.getNotificationsEnabled()) {
      await _messaging.subscribeToTopic('new_ads');
    }
  }

  Future<void> unsubscribeFromNewAds() async {
    await _messaging.unsubscribeFromTopic('new_ads');
  }
}