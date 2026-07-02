import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umra_flutter/screens/dua_book_screen.dart';
import 'package:umra_flutter/screens/home_screen.dart';
import 'package:umra_flutter/screens/prayer_time_screen.dart';
import 'package:umra_flutter/screens/settings_screen.dart';

import '../helpers/screen_harness.dart';

/// Проверяет, что у иконок-кнопок в AppBar есть semantic label (tooltip),
/// а не голая иконка — иначе VoiceOver/TalkBack озвучивают их как пустую
/// "Button".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Экраны без нижнего таб-бара — гоняем полный accessibility-гайдлайн:
  // он проверяет вообще все тапабельные Semantics-узлы, а не только
  // IconButton, так что заодно ловит будущие GestureDetector/InkWell
  // без подписи.
  final guidelineScreens = <String, Widget Function()>{
    'SettingsScreen': () => const SettingsScreen(),
    'PrayerTimeScreen': () => const PrayerTimeScreen(),
    'DuaBookScreen': () => const DuaBookScreen(),
  };

  for (final entry in guidelineScreens.entries) {
    testWidgets('${entry.key}: тапабельные элементы имеют semantic label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      stubNotificationsChannel(tester);
      usePhoneViewport(tester);

      await pumpScreen(tester, entry.value(), locale: const Locale('ru'));

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      await unmountScreen(tester);
      handle.dispose();
    });
  }

  // HomeScreen содержит нижний таб-бар (GlassTabBar из liquid_glass_widgets
  // 0.18.4), у которого свой Semantics-узел для drag-жеста свайпа между
  // вкладками — он получает непустой, но бесполезный label "Tab" от самого
  // пакета (см. комментарий в home_screen.dart), поэтому labeledTapTarget-
  // Guideline формально проходит, но ничего не гарантирует для таб-бара.
  // Реальный фикс возможен только патчем пакета. Здесь же точечно проверяем
  // то, что действительно контролируем сами — IconButton-ы в AppBar.
  testWidgets('HomeScreen: IconButton-ы в AppBar имеют tooltip', (
    tester,
  ) async {
    stubNotificationsChannel(tester);
    usePhoneViewport(tester);

    await pumpScreen(tester, const HomeScreen(), locale: const Locale('ru'));

    final iconButtons = tester.widgetList<IconButton>(find.byType(IconButton));
    expect(iconButtons, isNotEmpty);
    for (final button in iconButtons) {
      expect(
        button.tooltip,
        isNotNull,
        reason:
            'IconButton без tooltip озвучивается VoiceOver/TalkBack как '
            'пустая "Button"',
      );
      expect(button.tooltip, isNotEmpty);
    }

    await unmountScreen(tester);
  });
}
