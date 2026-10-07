import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../gift/gift_book.dart';

class GiftReminder {
  GiftReminder._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static var _ready = false;

  static Future<void> sync(GiftBook book, {required bool enabled}) async {
    try {
      await _ensure();
      await _plugin.cancelAll();
      if (!enabled) return;
      final now = tz.TZDateTime.now(tz.local);
      final hits = GiftEngine.upcoming(book, DateTime.now());
      for (final hit in hits) {
        final when = _when(hit.date, now);
        if (when == null) continue;
        final id = hit.occasion.id.hashCode & 0x7fffffff;
        await _plugin.zonedSchedule(
          id,
          "${hit.person.name}'s ${hit.occasion.label}",
          hit.days == 0
              ? 'Today is the day.'
              : 'Coming up ${GiftEngine.countdown(hit.days).toLowerCase()}.',
          when,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'giftstory_occasions',
              'Occasions',
              channelDescription: 'Reminders for birthdays and gift dates',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (_) {}
  }

  static Future<void> _ensure() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: true);
    _ready = true;
  }

  static tz.TZDateTime? _when(DateTime occasion, tz.TZDateTime now) {
    final dayOf =
        tz.TZDateTime(tz.local, occasion.year, occasion.month, occasion.day, 9);
    final before = dayOf.subtract(const Duration(days: 1));
    if (before.isAfter(now)) return before;
    if (dayOf.isAfter(now)) return dayOf;
    return null;
  }
}
