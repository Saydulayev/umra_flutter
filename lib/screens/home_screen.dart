import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../utils/platform_icons.dart';
import '../providers/user_preferences_provider.dart';
import '../models/step_model.dart';
import '../models/app_theme.dart';
import '../screens/step_detail_screen.dart';
import '../screens/hajj_step_detail_screen.dart';
import '../screens/useful_info_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/prayer_time_screen.dart';
import '../screens/dua_book_screen.dart';
import '../utils/responsive_metrics.dart';
import '../theme/app_type.dart';
import '../widgets/app_card.dart';

const double _kBottomTabBarReservedSpace = 88.0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isCheckingReview = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Одноразовая проверка при открытии экрана с небольшой задержкой,
    // чтобы не блокировать первый рендер.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), _checkAndShowReviewDialog);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Проверяем при возвращении из фона — подходящий нейтральный момент.
    if (state == AppLifecycleState.resumed) _checkAndShowReviewDialog();
  }

  Future<void> _checkAndShowReviewDialog() async {
    if (!mounted || _isCheckingReview) return;
    final prefsProvider = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );
    if (prefsProvider.isShowingDialog || prefsProvider.hasRatedApp) return;

    _isCheckingReview = true;
    try {
      await prefsProvider.checkAndShowReviewIfNeeded();
      if (prefsProvider.hasShownReviewDialog &&
          !prefsProvider.hasRatedApp &&
          !prefsProvider.isShowingDialog) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && !prefsProvider.isShowingDialog) {
          await prefsProvider.showReviewDialog(context);
        }
      }
    } finally {
      _isCheckingReview = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: [
          // Каждая вкладка — самостоятельный экран со своим Scaffold/AppBar
          // (как в Instagram: состояние каждой вкладки сохраняется).
          IndexedStack(
            index: _selectedTab,
            children: [
              _StepsScaffold(
                theme: theme,
                body: _UmraTabBody(theme: theme, l10n: l10n),
              ),
              _StepsScaffold(
                theme: theme,
                body: _HajjTabBody(theme: theme, l10n: l10n),
              ),
              const DuaBookScreen(embedded: true),
              const PrayerTimeScreen(embedded: true),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomTabBar(
              selectedIndex: _selectedTab,
              l10n: l10n,
              onTap: (i) => setState(() => _selectedTab = i),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Steps tab shell (Umra / Hajj) — AppBar with settings only ───────────────

class _StepsScaffold extends StatelessWidget {
  final AppTheme theme;
  final Widget body;

  const _StepsScaffold({required this.theme, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(PlatformIcons.settings, color: theme.textColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: body,
    );
  }
}

// ─── Umra Tab ────────────────────────────────────────────────────────────────

class _UmraTabBody extends StatelessWidget {
  final AppTheme theme;
  final AppLocalizations l10n;

  const _UmraTabBody({required this.theme, required this.l10n});

  static const _cardRadius = 24.0;

  List<UmraStep> get _numberedSteps =>
      UmraSteps.allSteps.where((s) => s.id != 'useful').toList();

  UmraStep? get _usefulStep =>
      UmraSteps.allSteps.where((s) => s.id == 'useful').firstOrNull;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final metrics = ResponsiveMetrics.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: bottomPadding + _kBottomTabBarReservedSpace,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Text(
                  l10n.umra.toUpperCase(),
                  style: TextStyle(
                    fontSize: metrics.largeTitleFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: theme.textColor,
                  ),
                ),
              ),

              // Steps grouped card
              _GroupedCard(
                theme: theme,
                cardRadius: _cardRadius,
                padding: metrics.listScreenHPad,
                children: List.generate(_numberedSteps.length, (i) {
                  final step = _numberedSteps[i];
                  return _StepRowItem(
                    key: ValueKey(step.id),
                    badge: _StepBadge(stepNumber: step.stepNumber, theme: theme),
                    title: _localizedTitle(step.titleKey),
                    subtitle: null,
                    stepLabel: step.iconText.replaceAll('\n', ' '),
                    theme: theme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StepDetailScreen(step: step),
                      ),
                    ),
                  );
                }),
              ),

              // Useful info — separate card
              if (_usefulStep != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _GroupedCard(
                    theme: theme,
                    cardRadius: _cardRadius,
                    padding: metrics.listScreenHPad,
                    children: [
                      _StepRowItem(
                        badge: _InfoBadge(theme: theme),
                        title: l10n.usefulTitle,
                        subtitle: null,
                        theme: theme,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UsefulInfoScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedTitle(String key) {
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
      default:
        return key;
    }
  }
}

// ─── Hajj Tab ────────────────────────────────────────────────────────────────

class _HajjTabBody extends StatelessWidget {
  final AppTheme theme;
  final AppLocalizations l10n;

  const _HajjTabBody({required this.theme, required this.l10n});

  static const _cardRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    final steps = HajjSteps.allSteps;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final metrics = ResponsiveMetrics.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: bottomPadding + _kBottomTabBarReservedSpace,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Text(
                  l10n.hajj.toUpperCase(),
                  style: TextStyle(
                    fontSize: metrics.largeTitleFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: theme.textColor,
                  ),
                ),
              ),

              // Steps grouped card
              _GroupedCard(
                theme: theme,
                cardRadius: _cardRadius,
                padding: metrics.listScreenHPad,
                children: List.generate(steps.length, (i) {
                  final step = steps[i];
                  return _StepRowItem(
                    key: ValueKey(step.id),
                    badge: _StepBadge(stepNumber: step.stepNumber, theme: theme),
                    title: _localizedTitle(step.titleKey),
                    subtitle: step.subtitleKey != null
                        ? _localizedSubtitle(step.subtitleKey!)
                        : null,
                    stepLabel: step.iconText.replaceAll('\n', ' '),
                    theme: theme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HajjStepDetailScreen(step: step),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedTitle(String key) {
    switch (key) {
      case 'hajjTarwiyahTitle':
        return l10n.hajjTarwiyahTitle;
      case 'hajjArafatTitle':
        return l10n.hajjArafatTitle;
      case 'hajjNahrTitle':
        return l10n.hajjNahrTitle;
      case 'hajjTashriqTitle':
        return l10n.hajjTashriqTitle;
      case 'hajjWadaTitle':
        return l10n.hajjWadaTitle;
      default:
        return key;
    }
  }

  String _localizedSubtitle(String key) {
    switch (key) {
      case 'hajjTarwiyahSubtitle':
        return l10n.hajjTarwiyahSubtitle;
      case 'hajjArafatSubtitle':
        return l10n.hajjArafatSubtitle;
      case 'hajjNahrSubtitle':
        return l10n.hajjNahrSubtitle;
      case 'hajjTashriqSubtitle':
        return l10n.hajjTashriqSubtitle;
      default:
        return key;
    }
  }
}

// ─── Grouped card (single card with all rows + dividers) ─────────────────────

class _GroupedCard extends StatelessWidget {
  final AppTheme theme;
  final double cardRadius;
  final double padding;
  final List<Widget> children;

  const _GroupedCard({
    required this.theme,
    required this.cardRadius,
    required this.padding,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = theme.textColor.withValues(alpha: 0.10);

    // Build children list with dividers inserted between rows
    final List<Widget> withDividers = [];
    for (int i = 0; i < children.length; i++) {
      withDividers.add(children[i]);
      if (i < children.length - 1) {
        withDividers.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, thickness: 0.5, color: dividerColor),
          ),
        );
      }
    }

    return AppCard(
      theme: theme,
      cornerRadius: cardRadius,
      margin: EdgeInsets.symmetric(horizontal: padding),
      shadows: [
        BoxShadow(
          color: theme.cardShadowColor,
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(mainAxisSize: MainAxisSize.min, children: withDividers),
    );
  }
}

// ─── Step row (one row inside the grouped card) ───────────────────────────────

class _StepRowItem extends StatelessWidget {
  final Widget badge;
  final String title;
  final String? subtitle;
  final String? stepLabel; // e.g. "ШАГ 1" — null for useful info
  final AppTheme theme;
  final VoidCallback onTap;

  const _StepRowItem({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.onTap,
    this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: metrics.homeRowHorizontalPadding,
            vertical: metrics.homeRowVerticalPadding,
          ),
          child: Row(
            children: [
              badge,
              SizedBox(width: metrics.homeRowGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // "ШАГ 1" label — like iOS caption with tracking
                    if (stepLabel != null) ...[
                      Text(
                        stepLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppType(metrics).overline,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: theme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: metrics.stepItemFontSize,
                        fontWeight: FontWeight.w600,
                        color: theme.textColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppType(metrics).caption,
                          color: theme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                PlatformIcons.chevronRight,
                color: theme.textColor.withValues(alpha: 0.25),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step badge circle ────────────────────────────────────────────────────────

class _StepBadge extends StatelessWidget {
  final int stepNumber;
  final AppTheme theme;

  const _StepBadge({required this.stepNumber, required this.theme});

  @override
  Widget build(BuildContext context) {
    final badgeSize = ResponsiveMetrics.of(context).homeBadgeSize;

    return Container(
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
          '$stepNumber',
          style: TextStyle(
            fontSize: (badgeSize * 0.40).clamp(20.0, 26.0),
            fontWeight: FontWeight.bold,
            color: theme.isDark ? Colors.black : Colors.white,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ─── Info badge (for Useful Info row) ────────────────────────────────────────

class _InfoBadge extends StatelessWidget {
  final AppTheme theme;
  const _InfoBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    final badgeSize = ResponsiveMetrics.of(context).homeBadgeSize;

    return Container(
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
      child: Icon(
        PlatformIcons.info,
        color: theme.isDark ? Colors.black : Colors.white,
        size: badgeSize * 0.43,
      ),
    );
  }
}

// ─── Bottom tab bar — iOS 26 Liquid Glass (liquid_glass_widgets) ─────────────

class _BottomTabBar extends StatelessWidget {
  final int selectedIndex;
  final AppLocalizations l10n;
  final ValueChanged<int> onTap;

  const _BottomTabBar({
    required this.selectedIndex,
    required this.l10n,
    required this.onTap,
  });

  // Без extraButton GlassBottomBar выравнивает компактную пилюлю по левому
  // краю своего (полноширинного) Row, а не по центру. Поэтому задаём ей
  // точную ширину = ширина пилюли + внутренние отступы и центрируем сами.
  static const double _tabWidth = 72;
  static const int _tabCount = 4;
  static const double _horizontalPadding = 20;
  static const double _pillTotalWidth =
      _tabWidth * _tabCount + _horizontalPadding * 2;

  @override
  Widget build(BuildContext context) {
    // Цвета адаптируем под тему — ничего не хардкодим под одну схему.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color selectedIconColor = isDark ? Colors.white : Colors.black;
    final Color unselectedIconColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.45);
    // «Линза» под активной иконкой — полупрозрачная подсветка в цвет темы.
    final Color indicatorColor = isDark
        ? Colors.white.withValues(alpha: 0.20)
        : Colors.black.withValues(alpha: 0.10);

    // Тинт самого стекла. Дефолт пакета — Colors.white24 (отсюда серебристый
    // фрост в тёмной теме), поэтому задаём явно: тёмный тинт в тёмной теме,
    // светлый — в светлой.
    final LiquidGlassSettings glassSettings = isDark
        ? const LiquidGlassSettings(
            glassColor: Color.fromRGBO(12, 12, 14, 0.55),
            thickness: 26,
            blur: 5,
            lightIntensity: 0.5,
            ambientStrength: 0.3,
            refractiveIndex: 1.4,
            saturation: 1.1,
          )
        : const LiquidGlassSettings(
            glassColor: Color.fromRGBO(255, 255, 255, 0.6),
            thickness: 26,
            blur: 5,
            lightIntensity: 0.6,
            ambientStrength: 0.5,
            refractiveIndex: 1.4,
            saturation: 1.1,
          );

    return Center(
      child: SizedBox(
        width: _pillTotalWidth,
        child: GlassBottomBar(
          selectedIndex: selectedIndex,
          onTabSelected: onTap,
          selectedIconColor: selectedIconColor,
          unselectedIconColor: unselectedIconColor,
          indicatorColor: indicatorColor,
          glassSettings: glassSettings,
          // «Magic-lens» маскирование иконок сквозь стекло.
          maskingQuality: MaskingQuality.high,
          // Тише «желейный» подскок индикатора по высоте при переходе
          // (дефолт 14 — раздувается сильнее).
          indicatorExpansion: 6,
          // Компактные пилюли под 4 иконки (iOS 26), а не на всю ширину.
          tabWidth: _tabWidth,
          horizontalPadding: _horizontalPadding,
          // label: null → только иконки, без подписей (Instagram-стиль).
          tabs: [
            GlassBottomBarTab(
              label: null,
              icon: Icon(PlatformIcons.home),
              activeIcon: Icon(PlatformIcons.homeFill),
            ),
            // SVG пакет не красит сам — задаём цвет явно через colorFilter
            // под оба состояния (неактивное / активное).
            GlassBottomBarTab(
              label: null,
              icon: SvgPicture.asset(
                'assets/icons/kaaba.svg',
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                  unselectedIconColor,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/kaaba.svg',
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                  selectedIconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            GlassBottomBarTab(
              label: null,
              icon: Icon(PlatformIcons.book),
              activeIcon: Icon(PlatformIcons.bookFill),
            ),
            GlassBottomBarTab(
              label: null,
              icon: Icon(PlatformIcons.clock),
              activeIcon: Icon(PlatformIcons.clockFill),
            ),
          ],
        ),
      ),
    );
  }
}
