import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import '../utils/platform_icons.dart';
import '../widgets/app_card.dart';
import '../theme/app_type.dart';
import '../utils/responsive_metrics.dart';
import '../models/useful_info_model.dart';
import '../screens/useful_info_detail_screen.dart'
    show UsefulInfoDetailScreen, SubChapterDetailScreen;
import '../screens/janaza_prayer_screen.dart';

class UsefulInfoScreen extends StatelessWidget {
  const UsefulInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final hPad = isTablet ? 20.0 : 16.0;
    final cardRadius = ResponsiveMetrics.of(context).primaryCardRadius;

    final chapters = UsefulInfoChapters.getChapters();

    final items = <_InfoItem>[
      ...chapters.map(
        (chapter) => _InfoItem(
          title: _getChapterTitle(chapter.titleKey, l10n),
          onTap: () {
            if (chapter.directContentKey != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubChapterDetailScreen(
                    subChapter: SubChapter(
                      id: chapter.id,
                      titleKey: chapter.titleKey,
                      contentKey: chapter.directContentKey!,
                    ),
                    chapterTitle: _getChapterTitle(chapter.titleKey, l10n),
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UsefulInfoDetailScreen(chapter: chapter),
                ),
              );
            }
          },
        ),
      ),
      _InfoItem(
        title: l10n.janazaPrayerGuide,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JanazaPrayerScreen()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.usefulInfoTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor),
        ),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, bottomPadding + 32),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveMetrics.of(context).contentMaxWidth,
                ),
                child: AppCard(
                  theme: theme,
                  cornerRadius: cardRadius,
                  shadows: [
                    BoxShadow(
                      color: theme.cardShadowColor,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildRows(
                      items,
                      theme,
                      isTablet,
                      AppType.of(context),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildRows(
    List<_InfoItem> items,
    AppTheme theme,
    bool isTablet,
    AppType type,
  ) {
    final rows = <Widget>[];
    final hPad = isTablet ? 20.0 : 16.0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      rows.add(
        GestureDetector(
          onTap: item.onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: type.callout,
                      color: theme.textColor,
                    ),
                  ),
                ),
                Icon(
                  PlatformIcons.chevronRight,
                  size: 18,
                  color: theme.textColor.withValues(alpha: 0.25),
                ),
              ],
            ),
          ),
        ),
      );

      if (i < items.length - 1) {
        rows.add(
          Divider(
            height: 1,
            thickness: 0.5,
            indent: hPad,
            endIndent: hPad,
            color: theme.borderColor,
          ),
        );
      }
    }

    return rows;
  }

  String _getChapterTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'etiquetteManners':
        return l10n.etiquetteManners;
      case 'hajjUmrahVirtues':
        return l10n.hajjUmrahVirtues;
      case 'hajjUmrahObligation':
        return l10n.hajjUmrahObligation;
      case 'safarSunnahsTitle':
        return l10n.safarSunnahsTitle;
      default:
        return key;
    }
  }
}

class _InfoItem {
  final String title;
  final VoidCallback onTap;
  const _InfoItem({required this.title, required this.onTap});
}
