import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/user_preferences_provider.dart';
import 'providers/font_provider.dart';
import 'providers/purchase_provider.dart';
import 'providers/notification_preferences_provider.dart';
import 'services/notification_service.dart';
import 'repositories/preferences_repository.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'models/app_theme.dart';
import 'services/app_usage_tracker.dart';
import 'services/crashlytics_backend.dart';
import 'services/error_reporter.dart';
import 'utils/responsive_metrics.dart';
import 'theme/app_type.dart';
import 'theme/app_fonts.dart';
import 'firebase_options.dart';

void main() {
  // Run the whole app inside a guarded zone so that any uncaught asynchronous
  // error is funnelled into a single place. Framework and platform errors are
  // wired separately via ErrorReporter.install().
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Firebase должен быть готов до того, как ErrorReporter начнёт
      // репортить ошибки через CrashlyticsBackend — иначе первые же ошибки
      // на старте (до инициализации) будут потеряны.
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // В debug-сборках отчёты не шлём: иначе каждый крэш во время разработки
      // засорял бы дашборд реальных пользовательских данных.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );

      // Install global error handlers as early as possible.
      ErrorReporter.install(backend: CrashlyticsBackend());

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      await AppUsageTracker().initialize();
      await NotificationService.init();

      // Прогрев шейдеров liquid glass (убирает белую вспышку при первом кадре).
      await LiquidGlassWidgets.initialize();

      // Восстанавливаем ранее подобранное адаптивом качество стекла, чтобы НЕ
      // прогонять ~3-секундный бенчмарк при каждом холодном старте. Без этого
      // на слабых устройствах пользователь каждый запуск видит окно деградации
      // качества, пока идёт замер. Первый запуск: ключа нет → null → бенчмарк
      // отрабатывает один раз и сохраняет результат через onQualityChanged.
      // Последующие запуски: стартуем сразу с сохранённого качества.
      const glassQualityKey = 'glass_quality';
      final savedGlassQuality = await PreferencesRepository().getString(
        glassQualityKey,
      );
      GlassQuality? initialGlassQuality;
      if (savedGlassQuality != null) {
        for (final q in GlassQuality.values) {
          if (q.name == savedGlassQuality) {
            initialGlassQuality = q;
            break;
          }
        }
      }

      // wrap() ставит корневой backdrop-шеринг, доступность и адаптивное
      // качество (бенчмаркает устройство и сам опускает качество на слабых).
      runApp(
        LiquidGlassWidgets.wrap(
          adaptiveQuality: true,
          // ignore: experimental_member_use
          adaptiveConfig: GlassAdaptiveScopeConfig(
            // null на первом запуске → разовый бенчмарк; далее — сохранённое.
            initialQuality: initialGlassQuality,
            // Разрешаем поднять качество обратно после остывания троттлинга.
            allowStepUp: true,
            // Сохраняем подобранное качество, как только оно устаканилось.
            onQualityChanged: (_, to) {
              PreferencesRepository().setString(glassQualityKey, to.name);
            },
          ),
          child: const MyApp(),
        ),
      );
    },
    (error, stack) {
      ErrorReporter.recordError(error, stack, fatal: true);
    },
  );
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
        ChangeNotifierProxyProvider<LocalizationProvider, FontProvider>(
          create: (_) => FontProvider(),
          update: (_, localizationProvider, fontProvider) => fontProvider!
            ..setLanguageCode(localizationProvider.currentLocale.languageCode),
        ),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationPreferencesProvider(),
        ),
      ],
      child: Consumer2<ThemeProvider, LocalizationProvider>(
        builder: (context, themeProvider, localizationProvider, child) {
          final theme = themeProvider.selectedTheme;
          final fontFamily = AppFonts.forLanguageCode(
            localizationProvider.currentLocale.languageCode,
          );

          final overlayStyle = SystemUiOverlayStyle(
            statusBarBrightness: theme.isDark
                ? Brightness.dark
                : Brightness.light,
            statusBarIconBrightness: theme.isDark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarIconBrightness: theme.isDark
                ? Brightness.light
                : Brightness.dark,
          );

          return MaterialApp(
            title: 'Umra Guide',
            debugShowCheckedModeBanner: false,

            theme: _buildThemeData(theme, overlayStyle, fontFamily),

            locale: localizationProvider.currentLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) return supportedLocales.first;
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },

            home: localizationProvider.hasSelectedLanguage
                ? const HomeScreen()
                : const LanguageSelectionScreen(),

            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              final cappedTextScale = mediaQuery.textScaler
                  .scale(1.0)
                  .clamp(1.0, ResponsiveMetrics.maxTextScale)
                  .toDouble();

              // Применяем единый адаптивный масштаб типографики к теме,
              // чтобы системные компоненты (AppBar, Dialog, кнопки,
              // TextTheme) масштабировались по размеру экрана.
              final scaledTheme = AppType.of(
                context,
              ).applyToTheme(Theme.of(context));

              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(cappedTextScale),
                  ),
                  child: Theme(data: scaledTheme, child: child!),
                ),
              );
            },
          );
        },
      ),
    );
  }

  ThemeData _buildThemeData(
    AppTheme theme,
    SystemUiOverlayStyle overlayStyle,
    String fontFamily,
  ) {
    final colorScheme = ColorScheme(
      brightness: theme.isDark ? Brightness.dark : Brightness.light,
      primary: theme.primaryColor,
      onPrimary: Colors.white,
      secondary: theme.secondaryColor,
      onSecondary: Colors.white,
      error: theme.errorColor,
      onError: Colors.white,
      surface: theme.lightBackgroundColor,
      onSurface: theme.textColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: theme.primaryColor,
      scaffoldBackgroundColor: theme.backgroundColor,
      fontFamily: fontFamily,

      // AppBar
      appBarTheme: AppBarTheme(
        systemOverlayStyle: overlayStyle,
        backgroundColor: theme.backgroundColor,
        foregroundColor: theme.textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          // fontSize задаётся адаптивно в AppType.applyToTheme (роль body).
          fontWeight: FontWeight.w600,
          color: theme.textColor,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: theme.lightBackgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: theme.borderColor,
        thickness: 1,
        space: 1,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        tileColor: theme.lightBackgroundColor,
        textColor: theme.textColor,
        iconColor: theme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: theme.lightBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: theme.lightBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          // fontSize задаётся адаптивно в AppType.applyToTheme (роль body).
          fontWeight: FontWeight.bold,
          color: theme.textColor,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          // fontSize задаётся адаптивно в AppType.applyToTheme (роль caption).
          color: theme.secondaryTextColor,
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            // fontSize задаётся адаптивно в AppType.applyToTheme (роль callout).
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: theme.primaryColor,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            // fontSize задаётся адаптивно в AppType.applyToTheme (роль caption).
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // IconButton
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: theme.primaryColor),
      ),

      // Checkbox / Switch tint
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? theme.primaryColor
              : theme.borderColor,
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: theme.isDark
            ? theme.lightBackgroundColor
            : const Color(0xFF1C1C1E),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: theme.isDark ? theme.textColor : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
