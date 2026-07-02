import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umra_flutter/screens/dua_book_screen.dart';
import 'package:umra_flutter/screens/home_screen.dart';
import 'package:umra_flutter/screens/prayer_time_screen.dart';
import 'package:umra_flutter/screens/settings_screen.dart';

import '../helpers/screen_harness.dart';

/// Smoke-тесты устойчивости layout к крупному системному шрифту.
///
/// Цель — измерить, до какого textScaler можно поднять потолок
/// `ResponsiveMetrics.maxTextScale` (сейчас 1.3): для возрастной аудитории
/// приложения крупный системный шрифт — самая массовая accessibility-настройка.
/// Продакшен-кламп в main.dart сюда не попадает (экраны пампятся напрямую),
/// поэтому масштаб подставляется свободно через MediaQuery.
///
/// Матрица: 4 экрана × (en, de — самые длинные строки, ar — RTL) × (1.5, 2.0).
/// Прогоняется на телефонном viewport 390×844 (iPhone 13-класс) — на нём
/// overflow вероятнее, чем на дефолтных для тестов 800×600.
/// Ловим RenderFlex overflow и прочие исключения построения; текст,
/// усечённый через ellipsis, исключением не является и тест не валит.

const _scales = [1.5, 2.0];
const _locales = [Locale('en'), Locale('de'), Locale('ar')];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final screens = <String, Widget Function()>{
    'HomeScreen': () => const HomeScreen(),
    'SettingsScreen': () => const SettingsScreen(),
    'PrayerTimeScreen': () => const PrayerTimeScreen(),
    'DuaBookScreen': () => const DuaBookScreen(),
  };

  for (final entry in screens.entries) {
    group(entry.key, () {
      for (final scale in _scales) {
        for (final locale in _locales) {
          testWidgets(
            'выдерживает крупный текст: scale=$scale, локаль=$locale',
            (tester) async {
              stubNotificationsChannel(tester);
              usePhoneViewport(tester);

              await pumpScreen(
                tester,
                entry.value(),
                locale: locale,
                textScale: scale,
              );

              expect(
                tester.takeException(),
                isNull,
                reason:
                    '${entry.key} ломается при textScale=$scale '
                    '(${locale.languageCode}) — потолок maxTextScale '
                    'поднимать выше этого значения нельзя без правок layout',
              );

              await unmountScreen(tester);
            },
          );
        }
      }
    });
  }
}
