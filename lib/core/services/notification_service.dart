import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

typedef NotificationTapHandler = void Function(String? payload);

class NotificationService {
  NotificationService();

  static const int _timerNotificationId = 7001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  NotificationTapHandler? _tapHandler;

  Future<void> init({NotificationTapHandler? onTap}) async {
    _tapHandler = onTap ?? _tapHandler;

    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final NotificationAppLaunchDetails? launchDetails =
        await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _dispatchPayload(launchDetails?.notificationResponse?.payload);
    }

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> scheduleTimerCompletion({
    required Duration delay,
    required String categoryTitle,
  }) async {
    if (!_initialized || delay.inSeconds <= 0) {
      return;
    }

    final when = tz.TZDateTime.now(tz.local).add(delay);

    await _plugin.zonedSchedule(
      _timerNotificationId,
      'Timer complete',
      '$categoryTitle session reached your target.',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'timeflow_timer_channel',
          'Timer alerts',
          channelDescription: 'Alerts for timer completion',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'timer_complete',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTimerCompletion() async {
    if (!_initialized) {
      return;
    }
    await _plugin.cancel(_timerNotificationId);
  }

  void _handleNotificationResponse(NotificationResponse response) {
    _dispatchPayload(response.payload);
  }

  void _dispatchPayload(String? payload) {
    _tapHandler?.call(payload);
  }
}
