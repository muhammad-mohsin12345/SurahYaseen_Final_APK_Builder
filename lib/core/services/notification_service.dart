import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/local/app_state.dart';
import '../constants/strings.dart';

/// Daily reading reminder using local notifications (works offline).
class NotificationService {
  NotificationService._();
  static final NotificationService I = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      _setLocalZone();
      await _plugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ));
      _ready = true;
      if (AppState.I.s.reminderOn) await schedule();
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  /// Finds a timezone that matches the phone's current UTC offset.
  void _setLocalZone() {
    final off = DateTime.now().timeZoneOffset;
    try {
      final k = tz.getLocation('Asia/Karachi');
      if (tz.TZDateTime.now(k).timeZoneOffset == off) {
        tz.setLocalLocation(k);
        return;
      }
    } catch (_) {}
    for (final l in tz.timeZoneDatabase.locations.values) {
      if (tz.TZDateTime.now(l).timeZoneOffset == off) {
        tz.setLocalLocation(l);
        return;
      }
    }
  }

  Future<bool> requestPermission() async {
    try {
      final a = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await a?.requestNotificationsPermission();
      return granted ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<void> schedule() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(1);
      final s = AppState.I.s;
      final now = tz.TZDateTime.now(tz.local);
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, s.hour, s.minute);
      if (when.isBefore(now)) when = when.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        1,
        'Surah Yaseen',
        tr('reminderMsg'),
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily reminder',
            channelDescription: 'Daily Surah Yaseen reading reminder',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Schedule failed: $e');
    }
  }

  Future<void> cancel() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(1);
    } catch (_) {}
  }
}
