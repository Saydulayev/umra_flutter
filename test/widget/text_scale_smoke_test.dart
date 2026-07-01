import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umra_flutter/constants/app_constants.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import 'package:umra_flutter/providers/font_provider.dart';
import 'package:umra_flutter/providers/localization_provider.dart';
import 'package:umra_flutter/providers/notification_preferences_provider.dart';
import 'package:umra_flutter/providers/purchase_provider.dart';
import 'package:umra_flutter/providers/theme_provider.dart';
import 'package:umra_flutter/providers/user_preferences_provider.dart';
import 'package:umra_flutter/repositories/preferences_repository.dart';
import 'package:umra_flutter/screens/dua_book_screen.dart';
import 'package:umra_flutter/screens/home_screen.dart';
import 'package:umra_flutter/screens/prayer_time_screen.dart';
import 'package:umra_flutter/screens/settings_screen.dart';

import '../helpers/fake_purchase_service.dart';

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

void _stubNotificationsChannel(WidgetTester tester) {
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
    call,
  ) async {
    switch (call.method) {
      case 'initialize':
      case 'canScheduleExactNotifications':
      case 'areNotificationsEnabled':
        return true;
      case 'pendingNotificationRequests':
        return <Map<String, Object?>>[];
      default:
        return null;
    }
  });
}

void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532); // iPhone 13: 390×844 @3x
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required Locale locale,
  required double textScale,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    PrefsKeys.selectedTheme: 'nur',
    PrefsKeys.selectedLanguage: locale.languageCode,
    PrefsKeys.hasSelectedLanguage: true,
    PrefsKeys.hasRatedApp: true, // review-диалог не должен вклиниваться
  });
  PreferencesRepository().resetCacheForTesting();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
        ChangeNotifierProvider(
          create: (_) => FontProvider()..setLanguageCode(locale.languageCode),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              PurchaseProvider(purchaseService: FakePurchaseService()),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationPreferencesProvider(),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Подставляем масштаб так же, как это делает builder в main.dart,
        // только без клампа — мы как раз измеряем, где предел.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );

  await tester.pump();
  await tester.pump();
  // HomeScreen откладывает review-чек на 2 секунды — проматываем таймер.
  await tester.pump(const Duration(seconds: 3));
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

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
              _stubNotificationsChannel(tester);
              _usePhoneViewport(tester);

              await _pumpScreen(
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

              await _unmount(tester);
            },
          );
        }
      }
    });
  }
}
