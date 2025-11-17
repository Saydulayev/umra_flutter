import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import 'package:umra_flutter/l10n/app_localizations_de.dart';
import 'package:umra_flutter/l10n/app_localizations_en.dart';
import 'package:umra_flutter/l10n/app_localizations_fr.dart';
import 'package:umra_flutter/l10n/app_localizations_id.dart';
import 'package:umra_flutter/l10n/app_localizations_ru.dart';
import 'package:umra_flutter/l10n/app_localizations_tr.dart';
import '../providers/theme_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/font_provider.dart';
import '../models/step_model.dart';
import '../models/app_theme.dart';
import '../widgets/player_widget.dart';
import '../widgets/counter_tap_widget.dart';
import '../widgets/custom_toolbar.dart';
import '../widgets/arabic_text_widget.dart';
import '../screens/useful_info_screen.dart';

class StepDetailScreen extends StatelessWidget {
  final UmraStep step;

  const StepDetailScreen({super.key, required this.step});

  static AppLocalizations _getLocalization(
    LocalizationProvider localizationProvider,
  ) {
    final locale = localizationProvider.currentLocale;
    switch (locale.languageCode) {
      case 'de':
        return AppLocalizationsDe();
      case 'en':
        return AppLocalizationsEn();
      case 'fr':
        return AppLocalizationsFr();
      case 'id':
        return AppLocalizationsId();
      case 'ru':
        return AppLocalizationsRu();
      case 'tr':
        return AppLocalizationsTr();
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, LocalizationProvider, FontProvider>(
      builder: (context, themeProvider, localizationProvider, fontProvider, child) {
    final theme = themeProvider.selectedTheme;

        // Получаем локализацию напрямую из провайдера
        final l10n = _getLocalization(localizationProvider);

        // Отладочная информация
        debugPrint(
          'StepDetailScreen: Current locale: ${localizationProvider.currentLocale}',
        );
        debugPrint(
          'StepDetailScreen: AppLocalizations locale: ${l10n.localeName}',
        );

    // Определяем, какой контент показывать в зависимости от шага
    Widget content;

    switch (step.id) {
      case 'step1':
            content = _buildStep1Content(theme, l10n, fontProvider);
        break;
      case 'step2':
            content = _buildStep2Content(theme, l10n, fontProvider);
        break;
      case 'step3':
            content = _buildStep3Content(theme, l10n, fontProvider);
        break;
      case 'step4':
            content = _buildStep4Content(theme, l10n, fontProvider);
        break;
      case 'step5':
            content = _buildStep5Content(theme, l10n, fontProvider);
        break;
      case 'step6':
            content = _buildStep6Content(theme, l10n, fontProvider);
        break;
      case 'step7':
            content = _buildStep7Content(theme, l10n, fontProvider);
        break;
      case 'useful':
            return const UsefulInfoScreen();
      default:
        content = _buildDefaultContent(theme, fontProvider);
    }

    return Scaffold(
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getLocalizedTitle(step.titleKey, l10n),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
            actions: const [CustomToolbar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: content,
        ),
      ),
        );
      },
    );
  }

  Widget _buildStep1Content(AppTheme theme, AppLocalizations l10n, FontProvider fontProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Заголовок
        SelectableText(
          l10n.step1EnterIhram,
          style: fontProvider.getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ) ?? TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // 2. "When entering the state of Ihram, say:"
        SelectableText(
          l10n.step1WhenEnteringIhram,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        // 3. Арабский текст + Player 1
        ArabicTextWidget(text: l10n.step1FirstArabic),
        const PlayerWidget(fileName: '1'),
        const SizedBox(height: 16),
        // 4. "Turn your face towards the Qiblah and say:"
        SelectableText(
          l10n.step1TurnToQiblah,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        // 5. Арабский текст + Player 2
        ArabicTextWidget(text: l10n.step1SecondArabic),
        const PlayerWidget(fileName: '2'),
        const SizedBox(height: 8),
        // 6. "O Allah, this Umrah is without any ostentation or fame"
        SelectableText(
          l10n.step1OAllahUmrah,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // 7. Арабский текст + Player 3
        ArabicTextWidget(text: l10n.step1ThirdArabic),
        const PlayerWidget(fileName: '3'),
        const SizedBox(height: 8),
        // 8. "Labbayka Allahumma labbayk"
        SelectableText(
          l10n.step1Labbayka,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // 9. "Entering the Sacred Mosque from the right foot"
        SelectableText(
          l10n.step1EnteringSacredMosque,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        // 10. Арабский текст + Player 4
        ArabicTextWidget(text: l10n.step1EnteringSacredMosqueDuaArabic),
        const PlayerWidget(fileName: '4'),
        const SizedBox(height: 8),
        // 11. "entering the Sacred Mosque"
        SelectableText(
          l10n.step1EnteringSacredMosqueDua,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        // 12. "Conditioning for Hajj or Umrah." - заголовок
        SelectableText(
          l10n.step1ConditioningHajj,
          style: fontProvider.getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ) ?? TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // 13. "If a pilgrim fears that some reason may prevent them from completing the Hajj"
        SelectableText(
          l10n.step1ConditioningHajjText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        // 14. Арабский текст + Player 5
        ArabicTextWidget(text: l10n.step1ConditioningHajjArabic),
        const PlayerWidget(fileName: '5'),
        const SizedBox(height: 8),
        // 15. "Ihram text1"
        SelectableText(
          l10n.step1IhramText1,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        // 16. "Umrah for parents" - заголовок
        SelectableText(
          l10n.step1UmrahForParents,
          style: fontProvider.getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ) ?? TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // 17. "Umrah for parents explanation"
        SelectableText(
          l10n.step1UmrahForParentsExplanation,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // 18. "Umrah for father arabic"
        ArabicTextWidget(text: l10n.step1UmrahForFatherArabic),
        const SizedBox(height: 8),
        // 19. "Umrah for father"
        SelectableText(
          l10n.step1UmrahForFather,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // 20. "Umrah for mother arabic"
        ArabicTextWidget(text: l10n.step1UmrahForMotherArabic),
        const SizedBox(height: 8),
        // 21. "Umrah for mother"
        SelectableText(
          l10n.step1UmrahForMother,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
          ),
        const SizedBox(height: 16),
        // 22. "Umrah for other person arabic"
        ArabicTextWidget(text: l10n.step1UmrahForOtherArabic),
        const SizedBox(height: 8),
        // 23. "Umrah for other person"
        SelectableText(
          l10n.step1UmrahForOther,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildStep2Content(AppTheme theme, AppLocalizations l10n, FontProvider fontProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Заголовок "Kaaba text1"
        SelectableText(
          l10n.step2KaabaText1,
          style: fontProvider.getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ) ?? TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // 2. "Kaaba text2"
        SelectableText(
          l10n.step2KaabaText2,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // 3. Арабский текст "الله أكبر" + Player 6
        ArabicTextWidget(text: l10n.step2TakbirArabic),
        const PlayerWidget(fileName: '6'),
        const SizedBox(height: 16),
        // 4. "Kaaba text3"
        SelectableText(
          l10n.step2KaabaText3,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
          ),
        const SizedBox(height: 16),
        // 5. Арабский текст дуа + Player 7
        ArabicTextWidget(text: l10n.step2DuaArabic),
        const PlayerWidget(fileName: '7'),
        const SizedBox(height: 16),
        // 6. "Kaaba text4"
        SelectableText(
          l10n.step2KaabaText4,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildStep3Content(AppTheme theme, AppLocalizations l10n, FontProvider fontProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Заголовок "Prayer after Tawaf of Kaaba."
        SelectableText(
          l10n.step3PrayerAfterTawaf,
          style: fontProvider.getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ) ?? TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // 2. "Having completed seven circuits around the Kaaba"
        SelectableText(
          l10n.step3CompletedSevenCircuits,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // 3. Арабский текст + Player 13
        ArabicTextWidget(text: l10n.step3ArabicText),
        const PlayerWidget(fileName: '13'),
        const SizedBox(height: 16),
        // 4. "Place of standing of Ibrahim"
        SelectableText(
          l10n.step3PlaceOfStanding,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildStep4Content(AppTheme theme, AppLocalizations l10n, FontProvider fontProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Заголовок "Drinking Zamzam water."
        SelectableText(
          l10n.step4DrinkingZamzam,
          style: fontProvider.getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ) ?? TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // 2. "Zamzam text"
        SelectableText(
          l10n.step4ZamzamText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildStep5Content(AppTheme theme, AppLocalizations l10n, FontProvider fontProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Заголовок "Return to the Black Stone."
        SelectableText(
          l10n.step5ReturnToBlackStone,
          style: fontProvider.getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ) ?? TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // 2. "Return to the Black Stone, recite the Takbir."
        SelectableText(
          l10n.step5ReturnReciteTakbir,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 32),
        // 3. "Allah is great."
        SelectableText(
          l10n.step5AllahIsGreat,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // 4. Арабский текст + Player 6
        ArabicTextWidget(text: l10n.step5TakbirArabic),
        const PlayerWidget(fileName: '6'),
      ],
    );
  }

  Widget _buildStep6Content(AppTheme theme, AppLocalizations l10n, FontProvider fontProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Заголовок "Safa and Marwa"
        SelectableText(
          l10n.step6SafaAndMarwa,
          style: fontProvider.getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ) ?? TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Group 1
        // 2. "Head towards the hill of Safa"
        SelectableText(
          l10n.step6HeadTowardsSafa,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // 3. Арабский текст суры + Player 8
        ArabicTextWidget(text: l10n.step6SurahBaqarahArabic),
        const PlayerWidget(fileName: '8'),
        const SizedBox(height: 16),
        // 4. "Surah Al-Baqarah, verse 158." + полный текст
        SelectableText(
          l10n.step6SurahBaqarahVerse,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        SelectableText(
          l10n.step6SurahBaqarahText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
          ),
        const SizedBox(height: 16),
        // 5. Арабский текст "نَبْدَأُ بِمَا بَدَأَ اللهُ بِهِ" + Player 9
        ArabicTextWidget(text: l10n.step6WeBeginArabic),
        const PlayerWidget(fileName: '9'),
        const SizedBox(height: 16),
        // 6. "We begin with that string" + полный текст
        SelectableText(
          l10n.step6WeBegin,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        SelectableText(
          l10n.step6WeBeginText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // Group 2
        // 7. Арабский текст зикра + CounterTapWidget + Player 10
        ArabicTextWidget(text: l10n.step6RemembranceArabic),
        const CounterTapWidget(),
        const PlayerWidget(fileName: '10'),
        const SizedBox(height: 16),
        // 8. "Remembrance of Allah during the Sa'i of Safa and Marwa." + полный текст
        SelectableText(
          l10n.step6RemembranceTitle,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        SelectableText(
          l10n.step6RemembranceText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
          ),
        const SizedBox(height: 16),
        // 9. Арабский текст дуа + Player 11
        ArabicTextWidget(text: l10n.step6DuasDuringSaiArabic),
        const PlayerWidget(fileName: '11'),
        const SizedBox(height: 16),
        // 10. "Du'a during the Sa'i ritual of Safa and Marwa." + полный текст
        SelectableText(
          l10n.step6DuasDuringSaiTitle,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        SelectableText(
          l10n.step6DuasDuringSaiText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // 11. Арабский текст дуа при выходе + Player 12
        ArabicTextWidget(text: l10n.step6ExitingSacredMosqueArabic),
        const PlayerWidget(fileName: '12'),
        const SizedBox(height: 16),
        // 12. "Du'a upon exiting the Sacred Mosque." + полный текст
        SelectableText(
          l10n.step6ExitingSacredMosqueTitle,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        SelectableText(
          l10n.step6ExitingSacredMosqueText,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildStep7Content(AppTheme theme, AppLocalizations l10n, FontProvider fontProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        SelectableText(
          l10n.step7ShavingHead,
          style: fontProvider.getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ) ?? TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Текст "Men shorten or shave their hair."
        SelectableText(
          l10n.step7MenShortenHair,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // Декоративный разделитель
        SelectableText(
          "ⵈ━══════╗◊╔══════━ⵈ",
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          )?.copyWith(letterSpacing: 2) ?? TextStyle(
            fontSize: 18,
            color: Colors.black87,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Текст "Du'a at the end."
        SelectableText(
          l10n.step7DuaAtEnd,
          style: fontProvider.getTextStyle(
            fontSize: 18,
            color: Colors.black87,
          ) ?? TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildDefaultContent(AppTheme theme, FontProvider fontProvider) {
    return SelectableText(
      'Content for ${step.titleKey}',
      style: fontProvider.getTextStyle(
        fontSize: 18,
        color: Colors.black87,
      ) ?? TextStyle(
        fontSize: 18,
        color: Colors.black87,
      ),
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
      case 'usefulTitle':
        return l10n.usefulTitle;
      default:
        return key;
    }
  }
}
