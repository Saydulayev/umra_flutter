import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/localization_provider.dart';
import '../models/app_theme.dart';
import '../widgets/theme_selection_sheet.dart';
import '../constants/app_constants.dart';
import 'privacy_policy_screen.dart';
import 'donation_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                color: Colors.grey[200],
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
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settingsString,
          style: TextStyle(color: theme.textColor),
        ),
        backgroundColor: theme.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Feedback Button
            _buildSettingsItem(
              context,
              icon: Icons.message,
              title: l10n.feedbackString,
              onTap: () => _launchEmail(context),
              theme: theme,
            ),
            const SizedBox(height: 8),
            // Rate the App Button
            _buildSettingsItem(
              context,
              icon: Icons.star,
              title: l10n.rateTheAppString,
              onTap: _launchAppStore,
              theme: theme,
            ),
            const SizedBox(height: 8),
            // Language Selection
            _buildSettingsItem(
              context,
              icon: Icons.language,
              title: l10n.selectLanguageSettingsString,
              onTap: () {
                _showLanguageDialog(context, localizationProvider);
              },
              theme: theme,
            ),
            const SizedBox(height: 8),
            // Theme Selection
            _buildSettingsItem(
              context,
              icon: Icons.palette,
              title: l10n.appThemeString,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const ThemeSelectionSheet(),
                );
              },
              theme: theme,
            ),
            const SizedBox(height: 8),
            // Support Developer / Donations
            _buildSettingsItem(
              context,
              icon: Icons.favorite,
              title: l10n.supportTheDeveloperString,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DonationScreen(),
                  ),
                );
              },
              theme: theme,
            ),
            const SizedBox(height: 8),
            // Privacy Policy
            _buildSettingsItem(
              context,
              icon: Icons.privacy_tip,
              title: l10n.privacyPolicyTitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required AppTheme theme,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.gradientTopColor, theme.lightBackgroundColor],
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.primaryColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textColor,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.secondaryTextColor,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.primaryColor),
            ],
          ),
        ),
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
