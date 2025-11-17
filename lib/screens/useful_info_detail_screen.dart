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
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                        colors: [theme.gradientTopColor, Colors.white],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getSubChapterTitle(subChapter.titleKey, l10n),
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
    // Метод для получения локализованного контента подглав
    // Когда контент будет добавлен в .arb файлы, можно будет использовать switch-case
    // Пока возвращаем ключ как fallback
    // TODO: Добавить ключи контента в .arb файлы и использовать их здесь
    switch (key) {
      // Пока контент не добавлен в локализацию, возвращаем ключ
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
          style: const TextStyle(fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
          ),
        ),
      ),
    );
  }
}
