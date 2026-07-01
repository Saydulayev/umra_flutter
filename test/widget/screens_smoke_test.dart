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

/// Smoke-тесты: каждый экран прогоняется через все 3 темы и 2 локали
/// (en + ar ради RTL). Цель — не пиксель-в-пиксель, а поймать дешёвые
/// регрессии: null в локализованной строке, overflow в layout,
/// необработанное исключение при построении.

const _themes = ['nur', 'layl', 'emerald'];
const _locales = [Locale('en'), Locale('ar')];

/// flutter_local_notifications ходит в платформенный канал даже при
/// cancelAll (HomeScreen перепланирует уведомления на старте). Стабим канал,
/// чтобы не ловить MissingPluginException.
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
        return null; // cancel, zonedSchedule и прочее — просто «ок»
    }
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required String themeName,
  required Locale locale,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    PrefsKeys.selectedTheme: themeName,
    PrefsKeys.selectedLanguage: locale.languageCode,
    PrefsKeys.hasSelectedLanguage: true,
    // Review-условия заведомо не выполнены (нулевое использование),
    // чтобы диалог оценки не вклинивался в smoke-тест.
    PrefsKeys.hasRatedApp: true,
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
        home: screen,
      ),
    ),
  );

  // Даём провайдерам загрузиться из моковых SharedPreferences.
  await tester.pump();
  await tester.pump();
  // HomeScreen откладывает review-чек на 2 секунды — проматываем, чтобы
  // таймер не остался висеть к концу теста.
  await tester.pump(const Duration(seconds: 3));
}

/// Размонтирует экран, чтобы погасить периодические таймеры
/// (_PrayerCountdown обновляется каждую секунду) до конца testWidgets.
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
      for (final themeName in _themes) {
        for (final locale in _locales) {
          testWidgets('строится без ошибок: тема=$themeName, локаль=$locale', (
            tester,
          ) async {
            _stubNotificationsChannel(tester);

            await _pumpScreen(
              tester,
              entry.value(),
              themeName: themeName,
              locale: locale,
            );

            // Экран построился и не бросил исключений (overflow, null
            // в локализации и т.п. провалили бы pump выше).
            expect(tester.takeException(), isNull);
            expect(find.byWidgetPredicate((w) => w is Scaffold), findsWidgets);

            await _unmount(tester);
          });
        }
      }
    });
  }

  testWidgets('RTL: арабская локаль даёт right-to-left направление', (
    tester,
  ) async {
    _stubNotificationsChannel(tester);
    await _pumpScreen(
      tester,
      const DuaBookScreen(),
      themeName: 'nur',
      locale: const Locale('ar'),
    );

    final context = tester.element(find.byType(DuaBookScreen));
    expect(Directionality.of(context), TextDirection.rtl);

    await _unmount(tester);
  });
}
