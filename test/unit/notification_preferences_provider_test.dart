import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umra_flutter/constants/app_constants.dart';
import 'package:umra_flutter/providers/notification_preferences_provider.dart';
import 'package:umra_flutter/repositories/preferences_repository.dart';

// Сеттеры (setAtTime/setBefore/setSunrise) здесь сознательно не вызываются:
// они дергают NotificationService.scheduleAll → платформенный канал
// flutter_local_notifications, которого нет в юнит-тестах. Логика загрузки —
// самая ценная часть: от isLoaded зависит гарантия в home_screen.dart, что
// перепланирование не сотрёт включённые уведомления до загрузки флагов.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PreferencesRepository().resetCacheForTesting();
  });

  test('дефолты: sunrise включён, atTime и before выключены', () async {
    final provider = NotificationPreferencesProvider();
    await pumpEventQueue();

    expect(provider.sunriseEnabled, isTrue);
    expect(provider.atTimeEnabled, isFalse);
    expect(provider.beforeEnabled, isFalse);
  });

  test(
    'isLoaded false сразу после создания и true только после загрузки — '
    'гарантия для home_screen: нельзя перепланировать до загрузки флагов',
    () async {
      final provider = NotificationPreferencesProvider();

      // Синхронно после конструктора флаги ещё не загружены.
      expect(provider.isLoaded, isFalse);

      await pumpEventQueue();
      expect(provider.isLoaded, isTrue);
    },
  );

  test('сохранённые значения восстанавливаются', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      PrefsKeys.notifAtTime: true,
      PrefsKeys.notifBefore: true,
      PrefsKeys.notifSunrise: false,
    });
    PreferencesRepository().resetCacheForTesting();

    final provider = NotificationPreferencesProvider();
    await pumpEventQueue();

    expect(provider.atTimeEnabled, isTrue);
    expect(provider.beforeEnabled, isTrue);
    expect(provider.sunriseEnabled, isFalse);
  });

  test('слушатели уведомляются после загрузки', () async {
    final provider = NotificationPreferencesProvider();
    var notified = 0;
    provider.addListener(() => notified++);

    await pumpEventQueue();
    expect(notified, greaterThanOrEqualTo(1));
  });
}
