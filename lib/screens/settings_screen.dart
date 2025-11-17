import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/localization_provider.dart';
import '../models/app_theme.dart';
import '../widgets/theme_selection_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'saydulayev.wien@gmail.com',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchAppStore() async {
    final Uri appStoreUri = Uri.parse('https://apps.apple.com/app/id1673683355');
    if (await canLaunchUrl(appStoreUri)) {
      await launchUrl(appStoreUri, mode: LaunchMode.externalApplication);
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
        title: Text(l10n.settingsString),
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
              onTap: _launchEmail,
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
              subtitle: _getThemeName(themeProvider.selectedTheme, l10n),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const ThemeSelectionSheet(),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
              colors: [theme.gradientTopColor, Colors.white],
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.primaryColor,
              ),
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
              trailing: localizationProvider.currentLocale.languageCode ==
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
