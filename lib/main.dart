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
import 'providers/notification_preferences_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'models/app_theme.dart';
import 'services/app_usage_tracker.dart';
import 'utils/responsive_metrics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await AppUsageTracker().initialize();
  await NotificationService.init();

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

                    theme: _buildThemeData(theme, overlayStyle),

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

                      return AnnotatedRegion<SystemUiOverlayStyle>(
                        value: overlayStyle,
                        child: MediaQuery(
                          data: mediaQuery.copyWith(
                            textScaler: TextScaler.linear(cappedTextScale),
                          ),
                          child: child!,
                        ),
                      );
                    },
                  );
                },
          ),
    );
  }

  ThemeData _buildThemeData(AppTheme theme, SystemUiOverlayStyle overlayStyle) {
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
      fontFamily: 'Lato',

      // AppBar
      appBarTheme: AppBarTheme(
        systemOverlayStyle: overlayStyle,
        backgroundColor: theme.backgroundColor,
        foregroundColor: theme.textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
        titleTextStyle: TextStyle(
          fontFamily: 'Lato',
          fontSize: 18,
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
          fontFamily: 'Lato',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.textColor,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Lato',
          fontSize: 15,
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
          textStyle: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: theme.primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 15,
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
          fontFamily: 'Lato',
          color: theme.isDark ? theme.textColor : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
