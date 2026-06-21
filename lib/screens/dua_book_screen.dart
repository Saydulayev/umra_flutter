import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dua_model.dart';
import '../models/app_theme.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/platform_icons.dart';
import '../widgets/app_card.dart';
import '../widgets/arabic_text_widget.dart';
import '../widgets/player_widget.dart';
import '../utils/responsive_metrics.dart';
import '../theme/app_type.dart';

// ─── Key → localized string helper ──────────────────────────────────────────

String _localized(AppLocalizations l10n, String key) {
  switch (key) {
    // Category labels
    case 'duaCategoryUmrah': return l10n.duaCategoryUmrah;
    case 'duaCategoryHajj': return l10n.duaCategoryHajj;
    // UI labels
    case 'duaDetailTranslitLabel': return l10n.duaDetailTranslitLabel;
    case 'duaDetailTransLabel': return l10n.duaDetailTransLabel;
    // Titles
    case 'duaNiyyahUmrahTitle': return l10n.duaNiyyahUmrahTitle;
    case 'duaIhramUmrahTitle': return l10n.duaIhramUmrahTitle;
    case 'duaTalbiyahTitle': return l10n.duaTalbiyahTitle;
    case 'duaMasjidEnterTitle': return l10n.duaMasjidEnterTitle;
    case 'duaConditionTitle': return l10n.duaConditionTitle;
    case 'duaRabbanaTitle': return l10n.duaRabbanaTitle;
    case 'duaMaqamIbrahimTitle': return l10n.duaMaqamIbrahimTitle;
    case 'duaSafaAyahTitle': return l10n.duaSafaAyahTitle;
    case 'duaNabdauTitle': return l10n.duaNabdauTitle;
    case 'duaZikrSafaTitle': return l10n.duaZikrSafaTitle;
    case 'duaRabbiIghfirTitle': return l10n.duaRabbiIghfirTitle;
    case 'duaMasjidExitTitle': return l10n.duaMasjidExitTitle;
    case 'duaNiyyahHajjTitle': return l10n.duaNiyyahHajjTitle;
    case 'duaIhramHajjTitle': return l10n.duaIhramHajjTitle;
    case 'duaArafatTitle': return l10n.duaArafatTitle;
    // Transliterations (new keys)
    case 'duaNiyyahUmrahTranslit': return l10n.duaNiyyahUmrahTranslit;
    case 'duaIhramUmrahTranslit': return l10n.duaIhramUmrahTranslit;
    case 'duaTalbiyahTranslit': return l10n.duaTalbiyahTranslit;
    case 'duaMasjidEnterTranslit': return l10n.duaMasjidEnterTranslit;
    case 'duaConditionTranslit': return l10n.duaConditionTranslit;
    case 'duaRabbanaTranslit': return l10n.duaRabbanaTranslit;
    case 'duaMaqamIbrahimTranslit': return l10n.duaMaqamIbrahimTranslit;
    case 'duaSafaAyahTranslit': return l10n.duaSafaAyahTranslit;
    case 'duaNabdauTranslit': return l10n.duaNabdauTranslit;
    case 'duaZikrSafaTranslit': return l10n.duaZikrSafaTranslit;
    case 'duaRabbiIghfirTranslit': return l10n.duaRabbiIghfirTranslit;
    case 'duaMasjidExitTranslit': return l10n.duaMasjidExitTranslit;
    // Translations (new keys)
    case 'duaNiyyahUmrahTrans': return l10n.duaNiyyahUmrahTrans;
    case 'duaIhramUmrahTrans': return l10n.duaIhramUmrahTrans;
    case 'duaTalbiyahTrans': return l10n.duaTalbiyahTrans;
    case 'duaMasjidEnterTrans': return l10n.duaMasjidEnterTrans;
    case 'duaConditionTrans': return l10n.duaConditionTrans;
    case 'duaRabbanaTrans': return l10n.duaRabbanaTrans;
    case 'duaMaqamIbrahimTrans': return l10n.duaMaqamIbrahimTrans;
    case 'duaSafaAyahTrans': return l10n.duaSafaAyahTrans;
    case 'duaNabdauTrans': return l10n.duaNabdauTrans;
    case 'duaZikrSafaTrans': return l10n.duaZikrSafaTrans;
    case 'duaRabbiIghfirTrans': return l10n.duaRabbiIghfirTrans;
    case 'duaMasjidExitTrans': return l10n.duaMasjidExitTrans;
    case 'duaNiyyahHajjTrans': return l10n.duaNiyyahHajjTrans;
    // Reused Hajj keys
    case 'hajj_step1_ihram_transliteration': return l10n.hajj_step1_ihram_transliteration;
    case 'hajj_step1_ihram_dua_transliteration': return l10n.hajj_step1_ihram_dua_transliteration;
    case 'hajj_step1_ihram_dua_translation': return l10n.hajj_step1_ihram_dua_translation;
    case 'hajj_step1_talbiyah_transliteration': return l10n.hajj_step1_talbiyah_transliteration;
    case 'hajj_step1_talbiyah_translation': return l10n.hajj_step1_talbiyah_translation;
    case 'hajj_step2_dua_transliteration': return l10n.hajj_step2_dua_transliteration;
    case 'hajj_step2_dua_translation': return l10n.hajj_step2_dua_translation;
    default: return key;
  }
}

// ─── DuaBookScreen (category list) ──────────────────────────────────────────

class DuaBookScreen extends StatelessWidget {
  const DuaBookScreen({super.key});

  static const _cardRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final l10n = AppLocalizations.of(context)!;
    final dividerColor = theme.textColor.withValues(alpha: 0.10);

    final List<Widget> rows = [];
    final categories = DuaBookData.categories;
    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      rows.add(_CategoryRow(
        category: cat,
        theme: theme,
        l10n: l10n,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuaCategoryScreen(category: cat),
          ),
        ),
      ));
      if (i < categories.length - 1) {
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(height: 1, thickness: 0.5, color: dividerColor),
        ));
      }
    }

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.duaBookNavTitle,
          style: TextStyle(
            color: theme.textColor,
            fontWeight: FontWeight.w600,
            fontSize: AppType.of(context).callout,
          ),
        ),
        leading: IconButton(
          icon: Icon(PlatformIcons.arrowBack, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Builder(
        builder: (context) {
          final metrics = ResponsiveMetrics.of(context);
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              metrics.listScreenHPad,
              8,
              metrics.listScreenHPad,
              bottomPadding + 32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
                child: AppCard(
                  theme: theme,
                  cornerRadius: _cardRadius,
                  shadows: [
                    BoxShadow(
                      color: theme.cardShadowColor,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  child: Column(mainAxisSize: MainAxisSize.min, children: rows),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final DuaCategory category;
  final AppTheme theme;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.category,
    required this.theme,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);
    final badgeSize = metrics.duaBadgeSize;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    category.id == 'umrah' ? 'U' : 'H',
                    style: TextStyle(
                      fontSize: badgeSize * 0.40,
                      fontWeight: FontWeight.bold,
                      color: theme.isDark ? Colors.black : Colors.white,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _localized(l10n, category.titleKey),
                  style: TextStyle(
                    fontSize: metrics.stepItemFontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor,
                  ),
                ),
              ),
              Text(
                '${category.duas.length}',
                style: TextStyle(
                  fontSize: AppType.of(context).caption,
                  fontWeight: FontWeight.w600,
                  color: theme.textColor.withValues(alpha: 0.40),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                PlatformIcons.chevronRight,
                color: theme.textColor.withValues(alpha: 0.25),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── DuaCategoryScreen (list of duas) ────────────────────────────────────────

class DuaCategoryScreen extends StatelessWidget {
  final DuaCategory category;

  const DuaCategoryScreen({super.key, required this.category});

  static const _cardRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final l10n = AppLocalizations.of(context)!;
    final dividerColor = theme.textColor.withValues(alpha: 0.10);

    final List<Widget> rows = [];
    final duas = category.duas;
    for (int i = 0; i < duas.length; i++) {
      final dua = duas[i];
      rows.add(_DuaRow(
        dua: dua,
        theme: theme,
        l10n: l10n,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuaPageScreen(
              category: category,
              initialIndex: i,
            ),
          ),
        ),
      ));
      if (i < duas.length - 1) {
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(height: 1, thickness: 0.5, color: dividerColor),
        ));
      }
    }

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _localized(l10n, category.titleKey),
          style: TextStyle(
            color: theme.textColor,
            fontWeight: FontWeight.w600,
            fontSize: AppType.of(context).callout,
          ),
        ),
        leading: IconButton(
          icon: Icon(PlatformIcons.arrowBack, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Builder(
        builder: (context) {
          final metrics = ResponsiveMetrics.of(context);
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              metrics.listScreenHPad,
              8,
              metrics.listScreenHPad,
              bottomPadding + 32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
                child: AppCard(
                  theme: theme,
                  cornerRadius: _cardRadius,
                  shadows: [
                    BoxShadow(
                      color: theme.cardShadowColor,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  child: Column(mainAxisSize: MainAxisSize.min, children: rows),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DuaRow extends StatelessWidget {
  final Dua dua;
  final AppTheme theme;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _DuaRow({
    required this.dua,
    required this.theme,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // Arabic preview (right-aligned, limited width)
              SizedBox(
                width: metrics.duaArabicPreviewWidth,
                child: Text(
                  dua.arabic.split('\n').first,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  locale: const Locale('ar'),
                  style: TextStyle(
                    fontFamily: 'KFGQPCUthmanTahaNaskh',
                    fontSize: metrics.duaArabicPreviewFontSize,
                    color: theme.primaryColor,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _localized(l10n, dua.titleKey),
                  style: TextStyle(
                    fontSize: AppType.of(context).callout,
                    fontWeight: FontWeight.w500,
                    color: theme.textColor,
                  ),
                ),
              ),
              Icon(
                PlatformIcons.chevronRight,
                color: theme.textColor.withValues(alpha: 0.25),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── DuaPageScreen (horizontal paging) ───────────────────────────────────────

class DuaPageScreen extends StatefulWidget {
  final DuaCategory category;
  final int initialIndex;

  const DuaPageScreen({
    super.key,
    required this.category,
    required this.initialIndex,
  });

  @override
  State<DuaPageScreen> createState() => _DuaPageScreenState();
}

class _DuaPageScreenState extends State<DuaPageScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final l10n = AppLocalizations.of(context)!;
    final duas = widget.category.duas;
    final currentDua = duas[_currentIndex];

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _localized(l10n, currentDua.titleKey),
          style: TextStyle(
            color: theme.textColor,
            fontWeight: FontWeight.w600,
            fontSize: AppType.of(context).callout,
          ),
        ),
        leading: IconButton(
          icon: Icon(PlatformIcons.arrowBack, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: duas.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => _DuaSinglePage(dua: duas[i]),
          ),
          if (duas.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).viewPadding.bottom + 16,
              left: 0,
              right: 0,
              child: _PageIndicator(
                count: duas.length,
                current: _currentIndex,
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int current;
  final AppTheme theme;

  const _PageIndicator({
    required this.count,
    required this.current,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 8 : 6,
          height: isActive ? 8 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? theme.primaryColor
                : theme.textColor.withValues(alpha: 0.30),
          ),
        );
      }),
    );
  }
}

// ─── Single dua page content ──────────────────────────────────────────────────

class _DuaSinglePage extends StatelessWidget {
  final Dua dua;

  const _DuaSinglePage({required this.dua});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final showSupportingText = locale != 'ar';

    final metrics = ResponsiveMetrics.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom + 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Arabic text (reuses existing ArabicTextWidget)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ArabicTextWidget(text: dua.arabic),
              ),

              // Audio player
              if (dua.audioFile != null) ...[
                PlayerWidget(fileName: dua.audioFile!),
              ],

              if (showSupportingText) ...[
                // Transliteration
                const SizedBox(height: 16),
                _InfoCard(
                  label: _localized(l10n, 'duaDetailTranslitLabel').toUpperCase(),
                  body: _localized(l10n, dua.translitKey),
                  theme: theme,
                  italic: true,
                ),

                // Translation
                const SizedBox(height: 12),
                _InfoCard(
                  label: _localized(l10n, 'duaDetailTransLabel').toUpperCase(),
                  body: _localized(l10n, dua.transKey),
                  theme: theme,
                  italic: false,
                ),
              ],

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String body;
  final AppTheme theme;
  final bool italic;

  const _InfoCard({
    required this.label,
    required this.body,
    required this.theme,
    required this.italic,
  });

  static const _contentPadding = 16.0;
  static const _cardRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _contentPadding),
      child: SizedBox(
        width: double.infinity,
        child: AppCard(
          theme: theme,
          cornerRadius: _cardRadius,
          shadows: [
            BoxShadow(
              color: theme.cardShadowColor,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(_contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppType.of(context).overline,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: AppType.of(context).body,
                    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                    color: theme.textColor.withValues(alpha: 0.85),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
