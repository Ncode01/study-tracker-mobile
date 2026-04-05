import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _timerNotificationId = 7001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTimerCompletion() async {
    if (!_initialized) {
      return;
    }
    await _plugin.cancel(_timerNotificationId);
  }
}
