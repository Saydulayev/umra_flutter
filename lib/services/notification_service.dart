import '../utils/app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'prayer_time_service.dart';

/// Notification ID allocation:
///   at-time  → IDs 100..105  (index 0=Fajr 1=Sunrise 2=Dhuhr 3=Asr 4=Maghrib 5=Isha)
///   30-min   → IDs 200..205
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _atTimeChannelId = 'prayer_at_time';
  static const _atTimeChannelName = 'Prayer Time';
  static const _beforeChannelId = 'prayer_before';
  static const _beforeChannelName = 'Prayer Reminder';

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  /// Request system notification permission. Returns true if granted.
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final notifGranted =
          await android.requestNotificationsPermission() ?? false;
      // SCHEDULE_EXACT_ALARM requires a separate user grant on Android 12+
      await android.requestExactAlarmsPermission();
      return notifGranted;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  /// Check permission without prompting.
  static Future<bool> hasPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  /// Open OS notification settings panel for this app (Android only).
  /// On iOS use url_launcher with 'app-settings:' URI from the call site.
  static Future<void> openSystemSettings() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  /// Cancel all scheduled prayer notifications.
  static Future<void> cancelAll() async {
    for (int i = 0; i <= 5; i++) {
      await _plugin.cancel(100 + i);
      await _plugin.cancel(200 + i);
    }
  }

  /// Schedule (or reschedule) all prayer notifications.
  static Future<void> scheduleAll({
    required PrayerCity city,
    required bool atTimeEnabled,
    required bool beforeEnabled,
    required bool sunriseEnabled,
  }) async {
    await cancelAll();
    if (!atTimeEnabled && !beforeEnabled) return;

    final data = PrayerTimeService.getTodayPrayerTimes(city);
    if (data == null) return;

    final prayers = [
      (name: 'Fajr',    time: data.fajr,    isSunrise: false),
      (name: 'Sunrise',  time: data.sunrise,  isSunrise: true),
      (name: 'Dhuhr',   time: data.dhuhr,   isSunrise: false),
      (name: 'Asr',     time: data.asr,     isSunrise: false),
      (name: 'Maghrib', time: data.maghrib, isSunrise: false),
      (name: 'Isha',    time: data.isha,    isSunrise: false),
    ];

    for (int i = 0; i < prayers.length; i++) {
      final p = prayers[i];
      if (p.isSunrise && !sunriseEnabled) continue;

      if (atTimeEnabled) {
        await _scheduleRepeating(
          id: 100 + i,
          title: p.name,
          body: 'Time for ${p.name}',
          scheduledTime: p.time,
          channelId: _atTimeChannelId,
          channelName: _atTimeChannelName,
        );
      }

      if (beforeEnabled && !p.isSunrise) {
        await _scheduleRepeating(
          id: 200 + i,
          title: 'Prepare for next prayer',
          body: 'Time for ${p.name} in 30 minutes',
          scheduledTime: p.time.subtract(const Duration(minutes: 30)),
          channelId: _beforeChannelId,
          channelName: _beforeChannelName,
        );
      }
    }
  }

  static Future<void> _scheduleRepeating({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String channelId,
    required String channelName,
  }) async {
    try {
      final location = tz.getLocation('Asia/Riyadh');
      // scheduledTime.hour/.minute is already Mecca wall-clock (UTC+3)
      final now = tz.TZDateTime.now(location);
      var scheduled = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
    } catch (e) {
      AppLogger.e('NotificationService: failed to schedule id=$id', e);
    }
  }
}
