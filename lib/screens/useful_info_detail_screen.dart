import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../models/useful_info_model.dart';

class UsefulInfoDetailScreen extends StatelessWidget {
  final Chapter chapter;

  const UsefulInfoDetailScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getChapterTitle(chapter.titleKey, l10n),
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor),
        ),
        backgroundColor: theme.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: chapter.subChapters.map((subChapter) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubChapterDetailScreen(
                          subChapter: subChapter,
                          chapterTitle: _getChapterTitle(
                            chapter.titleKey,
                            l10n,
                          ),
                        ),
                      ),
                    );
                  },
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
                        Expanded(
                          child: Text(
                            _getSubChapterTitle(subChapter.titleKey, l10n),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.textColor,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: theme.primaryColor),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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

  String _getSubChapterTitle(String key, AppLocalizations l10n) {
    switch (key) {
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
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;

    return Scaffold(
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getSubChapterTitle(
            subChapter.titleKey,
            AppLocalizations.of(context)!,
          ),
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor),
        ),
        backgroundColor: theme.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            _getSubChapterContent(
              subChapter.contentKey,
              AppLocalizations.of(context)!,
            ),
            style: TextStyle(fontSize: 18, color: theme.textColor, height: 1.5),
          ),
        ),
      ),
    );
  }
}
