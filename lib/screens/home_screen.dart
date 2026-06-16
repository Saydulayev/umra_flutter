import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(PlatformIcons.book, color: theme.textColor),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DuaBookScreen()),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PlatformIcons.clock, color: theme.textColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrayerTimeScreen()),
            ),
          ),
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
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedTab,
            children: [
              _UmraTabBody(theme: theme, l10n: l10n),
              _HajjTabBody(theme: theme, l10n: l10n),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomTabBar(
              selectedIndex: _selectedTab,
              theme: theme,
              umraLabel: l10n.umra,
              hajjLabel: l10n.hajj,
              onTap: (i) => setState(() => _selectedTab = i),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Umra Tab ────────────────────────────────────────────────────────────────

class _UmraTabBody extends StatelessWidget {
  final AppTheme theme;
  final AppLocalizations l10n;

  const _UmraTabBody({required this.theme, required this.l10n});

  static const _padding = 16.0;
  static const _cardRadius = 24.0;

  List<UmraStep> get _numberedSteps =>
      UmraSteps.allSteps.where((s) => s.id != 'useful').toList();

  UmraStep? get _usefulStep =>
      UmraSteps.allSteps.where((s) => s.id == 'useful').firstOrNull;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: bottomPadding + _kBottomTabBarReservedSpace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Text(
              l10n.umra.toUpperCase(),
              style: TextStyle(
                fontSize: 34,
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
            padding: _padding,
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
                padding: _padding,
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

  static const _padding = 16.0;
  static const _cardRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    final steps = HajjSteps.allSteps;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: bottomPadding + _kBottomTabBarReservedSpace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Text(
              l10n.hajj.toUpperCase(),
              style: TextStyle(
                fontSize: 34,
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
            padding: _padding,
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
                          fontSize: 11,
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
                        fontSize: 16,
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
                          fontSize: 13,
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

// ─── Bottom tab bar — Liquid Glass (iOS 26 style) ────────────────────────────

class _BottomTabBar extends StatelessWidget {
  final int selectedIndex;
  final AppTheme theme;
  final String umraLabel;
  final String hajjLabel;
  final ValueChanged<int> onTap;

  const _BottomTabBar({
    required this.selectedIndex,
    required this.theme,
    required this.umraLabel,
    required this.hajjLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final barWidth = ResponsiveMetrics.of(context).bottomTabBarWidth;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Center(
        child: SizedBox(
          width: barWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                constraints: const BoxConstraints(minHeight: 65),
                decoration: BoxDecoration(
                  color: theme.isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: theme.isDark ? 0.14 : 0.85,
                    ),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: theme.isDark ? 0.26 : 0.10,
                      ),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabItem(
                        letter: 'U',
                        label: umraLabel,
                        isSelected: selectedIndex == 0,
                        theme: theme,
                        onTap: () => onTap(0),
                      ),
                    ),
                    Expanded(
                      child: _TabItem(
                        letter: 'H',
                        label: hajjLabel,
                        isSelected: selectedIndex == 1,
                        theme: theme,
                        onTap: () => onTap(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String letter;
  final String label;
  final bool isSelected;
  final AppTheme theme;
  final VoidCallback onTap;

  const _TabItem({
    required this.letter,
    required this.label,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isSelected
        ? theme.primaryColor
        : theme.isDark
        ? Colors.white.withValues(alpha: 0.66)
        : Colors.black.withValues(alpha: 0.88);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: isSelected
                  ? (theme.isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.07))
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? theme.primaryColor
                        : theme.isDark
                        ? Colors.white.withValues(alpha: 0.88)
                        : Colors.black.withValues(alpha: 0.90),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : theme.isDark
                            ? Colors.black.withValues(alpha: 0.80)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: labelColor,
                    height: 1,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
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
