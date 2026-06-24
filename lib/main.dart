import 'dart:async';

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
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'models/app_theme.dart';
import 'services/app_usage_tracker.dart';
import 'services/error_reporter.dart';
import 'utils/responsive_metrics.dart';
import 'theme/app_type.dart';
import 'theme/app_fonts.dart';

void main() {
  // Run the whole app inside a guarded zone so that any uncaught asynchronous
  // error is funnelled into a single place. Framework and platform errors are
  // wired separately via ErrorReporter.install().
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Install global error handlers as early as possible. To enable crash
      // reporting in production, pass a backend here, e.g.:
      //   ErrorReporter.install(backend: CrashlyticsBackend());
      ErrorReporter.install();

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      await AppUsageTracker().initialize();
      await NotificationService.init();

      // Прогрев шейдеров liquid glass (убирает белую вспышку при первом кадре).
      await LiquidGlassWidgets.initialize();

      // wrap() ставит корневой backdrop-шеринг, доступность и адаптивное
      // качество (бенчмаркает устройство и сам опускает качество на слабых).
      runApp(
        LiquidGlassWidgets.wrap(
          adaptiveQuality: true,
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
          update: (_, localizationProvider, fontProvider) =>
              fontProvider!
                ..setLanguageCode(
                  localizationProvider.currentLocale.languageCode,
                ),
        ),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationPreferencesProvider(),
        ),
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
                        if (supportedLocale.languageCode ==
                            locale.languageCode) {
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
