import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/user_preferences_provider.dart';
import 'providers/font_provider.dart';
import 'providers/purchase_provider.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'models/app_theme.dart';
import 'services/app_usage_tracker.dart';

// Платформенный канал для обновления системного UI на Android
const MethodChannel _systemUIChannel = MethodChannel('saydulayev.wien_gmail.com.umra/system_ui');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Включаем edge-to-edge для Android 15
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Инициализируем трекер использования приложения
  await AppUsageTracker().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
        ChangeNotifierProvider(create: (_) => FontProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
      ],
      child:
          Consumer3<
            ThemeProvider,
            LocalizationProvider,
            UserPreferencesProvider
          >(
            builder:
                (
                  context,
                  themeProvider,
                  localizationProvider,
                  prefsProvider,
                  child,
                ) {
                  final theme = themeProvider.selectedTheme;
                  
                  // ВАЖНО: Для Android 15+ (API 35+) Flutter SDK использует устаревшие API через SystemChrome
                  // (setStatusBarColor, setNavigationBarColor, setNavigationBarDividerColor)
                  // Эти API не поддерживаются в Android 15+
                  // 
                  // Решение: НЕ используем SystemChrome.setSystemUIOverlayStyle() для Android
                  // Вместо этого управляем внешним видом через WindowInsetsControllerCompat в MainActivity
                  // через платформенный канал
                  if (Platform.isAndroid) {
                    // Обновляем яркость иконок через платформенный канал
                    // Это предотвращает использование устаревших API в Android 15+
                    _systemUIChannel.invokeMethod('updateSystemUIAppearance', {
                      'isDark': theme.isDark,
                    }).catchError((error) {
                      // Игнорируем ошибки, если канал недоступен
                    });
                  } else if (Platform.isIOS) {
                    // Для iOS используем обычный подход
                    final overlayStyle = SystemUiOverlayStyle(
                      statusBarIconBrightness: theme.isDark
                          ? Brightness.light
                          : Brightness.dark,
                      systemNavigationBarIconBrightness: theme.isDark
                          ? Brightness.light
                          : Brightness.dark,
                      systemStatusBarContrastEnforced: false,
                      systemNavigationBarContrastEnforced: false,
                    );
                    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
                  }

                  return MaterialApp(
                    title: 'Umra Guide',
                    debugShowCheckedModeBanner: false,

                    // Тема
                    theme: ThemeData(
                      primarySwatch: _getColorSwatch(theme),
                      primaryColor: theme.primaryColor,
                      scaffoldBackgroundColor: theme.backgroundColor,
                      fontFamily: 'Lato',
                      useMaterial3: true,
                    ),

                    // Локализация
                    locale: localizationProvider.currentLocale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    localeResolutionCallback: (locale, supportedLocales) {
                      if (locale == null) {
                        return supportedLocales.first;
                      }
                      // Проверяем точное совпадение
                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                            locale.languageCode) {
                          return supportedLocale;
                        }
                      }
                      // Если не найдено, возвращаем первый поддерживаемый
                      return supportedLocales.first;
                    },

                    // Начальный экран
                    home: localizationProvider.hasSelectedLanguage
                        ? const HomeScreen()
                        : const LanguageSelectionScreen(),
                    // Важно: отключаем кэширование роутов для правильной работы локализации
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: const TextScaler.linear(1.0)),
                        child: child!,
                      );
                    },
                  );
                },
          ),
    );
  }

  MaterialColor _getColorSwatch(AppTheme theme) {
    // Создаем MaterialColor на основе темы
    final color = theme.primaryColor;
    return MaterialColor(color.toARGB32(), <int, Color>{
      50: color.withValues(alpha: 0.1),
      100: color.withValues(alpha: 0.2),
      200: color.withValues(alpha: 0.3),
      300: color.withValues(alpha: 0.4),
      400: color.withValues(alpha: 0.5),
      500: color,
      600: color.withValues(alpha: 0.7),
      700: color.withValues(alpha: 0.8),
      800: color.withValues(alpha: 0.9),
      900: color,
    });
  }
}
