import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import '../utils/platform_icons.dart';
import '../models/useful_info_model.dart';
import '../widgets/app_card.dart';
import '../widgets/arabic_text_widget.dart';
import '../utils/responsive_metrics.dart';
import '../theme/app_type.dart';

bool _isLongArabicLine(String s) {
  final trimmed = s.trim();
  if (trimmed.length < 40) return false;
  final first = trimmed.runes.firstOrNull;
  if (first == null) return false;
  return (first >= 0x0600 && first <= 0x06FF) ||
      (first >= 0x0750 && first <= 0x077F);
}

// Парсинг контента: блоки, разделённые \n\n; строки вида "1) ..." — заголовок
List<({bool isHeading, String text})> _parseFormattedContent(String content) {
  final blocks = content.split('\n\n');
  final result = <({bool isHeading, String text})>[];
  final headingRe = RegExp(r'^\d+\)');

  for (final block in blocks) {
    final trimmed = block.trim();
    if (trimmed.isEmpty) continue;
    final lines = trimmed.split('\n');
    final firstLine = lines.first;
    if (headingRe.hasMatch(firstLine)) {
      result.add((isHeading: true, text: firstLine));
      final rest = lines.skip(1).join('\n').trim();
      if (rest.isNotEmpty) result.add((isHeading: false, text: rest));
    } else {
      result.add((isHeading: false, text: trimmed));
    }
  }
  return result;
}

Widget _buildArabicCard(String line, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: ArabicTextWidget(text: line, addHorizontalPadding: false),
  );
}

Widget _buildBodyBlock(String text, Color textColor, BuildContext context) {
  final metrics = ResponsiveMetrics.of(context);
  final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (int i = 0; i < lines.length; i++) ...[
        if (_isLongArabicLine(lines[i]))
          _buildArabicCard(lines[i], context)
        else
          Text(
            lines[i],
            style: TextStyle(
              fontSize: metrics.bodyFontSize,
              color: textColor,
              height: 1.6,
            ),
          ),
        if (i < lines.length - 1 && !_isLongArabicLine(lines[i]))
          const SizedBox(height: 6),
      ],
    ],
  );
}

Widget _buildFormattedContent(
  String content,
  Color textColor,
  BuildContext context,
) {
  final metrics = ResponsiveMetrics.of(context);
  final blocks = _parseFormattedContent(content);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final block in blocks)
        Padding(
          padding: EdgeInsets.only(bottom: block.isHeading ? 8 : 16),
          child: block.isHeading
              ? Text(
                  block.text,
                  style: TextStyle(
                    fontSize: metrics.listFontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                )
              : _buildBodyBlock(block.text, textColor, context),
        ),
    ],
  );
}

class UsefulInfoDetailScreen extends StatelessWidget {
  final Chapter chapter;

  const UsefulInfoDetailScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final hPad = isTablet ? 20.0 : 16.0;
    final cardRadius = isTablet ? 28.0 : 24.0;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _getChapterTitle(chapter.titleKey, l10n),
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
                  context,
                  chapter.subChapters,
                  theme,
                  l10n,
                  hPad,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildRows(
    BuildContext context,
    List<SubChapter> subChapters,
    AppTheme theme,
    AppLocalizations l10n,
    double hPad,
  ) {
    final rows = <Widget>[];
    for (int i = 0; i < subChapters.length; i++) {
      final sub = subChapters[i];
      rows.add(
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubChapterDetailScreen(
                subChapter: sub,
                chapterTitle: _getChapterTitle(chapter.titleKey, l10n),
              ),
            ),
          ),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getSubChapterTitle(sub.titleKey, l10n),
                    style: TextStyle(
                      fontSize: AppType.of(context).callout,
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
      if (i < subChapters.length - 1) {
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
      default:
        return key;
    }
  }

  String _getSubChapterTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'safarSunnahsTitle':
        return l10n.safarSunnahsTitle;
      case 'sincerity':
        return l10n.sincerity;
      case 'laws':
        return l10n.laws;
      case 'choiceOfCompanions':
        return l10n.choiceOfCompanions;
      case 'financialIndependence':
        return l10n.financialIndependence;
      case 'nobleManners':
        return l10n.nobleManners;
      case 'zikrAndPrayers':
        return l10n.zikrAndPrayers;
      case 'cautionInRelationships':
        return l10n.cautionInRelationships;
      case 'atonementAndRewards':
        return l10n.atonementAndRewards;
      case 'hajjForWomen':
        return l10n.hajjForWomen;
      case 'perfectHajj':
        return l10n.perfectHajj;
      case 'followingTheSunnah':
        return l10n.followingTheSunnah;
      case 'hajjObligationEvidence':
        return l10n.hajjObligationEvidence;
      case 'umrahObligationEvidence':
        return l10n.umrahObligationEvidence;
      case 'conclusion':
        return l10n.conclusion;
      default:
        return key;
    }
  }
}

class SubChapterDetailScreen extends StatelessWidget {
  final SubChapter subChapter;
  final String chapterTitle;

  const SubChapterDetailScreen({
    super.key,
    required this.subChapter,
    required this.chapterTitle,
  });

  String _getSubChapterTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'safarSunnahsTitle':
        return l10n.safarSunnahsTitle;
      case 'sincerity':
        return l10n.sincerity;
      case 'laws':
        return l10n.laws;
      case 'choiceOfCompanions':
        return l10n.choiceOfCompanions;
      case 'financialIndependence':
        return l10n.financialIndependence;
      case 'nobleManners':
        return l10n.nobleManners;
      case 'zikrAndPrayers':
        return l10n.zikrAndPrayers;
      case 'cautionInRelationships':
        return l10n.cautionInRelationships;
      case 'atonementAndRewards':
        return l10n.atonementAndRewards;
      case 'hajjForWomen':
        return l10n.hajjForWomen;
      case 'perfectHajj':
        return l10n.perfectHajj;
      case 'followingTheSunnah':
        return l10n.followingTheSunnah;
      case 'hajjObligationEvidence':
        return l10n.hajjObligationEvidence;
      case 'umrahObligationEvidence':
        return l10n.umrahObligationEvidence;
      case 'conclusion':
        return l10n.conclusion;
      default:
        return key;
    }
  }

  String _getSubChapterContent(String key, AppLocalizations l10n) {
    switch (key) {
      case 'etiquetteMannersText1':
        return l10n.etiquetteMannersText1;
      case 'etiquetteMannersText2':
        return l10n.etiquetteMannersText2;
      case 'etiquetteMannersText3':
        return l10n.etiquetteMannersText3;
      case 'etiquetteMannersText4':
        return l10n.etiquetteMannersText4;
      case 'etiquetteMannersText5':
        return l10n.etiquetteMannersText5;
      case 'etiquetteMannersText6':
        return l10n.etiquetteMannersText6;
      case 'etiquetteMannersText7':
        return l10n.etiquetteMannersText7;
      case 'hajjUmrahVirtuesText1':
        return l10n.hajjUmrahVirtuesText1;
      case 'hajjUmrahVirtuesText2':
        return l10n.hajjUmrahVirtuesText2;
      case 'hajjUmrahVirtuesText3':
        return l10n.hajjUmrahVirtuesText3;
      case 'hajjUmrahVirtuesText4':
        return l10n.hajjUmrahVirtuesText4;
      case 'hajjUmrahObligationObligationEvidence':
        return l10n.hajjUmrahObligationObligationEvidence;
      case 'hajjUmrahObligationEvidenceUmrahObligation':
        return l10n.hajjUmrahObligationEvidenceUmrahObligation;
      case 'hajjUmrahObligationConcludingEvidence':
        return l10n.hajjUmrahObligationConcludingEvidence;
      case 'safarSunnahsContent':
        return l10n.safarSunnahsContent;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _getSubChapterTitle(
            subChapter.titleKey,
            AppLocalizations.of(context)!,
          ),
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor),
        ),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          final metrics = ResponsiveMetrics.of(context);
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 16, bottom: bottomPadding + 16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.listScreenHPad,
                  ),
                  child: Builder(
                    builder: (context) {
                      final content = _getSubChapterContent(
                        subChapter.contentKey,
                        AppLocalizations.of(context)!,
                      );
                      final useFormatted =
                          content.contains('1) ') || content.startsWith('1)');
                      if (useFormatted) {
                        return _buildFormattedContent(
                          content,
                          theme.textColor,
                          context,
                        );
                      }
                      return Text(
                        content,
                        style: TextStyle(
                          fontSize: metrics.bodyFontSize,
                          color: theme.textColor,
                          height: 1.5,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
