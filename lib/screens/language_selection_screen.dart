import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_metrics.dart';
import 'home_screen.dart';

// ---------------------------------------------------------------------------
// LanguageSelectionScreen — welcome / language-picker screen.
// Mirrors the SwiftUI LanguageSelectionView from the native iOS app:
//   1. Shimmering "UMRA GUIDE" title (fade-in + slide from top)
//   2. WelcomeImage in a white card (scale + fade-in)
//   3. Scrollable language buttons (fade-in + slide from bottom)
//   4. Optional "↓" chevron when list overflows
// ---------------------------------------------------------------------------

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  static const _languages = [
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'en', 'name': 'English'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'ar', 'name': 'العربية'},
  ];

  late final AnimationController _titleCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _listCtrl;

  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _listOpacity;
  late final Animation<Offset> _listSlide;

  @override
  void initState() {
    super.initState();

    const spring = Duration(milliseconds: 600);

    _titleCtrl = AnimationController(vsync: this, duration: spring);
    _logoCtrl = AnimationController(vsync: this, duration: spring);
    _listCtrl = AnimationController(vsync: this, duration: spring);

    final curve = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut);
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(curve);

    final logoCurve = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(logoCurve);
    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(logoCurve);

    final listCurve = CurvedAnimation(parent: _listCtrl, curve: Curves.easeOut);
    _listOpacity = Tween<double>(begin: 0, end: 1).animate(listCurve);
    _listSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(listCurve);

    // Sequential: title → logo → list
    _titleCtrl.forward().whenComplete(() {
      _logoCtrl.forward().whenComplete(() {
        _listCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _logoCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage(String code) async {
    final lp = Provider.of<LocalizationProvider>(context, listen: false);
    await lp.setLanguage(code);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final mq = MediaQuery.of(context);
    final metrics = ResponsiveMetrics.of(context);

    final hPad = metrics.languageHorizontalPadding;
    final topPad = metrics.languageTopPadding + mq.viewPadding.top;
    final bottomPad = metrics.languageBottomPadding + mq.viewPadding.bottom;
    final cardW = metrics.languageCardWidth;
    final cardH = metrics.languageCardHeight;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Padding(
        padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Shimmering title
            FadeTransition(
              opacity: _titleOpacity,
              child: SlideTransition(
                position: _titleSlide,
                child: _ShimmeringTitle(
                  textColor: theme.textColor.withValues(alpha: 0.6),
                ),
              ),
            ),
            SizedBox(
              height: metrics.isCompactPhone ? 18 : metrics.height * 0.05,
            ),

            // 2. Welcome image — centered card
            FadeTransition(
              opacity: _logoOpacity,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: cardW,
                  height: cardH,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/images/welcome_image.png',
                      fit: BoxFit.contain,
                      semanticLabel: '',
                    ),
                  ),
                ),
              ),
            ),

            // Отступ между логотипом и списком языков, чтобы список
            // не подходил вплотную к карточке изображения.
            SizedBox(
              height: metrics.isCompactPhone ? 20 : 32,
            ),

            // 3. Scrollable language list — занимает оставшееся место.
            // Список сам подстраивается под доступную высоту (Flexible внутри),
            // поэтому помещает все языки, когда есть место, и прокручивается
            // без переполнения, когда места мало (например, в landscape).
            Expanded(
              child: Align(
                alignment: const Alignment(0, 0.5),
                child: FadeTransition(
                  opacity: _listOpacity,
                  child: SlideTransition(
                    position: _listSlide,
                    child: _LanguageList(
                      languages: _languages,
                      theme: theme,
                      onSelect: _selectLanguage,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmering "UMRA GUIDE" title — replicates ShimmeringText.swift
// ---------------------------------------------------------------------------

class _ShimmeringTitle extends StatefulWidget {
  final Color textColor;
  const _ShimmeringTitle({required this.textColor});

  @override
  State<_ShimmeringTitle> createState() => _ShimmeringTitleState();
}

class _ShimmeringTitleState extends State<_ShimmeringTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmer = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const text = 'UMRA GUIDE';
    final baseStyle = TextStyle(
      fontSize: 38,
      fontWeight: FontWeight.w900,
      fontFamily: 'Lato',
      letterSpacing: 2.0,
      color: widget.textColor,
    );

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, shimmerValue) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final t = _shimmer.value;
            return LinearGradient(
              begin: Alignment(t - 0.4, -0.5),
              end: Alignment(t + 0.4, 0.5),
              colors: const [
                Colors.transparent,
                Colors.white,
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: Text(text, style: baseStyle, textAlign: TextAlign.center),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Scrollable language buttons list with optional "↓" chevron
// ---------------------------------------------------------------------------

class _LanguageList extends StatefulWidget {
  final List<Map<String, String>> languages;
  final dynamic theme;
  final void Function(String) onSelect;

  const _LanguageList({
    required this.languages,
    required this.theme,
    required this.onSelect,
  });

  @override
  State<_LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<_LanguageList> {
  final _scrollCtrl = ScrollController();
  bool _showChevron = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkChevron());
    _scrollCtrl.addListener(_checkChevron);
  }

  void _checkChevron() {
    if (!_scrollCtrl.hasClients) return;
    final canScroll = _scrollCtrl.position.maxScrollExtent > 0;
    final atBottom =
        _scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 4;
    final show = canScroll && !atBottom;
    if (show != _showChevron) setState(() => _showChevron = show);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Scrollbar(
            thumbVisibility: false,
            child: ListView.separated(
              controller: _scrollCtrl,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.languages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final lang = widget.languages[i];
                return _LanguageButton(
                  name: lang['name']!,
                  theme: theme,
                  onTap: () => widget.onSelect(lang['code']!),
                );
              },
            ),
          ),
        ),

        // Chevron scroll hint
        AnimatedOpacity(
          opacity: _showChevron ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: theme.textColor.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Single language button — mirrors LanguageButton.swift
// ---------------------------------------------------------------------------

class _LanguageButton extends StatelessWidget {
  final String name;
  final dynamic theme;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.name,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.lightBackgroundColor,
      borderRadius: BorderRadius.circular(22),
      elevation: 3,
      shadowColor: theme.cardShadowColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.borderColor, width: 1.2),
          ),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: theme.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
