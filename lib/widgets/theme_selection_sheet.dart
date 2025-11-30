import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';

class ThemeSelectionSheet extends StatelessWidget {
  const ThemeSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: theme.lightBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              l10n.themeSelectTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppTheme.values.map((appTheme) {
                  final themeName = _getThemeName(appTheme, l10n);
                  final isSelected = themeProvider.selectedTheme == appTheme;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: isSelected ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? appTheme.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          themeProvider.setTheme(appTheme);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: appTheme.isDark
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFE5E7EB), // Светло-серый верх
                                      const Color(0xFFF3F4F6), // Ещё светлее низ
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      appTheme.gradientTopColor,
                                      appTheme.lightBackgroundColor,
                                    ],
                                  ),
                          ),
                          child: Row(
                            children: [
                              Circle(color: appTheme.previewColor, size: 50),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  themeName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: appTheme.isDark
                                        ? const Color(0xFF111827) // Тёмный текст для светлого фона
                                        : appTheme.textColor,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: appTheme.primaryColor,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(AppTheme theme, AppLocalizations l10n) {
    switch (theme) {
      case AppTheme.blue:
        return l10n.themeHeavenly;
      case AppTheme.green:
        return l10n.themeOasis;
      case AppTheme.gold:
        return l10n.themeGold;
      case AppTheme.turquoise:
        return l10n.themeTurquoise;
      case AppTheme.dark:
        return l10n.themeDark;
    }
  }
}

// Простой виджет круга для превью темы
class Circle extends StatelessWidget {
  final Color color;
  final double size;

  const Circle({super.key, required this.color, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
