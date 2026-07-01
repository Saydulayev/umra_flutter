import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umra_flutter/constants/app_constants.dart';
import 'package:umra_flutter/models/app_theme.dart';
import 'package:umra_flutter/providers/theme_provider.dart';
import 'package:umra_flutter/repositories/preferences_repository.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PreferencesRepository().resetCacheForTesting();
  });

  tearDown(() {
    binding.platformDispatcher.clearPlatformBrightnessTestValue();
  });

  group('auto (дефолт) резолвится по системной яркости', () {
    test('светлая система → nur', () async {
      binding.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      final provider = ThemeProvider();
      await pumpEventQueue();

      expect(provider.themePreference, ThemePreference.auto);
      expect(provider.selectedTheme, AppTheme.nur);
    });

    test('тёмная система → layl', () async {
      binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      final provider = ThemeProvider();
      await pumpEventQueue();

      expect(provider.themePreference, ThemePreference.auto);
      expect(provider.selectedTheme, AppTheme.layl);
    });
  });

  test('сохранённое значение восстанавливается', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      PrefsKeys.selectedTheme: 'emerald',
    });
    PreferencesRepository().resetCacheForTesting();

    final provider = ThemeProvider();
    await pumpEventQueue();

    expect(provider.themePreference, ThemePreference.emerald);
    expect(provider.selectedTheme, AppTheme.emerald);
  });

  test('мусор в хранилище откатывается на auto (defensive orElse)', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      PrefsKeys.selectedTheme: 'hot-pink-disco',
    });
    PreferencesRepository().resetCacheForTesting();
    binding.platformDispatcher.platformBrightnessTestValue = Brightness.light;

    final provider = ThemeProvider();
    await pumpEventQueue();

    expect(provider.themePreference, ThemePreference.auto);
    expect(provider.selectedTheme, AppTheme.nur);
  });

  test('setTheme применяет и сохраняет выбор', () async {
    final provider = ThemeProvider();
    await pumpEventQueue();

    await provider.setTheme(ThemePreference.layl);

    expect(provider.selectedTheme, AppTheme.layl);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PrefsKeys.selectedTheme), 'layl');
  });

  test('явный выбор темы игнорирует системную яркость', () async {
    binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    final provider = ThemeProvider();
    await pumpEventQueue();

    await provider.setTheme(ThemePreference.nur);
    expect(provider.selectedTheme, AppTheme.nur);
  });
}
