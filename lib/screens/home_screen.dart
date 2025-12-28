import 'dart:async';
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
import '../widgets/ios_segmented_control.dart';
import '../widgets/hajj_icon_widget.dart';

enum PilgrimageType { umra, hajj }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _reviewCheckTimer;
  bool _isCheckingReview =
      false; // Флаг для предотвращения параллельных проверок
  PilgrimageType _selectedType = PilgrimageType.umra;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Проверяем сразу и затем периодически
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowReviewDialog();
      // Проверяем каждые 5 секунд
      _reviewCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
    // Проверяем при возврате в приложение
    if (state == AppLifecycleState.resumed) {
      _checkAndShowReviewDialog();
    }
  }

  Future<void> _checkAndShowReviewDialog() async {
    if (!mounted || _isCheckingReview) return;

    final prefsProvider = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );

    // Не проверяем, если диалог уже показывается
    if (prefsProvider.isShowingDialog) {
      return;
    }

    _isCheckingReview = true;
    try {
      // Проверяем условия
      await prefsProvider.checkAndShowReviewIfNeeded();

      // Если нужно показать диалог, показываем его
      if (prefsProvider.hasShownReviewDialog &&
          !prefsProvider.hasRatedApp &&
          !prefsProvider.isShowingDialog) {
        // Останавливаем периодическую проверку, пока диалог открыт
        _reviewCheckTimer?.cancel();

        // Небольшая задержка перед показом диалога для лучшего UX
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && !prefsProvider.isShowingDialog) {
          await prefsProvider.showReviewDialog(context);
        }

        // Возобновляем проверку после закрытия диалога
        if (mounted && !prefsProvider.hasRatedApp) {
          _reviewCheckTimer = Timer.periodic(const Duration(seconds: 5), (
            timer,
          ) {
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _selectedType == PilgrimageType.umra
              ? (l10n?.umra.toUpperCase() ?? 'UMRA')
              : (l10n?.hajj.toUpperCase() ?? 'ХАДЖ'),
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor),
        ),
        centerTitle: true,
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.access_time, color: theme.textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrayerTimeScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: theme.textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildListView(context, theme),
          // Сегментированный контрол внизу экрана
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                color: Colors.transparent,
                child: IOSSegmentedControl<PilgrimageType>(
                  segments: [
                    SegmentItem<PilgrimageType>(
                      value: PilgrimageType.umra,
                      label: l10n?.umra ?? 'Умра',
                      icon: 'U',
                    ),
                    SegmentItem<PilgrimageType>(
                      value: PilgrimageType.hajj,
                      label: l10n?.hajj ?? 'Хадж',
                      icon: 'H',
                    ),
                  ],
                  selectedValue: _selectedType,
                  onValueChanged: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  activeColor: theme.primaryColor,
                  inactiveColor: Colors.black87,
                  backgroundColor: theme.lightBackgroundColor,
                  theme: theme,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context, AppTheme theme) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    // Добавляем отступ снизу для сегментированного контрола
    return ListView.builder(
      padding: EdgeInsets.only(
        top: 10,
        bottom: bottomPadding + 100, // Место для сегментированного контрола
        left: 8,
        right: 8,
      ),
      itemCount: _selectedType == PilgrimageType.umra
          ? UmraSteps.allSteps.length
          : HajjSteps.allSteps.length,
      itemBuilder: (context, index) {
        if (_selectedType == PilgrimageType.umra) {
          final step = UmraSteps.allSteps[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: _buildStepRow(context, step, theme),
          );
        } else {
          final step = HajjSteps.allSteps[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: _buildHajjStepRow(context, step, theme),
          );
        }
      },
    );
  }

  /// Виджет для list view (как StepRow в Swift)
  Widget _buildStepRow(BuildContext context, UmraStep step, AppTheme theme) {
    return GestureDetector(
      onTap: () {
        _navigateToStep(context, step);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.lightBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Иконка с текстом (как для Хаджа)
            HajjIconWidget(iconText: step.iconText, theme: theme),
            const SizedBox(width: 15),
            // Текст
            Expanded(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  final title = _getLocalizedTitle(step.titleKey, l10n);
                  return Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textColor,
                    ),
                  );
                },
              ),
            ),
            // Стрелка
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                size: 14,
                color: theme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToStep(BuildContext context, UmraStep step) {
    if (step.id == 'useful') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UsefulInfoScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StepDetailScreen(step: step)),
      );
    }
  }

  void _navigateToHajjStep(BuildContext context, HajjStep step) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HajjStepDetailScreen(step: step)),
    );
  }

  /// Виджет для отображения шага Хаджа с подзаголовком
  Widget _buildHajjStepRow(
    BuildContext context,
    HajjStep step,
    AppTheme theme,
  ) {
    return GestureDetector(
      onTap: () {
        _navigateToHajjStep(context, step);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.lightBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Иконка с текстом
            HajjIconWidget(iconText: step.iconText, theme: theme),
            const SizedBox(width: 15),
            // Текст с заголовком и подзаголовком
            Expanded(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  final title = _getLocalizedHajjTitle(step.titleKey, l10n);
                  final subtitle = step.subtitleKey != null
                      ? _getLocalizedHajjSubtitle(step.subtitleKey!, l10n)
                      : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.textColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: theme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            // Стрелка
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                size: 14,
                color: theme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedTitle(String key, AppLocalizations? l10n) {
    if (l10n == null) return key;

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
      case 'usefulTitle':
        return l10n.usefulTitle;
      default:
        return key;
    }
  }

  String _getLocalizedHajjTitle(String key, AppLocalizations? l10n) {
    if (l10n == null) return key;

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

  String _getLocalizedHajjSubtitle(String key, AppLocalizations? l10n) {
    if (l10n == null) return key;

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
