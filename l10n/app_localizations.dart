import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('id'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Umra'**
  String get appName;

  /// No description provided for @mainScreenNameString.
  ///
  /// In en, this message translates to:
  /// **'UMRA'**
  String get mainScreenNameString;

  /// No description provided for @titleIhramScreen.
  ///
  /// In en, this message translates to:
  /// **'Ihram'**
  String get titleIhramScreen;

  /// No description provided for @titleRoundKaabaScreen.
  ///
  /// In en, this message translates to:
  /// **'Tawaf'**
  String get titleRoundKaabaScreen;

  /// No description provided for @titlePlaceIbrohimStandScreen.
  ///
  /// In en, this message translates to:
  /// **'The place where Ibrahim stood'**
  String get titlePlaceIbrohimStandScreen;

  /// No description provided for @titleWaterZamzamScreen.
  ///
  /// In en, this message translates to:
  /// **'Drinking Zamzam water'**
  String get titleWaterZamzamScreen;

  /// No description provided for @titleBlackStoneScreen.
  ///
  /// In en, this message translates to:
  /// **'Return to the Black Stone'**
  String get titleBlackStoneScreen;

  /// No description provided for @titleSafaAndMarvaScreen.
  ///
  /// In en, this message translates to:
  /// **'Safa and Marwa'**
  String get titleSafaAndMarvaScreen;

  /// No description provided for @titleShaveHeadScreen.
  ///
  /// In en, this message translates to:
  /// **'Shave head or cut hair'**
  String get titleShaveHeadScreen;

  /// No description provided for @usefulTitle.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get usefulTitle;

  /// No description provided for @circleString.
  ///
  /// In en, this message translates to:
  /// **'Walkthrough:'**
  String get circleString;

  /// No description provided for @addString.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addString;

  /// No description provided for @resetString.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetString;

  /// No description provided for @sayFinishedString.
  ///
  /// In en, this message translates to:
  /// **'Sa´y finished'**
  String get sayFinishedString;

  /// No description provided for @settingsString.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsString;

  /// No description provided for @selectLanguageSettingsString.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguageSettingsString;

  /// No description provided for @themeHeavenly.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get themeHeavenly;

  /// No description provided for @themeOasis.
  ///
  /// In en, this message translates to:
  /// **'Oasis'**
  String get themeOasis;

  /// No description provided for @themeGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get themeGold;

  /// No description provided for @themeTurquoise.
  ///
  /// In en, this message translates to:
  /// **'Sea'**
  String get themeTurquoise;

  /// No description provided for @usefulInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Useful Information'**
  String get usefulInfoTitle;

  /// No description provided for @step1EnterIhram.
  ///
  /// In en, this message translates to:
  /// **'into the state of Ihram'**
  String get step1EnterIhram;

  /// No description provided for @step1WhenEnteringIhram.
  ///
  /// In en, this message translates to:
  /// **'When entering the state of Ihram, say:'**
  String get step1WhenEnteringIhram;

  /// No description provided for @step1FirstArabic.
  ///
  /// In en, this message translates to:
  /// **'لَبَّيْكَ اللَّهُمَّ بِعُمْرَةَ'**
  String get step1FirstArabic;

  /// No description provided for @step1TurnToQiblah.
  ///
  /// In en, this message translates to:
  /// **'Turn your face towards the Qiblah and say:'**
  String get step1TurnToQiblah;

  /// No description provided for @step1SecondArabic.
  ///
  /// In en, this message translates to:
  /// **'اَللُّهُمَّ هَذِهِ عُمْرَةً لاٰ رِيَاءَ فِيهَا وَلَا سُمْعَةَ'**
  String get step1SecondArabic;

  /// No description provided for @step1OAllahUmrah.
  ///
  /// In en, this message translates to:
  /// **'O Allah, this Umrah is without any ostentation or fame'**
  String get step1OAllahUmrah;

  /// No description provided for @step1ThirdArabic.
  ///
  /// In en, this message translates to:
  /// **'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ،\nإِنَّ الْحَمْدَ، وَالنِّعْمَةَ، لَكَ وَالْمُلْكَ، لاَ شَرِيكَ لَكَ'**
  String get step1ThirdArabic;

  /// No description provided for @step1Labbayka.
  ///
  /// In en, this message translates to:
  /// **'Labbayka Allahumma labbayk'**
  String get step1Labbayka;

  /// No description provided for @step1EnteringSacredMosque.
  ///
  /// In en, this message translates to:
  /// **'Entering the Sacred Mosque from the right foot'**
  String get step1EnteringSacredMosque;

  /// No description provided for @step1EnteringSacredMosqueDuaArabic.
  ///
  /// In en, this message translates to:
  /// **'اَللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَ سَلِّمْ،اَللَّهُمَّ افْتَحْ لِي اَبْوَابَ رَحْمَتِكَ'**
  String get step1EnteringSacredMosqueDuaArabic;

  /// No description provided for @step1EnteringSacredMosqueDua.
  ///
  /// In en, this message translates to:
  /// **'entering the Sacred Mosque'**
  String get step1EnteringSacredMosqueDua;

  /// No description provided for @step1ConditioningHajjArabic.
  ///
  /// In en, this message translates to:
  /// **'اَللَّهُمَّ مَحِلِّي حَيْثُ حَبَسْتَنِي'**
  String get step1ConditioningHajjArabic;

  /// No description provided for @step1ConditioningHajj.
  ///
  /// In en, this message translates to:
  /// **'Conditioning for Hajj or Umrah.'**
  String get step1ConditioningHajj;

  /// No description provided for @step1ConditioningHajjText.
  ///
  /// In en, this message translates to:
  /// **'If a pilgrim fears that some reason may prevent them from completing the Hajj - be it illness or fear, then before reciting the Talbiyah, they may condition their Hajj before the Most High Lord, saying what the Messenger taught, peace and blessings of Allah be upon him:'**
  String get step1ConditioningHajjText;

  /// No description provided for @step1IhramText1.
  ///
  /// In en, this message translates to:
  /// **'\"Allahumma mahilli haythu habastani\"\n\n\"O Allah, my place of entering Ihram is where You have detained me.\"\n\nThis hadith is agreed upon. See also \"Sahih Abi Dawud\" (1776).\n\nTherefore, if a pilgrim does this, and something detains them or they become ill, they are allowed to exit the state of Ihram when performing Hajj or Umrah, and they will not need to sacrifice an animal as atonement and repeat the Hajj again, unless it was their first Hajj, which is obligatory, in which case it should be performed again.'**
  String get step1IhramText1;

  /// No description provided for @step1UmrahForParents.
  ///
  /// In en, this message translates to:
  /// **'Umrah for parents'**
  String get step1UmrahForParents;

  /// No description provided for @step1UmrahForFatherArabic.
  ///
  /// In en, this message translates to:
  /// **'لَبَّيْكَ ٱللّٰهُمَّ بِعُمْرَةٍ عَنْ أَبِي'**
  String get step1UmrahForFatherArabic;

  /// No description provided for @step1UmrahForFather.
  ///
  /// In en, this message translates to:
  /// **'Labbayka Allahumma bi-\'umrah \'an abi (father\'s name) - \"O Allah, I am performing \'umrah for my father (name).\"'**
  String get step1UmrahForFather;

  /// No description provided for @step1UmrahForMotherArabic.
  ///
  /// In en, this message translates to:
  /// **'لَبَّيْكَ ٱللّٰهُمَّ بِعُمْرَةٍ عَنْ أُمِّي'**
  String get step1UmrahForMotherArabic;

  /// No description provided for @step1UmrahForMother.
  ///
  /// In en, this message translates to:
  /// **'Labbayka Allahumma bi-\'umrah \'an ummi (mother\'s name) - \"O Allah, I am performing \'umrah for my mother (name).\"'**
  String get step1UmrahForMother;

  /// No description provided for @step1UmrahForOtherArabic.
  ///
  /// In en, this message translates to:
  /// **'لَبَّيْكَ ٱللّٰهُمَّ بِعُمْرَةٍ عَنْ'**
  String get step1UmrahForOtherArabic;

  /// No description provided for @step1UmrahForOther.
  ///
  /// In en, this message translates to:
  /// **'Labbayka Allahumma bi-\'umrah \'an (person\'s name) - \"O Allah, I am performing \'umrah for (person\'s name).\"'**
  String get step1UmrahForOther;

  /// No description provided for @step1UmrahForFatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Umrah for father:'**
  String get step1UmrahForFatherTitle;

  /// No description provided for @step1UmrahForMotherTitle.
  ///
  /// In en, this message translates to:
  /// **'Umrah for mother:'**
  String get step1UmrahForMotherTitle;

  /// No description provided for @step1UmrahForOtherTitle.
  ///
  /// In en, this message translates to:
  /// **'Umrah for another person:'**
  String get step1UmrahForOtherTitle;

  /// No description provided for @step1UmrahForParentsExplanation.
  ///
  /// In en, this message translates to:
  /// **'If you want to perform Umrah for your parents or another person, instead of the usual Talbiyah, recite one of the given formulas, adding after the words \"abi\" (father), \"ummi\" (mother) or simply after the word \"\'an\" the name of the person for whom Umrah is being performed. After pronouncing the intention and Talbiyah with the mention of the name, all other actions, supplications (dua) and remembrances of Allah (dhikr) are performed as usual, as if you are doing Umrah for yourself. The only difference is the intention.'**
  String get step1UmrahForParentsExplanation;

  /// No description provided for @step2KaabaText1.
  ///
  /// In en, this message translates to:
  /// **'Tawaf around the Kaaba'**
  String get step2KaabaText1;

  /// No description provided for @step2KaabaText2.
  ///
  /// In en, this message translates to:
  /// **'Begin the seven-fold circumambulation of the Kaaba (Tawaf).\n\nFrom the very beginning of this circumambulation of the Kaaba until its completion, men expose their right shoulder.\n\nAfter this, the pilgrim touches the Black Stone with his hand and kisses it.\n\nIf it is not possible to kiss the Black Stone, one should touch the Black Stone with one\'s hand.\n\nIf it is not possible to touch and kiss the Black Stone, then face it, point to it with your right hand and say the Takbir: \"Allahu Akbar\" Allah is Great. (All of this should be done during each round when circumambulating the Kaaba.)'**
  String get step2KaabaText2;

  /// No description provided for @step2KaabaText3.
  ///
  /// In en, this message translates to:
  /// **'Begin the seven-fold circumambulation of the Kaaba (Tawaf) from the Black Stone.\n\nPassing from the Black Stone to the Black Stone counts as one round. Starting a new round, point to the Black Stone with your right hand and say the Takbir. The first three rounds, from the Black Stone to the Black Stone, men must walk at a fast pace, and the remaining four - at a normal pace. If possible, touch the Yemeni corner during each round. Every time you pass between the Yemeni corner and the Black Stone, you should say:'**
  String get step2KaabaText3;

  /// No description provided for @step2KaabaText4.
  ///
  /// In en, this message translates to:
  /// **'Rabbana, atina fi-d-dunya hasanatan wa fil-akhirati hasanatan wa qina \'azaba-n-nar\n\n\"Our Lord! Grant us good in this world and good in the Hereafter, and protect us from the torment of the Fire!\",\n\nSurah \"Al-Baqarah\", verse 201.'**
  String get step2KaabaText4;

  /// No description provided for @step2DuaArabic.
  ///
  /// In en, this message translates to:
  /// **'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ'**
  String get step2DuaArabic;

  /// No description provided for @step2TakbirArabic.
  ///
  /// In en, this message translates to:
  /// **'الله أكبر'**
  String get step2TakbirArabic;

  /// No description provided for @step3PrayerAfterTawaf.
  ///
  /// In en, this message translates to:
  /// **'Prayer after Tawaf of Kaaba.'**
  String get step3PrayerAfterTawaf;

  /// No description provided for @step3CompletedSevenCircuits.
  ///
  /// In en, this message translates to:
  /// **'Having completed the seven-fold circumambulation of the Kaaba, the man covers his right shoulder. Then head to the place of standing of Ibrahim and say:'**
  String get step3CompletedSevenCircuits;

  /// No description provided for @step3ArabicText.
  ///
  /// In en, this message translates to:
  /// **'وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّ'**
  String get step3ArabicText;

  /// No description provided for @step3PlaceOfStanding.
  ///
  /// In en, this message translates to:
  /// **'Wa-ttakhidhu mim-maqami Ibrahima musalla\n\n\"Take the place [of standing] of Ibrahim as a place of prayer\" (Surah 2 \"Al-Baqarah = The Cow\", verse 125).\n\nIf possible, perform two rak\'ahs of prayer behind the place of standing of Ibrahim or anywhere in the Sacred Mosque. Do not forget to set up a barrier in front of you so that no one passes between you and this barrier. In the first rak\'ah after Surah 1 \"Al-Fatiha = The Opening\", read Surah 109 \"Al-Kafirun = The Disbelievers\", and in the second rak\'ah after Surah \"Al-Fatiha\" read Surah 112 \"Al-Ikhlas = The Sincerity\".\n\nAfter completing the prayer, go to the Zamzam water source.'**
  String get step3PlaceOfStanding;

  /// No description provided for @step4DrinkingZamzam.
  ///
  /// In en, this message translates to:
  /// **'Drinking Zamzam water.'**
  String get step4DrinkingZamzam;

  /// No description provided for @step4ZamzamText.
  ///
  /// In en, this message translates to:
  /// **'Drink the water and pour it on your head.\n\nJabir (may Allah be pleased with him) reported: \"The Prophet (peace and blessings of Allah be upon him) went to the Zamzam well, drank from it and poured it on his head\". Ahmad (3/394), Ibn Khuzaymah (4/305). The authenticity of the hadith was confirmed by az-Zarkashi, Badruddin al-\'Ayni, Shu\'ayb al-Arnaut. See \"\'Umdatul-Qari\" (9/227), \"Hashiya \'ala al-Manasik\" (p. 263), \"Takhrij al-Musnad\" (15243).\n\nIt is reported from Jabir (may Allah be pleased with him) that the Messenger of Allah (peace and blessings of Allah be upon him) said: \"Zamzam water helps to achieve what it is drunk for\".\n\nAhmad (3/357), Ibn Majah (3062), al-Hakim (1739). The authenticity of the hadith was confirmed by Sufyan ibn \'Uyaynah, al-Munziri, ad-Dumyat, Ibn al-Qayyim, az-Zarkashi, Ibn Hajar, al-Albani. See \"al-Mujalasa\" (509), \"al-Matjar ar-rabih\" (982), \"Zad al-Ma\'ad\" (4/393), \"al-Maqasid al-hasana\" (928), \"Fayd al-Qadir\" (7759), \"Sahih at-Targhib\" (1165).\n\nAsh-Shawkani said: \"This hadith contains evidence that drinking Zamzam water benefits the drinker, whatever intention he drinks it with, be it matters of this world or the Eternal world. For the words: \'Helps to achieve what it is drunk for\' are general\". See \"Nayl al-Awtar\" (5/105).\n\nAn-Nawawi said: \"The meaning of this hadith is that whoever drinks this water for something specific, acquires it. Indeed, scholars and righteous people have tried this to achieve their needs related to this world and the Eternal world and received it by the mercy of Allah the Most High\". See \"Tahzib al-asma wa-l-lughat\" (3/139).'**
  String get step4ZamzamText;

  /// No description provided for @step5ReturnToBlackStone.
  ///
  /// In en, this message translates to:
  /// **'Return to the Black Stone.'**
  String get step5ReturnToBlackStone;

  /// No description provided for @step5ReturnReciteTakbir.
  ///
  /// In en, this message translates to:
  /// **'Return to the Black Stone, recite the Takbir.'**
  String get step5ReturnReciteTakbir;

  /// No description provided for @step5AllahIsGreat.
  ///
  /// In en, this message translates to:
  /// **'Allah is great.'**
  String get step5AllahIsGreat;

  /// No description provided for @step5TakbirArabic.
  ///
  /// In en, this message translates to:
  /// **'الله أكبر'**
  String get step5TakbirArabic;

  /// No description provided for @step6SafaAndMarwa.
  ///
  /// In en, this message translates to:
  /// **'Safa and Marwa'**
  String get step6SafaAndMarwa;

  /// No description provided for @step6HeadTowardsSafa.
  ///
  /// In en, this message translates to:
  /// **'Head towards the hill of Safa'**
  String get step6HeadTowardsSafa;

  /// No description provided for @step6SurahBaqarahArabic.
  ///
  /// In en, this message translates to:
  /// **'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللهِ ۖ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا ۚ وَمَنْ تَطَوَّعَ خَيْرًا فَإِنَّ اللهَ شَاكِرٌ عَلِيمٌ'**
  String get step6SurahBaqarahArabic;

  /// No description provided for @step6SurahBaqarahVerse.
  ///
  /// In en, this message translates to:
  /// **'Surah Al-Baqarah, verse 158.'**
  String get step6SurahBaqarahVerse;

  /// No description provided for @step6SurahBaqarahText.
  ///
  /// In en, this message translates to:
  /// **'Inna-s-Safa wal-Marwata min sha\'a\'iri-llah, fa-man hajja-l-bayta awi-\'tamara fala junaha \'alayhi ayy-yat\'tawwafa bihima, wa man tatawwa\'a khayran fa-inna-llaha Shakirun \'alim.\n\n\"Indeed, as-Safa and al-Marwah are among the symbols of Allah. Whoever performs Hajj to the Kaaba or \'Umrah, he will not commit a sin if he passes between them. And if anyone voluntarily does a good deed, then indeed Allah is Appreciative, Knowing.\" (Surah \"Al-Baqarah\", verse 158)\n\nThen say:'**
  String get step6SurahBaqarahText;

  /// No description provided for @step6WeBeginArabic.
  ///
  /// In en, this message translates to:
  /// **'نَبْدَأُ بِمَا بَدَأَ اللهُ بِهِ'**
  String get step6WeBeginArabic;

  /// No description provided for @step6WeBegin.
  ///
  /// In en, this message translates to:
  /// **'We begin with that string'**
  String get step6WeBegin;

  /// No description provided for @step6WeBeginText.
  ///
  /// In en, this message translates to:
  /// **'Nabda\'u bima bada\'a-llahu bihi\n\n\"We begin with that which Allah began\"\n\nClimb the hill of Safa, turn to face the Kaaba and say:'**
  String get step6WeBeginText;

  /// No description provided for @step6RemembranceArabic.
  ///
  /// In en, this message translates to:
  /// **'اَلله أَكْبَرُ الله أَكْبَرُ الله اَكْبَرُ، لٰا إِلَهَ إِلَّا اللهُ وَحْدَهُ لٰا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَ لَهُ الْحَمْدُ، يُحْيِي وَ يُمِيتُ ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، لَا إِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، أَنْجَزَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَهَزَمَ الْأَحْزَابَ وَحْدَهُ.'**
  String get step6RemembranceArabic;

  /// No description provided for @step6RemembranceTitle.
  ///
  /// In en, this message translates to:
  /// **'Remembrance of Allah during the Sa\'i of Safa and Marwa.'**
  String get step6RemembranceTitle;

  /// No description provided for @step6RemembranceText.
  ///
  /// In en, this message translates to:
  /// **'Allahu akbar! Allahu akbar! Allahu akbar!\n\nLa ilaha illa-llahu wahdahu la sharika lahu! Lahul-mulku wa lahul-hamdu yuhyi wa yumitu wa huwa \'ala kulli shay\'in qadir! La ilaha illa llahu wahdahu la sharika lahu anjaza wa\'dahu, wa nasara \'abdahu, wa hazama-l-ahzaba wahdahu.\n\n\"Allah is Most Great, Allah is Most Great, Allah is Most Great!\n\nThere is no deity except Allah, the One, Who has no partner! To Him belongs the dominion and to Him belongs praise, He gives life and causes death, and He has power over all things! There is no deity except Allah, the One, Who has no partner! He fulfilled His promise, helped His servant and alone defeated the hostile tribes\"\n\nSay these words three times, raising your hands for dua after the first and second time. Then begin the passage from the hill of Safa to Marwah. One passage from Safa to Marwah counts as one time, and the return journey is the second. On the hill of Marwah, repeat the same order: dhikr - dua - dhikr - dua - dhikr. These dhikrs and duas should be repeated on each ascent to Safa and Marwah, except for the seventh passage. When reaching the first mark, marked in green, men must run to the second mark. The rest of the journey is done at a normal pace.\n\nDuring the Sa\'i ritual, you can turn to Allah with such a supplication:'**
  String get step6RemembranceText;

  /// No description provided for @step6DuasDuringSaiArabic.
  ///
  /// In en, this message translates to:
  /// **'رَبِّ اغْفِرْ وَ ارْحَمْ، إِنَّكَ أَنْتَ الْأَعَزُّ الْاَكْرَمُ.'**
  String get step6DuasDuringSaiArabic;

  /// No description provided for @step6DuasDuringSaiTitle.
  ///
  /// In en, this message translates to:
  /// **'Du\'a during the Sa\'i ritual of Safa and Marwa.'**
  String get step6DuasDuringSaiTitle;

  /// No description provided for @step6DuasDuringSaiText.
  ///
  /// In en, this message translates to:
  /// **'Rabbi-ghfir wa-rham, innaka antal-a\'azzu-l-akram\n\n\"Lord, forgive and have mercy, for You are the Most Great and Most Generous!\",\n\nthere is nothing wrong with this, as this supplication is established from a whole group of righteous predecessors.\n\nUpon completion of the seventh round, the pilgrim no longer recites dhikr and dua on the hill of Marwah. This means that the Sa\'i ritual is complete.\n\nSupplication upon exiting the Sacred Mosque. After completing the seventh passage on the hill of Marwah, exit the Sacred Mosque with your left foot, saying:'**
  String get step6DuasDuringSaiText;

  /// No description provided for @step6ExitingSacredMosqueArabic.
  ///
  /// In en, this message translates to:
  /// **'اَللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَ سَلِّمْ ، اَللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ.'**
  String get step6ExitingSacredMosqueArabic;

  /// No description provided for @step6ExitingSacredMosqueTitle.
  ///
  /// In en, this message translates to:
  /// **'Du\'a upon exiting the Sacred Mosque.'**
  String get step6ExitingSacredMosqueTitle;

  /// No description provided for @step6ExitingSacredMosqueText.
  ///
  /// In en, this message translates to:
  /// **'Allahumma, salli \'ala Muhammadin wa sallim! Allahumma, inni as\'alu-ka min fadli-ka!\n\nO Allah, bless Muhammad and grant him peace! O Allah, indeed, I ask You for Your Mercy!'**
  String get step6ExitingSacredMosqueText;

  /// No description provided for @step6RemembranceDuringSai.
  ///
  /// In en, this message translates to:
  /// **'Allahu akbar! Allahu akbar! Allahu akbar!\n\nLa ilaha illa-llahu wahdahu la sharika lahu! Lahul-mulku wa lahul-hamdu yuhyi wa yumitu wa huwa \'ala kulli shay\'in qadir! La ilaha illa llahu wahdahu la sharika lahu anjaza wa\'dahu, wa nasara \'abdahu, wa hazama-l-ahzaba wahdahu.\n\n\"Allah is Most Great, Allah is Most Great, Allah is Most Great!\n\nThere is no deity except Allah, the One, Who has no partner! To Him belongs the dominion and to Him belongs praise, He gives life and causes death, and He has power over all things! There is no deity except Allah, the One, Who has no partner! He fulfilled His promise, helped His servant and alone defeated the hostile tribes\"\n\nSay these words three times, raising your hands for dua after the first and second time. Then begin the passage from the hill of Safa to Marwah. One passage from Safa to Marwah counts as one time, and the return journey is the second. On the hill of Marwah, repeat the same order: dhikr - dua - dhikr - dua - dhikr. These dhikrs and duas should be repeated on each ascent to Safa and Marwah, except for the seventh passage. When reaching the first mark, marked in green, men must run to the second mark. The rest of the journey is done at a normal pace.\n\nDuring the Sa\'i ritual, you can turn to Allah with such a supplication:'**
  String get step6RemembranceDuringSai;

  /// No description provided for @step6DuasDuringSai.
  ///
  /// In en, this message translates to:
  /// **'Rabbi-ghfir wa-rham, innaka antal-a\'azzu-l-akram\n\n\"Lord, forgive and have mercy, for You are the Most Great and Most Generous!\",\n\nthere is nothing wrong with this, as this supplication is established from a whole group of righteous predecessors.\n\nUpon completion of the seventh round, the pilgrim no longer recites dhikr and dua on the hill of Marwah. This means that the Sa\'i ritual is complete.\n\nSupplication upon exiting the Sacred Mosque. After completing the seventh passage on the hill of Marwah, exit the Sacred Mosque with your left foot, saying:'**
  String get step6DuasDuringSai;

  /// No description provided for @step6ExitingSacredMosque.
  ///
  /// In en, this message translates to:
  /// **'Allahumma, salli \'ala Muhammadin wa sallim! Allahumma, inni as\'alu-ka min fadli-ka!\n\nO Allah, bless Muhammad and grant him peace! O Allah, indeed, I ask You for Your Mercy!'**
  String get step6ExitingSacredMosque;

  /// No description provided for @step7ShavingHead.
  ///
  /// In en, this message translates to:
  /// **'Shaving the head or trimming the hair.'**
  String get step7ShavingHead;

  /// No description provided for @step7MenShortenHair.
  ///
  /// In en, this message translates to:
  /// **'Then the man evenly shortens the hair on his head or shaves it, and the woman cuts off a lock the size of a third of a finger.\n\nNote:\n\nFor those coming for Hajj, it is better to shorten the hair if they will not have time to grow back after \'Umrah before Hajj, as shaving the head is done during Hajj.\n\nFor those coming to perform only \'Umrah (without Hajj), it is better to shave the head.\n\nComplete exit from the state of Ihram.\n\nAt this point, \'Umrah ends. The man removes the Ihram garment. The restrictions that were in effect in the state of Ihram are lifted.'**
  String get step7MenShortenHair;

  /// No description provided for @step7DuaAtEnd.
  ///
  /// In en, this message translates to:
  /// **'In conclusion, I ask Allah the Most High to accept all our good deeds and preserve for us the reward for their performance until the Day when we meet with Him,\n\n\"on that Day when neither wealth nor sons will benefit anyone, except those who appear before Allah with a pure heart\"\n\n(Surah \"Ash-Shu\'ara\", verses 88-89).\n\nI also ask Allah the Most High to grant full reward to all who participated in the creation, development and distribution of this application - whether by advice, knowledge, means or a kind word - for every Umrah performed with its help.\n\nAs the Messenger of Allah (peace and blessings of Allah be upon him) said:\n\n\"Whoever points to good, he will receive the same reward as the one who does this good deed\"\n\n(Sahih Muslim, No. 1893).\n\nPraise be to Allah, Lord of the worlds!'**
  String get step7DuaAtEnd;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'fr',
    'id',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
