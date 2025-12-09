import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  final List<Map<String, String>> languages = const [
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'en', 'name': 'English'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final theme = themeProvider.selectedTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          final topPadding = MediaQuery.of(context).viewPadding.top;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: topPadding + 24,
                bottom: bottomPadding + 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Логотип или заголовок
                  Text(
                    'UMRA',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Выберите язык / Select Language',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: theme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Список языков
                  ...languages.map((lang) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await localizationProvider.setLanguage(lang['code']!);
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.lightBackgroundColor,
                          foregroundColor: theme.textColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: theme.primaryColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          elevation: 4,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            lang['name']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
