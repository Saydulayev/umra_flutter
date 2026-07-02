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

import 'fake_purchase_service.dart';

/// Общий harness для смоук-тестов экранов: провайдеры, локализация,
/// стаб канала уведомлений и вьюпорт телефона — вынесено, чтобы не
/// дублировать между test/widget/text_scale_smoke_test.dart и другими
/// смоук-тестами (например, проверкой accessibility-гайдлайнов).
void stubNotificationsChannel(WidgetTester tester) {
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

void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532); // iPhone 13: 390×844 @3x
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required Locale locale,
  double textScale = 1.0,
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
        // только без клампа — так тесты могут мерить, где предел.
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

Future<void> unmountScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}
