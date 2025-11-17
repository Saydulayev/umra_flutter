import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/user_preferences_provider.dart';
import 'providers/font_provider.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'models/app_theme.dart';

void main() {
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

                  return MaterialApp(
                    key: ValueKey(localizationProvider.currentLocale.toString()),
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
                        if (supportedLocale.languageCode == locale.languageCode) {
                          return supportedLocale;
                        }
                      }
                      // Если не найдено, возвращаем первый поддерживаемый
                      return supportedLocales.first;
                    },

                    // Начальный экран
                    home: prefsProvider.hasSelectedLanguage
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
    return MaterialColor(color.value, <int, Color>{
      50: color.withOpacity(0.1),
      100: color.withOpacity(0.2),
      200: color.withOpacity(0.3),
      300: color.withOpacity(0.4),
      400: color.withOpacity(0.5),
      500: color,
      600: color.withOpacity(0.7),
      700: color.withOpacity(0.8),
      800: color.withOpacity(0.9),
      900: color,
    });
  }
}
