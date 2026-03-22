import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../models/app_theme.dart';
import '../widgets/theme_selection_sheet.dart';
import '../constants/app_constants.dart';
import '../constants/review_config.dart';
import 'donation_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const double _cardRadius = 18;
  static const double _spacingBetweenBlocks = 16;

  Future<void> _launchEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    const String email = AppStrings.contactEmail;

    // Получаем локализованные тему и тело письма
    final String subject = Uri.encodeComponent(l10n.feedbackEmailSubject);
    final String body = Uri.encodeComponent(l10n.feedbackEmailBody);

    // Создаем URI с предзаполненной темой и телом письма
    final Uri emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');

    try {
      // Пробуем открыть почтовое приложение
      // На Android externalApplication обычно работает лучше
      bool launched = false;

      try {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        launched = true;
      } catch (e) {
        // Если не получилось, пробуем platformDefault
        try {
          await launchUrl(emailUri, mode: LaunchMode.platformDefault);
          launched = true;
        } catch (e2) {
          // Не удалось открыть почтовое приложение
          launched = false;
        }
      }

      // Если не получилось открыть, показываем диалог с email
      if (!launched && context.mounted) {
        _showEmailDialog(context, email);
      }
    } catch (e) {
      // Обработка исключений при открытии почтового приложения
      if (context.mounted) {
        _showEmailDialog(context, email);
      }
    }
  }

  void _showEmailDialog(BuildContext context, String email) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = themeProvider.selectedTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.feedbackDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.feedbackDialogMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.lightBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.feedbackDialogCancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: email));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.feedbackEmailCopied),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: Text(l10n.feedbackDialogCopy),
          ),
        ],
      ),
    );
  }

  Future<void> _launchAppStore() async {
    final Uri playStoreUri = Uri.parse(AppStrings.playStoreUrl);
    if (await canLaunchUrl(playStoreUri)) {
      await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settingsString,
          style: TextStyle(color: theme.textColor),
        ),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          return ListView(
            padding: EdgeInsets.only(
              top: 16,
              bottom: bottomPadding + 16,
              left: 16,
              right: 16,
            ),
            children: [
              // Блок 1: Обратная связь, Оценить приложение
              _buildSettingsBlock(
                context,
                theme: theme,
                children: [
                  _buildSettingsRow(
                    context,
                    icon: Icons.feedback_outlined,
                    title: l10n.feedbackString,
                    onTap: () => _launchEmail(context),
                    theme: theme,
                  ),
                  _buildDivider(theme),
                  _buildSettingsRow(
                    context,
                    icon: Icons.star_outline,
                    title: l10n.rateTheAppString,
                    onTap: _launchAppStore,
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: _spacingBetweenBlocks),
              // Блок 2: Выбрать язык, Тема приложения
              _buildSettingsBlock(
                context,
                theme: theme,
                children: [
                  _buildSettingsRow(
                    context,
                    icon: Icons.language,
                    title: l10n.selectLanguageSettingsString,
                    onTap: () {
                      _showLanguageDialog(context, localizationProvider);
                    },
                    theme: theme,
                    trailing: _buildLanguageValue(
                      context,
                      localizationProvider,
                    ),
                  ),
                  _buildDivider(theme),
                  _buildSettingsRow(
                    context,
                    icon: Icons.palette_outlined,
                    title: l10n.appThemeString,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const ThemeSelectionSheet(),
                      );
                    },
                    theme: theme,
                    trailing: _buildThemeValue(theme, l10n),
                  ),
                ],
              ),
              const SizedBox(height: _spacingBetweenBlocks),
              // Блок 3: Поддержать разработчика
              _buildSettingsBlock(
                context,
                theme: theme,
                children: [
                  _buildSettingsRow(
                    context,
                    icon: Icons.paid_outlined,
                    title: l10n.supportTheDeveloperString,
                    onTap: () => showDonationBottomSheet(context),
                    theme: theme,
                  ),
                ],
              ),
              // Reset Review State (только в тестовом режиме)
              if (ReviewConfig.isTestMode) ...[
                const SizedBox(height: _spacingBetweenBlocks),
                _buildSettingsBlock(
                  context,
                  theme: theme,
                  children: [
                    _buildSettingsRow(
                      context,
                      icon: Icons.refresh,
                      title: 'Сбросить состояние оценки (тест)',
                      onTap: () async {
                        final prefsProvider =
                            Provider.of<UserPreferencesProvider>(
                              context,
                              listen: false,
                            );
                        await prefsProvider.resetReviewState();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Состояние оценки сброшено'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsBlock(
    BuildContext context, {
    required AppTheme theme,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isEmerald ? null : theme.lightBackgroundColor,
        gradient: theme.cardGradient,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: theme.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _buildDivider(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, thickness: 0.5, color: theme.borderColor),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required AppTheme theme,
    Widget? trailing,
  }) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final iconContainerSize = isTablet ? 46.0 : 38.0;
    final iconSize = isTablet ? 22.0 : 18.0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withValues(
                  alpha: theme.isDark ? 0.25 : 0.15,
                ),
              ),
              child: Icon(icon, color: theme.primaryColor, size: iconSize),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textColor,
                ),
              ),
            ),
            if (trailing != null) ...[trailing, const SizedBox(width: 6)],
            Icon(
              Icons.chevron_right,
              color: theme.textColor.withValues(alpha: 0.45),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageValue(
    BuildContext context,
    LocalizationProvider localizationProvider,
  ) {
    final theme = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).selectedTheme;
    final locale = localizationProvider.currentLocale;
    final languageName = _getLanguageName(locale.languageCode);
    return Text(
      languageName,
      style: TextStyle(fontSize: 16, color: theme.secondaryTextColor),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'tr':
        return 'Türkçe';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return code;
    }
  }

  Widget _buildThemeValue(AppTheme theme, AppLocalizations l10n) {
    final themeName = _getThemeName(theme, l10n);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          themeName,
          style: TextStyle(fontSize: 16, color: theme.secondaryTextColor),
        ),
      ],
    );
  }

  String _getThemeName(AppTheme theme, AppLocalizations l10n) {
    switch (theme) {
      case AppTheme.nur:
        return l10n.themeHeavenly; // "Nur"
      case AppTheme.layl:
        return l10n.themeOasis; // "Layl"
      case AppTheme.emerald:
        return l10n.themeGold; // "Emerald"
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    LocalizationProvider localizationProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final languages = [
      {'code': 'ru', 'name': 'Русский'},
      {'code': 'en', 'name': 'English'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'tr', 'name': 'Türkçe'},
      {'code': 'id', 'name': 'Bahasa Indonesia'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguageString),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return ListTile(
              title: Text(lang['name']!),
              trailing:
                  localizationProvider.currentLocale.languageCode ==
                      lang['code']
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                localizationProvider.setLanguage(lang['code']!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
