import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umra_flutter/constants/app_constants.dart';
import 'package:umra_flutter/constants/review_config.dart';
import 'package:umra_flutter/providers/user_preferences_provider.dart';
import 'package:umra_flutter/repositories/preferences_repository.dart';

/// Тесты процедуры принятия решения о показе review-диалога.
///
/// checkAndShowReviewIfNeeded проверяет 6 независимых условий. Каждый тест
/// делает «непройденным» ровно одно условие (остальные — заведомо пройдены
/// через _baseline) и проверяет, что диалог НЕ помечается к показу.
/// Сама процедура читает только SharedPreferences (без платформенных
/// каналов), поэтому setMockInitialValues покрывает её полностью.
///
/// Провайдер запускает проверку сам в конструкторе — поэтому все проверки
/// делаются после pumpEventQueue() на свежесозданном провайдере, без
/// повторного ручного вызова (он вернулся бы по ветке _hasShownReviewDialog).

Map<String, Object> _baseline({
  int? shownCount,
  int? lastShownDaysAgo,
  int? usageSeconds,
  int? launchCount,
  int? firstLaunchDaysAgo,
  bool? hasRated,
}) {
  final now = DateTime.now();
  final map = <String, Object>{
    PrefsKeys.reviewDialogShownCount: shownCount ?? 0,
    PrefsKeys.totalAppUsageTime:
        usageSeconds ?? ReviewConfig.minUsageTimeSeconds * 10,
    PrefsKeys.appLaunchCount: launchCount ?? ReviewConfig.minAppLaunches * 3,
    PrefsKeys.firstAppLaunchTime: now
        .subtract(
          Duration(days: firstLaunchDaysAgo ?? 30),
        )
        .millisecondsSinceEpoch,
    PrefsKeys.hasRatedApp: hasRated ?? false,
  };
  if (lastShownDaysAgo != null) {
    map[PrefsKeys.lastReviewDialogShownTime] = now
        .subtract(Duration(days: lastShownDaysAgo))
        .millisecondsSinceEpoch;
  }
  return map;
}

Future<UserPreferencesProvider> _createProvider(
  Map<String, Object> prefs,
) async {
  SharedPreferences.setMockInitialValues(prefs);
  PreferencesRepository().resetCacheForTesting();
  final provider = UserPreferencesProvider();
  await pumpEventQueue();
  return provider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('checkAndShowReviewIfNeeded', () {
    test('все условия выполнены → диалог помечен к показу, счётчик растёт',
        () async {
      final provider = await _createProvider(_baseline());

      expect(provider.hasShownReviewDialog, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PrefsKeys.reviewDialogShownCount), 1);
      expect(prefs.getInt(PrefsKeys.lastReviewDialogShownTime), isNotNull);
    });

    test('условие 1: достигнут максимум показов → НЕ показывается', () async {
      final provider = await _createProvider(
        _baseline(shownCount: ReviewConfig.maxTotalPrompts),
      );

      expect(provider.hasShownReviewDialog, isFalse);
      final prefs = await SharedPreferences.getInstance();
      // Счётчик не должен измениться.
      expect(
        prefs.getInt(PrefsKeys.reviewDialogShownCount),
        ReviewConfig.maxTotalPrompts,
      );
    });

    test('условие 2: показывали недавно → НЕ показывается', () async {
      final provider = await _createProvider(
        _baseline(lastShownDaysAgo: ReviewConfig.daysBetweenPrompts - 1),
      );

      expect(provider.hasShownReviewDialog, isFalse);
    });

    test('условие 2 (позитив): интервал прошёл → показывается', () async {
      final provider = await _createProvider(
        _baseline(lastShownDaysAgo: ReviewConfig.daysBetweenPrompts + 1),
      );

      expect(provider.hasShownReviewDialog, isTrue);
    });

    test('условие 3: мало времени использования → НЕ показывается', () async {
      final provider = await _createProvider(
        _baseline(usageSeconds: ReviewConfig.minUsageTimeSeconds - 1),
      );

      expect(provider.hasShownReviewDialog, isFalse);
    });

    test('условие 4: мало запусков → НЕ показывается', () async {
      final provider = await _createProvider(
        _baseline(launchCount: ReviewConfig.minAppLaunches - 1),
      );

      expect(provider.hasShownReviewDialog, isFalse);
    });

    test('условие 5: первый запуск сегодня → НЕ показывается', () async {
      final provider = await _createProvider(_baseline(firstLaunchDaysAgo: 0));

      expect(provider.hasShownReviewDialog, isFalse);
    });

    test('условие 6: пользователь уже оценил → НЕ показывается', () async {
      final provider = await _createProvider(_baseline(hasRated: true));

      expect(provider.hasShownReviewDialog, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PrefsKeys.reviewDialogShownCount), 0);
    });
  });

  group('остальные пользовательские настройки', () {
    test('setPrayerCity принимает только mecca/medina и сохраняет', () async {
      final provider = await _createProvider(_baseline(hasRated: true));

      await provider.setPrayerCity('medina');
      expect(provider.prayerCity, 'medina');

      await provider.setPrayerCity('paris'); // невалидный — игнорируется
      expect(provider.prayerCity, 'medina');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PrefsKeys.prayerCity), 'medina');
    });

    test('isGridView загружается и сохраняется', () async {
      final provider = await _createProvider(_baseline(hasRated: true));
      expect(provider.isGridView, isFalse);

      await provider.setIsGridView(true);
      expect(provider.isGridView, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PrefsKeys.isGridView), isTrue);
    });
  });
}
