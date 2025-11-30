import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../models/step_model.dart';
import '../models/app_theme.dart';
import '../screens/step_detail_screen.dart';
import '../screens/useful_info_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/prayer_time_screen.dart';
import '../widgets/styled_image_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'UMRA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.access_time, color: theme.textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrayerTimeScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: theme.textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _buildListView(context, theme),
      ),
    );
  }

  Widget _buildListView(BuildContext context, AppTheme theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      itemCount: UmraSteps.allSteps.length,
      itemBuilder: (context, index) {
        final step = UmraSteps.allSteps[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: _buildStepRow(context, step, theme),
        );
      },
    );
  }

  /// Виджет для list view (как StepRow в Swift)
  Widget _buildStepRow(BuildContext context, UmraStep step, AppTheme theme) {
    return GestureDetector(
      onTap: () {
        _navigateToStep(context, step);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.lightBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.isDark 
                  ? Colors.black.withValues(alpha: 0.3) 
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Изображение
            StyledImageWithTheme(
              imageName: step.imageName,
              theme: theme,
            ),
            const SizedBox(width: 15),
            // Текст
            Expanded(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  final title = _getLocalizedTitle(step.titleKey, l10n);
                  return Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textColor,
                    ),
                  );
                },
              ),
            ),
            // Стрелка
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                size: 14,
                color: theme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToStep(BuildContext context, UmraStep step) {
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

}
