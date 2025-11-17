import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../models/step_model.dart';
import '../screens/step_detail_screen.dart';
import '../screens/useful_info_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/prayer_time_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final prefsProvider = Provider.of<UserPreferencesProvider>(context);
    final theme = themeProvider.selectedTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'UMRA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            prefsProvider.isGridView ? Icons.list : Icons.grid_view,
            color: Colors.black87,
          ),
          onPressed: () {
            prefsProvider.setIsGridView(!prefsProvider.isGridView);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.black87),
            onPressed: () {
              _showLanguageDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.access_time, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrayerTimeScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: prefsProvider.isGridView
            ? _buildGridView(context, theme)
            : _buildListView(context, theme),
      ),
    );
  }

  Widget _buildGridView(BuildContext context, theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: UmraSteps.allSteps.length,
      itemBuilder: (context, index) {
        final step = UmraSteps.allSteps[index];
        return _buildStepCard(context, step, theme, showIndex: true);
      },
    );
  }

  Widget _buildListView(BuildContext context, theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: UmraSteps.allSteps.length,
      itemBuilder: (context, index) {
        final step = UmraSteps.allSteps[index];
        return SizedBox(
          height: 120,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: _buildStepCard(context, step, theme, showIndex: false),
          ),
        );
      },
    );
  }

  Widget _buildStepCard(BuildContext context, UmraStep step, theme, {required bool showIndex}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          if (step.id == 'useful') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UsefulInfoScreen(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StepDetailScreen(step: step),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                height: showIndex ? 120 : 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.gradientTopColor, Colors.white],
                  ),
                ),
                child: Center(
                  child: showIndex
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.mosque,
                              size: 60,
                              color: theme.primaryColor.withOpacity(0.3),
                            ),
                            Text(
                              '${step.stepNumber}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        )
                      : Icon(
                          Icons.mosque,
                          size: 40,
                          color: theme.primaryColor,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  String title;
                  try {
                    // Получаем локализованную строку по ключу
                    title = _getLocalizedTitle(step.titleKey, l10n);
                  } catch (e) {
                    title = step.titleKey;
                  }
                  return Text(
                    title,
                    style: TextStyle(
                      fontSize: showIndex ? 12 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedTitle(String key, AppLocalizations? l10n) {
    if (l10n == null) return key;

    switch (key) {
      case 'titleIhramScreen':
        return l10n.titleIhramScreen;
      case 'titleRoundKaabaScreen':
        return l10n.titleRoundKaabaScreen;
      case 'titlePlaceIbrohimStandScreen':
        return l10n.titlePlaceIbrohimStandScreen;
      case 'titleWaterZamzamScreen':
        return l10n.titleWaterZamzamScreen;
      case 'titleBlackStoneScreen':
        return l10n.titleBlackStoneScreen;
      case 'titleSafaAndMarvaScreen':
        return l10n.titleSafaAndMarvaScreen;
      case 'titleShaveHeadScreen':
        return l10n.titleShaveHeadScreen;
      case 'usefulTitle':
        return l10n.usefulTitle;
      default:
        return key;
    }
  }

  void _showLanguageDialog(BuildContext context) {
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
      builder: (dialogContext) => Consumer<LocalizationProvider>(
        builder: (context, locProvider, child) {
          return AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: languages.map((lang) {
                return ListTile(
                  title: Text(lang['name']!),
                  trailing: locProvider.currentLocale.languageCode == lang['code']
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () async {
                    await locProvider.setLanguage(lang['code']!);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
