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
            content = _buildDefaultContent(theme, fontProvider);
            break;
          case 'hajj_nahr':
            content = _buildDefaultContent(theme, fontProvider);
            break;
          case 'hajj_tashriq':
            content = _buildDefaultContent(theme, fontProvider);
            break;
          case 'hajj_wada':
            content = _buildDefaultContent(theme, fontProvider);
            break;
          default:
            content = _buildDefaultContent(theme, fontProvider);
        }

        return Scaffold(
          backgroundColor: theme.lightBackgroundColor,
          appBar: AppBar(
            title: Text(
              _getLocalizedTitle(step.titleKey, l10n),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            backgroundColor: theme.lightBackgroundColor,
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
        // Раздел: Вхождение в состояние ихрама
        StepTitleWidget(text: l10n.hajj_step1_ihram_title),
        const SizedBox(height: AppDimensions.paddingLarge),
        StepTextWidget(text: l10n.hajj_step1_ihram_text),
        const SizedBox(height: AppDimensions.paddingLarge),

        // Арабский текст ихрама
        StepArabicSection(
          arabicText: l10n.hajj_step1_ihram_arabic,
          audioFileName: '14', // TODO: заменить на правильный файл аудио
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
          audioFileName: '15', // TODO: заменить на правильный файл аудио
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
          audioFileName: '3', // TODO: заменить на правильный файл аудио
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
