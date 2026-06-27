import '../utils/app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'prayer_time_service.dart';
import '../l10n/app_localizations.dart';

/// Локализованные тексты уведомлений. Резолвятся из [AppLocalizations] на
/// стороне UI (где есть BuildContext) и передаются в [NotificationService.
/// scheduleAll], потому что сам сервис работает без контекста, а уведомления
/// планируются заранее — текст «запекается» в момент планирования.
///
/// Все списки длиной 6 в порядке: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha.
class PrayerNotificationTexts {
  final List<String> titles; // локализованные названия намазов
  final List<String> atTimeBody; // «в момент намаза»
  final String beforeTitle; // заголовок «за 30 минут»
  final List<String> beforeBody; // тело «за 30 минут»

  const PrayerNotificationTexts({
    required this.titles,
    required this.atTimeBody,
    required this.beforeTitle,
    required this.beforeBody,
  });

  factory PrayerNotificationTexts.of(AppLocalizations l10n) {
    final names = [
      l10n.fajr,
      l10n.sunrise,
      l10n.dhuhr,
      l10n.asr,
      l10n.maghrib,
      l10n.isha,
    ];
    return PrayerNotificationTexts(
      titles: names,
      atTimeBody: [for (final n in names) l10n.notificationPrayerNow(n)],
      beforeTitle: l10n.notificationPrayerSoonTitle,
      beforeBody: [for (final n in names) l10n.notificationPrayerSoon(n)],
    );
  }
}

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

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      try {
        final notifGranted =
            await android.requestNotificationsPermission() ?? false;
        // Точные будильники выдаются через USE_EXACT_ALARM (см. AndroidManifest)
        // автоматически на Android 13+, а на Android 12 SCHEDULE_EXACT_ALARM
        // предоставлен по умолчанию. Поэтому отдельный запрос/системный экран
        // «Сигналы и напоминания» больше не нужен — requestExactAlarmsPermission
        // не вызываем (он и был причиной всплывающего окна).
        return notifGranted;
      } catch (e) {
        // Плагин кидает NPE (null Context), если вызвать запрос до того, как
        // Activity прикреплена. Не роняем приложение — просто возвращаем false.
        AppLogger.e('NotificationService: requestPermission failed', e);
        return false;
      }
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
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
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  /// Open OS notification settings panel for this app (Android only).
  /// On iOS use url_launcher with 'app-settings:' URI from the call site.
  static Future<void> openSystemSettings() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
  }

  /// DEBUG-ТЕСТ. Планирует одноразовое уведомление через [seconds] секунд тем
  /// же путём, что и реальные напоминания о намазе (exact, allow-while-idle,
  /// тот же канал) — чтобы проверить доставку, не дожидаясь времени намаза.
  /// Вызывается только из debug-кнопки (см. prayer_time_screen, if kDebugMode).
  static Future<void> debugScheduleTest({int seconds = 30}) async {
    await init();
    final location = tz.getLocation('Asia/Riyadh');
    final when = tz.TZDateTime.now(location).add(Duration(seconds: seconds));
    await _plugin.zonedSchedule(
      9999,
      'Тест уведомления',
      'Если ты это видишь — уведомления работают ✅',
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _atTimeChannelId,
          _atTimeChannelName,
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
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
    required PrayerNotificationTexts texts,
  }) async {
    await cancelAll();
    if (!atTimeEnabled && !beforeEnabled) return;

    final data = PrayerTimeService.getTodayPrayerTimes(city);
    if (data == null) return;

    // Порядок строго соответствует индексам в [PrayerNotificationTexts]:
    // 0=Fajr 1=Sunrise 2=Dhuhr 3=Asr 4=Maghrib 5=Isha.
    final prayers = [
      (time: data.fajr, isSunrise: false),
      (time: data.sunrise, isSunrise: true),
      (time: data.dhuhr, isSunrise: false),
      (time: data.asr, isSunrise: false),
      (time: data.maghrib, isSunrise: false),
      (time: data.isha, isSunrise: false),
    ];

    for (int i = 0; i < prayers.length; i++) {
      final p = prayers[i];
      if (p.isSunrise && !sunriseEnabled) continue;

      if (atTimeEnabled) {
        await _scheduleRepeating(
          id: 100 + i,
          title: texts.titles[i],
          body: texts.atTimeBody[i],
          scheduledTime: p.time,
          channelId: _atTimeChannelId,
          channelName: _atTimeChannelName,
        );
      }

      if (beforeEnabled && !p.isSunrise) {
        await _scheduleRepeating(
          id: 200 + i,
          title: texts.beforeTitle,
          body: texts.beforeBody[i],
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
