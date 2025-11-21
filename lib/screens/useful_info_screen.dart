import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../models/useful_info_model.dart';
import '../screens/useful_info_detail_screen.dart';
import '../screens/janaza_prayer_screen.dart';

class UsefulInfoScreen extends StatelessWidget {
  const UsefulInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    final chapters = UsefulInfoChapters.getChapters();

    return Scaffold(
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.usefulInfoTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...chapters.map((chapter) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildInfoCard(
                  context,
                  theme,
                  title: _getChapterTitle(chapter.titleKey, l10n),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UsefulInfoDetailScreen(chapter: chapter),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            _buildInfoCard(
              context,
              theme,
              title: l10n.janazaPrayerGuide,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JanazaPrayerScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getChapterTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'etiquetteManners':
        return l10n.etiquetteManners;
      case 'hajjUmrahVirtues':
        return l10n.hajjUmrahVirtues;
      case 'hajjUmrahObligation':
        return l10n.hajjUmrahObligation;
      default:
        return key;
    }
  }

  Widget _buildInfoCard(
    BuildContext context,
    theme, {
    required String title,
    required VoidCallback onTap,
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
              colors: [theme.gradientTopColor, Colors.white],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: theme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
