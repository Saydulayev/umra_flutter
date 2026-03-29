import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/font_provider.dart';
import '../utils/platform_icons.dart';
import '../models/step_model.dart';
import '../models/app_theme.dart';
import '../widgets/counter_tap_widget.dart';
import '../widgets/custom_toolbar.dart';
import '../widgets/arabic_text_widget.dart';
import '../widgets/common/step_title_widget.dart';
import '../widgets/common/step_text_widget.dart';
import '../widgets/common/step_arabic_section.dart';
import '../screens/useful_info_screen.dart';
import '../constants/app_constants.dart';

class StepDetailScreen extends StatefulWidget {
  final UmraStep step;

  const StepDetailScreen({super.key, required this.step});

  @override
  State<StepDetailScreen> createState() => _StepDetailScreenState();
}

class _StepDetailScreenState extends State<StepDetailScreen> {
  static final _pages = UmraSteps.allSteps
      .where((s) => s.id != 'useful')
      .toList();

  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = _pages
        .indexWhere((s) => s.id == widget.step.id)
        .clamp(0, _pages.length - 1);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.step.id == 'useful') return const UsefulInfoScreen();

    return Consumer2<ThemeProvider, FontProvider>(
      builder: (context, themeProvider, fontProvider, _) {
        final theme = themeProvider.selectedTheme;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            title: Text(
              _getLocalizedTitle(_pages[_currentPage].titleKey, l10n),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            backgroundColor: theme.backgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: theme.primaryColor),
            actions: const [CustomToolbar()],
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final bottomPadding = MediaQuery.of(
                    context,
                  ).viewPadding.bottom;
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: bottomPadding + 48,
                      left: 10,
                      right: 10,
                    ),
                    child: _buildContent(
                      _pages[i].id,
                      theme,
                      l10n,
                      fontProvider,
                    ),
                  );
                },
              ),
              _PageIndicator(
                count: _pages.length,
                currentIndex: _currentPage,
                theme: theme,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    String id,
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    switch (id) {
      case 'step1':
        return _buildStep1Content(theme, l10n, fontProvider);
      case 'step2':
        return _buildStep2Content(theme, l10n, fontProvider);
      case 'step3':
        return _buildStep3Content(theme, l10n, fontProvider);
      case 'step4':
        return _buildStep4Content(theme, l10n, fontProvider);
      case 'step5':
        return _buildStep5Content(theme, l10n, fontProvider);
      case 'step6':
        return _buildStep6Content(theme, l10n, fontProvider);
      case 'step7':
        return _buildStep7Content(theme, l10n, fontProvider);
      default:
        return _buildDefaultContent(theme, fontProvider);
    }
  }

  Widget _buildStep1Content(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.preparation_before_ihram_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.preparation_before_ihram_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        const Divider(),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.step1EnterIhram),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.step1WhenEnteringIhram),
        const SizedBox(height: 8),
        StepArabicSection(
          arabicText: l10n.step1FirstArabic,
          audioFileName: '1',
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step1TurnToQiblah,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        StepArabicSection(
          arabicText: l10n.step1SecondArabic,
          audioFileName: '2',
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        StepTextWidget(text: l10n.step1OAllahUmrah),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.step1ThirdArabic,
          audioFileName: '3',
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.step1Labbayka,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step1EnteringSacredMosque,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        StepArabicSection(
          arabicText: l10n.step1EnteringSacredMosqueDuaArabic,
          audioFileName: '4',
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.step1EnteringSacredMosqueDua,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.step1ConditioningHajj),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step1ConditioningHajjText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        StepArabicSection(
          arabicText: l10n.step1ConditioningHajjArabic,
          audioFileName: '5',
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.step1IhramText1,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.step1UmrahForParents),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step1UmrahForParentsExplanation,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        ArabicTextWidget(text: l10n.step1UmrahForFatherArabic),
        const SizedBox(height: 8),
        SelectableText(
          l10n.step1UmrahForFather,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        ArabicTextWidget(text: l10n.step1UmrahForMotherArabic),
        const SizedBox(height: 8),
        SelectableText(
          l10n.step1UmrahForMother,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        ArabicTextWidget(text: l10n.step1UmrahForOtherArabic),
        const SizedBox(height: 8),
        SelectableText(
          l10n.step1UmrahForOther,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Content(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.step2KaabaText1),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step2KaabaText2,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.step2TakbirArabic,
          audioFileName: '6',
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step2KaabaText3,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.step2DuaArabic,
          audioFileName: '7',
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        CounterTapWidget(
          prefsKey: 'tawaf_counter',
          titleString: l10n.titleRoundKaabaScreen,
          labelString: l10n.tawafCircleString,
          finishedString: l10n.tawafFinishedString,
          icon: PlatformIcons.rotateRight,
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step2KaabaText4,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Content(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.step3PrayerAfterTawaf),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step3CompletedSevenCircuits,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.step3ArabicText,
          audioFileName: '13',
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step3PlaceOfStanding,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Content(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.step4DrinkingZamzam),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step4ZamzamText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStep5Content(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.step5ReturnToBlackStone),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step5ReturnReciteTakbir,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 32),
        SelectableText(
          l10n.step5AllahIsGreat,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.step5TakbirArabic,
          audioFileName: '6',
        ),
      ],
    );
  }

  Widget _buildStep6Content(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.step6SafaAndMarwa),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step6HeadTowardsSafa,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.step6SurahBaqarahArabic,
          audioFileName: '8',
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step6SurahBaqarahVerse,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.step6WeBeginArabic,
          audioFileName: '9',
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step6WeBegin,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          l10n.step6WeBeginText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.step6RemembranceArabic,
          audioFileName: '10',
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        CounterTapWidget(
          prefsKey: 'say_counter',
          titleString: l10n.titleSafaAndMarvaScreen,
          labelString: l10n.sayPassageString,
          finishedString: l10n.sayFinishedString,
          icon: PlatformIcons.walk,
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step6RemembranceText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.step6DuasDuringSaiArabic,
          audioFileName: '11',
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step6DuasDuringSaiText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.step6ExitingSacredMosqueArabic,
          audioFileName: '12',
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step6ExitingSacredMosqueText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStep7Content(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.step7ShavingHead),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step7MenShortenHair,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SelectableText(
          l10n.step7DuaAtEnd,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent(AppTheme theme, FontProvider fontProvider) {
    return SelectableText(
      'Content for ${widget.step.titleKey}',
      style: fontProvider.getTextStyle(fontSize: 18, color: theme.textColor),
    );
  }

  String _getLocalizedTitle(String key, AppLocalizations l10n) {
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

// ─── Page indicator dots ──────────────────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final AppTheme theme;

  const _PageIndicator({
    required this.count,
    required this.currentIndex,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding + 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) {
          final isActive = i == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 8 : 6,
            height: isActive ? 8 : 6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? theme.primaryColor
                  : theme.textColor.withValues(alpha: 0.30),
            ),
          );
        }),
      ),
    );
  }
}
