import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initializes local notifications for Android & iOS
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          AppLogger.info('Notification tapped with payload: ${response.payload}');
        },
      );

      _isInitialized = true;
      AppLogger.info('NotificationService initialized successfully.');
    } catch (e) {
      AppLogger.error('Failed to initialize NotificationService', error: e);
    }
  }

  /// Displays a native phone local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final int notificationId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'meetksa_notifications_channel',
      'MeetKSA Customer Notifications',
      channelDescription: 'Notifications from MeetKSA Customer web portal',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        platformDetails,
        payload: payload,
      );
      AppLogger.info('Displayed native notification: "$title" - "$body"');
    } catch (e) {
      AppLogger.error('Failed to show native notification', error: e);
    }
  }
}
