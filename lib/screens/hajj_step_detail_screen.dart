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

class HajjStepDetailScreen extends StatelessWidget {
  final HajjStep step;

  const HajjStepDetailScreen({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, FontProvider>(
      builder: (context, themeProvider, fontProvider, child) {
        final theme = themeProvider.selectedTheme;
        final l10n = AppLocalizations.of(context)!;

        // Определяем, какой контент показывать в зависимости от шага
        Widget content;

        switch (step.id) {
          case 'hajj_tarwiyah':
            content = _buildTarwiyahContent(theme, l10n, fontProvider);
            break;
          case 'hajj_arafat':
            content = _buildArafatContent(theme, l10n, fontProvider);
            break;
          case 'hajj_nahr':
            content = _buildNahrContent(theme, l10n, fontProvider);
            break;
          case 'hajj_tashriq':
            content = _buildTashriqContent(theme, l10n, fontProvider);
            break;
          case 'hajj_wada':
            content = _buildWadaContent(theme, l10n, fontProvider);
            break;
          default:
            content = _buildDefaultContent(theme, fontProvider);
        }

        return Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            title: Text(
              _getLocalizedTitle(step.titleKey, l10n),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            backgroundColor: theme.backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: theme.primaryColor),
            actions: const [CustomToolbar()],
          ),
          body: Builder(
            builder: (context) {
              final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: bottomPadding + 10,
                  left: 10,
                  right: 10,
                ),
                child: content,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTarwiyahContent(
    AppTheme theme,
    AppLocalizations l10n,
    FontProvider fontProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Раздел: Подготовка к ихраму
        StepTitleWidget(text: l10n.preparation_before_ihram_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.preparation_before_ihram_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        const Divider(),
        const SizedBox(height: AppDimensions.paddingExtraLarge),
        // Раздел: Вхождение в состояние ихрама
        StepTitleWidget(text: l10n.hajj_step1_ihram_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step1_ihram_text),
        const SizedBox(height: AppDimensions.paddingLarge),

        // Арабский текст ихрама
        StepArabicSection(
          arabicText: l10n.hajj_step1_ihram_arabic,
          audioFileName: '14', 
        ),
        const SizedBox(height: AppDimensions.paddingSmall),

        // Транслитерация и перевод ихрама
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

        // Арабский текст дуа ихрама
        StepArabicSection(
          arabicText: l10n.hajj_step1_ihram_dua_arabic,
          audioFileName: '15', 
        ),
        const SizedBox(height: AppDimensions.paddingSmall),

        // Транслитерация и перевод дуа ихрама
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

        // Раздел: Тальбия
        StepTitleWidget(text: l10n.hajj_step1_talbiyah_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step1_talbiyah_text),
        const SizedBox(height: AppDimensions.paddingLarge),

        // Арабский текст тальбии
        StepArabicSection(
          arabicText: l10n.hajj_step1_talbiyah_arabic,
          audioFileName: '3', 
        ),
        const SizedBox(height: AppDimensions.paddingSmall),

        // Транслитерация и перевод тальбии
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

        // Раздел: Перемещение в долину Мина
        StepTitleWidget(text: l10n.hajj_step1_mina_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step1_mina_text),
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
        // Раздел: Перемещение в долину Арафат
        StepTitleWidget(text: l10n.hajj_step2_arafat_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step2_arafat_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Стояние на Арафате
        StepTitleWidget(text: l10n.hajj_step2_standing_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step2_standing_text),
        const SizedBox(height: AppDimensions.paddingLarge),

        // Арабский текст дуа
        StepArabicSection(
          arabicText: l10n.hajj_step2_dua_arabic,
          audioFileName: '16', 
        ),
        const SizedBox(height: AppDimensions.paddingSmall),

        // Транслитерация и перевод дуа
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

        // Раздел: Перемещение из Арафата в Муздалифу
        StepTitleWidget(text: l10n.hajj_step2_muzdalifah_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step2_muzdalifah_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Ночёвка в Муздалифе
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
        // Раздел: Фаджр
        StepTitleWidget(text: l10n.hajj_step3_fajr_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_fajr_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Перемещение в Аль-Маш'ар-аль-Харам
        StepTitleWidget(text: l10n.hajj_step3_mashaar_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_mashaar_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Перемещение в долину Мина
        StepTitleWidget(text: l10n.hajj_step3_mina_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_mina_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Бросание камешков в Большой столб
        StepTitleWidget(text: l10n.hajj_step3_jamarat_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_jamarat_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Частичный выход из состояния ихрама
        StepTitleWidget(text: l10n.hajj_step3_partial_exit_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_partial_exit_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Жертвоприношение
        StepTitleWidget(text: l10n.hajj_step3_sacrifice_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_sacrifice_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Бритьё головы
        StepTitleWidget(text: l10n.hajj_step3_shaving_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_shaving_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Основной обход Каабы
        StepTitleWidget(text: l10n.hajj_step3_tawaf_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_tawaf_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Вниманию тех, кто не смог совершить основной обход Каабы
        StepTitleWidget(text: l10n.hajj_step3_attention_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_attention_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Полный выход из состояния ихрама
        StepTitleWidget(text: l10n.hajj_step3_full_exit_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step3_full_exit_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Возвращение в долину Мина
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
        // Раздел: Пребывание в Мине
        StepTitleWidget(text: l10n.hajj_step4_stay_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step4_stay_text),
        const SizedBox(height: AppDimensions.paddingExtraLarge),

        // Раздел: Бросание камешков в три столба
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
        // Прощальный обход Каабы
        StepTextWidget(text: l10n.hajj_step5_farewell_text),
      ],
    );
  }

  Widget _buildDefaultContent(AppTheme theme, FontProvider fontProvider) {
    return SelectableText(
      'Контент для ${step.titleKey}',
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
