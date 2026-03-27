import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../models/step_model.dart';
import '../models/app_theme.dart';
import '../screens/step_detail_screen.dart';
import '../screens/hajj_step_detail_screen.dart';
import '../screens/useful_info_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/prayer_time_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _reviewCheckTimer;
  bool _isCheckingReview = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowReviewDialog();
      _reviewCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _checkAndShowReviewDialog();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reviewCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) _checkAndShowReviewDialog();
  }

  Future<void> _checkAndShowReviewDialog() async {
    if (!mounted || _isCheckingReview) return;
    final prefsProvider = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );
    if (prefsProvider.isShowingDialog) return;

    _isCheckingReview = true;
    try {
      await prefsProvider.checkAndShowReviewIfNeeded();
      if (prefsProvider.hasShownReviewDialog &&
          !prefsProvider.hasRatedApp &&
          !prefsProvider.isShowingDialog) {
        _reviewCheckTimer?.cancel();
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && !prefsProvider.isShowingDialog) {
          await prefsProvider.showReviewDialog(context);
        }
        if (mounted && !prefsProvider.hasRatedApp) {
          _reviewCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
            _checkAndShowReviewDialog();
          });
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
      extendBody: true,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.access_time_rounded,
              color: theme.textColor.withValues(alpha: 0.55),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrayerTimeScreen()),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.textColor.withValues(alpha: 0.55),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _UmraTabBody(theme: theme, l10n: l10n),
          _HajjTabBody(theme: theme, l10n: l10n),
        ],
      ),
      bottomNavigationBar: _BottomTabBar(
        selectedIndex: _selectedTab,
        theme: theme,
        umraLabel: l10n.umra,
        hajjLabel: l10n.hajj,
        onTap: (i) => setState(() => _selectedTab = i),
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
      padding: EdgeInsets.only(bottom: bottomPadding + 80),
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
              final stepLabel =
                  '${l10n.stepPrefix} ${step.stepNumber}'.toUpperCase();
              return _StepRowItem(
                key: ValueKey(step.id),
                badge: _StepBadge(iconText: step.iconText, theme: theme),
                title: _localizedTitle(step.titleKey),
                subtitle: null,
                stepLabel: stepLabel,
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
      padding: EdgeInsets.only(bottom: bottomPadding + 80),
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
              final stepLabel =
                  '${l10n.stepPrefix} ${step.stepNumber}'.toUpperCase();
              return _StepRowItem(
                key: ValueKey(step.id),
                badge: _StepBadge(iconText: step.iconText, theme: theme),
                title: _localizedTitle(step.titleKey),
                subtitle: step.subtitleKey != null
                    ? _localizedSubtitle(step.subtitleKey!)
                    : null,
                stepLabel: stepLabel,
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: theme.isEmerald ? null : theme.lightBackgroundColor,
        gradient: theme.cardGradient,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: theme.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.cardShadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: withDividers,
        ),
      ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              badge,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // "ШАГ 1" label — like iOS caption with tracking
                    if (stepLabel != null) ...[
                      Text(
                        stepLabel!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: theme.textColor.withValues(alpha: 0.40),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      title,
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
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textColor.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
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
  final String iconText;
  final AppTheme theme;

  const _StepBadge({
    required this.iconText,
    required this.theme,
  });

  double get _fontSize {
    final longest = iconText.split('\n').map((l) => l.length).reduce(max);
    if (longest > 6) return 8.0;
    if (longest > 4) return 9.0;
    return 10.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
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
          iconText,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
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
    return Container(
      width: 56,
      height: 56,
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
      child: const Icon(
        Icons.info_outline_rounded,
        color: Colors.black,
        size: 24,
      ),
    );
  }
}

// ─── Bottom tab bar ───────────────────────────────────────────────────────────

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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        backgroundColor: theme.lightBackgroundColor,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.secondaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: _TabLetterIcon(letter: 'U', isSelected: false, theme: theme),
            activeIcon: _TabLetterIcon(
              letter: 'U',
              isSelected: true,
              theme: theme,
            ),
            label: umraLabel,
          ),
          BottomNavigationBarItem(
            icon: _TabLetterIcon(letter: 'H', isSelected: false, theme: theme),
            activeIcon: _TabLetterIcon(
              letter: 'H',
              isSelected: true,
              theme: theme,
            ),
            label: hajjLabel,
          ),
        ],
      ),
    );
  }
}

class _TabLetterIcon extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final AppTheme theme;

  const _TabLetterIcon({
    required this.letter,
    required this.isSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? theme.primaryColor
            : theme.primaryColor.withValues(alpha: 0.12),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : theme.primaryColor,
          ),
        ),
      ),
    );
  }
}
