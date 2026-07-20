import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local-only notifications: morning/evening check-in nudges and optional
/// meal-capture reminders. Nothing here touches the network, and none of it
/// is load-bearing — the app works with notifications denied.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _morningId = 1;
  static const _eveningId = 2;
  static const _mealIds = [10, 11, 12];

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    try {
      tzdata.initializeTimeZones();
      final localZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localZone.identifier));
      final ok = await _plugin.initialize(
        settings: const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      _initialized = ok ?? true;
    } on Exception {
      _initialized = false; // e.g. unsupported platform during development
    }
    return _initialized;
  }

  Future<void> applyPreferences({
    required bool morningReminder,
    required bool eveningReminder,
    required bool mealReminders,
  }) async {
    if (!await _ensureInitialized()) return;

    await _plugin.cancelAll();

    if (morningReminder) {
      await _scheduleDaily(
        id: _morningId,
        hour: 9,
        title: 'Morning check-in',
        body: 'Sleep, stress, and how yesterday ended — 20 seconds.',
      );
    }
    if (eveningReminder) {
      await _scheduleDaily(
        id: _eveningId,
        hour: 21,
        title: 'Evening check-in',
        body: 'Close the day: context logged, meals complete?',
      );
    }
    if (mealReminders) {
      const hours = [8, 13, 19];
      for (var i = 0; i < _mealIds.length; i++) {
        await _scheduleDaily(
          id: _mealIds[i],
          hour: hours[i],
          title: 'Meal logged?',
          body: 'Calm-day meals are half the evidence.',
        );
      }
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: next,
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
            'culprit_reminders',
            'Reminders',
            importance: Importance.low,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      );
    } on Exception {
      // Notifications are a nudge, never load-bearing.
    }
  }

  Future<void> cancelAll() async {
    if (!await _ensureInitialized()) return;
    await _plugin.cancelAll();
  }
}
