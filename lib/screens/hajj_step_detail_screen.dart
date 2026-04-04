import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/font_provider.dart';
import '../models/step_model.dart';
import '../models/app_theme.dart';
import '../widgets/custom_toolbar.dart';
import '../widgets/common/step_title_widget.dart';
import '../widgets/common/step_text_widget.dart';
import '../widgets/common/step_arabic_section.dart';
import '../constants/app_constants.dart';

class HajjStepDetailScreen extends StatefulWidget {
  final HajjStep step;

  const HajjStepDetailScreen({super.key, required this.step});

  @override
  State<HajjStepDetailScreen> createState() => _HajjStepDetailScreenState();
}

class _HajjStepDetailScreenState extends State<HajjStepDetailScreen> {
  static final _pages = HajjSteps.allSteps;

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
      case 'hajj_tarwiyah':
        return _buildTarwiyahContent(theme, l10n, fontProvider);
      case 'hajj_arafat':
        return _buildArafatContent(theme, l10n, fontProvider);
      case 'hajj_nahr':
        return _buildNahrContent(theme, l10n, fontProvider);
      case 'hajj_tashriq':
        return _buildTashriqContent(theme, l10n, fontProvider);
      case 'hajj_wada':
        return _buildWadaContent(theme, l10n, fontProvider);
      default:
        return _buildDefaultContent(theme, fontProvider);
    }
  }

  Widget _buildTarwiyahContent(
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
        StepTitleWidget(text: l10n.hajj_step1_ihram_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step1_ihram_text),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.hajj_step1_ihram_arabic,
          audioFileName: '14',
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.hajj_step1_ihram_transliteration,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.hajj_step1_ihram_translation,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.hajj_step1_ihram_dua_arabic,
          audioFileName: '15',
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.hajj_step1_ihram_dua_transliteration,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.hajj_step1_ihram_dua_translation,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step1_talbiyah_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step1_talbiyah_text),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.hajj_step1_talbiyah_arabic,
          audioFileName: '3',
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.hajj_step1_talbiyah_transliteration,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.hajj_step1_talbiyah_translation,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step1_mina_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step1_mina_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        const Divider(),
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
      ],
    );
  }

  Widget _buildArafatContent(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.hajj_step2_arafat_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step2_arafat_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step2_standing_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step2_standing_text),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepArabicSection(
          arabicText: l10n.hajj_step2_dua_arabic,
          audioFileName: '16',
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.hajj_step2_dua_transliteration,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SelectableText(
          l10n.hajj_step2_dua_translation,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step2_muzdalifah_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step2_muzdalifah_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step2_night_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step2_night_text),
      ],
    );
  }

  Widget _buildNahrContent(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.hajj_step3_fajr_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_fajr_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step3_mashaar_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_mashaar_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step3_mina_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_mina_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step3_jamarat_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_jamarat_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step3_partial_exit_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_partial_exit_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step3_sacrifice_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_sacrifice_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step3_shaving_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_shaving_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step3_tawaf_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_tawaf_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step3_attention_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_attention_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step3_full_exit_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_full_exit_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step3_return_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_return_text),
      ],
    );
  }

  Widget _buildTashriqContent(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.hajj_step4_stay_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step4_stay_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        StepTitleWidget(text: l10n.hajj_step4_jamarat_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step4_jamarat_text),
      ],
    );
  }

  Widget _buildWadaContent(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitleWidget(text: l10n.hajj_step5_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step5_farewell_text),
      ],
    );
  }

  Widget _buildDefaultContent(AppTheme theme, FontProvider fontProvider) {
    return SelectableText(
      'Контент для ${widget.step.titleKey}',
      style: fontProvider.getTextStyle(fontSize: 18, color: theme.textColor),
    );
  }

  String _getLocalizedTitle(String key, AppLocalizations l10n) {
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
