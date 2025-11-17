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
    // Используем локализацию, если ключ существует, иначе fallback на английский
    switch (key) {
      case 'etiquetteManners':
        return 'Etiquette and Manners';
      case 'hajjUmrahVirtues':
        return 'Hajj and Umrah Virtues';
      case 'hajjUmrahObligation':
        return 'Hajj and Umrah Obligation';
      default:
        return key;
    }
  }

  String _getSubChapterTitle(String key, AppLocalizations l10n) {
    // Используем локализацию, если ключ существует, иначе возвращаем ключ
    // В будущем можно добавить эти ключи в .arb файлы
    return key;
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
    // Используем локализацию, если ключ существует, иначе возвращаем ключ
    return key;
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
            subChapter
                .contentKey, // В будущем можно добавить локализацию контента
            style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
          ),
        ),
      ),
    );
  }
}
