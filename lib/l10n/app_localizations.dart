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

  /// No description provided for @feedbackString.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackString;

  /// No description provided for @rateTheAppString.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateTheAppString;

  /// No description provided for @appThemeString.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appThemeString;

  /// No description provided for @notificationSettingsString.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsString;

  /// No description provided for @selectLanguageString.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageString;

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

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get themeDark;

  /// No description provided for @themeSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose App Theme'**
  String get themeSelectTitle;

  /// No description provided for @usefulInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Useful Information'**
  String get usefulInfoTitle;

  /// No description provided for @etiquetteManners.
  ///
  /// In en, this message translates to:
  /// **'Etiquette and Manners'**
  String get etiquetteManners;

  /// No description provided for @hajjUmrahVirtues.
  ///
  /// In en, this message translates to:
  /// **'Hajj and Umrah Virtues'**
  String get hajjUmrahVirtues;

  /// No description provided for @hajjUmrahObligation.
  ///
  /// In en, this message translates to:
  /// **'Hajj and Umrah Obligation'**
  String get hajjUmrahObligation;

  /// No description provided for @janazaPrayerGuide.
  ///
  /// In en, this message translates to:
  /// **'Janaza Prayer'**
  String get janazaPrayerGuide;

  /// No description provided for @titleJanazaGuide.
  ///
  /// In en, this message translates to:
  /// **'Janaza Prayer'**
  String get titleJanazaGuide;

  /// No description provided for @basicRules.
  ///
  /// In en, this message translates to:
  /// **'Janaza Prayer Guide'**
  String get basicRules;

  /// No description provided for @janazaBasicRules.
  ///
  /// In en, this message translates to:
  /// **'📌 Essential Rules of the Janazah Prayer (Funeral Prayer).\n\nThe prayer is performed while standing, without bowing (ruku\') or prostration (sujood). It consists of four takbirs (saying \'Allahu Akbar\').\n\nAfter each takbir, specific supplications are recited:\n\n1 Surah Al-Fatihah\n\n2 Salawat upon the Prophet ﷺ\n\n3 Dua for the deceased\n\n4 You can make a supplication or conclude the prayer'**
  String get janazaBasicRules;

  /// No description provided for @firstTakbirTitle.
  ///
  /// In en, this message translates to:
  /// **'1. First Takbir'**
  String get firstTakbirTitle;

  /// No description provided for @firstTakbirText.
  ///
  /// In en, this message translates to:
  /// **'Raise your hands to the level of your shoulders or ears and say:\n\nاللَّهُ أَكْبَرُ\n\nAllahu Akbar (\"Allah is the Greatest\")\n\nThen:\n\nRecite Surah Al-Fatihah.'**
  String get firstTakbirText;

  /// No description provided for @secondTakbirTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Second Takbir'**
  String get secondTakbirTitle;

  /// No description provided for @secondTakbirText.
  ///
  /// In en, this message translates to:
  /// **'Say the takbir (without raising the hands):\n\nاللَّهُ أَكْبَرُ - Allahu Akbar\n\nRecite Salawat upon the Prophet ﷺ:\n\nاللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ. اللَّهُمَّ بَارِكْ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ\n\nAllahumma salli \'ala Muhammadin wa \'ala ali Muhammadin, kama sallayta \'ala Ibrahima wa \'ala ali Ibrahima, innaka Hamidun, Majidun. Allahumma, barik \'ala Muhammadin wa \'ala ali Muhammadin kama barakta \'ala Ibrahima wa \'ala ali Ibrahima, innaka Hamidun, Majidun!'**
  String get secondTakbirText;

  /// No description provided for @translateSecondTakbirText.
  ///
  /// In en, this message translates to:
  /// **'\"O Allah, bless Muhammad and his family, as You blessed Ibrahim and Ibrahim\'s family, indeed, You are Praiseworthy, Glorious! O Allah, send blessings to Muhammad and his family, as You sent them to Ibrahim and his family, indeed, You are Praiseworthy, Glorious!\".'**
  String get translateSecondTakbirText;

  /// No description provided for @thirdTakbirTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Third Takbir'**
  String get thirdTakbirTitle;

  /// No description provided for @thirdTakbirText.
  ///
  /// In en, this message translates to:
  /// **'Say the takbir (without raising the hands):\n\nاللَّهُ أَكْبَرُ - Allahu Akbar\n\nRecite the dua for the deceased (if male):\n\nاللَّهُمَّ اغْفِرْ لَهُ، وَارْحَمْهُ،\n\nAllahumma ghfir lahu, warhamhu.\n\nOr:\n\nاللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ، وَعَافِهِ، وَاعْفُ عَنْهُ، وَأَكْرِمْ نُزُلَهُ، وَوَسِّعْ مُدْخَلَهُ، وَاغْسِلْهُ بِالْمَاءِ وَالثَّلْجِ وَالْبَرَدِ، وَنَقِّهِ مِنَ الْخَطَايَا كَمَا نَقَّيْتَ الثَّوْبَ الأبْيَضَ مِنَ الدَّنَسِ، وَأَبْدِلْهُ دَاراً خَيْراً مِنْ دَارِهِ، وَأَهْلاً خَيْراً مِنْ أَهْلِهِ، وَزَوْجاً خَيْرا ًمِنْ زَوَجِهِ، وَأَدْخِلْهُ الْجَنَّةَ، وَأَعِذْهُ مِنْ عَذَابِ الْقَبْرِ وَعَذَابِ النَّارِ\n\nAllahumma ghfir lahu, warhamhu, wa \'afihi, wa\'fu \'anhu, wa akrim nuzulah, wa wassi\' mudkhala, wa ghsilhu bilma\'i, was-salji wal-baradi, wa naqqi-hi mina-l-khataya, kama yunaqqa-s-sawbu-l-abyadu mina-d-danas, wa abdil-hu daran khayran min darihi, wa ahlan khayran min ahlihi, wa zawjan khayran min zawjihi, wa adkhilhu-l-jannata, wa a\'iz-hu min \'azabi-l-qabri wa \'azabi-n-nari.'**
  String get thirdTakbirText;

  /// No description provided for @translateThirdTakbirText.
  ///
  /// In en, this message translates to:
  /// **'Awf ibn Malik reported: \"Once the Messenger of Allah (peace and blessings of Allah be upon him) performed the janaza prayer, and I remembered that, when making dua for the deceased, he said: \'O Allah! Forgive him, and have mercy on him, and grant him relief, and give him a good reception, and make his grave spacious, and wash him with water, snow and hail! Purify him from sins, as You purify white clothes from dirt, and give him in return a house better than his house, and a family better than his family, and a wife better than his wife, and enter him into Paradise and protect him from the torment of the grave and from the torment of the Fire!\'\" - Abu \'Abdur-Rahman said: \"And I even wanted to be in the place of the deceased myself\". Muslim 2/663.'**
  String get translateThirdTakbirText;

  /// No description provided for @duaVariationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Dua Variations Depending on the Deceased'**
  String get duaVariationsTitle;

  /// No description provided for @duaVariationsText.
  ///
  /// In en, this message translates to:
  /// **'📌 If the deceased is one man\n\n- Use the form: لَهُ (lahu)\n\nاللَّهُمَّ اغْفِرْ لَهُ، وَارْحَمْهُ،\n\n(Allahumma ghfir lahu, warhamhu.)\n\n📌 If the deceased is one woman\n\n- Replace all forms from masculine to feminine: لَهَا (laha)\n\nاللَّهُمَّ اغْفِرْ لَهَا، وَارْحَمْهَا،\n\n(Allahumma ghfir laha, warhamha.)\n\n📌 If several deceased (men only)\n\n- Use the masculine plural form: لَهُمْ (lahum)\n\nاللَّهُمَّ اغْفِرْ لَهُمْ، وَارْحَمْهُمْ،\n\n(Allahumma ghfir lahum, warhamhum.)\n\n📌 If several deceased (women only)\n\n- Use the feminine plural form: لَهُنَّ (lahunna)\n\nاللَّهُمَّ اغْفِرْ لَهُنَّ، وَارْحَمْهُنَّ،\n\n(Allahumma ghfir lahunna, warhamhunna.)\n\n📌 If it is unknown whether the deceased was a man or a woman, or if several deceased (men and women together), use the form: لَهُمْ (lahum).\n\nاللَّهُمَّ اغْفِرْ لَهُمْ، وَارْحَمْهُمْ،\n\n(Allahumma ghfir lahum, warhamhum.)'**
  String get duaVariationsText;

  /// No description provided for @fourthTakbirTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Fourth Takbir'**
  String get fourthTakbirTitle;

  /// No description provided for @fourthTakbirText.
  ///
  /// In en, this message translates to:
  /// **'Say the takbir (without raising the hands):\n\nاللَّهُ أَكْبَرُ - Allahu Akbar\n\nYou can make a supplication, but it is not obligatory.'**
  String get fourthTakbirText;

  /// No description provided for @fourthTakbirAdditionalInfo.
  ///
  /// In en, this message translates to:
  /// **'On the permissibility of making dua for the deceased after the fourth takbir.\n\nIt is reported that when \'Abdullah ibn Abu Awf performed the janaza prayer over his daughter, he said the takbir four times. After saying it the fourth time, he stood for as long as it took between two takbirs, asking Allah for forgiveness for his daughter and making dua for her, then said: \"This is how the Messenger of Allah (peace and blessings of Allah be upon him) did it\" al-Hakim 1/512. See \"Sahih Sunan Ibn Majah\" 1220.'**
  String get fourthTakbirAdditionalInfo;

  /// No description provided for @taslimTitle.
  ///
  /// In en, this message translates to:
  /// **'Conclusion (Taslim)'**
  String get taslimTitle;

  /// No description provided for @taslimText.
  ///
  /// In en, this message translates to:
  /// **'📌 You can say the taslim once to the right or twice (to the right and to the left).\n\nThe Messenger of Allah (peace and blessings of Allah be upon him), when performing the janaza prayer, did both one and two greetings, but he did one greeting more often.'**
  String get taslimText;

  /// No description provided for @translateText.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translateText;

  /// No description provided for @sincerity.
  ///
  /// In en, this message translates to:
  /// **'Sincerity'**
  String get sincerity;

  /// No description provided for @laws.
  ///
  /// In en, this message translates to:
  /// **'Laws'**
  String get laws;

  /// No description provided for @choiceOfCompanions.
  ///
  /// In en, this message translates to:
  /// **'Choice of Companions'**
  String get choiceOfCompanions;

  /// No description provided for @financialIndependence.
  ///
  /// In en, this message translates to:
  /// **'Financial Independence'**
  String get financialIndependence;

  /// No description provided for @nobleManners.
  ///
  /// In en, this message translates to:
  /// **'Noble Manners'**
  String get nobleManners;

  /// No description provided for @zikrAndPrayers.
  ///
  /// In en, this message translates to:
  /// **'Zikr and Prayers'**
  String get zikrAndPrayers;

  /// No description provided for @cautionInRelationships.
  ///
  /// In en, this message translates to:
  /// **'Caution in Relationships'**
  String get cautionInRelationships;

  /// No description provided for @atonementAndRewards.
  ///
  /// In en, this message translates to:
  /// **'Atonement and Rewards'**
  String get atonementAndRewards;

  /// No description provided for @hajjForWomen.
  ///
  /// In en, this message translates to:
  /// **'Hajj for Women'**
  String get hajjForWomen;

  /// No description provided for @perfectHajj.
  ///
  /// In en, this message translates to:
  /// **'Perfect Hajj'**
  String get perfectHajj;

  /// No description provided for @followingTheSunnah.
  ///
  /// In en, this message translates to:
  /// **'Following the Sunnah'**
  String get followingTheSunnah;

  /// No description provided for @hajjObligationEvidence.
  ///
  /// In en, this message translates to:
  /// **'Hajj Obligation Evidence'**
  String get hajjObligationEvidence;

  /// No description provided for @umrahObligationEvidence.
  ///
  /// In en, this message translates to:
  /// **'Umrah Obligation Evidence'**
  String get umrahObligationEvidence;

  /// No description provided for @conclusion.
  ///
  /// In en, this message translates to:
  /// **'Conclusion'**
  String get conclusion;

  /// No description provided for @step1EnterIhram.
  ///
  /// In en, this message translates to:
  /// **'\nEnter the state of Ihram at the designated place (Miqat).\n'**
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
  /// **'\nLabbayka Allahumma bi-´umrah.\n\nTurn your face towards the Qibla and say:\n'**
  String get step1TurnToQiblah;

  /// No description provided for @step1SecondArabic.
  ///
  /// In en, this message translates to:
  /// **'اَللُّهُمَّ هَذِهِ عُمْرَةً لاٰ رِيَاءَ فِيهَا وَلَا سُمْعَةَ'**
  String get step1SecondArabic;

  /// No description provided for @step1OAllahUmrah.
  ///
  /// In en, this message translates to:
  /// **'Allahumma hazihi \'umrah, la riya\'a fiha wa la sum\'ah.\n\nO Allah, this Umrah - there is no showing off or seeking fame in it!\n\n\nThen begin loudly reciting the Talbiyah:\n'**
  String get step1OAllahUmrah;

  /// No description provided for @step1ThirdArabic.
  ///
  /// In en, this message translates to:
  /// **'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ،\nإِنَّ الْحَمْدَ، وَالنِّعْمَةَ، لَكَ وَالْمُلْكَ، لاَ شَرِيكَ لَكَ'**
  String get step1ThirdArabic;

  /// No description provided for @step1Labbayka.
  ///
  /// In en, this message translates to:
  /// **'Labbayka Allahumma labbayk! Labbayka laa shariika laka labbayka! Innal hamda wanni\'mata laka wal mulk, laa shariika lak\n\n(«Here I am, O Allah, here I am! Here I am, there is no partner for You, here I am! Verily, all praise, grace, and sovereignty belong to You. You have no partner.»).\n\n\nUpon reaching the sacred territory of Mecca and seeing the houses of Mecca, one should stop reciting the Talbiyah.'**
  String get step1Labbayka;

  /// No description provided for @step1EnteringSacredMosque.
  ///
  /// In en, this message translates to:
  /// **'\n\nUpon entering the Sacred Mosque with the right foot, say:\n'**
  String get step1EnteringSacredMosque;

  /// No description provided for @step1EnteringSacredMosqueDuaArabic.
  ///
  /// In en, this message translates to:
  /// **'اَللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَ سَلِّمْ،اَللَّهُمَّ افْتَحْ لِي اَبْوَابَ رَحْمَتِكَ'**
  String get step1EnteringSacredMosqueDuaArabic;

  /// No description provided for @step1EnteringSacredMosqueDua.
  ///
  /// In en, this message translates to:
  /// **'Allahumma, solli ´ala Muhammadin wa sallim! Allahumma - ftah li abwaba rohmati-ka!\n\nO Allah, bless Muhammad and grant him peace! O Allah, open for me the gates of Your mercy!'**
  String get step1EnteringSacredMosqueDua;

  /// No description provided for @step1ConditioningHajjArabic.
  ///
  /// In en, this message translates to:
  /// **'اَللَّهُمَّ مَحِلِّي حَيْثُ حَبَسْتَنِي'**
  String get step1ConditioningHajjArabic;

  /// No description provided for @step1ConditioningHajj.
  ///
  /// In en, this message translates to:
  /// **'\nConditions for performing Hajj or Umrah.\n'**
  String get step1ConditioningHajj;

  /// No description provided for @step1ConditioningHajjText.
  ///
  /// In en, this message translates to:
  /// **'If a pilgrim is afraid that something might prevent them from completing the Hajj, such as illness or fear, then before reciting the Talbiyah, they may condition their intention for Hajj before the Almighty Lord by saying what the Prophet, peace and blessings be upon him, taught them:\n'**
  String get step1ConditioningHajjText;

  /// No description provided for @step1IhramText1.
  ///
  /// In en, this message translates to:
  /// **'«Allahumma mahilli haysu habastani»\n\n«O Allah, my place of entering into Ihram is wherever You have detained me».\n\nThis hadith is considered sahih (authentic). See also «Sahih Abi Dawud» (1776).\n\nTherefore, if a pilgrim acts in this way and is prevented by something or falls ill, then he is allowed to exit the state of ihram during the performance of hajj or umrah, and he will not have to sacrifice an animal as atonement and repeat the hajj, unless it was his first mandatory hajj, which in this case he would have to repeat again.'**
  String get step1IhramText1;

  /// No description provided for @step1UmrahForParents.
  ///
  /// In en, this message translates to:
  /// **'\n\nUmrah for parents\n'**
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
  /// **'\nCircumambulation (Tawaf) around the Kaaba.'**
  String get step2KaabaText1;

  /// No description provided for @step2KaabaText2.
  ///
  /// In en, this message translates to:
  /// **'\nBegin the sevenfold circumambulation (Tawaf) around the Kaaba.\nFrom the beginning of this tawaf until its completion, men should bare their right shoulder.\n\nAfter that, the pilgrim touches the Black Stone with their hand and kisses it.\n\nIf it\'s not possible to kiss the Black Stone, one should touch it with their hand.\n\nIf it is not possible to touch and kiss the Black Stone, then face it, point to it with your right hand and say «Allahu Akbar»  (Allah is Great). (All of this should be done during each round of circumambulation around the Kaaba.)\n'**
  String get step2KaabaText2;

  /// No description provided for @step2KaabaText3.
  ///
  /// In en, this message translates to:
  /// **'Begin the sevenfold circumambulation (tawaf) of the Kaaba from the Black Stone. Completing a circuit from the Black Stone to the Black Stone is counted as one circuit. At the start of each new circuit, point with your right hand to the Black Stone and say the takbir. For the first three circuits from the Black Stone to the Black Stone, men should walk quickly, and for the remaining four, they should walk at a normal pace. If possible, touch the Yemeni corner during each circuit. Every time you pass between the Yemeni corner and the Black Stone, say:\n'**
  String get step2KaabaText3;

  /// No description provided for @step2KaabaText4.
  ///
  /// In en, this message translates to:
  /// **'Rabbana, atina fid-dunya hasanatan wa fil-akhiroti hasanatan wa qina azaba-n-nar\n\n(«Our Lord, grant us the good of this world and the good of the Hereafter, and protect us from the torment of the Fire!», Surah Al-Baqarah, verse 201).'**
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
  /// **'Prayer after circumambulating(tawaf) the Kaaba'**
  String get step3PrayerAfterTawaf;

  /// No description provided for @step3CompletedSevenCircuits.
  ///
  /// In en, this message translates to:
  /// **'\nHaving completed the seven rounds around the Kaaba, the man covers his right shoulder. Then head towards the place of Ibrahim\'s standing and say:\n'**
  String get step3CompletedSevenCircuits;

  /// No description provided for @step3ArabicText.
  ///
  /// In en, this message translates to:
  /// **'وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّ'**
  String get step3ArabicText;

  /// No description provided for @step3PlaceOfStanding.
  ///
  /// In en, this message translates to:
  /// **'Wa-ttahizu mim-maqomi Ibrohima musollya.\n\nAnd take, [O believers], from the standing place of Ibrahim a place of prayer» (Surah Al-Baqarah, verse 125).\n\nIf possible, at the Station of Ibrahim or any place in the Sacred Mosque, perform two rak\'ahs of prayer. Remember to place a barrier in front of you so that no one passes between you and the barrier.\nIn the first rak\'ah after reciting Surah 1 «Al-Fatihah = The Opening», recite Surah 109 «Al-Kafirun = The Disbelievers», and in the second rak\'ah after Surah «Al-Fatihah», recite Surah 112 «Al-Ikhlas = The Purity of Faith». After completing the prayer, head to the Zamzam water source.'**
  String get step3PlaceOfStanding;

  /// No description provided for @step4DrinkingZamzam.
  ///
  /// In en, this message translates to:
  /// **'\nDrinking Zamzam water.'**
  String get step4DrinkingZamzam;

  /// No description provided for @step4ZamzamText.
  ///
  /// In en, this message translates to:
  /// **'\nDrink water and pour it over your head.\n\nJabir (may Allah be pleased with him) narrated: «The Prophet (peace be upon him) went to the well of Zamzam, drank from it and poured it over his head.» This hadith is authentic, and it is reported in Ahmad (3/394), Ibn Khuzaymah (4/305). The authenticity of the hadith is confirmed by az-Zarkashi, Badr al-Din al-Ayni, and Shu\'ayb al-Arnaut. See «Umdat al-Qari» (9/227), «Hashiya \'ala al-Manasik» (p. 263), «Tahridj al-Musnad» (15243).\n\nFrom the words of Jabir (may Allah be pleased with him), it is reported that the Messenger of Allah (peace be upon him) said: «The water of Zamzam helps to achieve what it is drunk for.» This hadith is reported in Ahmad (3/357), Ibn Majah (3062), and Al-Hakim (1739). The authenticity of the hadith has been confirmed by scholars such as Sufyan ibn \'Uyaynah, Al-Munziri, Ad-Dumyati, Ibn Al-Qayyim, Az-Zarkashi, Ibn Hajar, and Al-Albani. See «Al-Mudjalasa» (509), «Al-Matjar Ar-Rabih» (982), «Zadul-Ma\'ad» (4/393), «Al-Maqasid Al-Hasanah» (928), «Faidul-Qadir» (7759), and «Sahih At-Targhib» (1165).\n\nAsh-Shawkani said: «This hadith contains evidence that drinking Zamzam water is beneficial for the drinker, no matter what intention they have, whether it is for the affairs of this world or the Hereafter. The words \'it serves the purpose for which it is drunk\' are general in meaning.» See «Nayl al-Awtar» (5/105).\nAn-Nawawi said: «The meaning of this hadith is that whoever drinks this water for a specific purpose, will attain it. Truly, scholars and righteous people have tried this to achieve their needs, whether in this world or the Hereafter, and they have received it by the grace of Almighty Allah.» See «Tahzib al-asma wa al-lughat» (3/139).'**
  String get step4ZamzamText;

  /// No description provided for @step5ReturnToBlackStone.
  ///
  /// In en, this message translates to:
  /// **'\nReturn to the Black Stone.'**
  String get step5ReturnToBlackStone;

  /// No description provided for @step5ReturnReciteTakbir.
  ///
  /// In en, this message translates to:
  /// **'\nReturn to the Black Stone, saying takbir, and touch it with your hand as explained earlier, or point to it with your hand and say takbir. Allah is Great.'**
  String get step5ReturnReciteTakbir;

  /// No description provided for @step5AllahIsGreat.
  ///
  /// In en, this message translates to:
  /// **'\nAllahu Akbar.\n'**
  String get step5AllahIsGreat;

  /// No description provided for @step5TakbirArabic.
  ///
  /// In en, this message translates to:
  /// **'الله أكبر'**
  String get step5TakbirArabic;

  /// No description provided for @step6SafaAndMarwa.
  ///
  /// In en, this message translates to:
  /// **'\nSafa and Marwa'**
  String get step6SafaAndMarwa;

  /// No description provided for @step6HeadTowardsSafa.
  ///
  /// In en, this message translates to:
  /// **'\nGo to the hill of Safa to perform the seven rounds of the ritual walk (sa\'y) between the hills of Safa and Marwa. Begin the sa\'y at the hill of Safa.\n\n\n       As you approach Safa, recite:\n'**
  String get step6HeadTowardsSafa;

  /// No description provided for @step6SurahBaqarahArabic.
  ///
  /// In en, this message translates to:
  /// **'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللهِ ۖ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا ۚ وَمَنْ تَطَوَّعَ خَيْرًا فَإِنَّ اللهَ شَاكِرٌ عَلِيمٌ'**
  String get step6SurahBaqarahArabic;

  /// No description provided for @step6SurahBaqarahVerse.
  ///
  /// In en, this message translates to:
  /// **'Inna Ssofaa wal-Marwata min sha\'aaa\'iril laah, faman hajjal Baita awi\'tamaro falaa junaaha \'alaihi ayyatt´owwafa bihimaa, wa man tat´owwa\'a hoyron fa-inna-LLAha Shakirun ´alim.\n\n«Indeed, as-Safa and al-Marwah are among the symbols of Allah. So whoever makes Hajj to the House or performs \'umrah - there is no blame upon him for walking between them. And whoever volunteers good - then indeed, Allah is appreciative and Knowing.» (Surah Al-Baqarah, verse 158.\n\n    Then say:\n'**
  String get step6SurahBaqarahVerse;

  /// No description provided for @step6SurahBaqarahText.
  ///
  /// In en, this message translates to:
  /// **'Inna-s-Safa wal-Marwata min sha\'a\'iri-llah, fa-man hajja-l-bayta awi-\'tamara fala junaha \'alayhi ayy-yat\'tawwafa bihima, wa man tatawwa\'a khayran fa-inna-llaha Shakirun \'alim.\n\n\"Indeed, as-Safa and al-Marwah are among the symbols of Allah. Whoever performs Hajj to the Kaaba or \'Umrah, he will not commit a sin if he passes between them. And if anyone voluntarily does a good deed, then indeed Allah is Appreciative, Knowing.\" (Surah \"Al-Baqarah\", verse 158)'**
  String get step6SurahBaqarahText;

  /// No description provided for @step6WeBeginArabic.
  ///
  /// In en, this message translates to:
  /// **'نَبْدَأُ بِمَا بَدَأَ اللهُ بِهِ'**
  String get step6WeBeginArabic;

  /// No description provided for @step6WeBegin.
  ///
  /// In en, this message translates to:
  /// **'Nabdau bima badaa-Llahu bihi'**
  String get step6WeBegin;

  /// No description provided for @step6WeBeginText.
  ///
  /// In en, this message translates to:
  /// **'«We begin with that with which Allah began.»\n\nAscend to the hill of Safa, turn your face towards the Kaaba, and say:\n'**
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
  /// **'Allahu Akbar! Allahu Akbar! Allahu Akbar!\nLa ilaha illa-Llahu wahdahu la sharika lahu. Lahul mulku wa lahul hamdu yuhyi wa yumitu wa huwa \'ala kulli shay\'in qodir. La ilaha illa-Llahu wahdahu la sharika lah, anjaza wa\'dahu, wa nasaro \'abdahu, wa hazamal ahzaba wahdahu\n\n«Allah is the Greatest, Allah is the Greatest, Allah is the Greatest!\nThere is no deity except Allah, the One without any partners! To Him belongs the power and to Him belongs all praise. He gives life and causes death, and He has power over all things. There is no deity except Allah, the One without any partners! He fulfilled His promise, aided His servant, and alone defeated the hostile tribes.»\n\nRecite these words three times, raising your hands for supplication (dua) after the first and second recitations. Then begin walking from Safa to Marwa. Walking from Safa to Marwa counts as one round, and the return from Marwa to Safa counts as the second round. At the top of Marwa, repeat the same pattern: zikr — dua — zikr — dua — zikr, raising your hands for dua after the first and second recitations. This zikr and dua should be repeated every time you ascend Safa or Marwa, except for the seventh and final round. Upon reaching the first green marker, men should run until the second marker, and the rest of the path should be walked at a normal pace.\n\nDuring the Sa\'i ritual, you can supplicate to Allah with the following prayer\n'**
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
  /// **'Rabbi-ghfir wa rham, innaka anta a´azzul-akram\n\n«O Lord, forgive and have mercy, for You are the Most Great and Generous!»,\n\nThere is nothing wrong with this, as this supplication is established by a whole group of righteous predecessors.\n\nAfter the seventh round, the pilgrim ceases to recite Zikr and Dua on the Marwa hill. This marks the completion of the Sa\'i ritual.\n\nPrayer upon exiting the Sacred Mosque. After completing the seventh circuit on the hill of Marwa, exit the Sacred Mosque with your left foot, saying:\n'**
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
  /// **'Allahumma solli \'ala Muhammadin wa sallim! Allahumma, inni as\'aluka min fadlika!\n\nO Allah, bless Muhammad and grant him peace! O Allah, indeed, I ask You for Your Mercy!'**
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
  /// **'\nShaving the head or trimming the hair.'**
  String get step7ShavingHead;

  /// No description provided for @step7MenShortenHair.
  ///
  /// In en, this message translates to:
  /// **'\nThen the man evenly trims his hair on his head or shaves it off, while the woman cuts a lock of hair equivalent to the length of a finger joint.\n\nNote:\nIt is preferable for those who have arrived for Hajj to trim their hair if they do not have enough time for it to grow back before Hajj, as shaving the head is done during Hajj. For those who have come only to perform Umrah (without Hajj), it is better to shave the head.\n\nThe complete exit from the state of Ihram. With this, the Umrah is completed. The man removes the Ihram attire. The restrictions that were applicable in the state of Ihram are lifted.'**
  String get step7MenShortenHair;

  /// No description provided for @step7DuaAtEnd.
  ///
  /// In en, this message translates to:
  /// **'\nIn conclusion, I ask Allah, the Almighty, to accept all our good deeds and preserve the reward for them until the Day when we meet Him,\n\"The Day when neither wealth nor children will be of any benefit, except for those who come to Allah with a sound heart\"\n(Surah Ash-Shu\'ara, Ayahs 88–89).\n\nI also ask Allah to grant the full reward to everyone who contributed to the development, improvement, and dissemination of this application — whether through advice, knowledge, financial support, or kind words — for every Umrah performed with its help.\nAs the Messenger of Allah (peace and blessings be upon him) said:\n\"Whoever points to a good deed will have a reward equal to that of the one who does it\"\n(Sahih Muslim, No. 1893).\n\nPraise be to Allah, the Lord of the worlds!'**
  String get step7DuaAtEnd;

  /// No description provided for @etiquetteMannersText1.
  ///
  /// In en, this message translates to:
  /// **'The most important thing that a person performing Hajj and \'Umrah is obliged to do is sincerity before Allah. He must get rid of showing off and desire for fame in order to receive reward for this Hajj and this \'Umrah.\n\nIt is reported from Abu Huraira, may Allah be pleased with him, that the Messenger of Allah, may Allah bless him and grant him peace, said: \"Allah the Most High said: \'I am completely independent of partners. If someone does something not only for Me but also for someone else, I will reject both him and his polytheism!\'\" Muslim, 2985.\n\nIt is also reported that the Messenger of Allah, may Allah bless him and grant him peace, said: \"O Allah, (make this) Hajj one in which there is neither showing off nor desire for fame!\" Ibn Majah, 2890.'**
  String get etiquetteMannersText1;

  /// No description provided for @etiquetteMannersText2.
  ///
  /// In en, this message translates to:
  /// **'A person who wants to perform Hajj and \'Umrah should make an effort to study the rulings related to Hajj and \'Umrah in order to perform them based on knowledge.'**
  String get etiquetteMannersText2;

  /// No description provided for @etiquetteMannersText3.
  ///
  /// In en, this message translates to:
  /// **'A person performing Hajj and \'Umrah should try to choose the best companions for the journey to Hajj, in order to benefit from them both in knowledge and in behavior.\n\nIt is reported from Abu Musa al-Ash\'ari, may Allah be pleased with him, that the Messenger of Allah, may Allah bless him and grant him peace, said: \"The example of a righteous companion and a bad one is like that of a perfume seller and a blacksmith\'s bellows. As for the perfume seller, he will either give you a gift, or you will buy something from him, or you will smell the fragrance emanating from him. As for the one who blows the bellows, he will either burn your clothes, or you will smell the stench emanating from him.\" al-Bukhari 5534, Muslim 2628.'**
  String get etiquetteMannersText3;

  /// No description provided for @etiquetteMannersText4.
  ///
  /// In en, this message translates to:
  /// **'A person performing Hajj and \'Umrah should have a certain amount of money with them so as not to need the money of other people.\n\nIt is reported from Abu Sa\'id al-Khudri, may Allah be pleased with him, that the Prophet, may Allah bless him and grant him peace, said: \"Whoever strives for self-restraint, Allah will guide him to self-restraint, and whoever tries to be self-sufficient, Allah will save him from the need to turn to others.\" al-Bukhari, 1469; Muslim, 1053.'**
  String get etiquetteMannersText4;

  /// No description provided for @etiquetteMannersText5.
  ///
  /// In en, this message translates to:
  /// **'A person performing Hajj and \'Umrah should adorn themselves with noble manners and treat other people in the best way.\n\nIt is reported from Abu Dharr, may Allah be pleased with him, that the Prophet, may Allah bless him and grant him peace, said: \"Fear Allah wherever you are! After a bad deed, do a good deed that will erase it, and maintain the best manners in your dealings with people.\" at-Tirmidhi, 1987.\n\nIt is reported from \'Abdullah ibn \'Amr ibn al-\'As, may Allah be pleased with him and his father, that the Prophet, may Allah bless him and grant him peace, said: \"Let the one who wishes to be removed from the Fire and entered into Paradise be a believer in Allah and the Last Day when death comes to him, and let him treat people the same way he wishes people to treat him.\" Muslim, 1844.'**
  String get etiquetteMannersText5;

  /// No description provided for @etiquetteMannersText6.
  ///
  /// In en, this message translates to:
  /// **'A person performing Hajj and \'Umrah should occupy themselves with remembrance of Allah (dhikr), supplications to Him (du\'a) and requests for forgiveness (istighfar). He should protect his tongue from everything except good speech. He should occupy all his time with what will benefit him both in this worldly life and in the Hereafter.\n\nIt is reported from Abu Huraira, may Allah be pleased with him, that the Messenger of Allah, may Allah bless him and grant him peace, said: \"Let the one who believes in Allah and the Last Day speak good or remain silent.\" al-Bukhari, 6018; Muslim, 47.\n\nIt is reported from Ibn \'Abbas, may Allah be pleased with him and his father, that the Messenger of Allah, may Allah bless him and grant him peace, said: \"Two blessings that many people are deprived of: health and free time.\" al-Bukhari, 6412.'**
  String get etiquetteMannersText6;

  /// No description provided for @etiquetteMannersText7.
  ///
  /// In en, this message translates to:
  /// **'A person performing Hajj and \'Umrah should beware of offending other people with their word or deed.\n\nThe Prophet, may Allah bless him and grant him peace, said: \"A Muslim is one who does not harm (other) Muslims with his tongue and his hands.\" al-Bukhari, 10; Muslim, 41.\n\nLet a Muslim also beware of harming other Muslims with the foul smell of cigarette smoke, if he himself smokes. And this is despite the fact that he is already obliged to quit smoking and repent to Allah. Indeed, smoking harms health and destroys his property.\n\nA Muslim should strive to adhere to the above-mentioned good moral qualities always and everywhere, but especially during his journey to Hajj or \'Umrah.'**
  String get etiquetteMannersText7;

  /// No description provided for @hajjUmrahVirtuesText1.
  ///
  /// In en, this message translates to:
  /// **'Authentic hadiths from the Messenger of Allah, may Allah bless him and grant him peace, have come about the virtue of Hajj and \'Umrah. Let us cite some of them:\n\nIt is reported from Abu Huraira, may Allah be pleased with him, that the Messenger of Allah, may Allah bless him and grant him peace, said: \"Performing \'Umrah until the next \'Umrah serves as expiation for the sins committed between them, and as for the perfect Hajj, there is no reward for it except Paradise.\" al-Bukhari, 1773; Muslim, 1349.\n\nIt is reported from Ibn Mas\'ud, may Allah be pleased with him, that the Messenger of Allah, may Allah bless him and grant him peace, said: \"Perform Hajj and \'Umrah regularly, for they remove poverty and sins just as the blacksmith\'s bellows remove slag from iron, gold and silver. And for the perfect Hajj there is no reward except Paradise.\" at-Tirmidhi, 810; an-Nasa\'i, 2631.\n\nIt is reported from Ibn \'Abbas, may Allah be pleased with him and his father, that the Messenger of Allah, may Allah bless him and grant him peace, said: \"Perform Hajj and \'Umrah regularly, for they remove poverty and sins just as the blacksmith\'s bellows remove slag from iron.\" an-Nasa\'i, 2630.'**
  String get hajjUmrahVirtuesText1;

  /// No description provided for @hajjUmrahVirtuesText2.
  ///
  /// In en, this message translates to:
  /// **'It is reported from the words of the mother of the believers \'Aisha, may Allah be pleased with her, that she once said: \"O Messenger of Allah, we consider jihad to be the best deed, so should we not take part in it?\" The Prophet, may Allah bless him and grant him peace, replied: \"No! The best jihad for you (women) is the perfect Hajj.\" al-Bukhari, 1520.\n\nAlso in another version it is reported that \'Aisha, may Allah be pleased with her, said: \"O Messenger of Allah, should women perform jihad?\" The Prophet, may Allah bless him and grant him peace, replied: \"They should perform jihad in which there is no fighting, and that is Hajj and \'Umrah.\" Ibn Majah, 2901.'**
  String get hajjUmrahVirtuesText2;

  /// No description provided for @hajjUmrahVirtuesText3.
  ///
  /// In en, this message translates to:
  /// **'It is reported from Abu Huraira, may Allah be pleased with him, that the Prophet, may Allah bless him and grant him peace, said: \"Whoever performs Hajj for the sake of Allah, without approaching his wife and without committing anything sinful and unworthy, will return home as he was on the day his mother gave birth to him.\" al-Bukhari, 1521; Muslim, 1350.\n\nIt is also reported that the Prophet, may Allah bless him and grant him peace, said to \'Amr ibn al-\'As, may Allah be pleased with him: \"Do you not know that Islam destroys everything that was before, and hijrah destroys everything that was before, and Hajj destroys everything that was before?\" Muslim, 121.\n\nThe perfect Hajj (mentioned in the above hadiths) is one that conforms to the Sunnah of the Messenger of Allah, may Allah bless him and grant him peace.'**
  String get hajjUmrahVirtuesText3;

  /// No description provided for @hajjUmrahVirtuesText4.
  ///
  /// In en, this message translates to:
  /// **'It is reported from Jabir, may Allah be pleased with him, that the Prophet, may Allah bless him and grant him peace, said: \"Learn your religious rites from me, for I do not know - perhaps after this Hajj of mine I will never perform pilgrimage again.\" Muslim, 1297.\n\nIn another version of this hadith it is reported that the Prophet, may Allah bless him and grant him peace, said: \"O people, learn your religious rites from me, for I do not know - perhaps I will not perform Hajj again after this year.\" an-Nasa\'i, 3062.'**
  String get hajjUmrahVirtuesText4;

  /// No description provided for @hajjUmrahObligationObligationEvidence.
  ///
  /// In en, this message translates to:
  /// **'Performing Hajj and \'Umrah is obligatory once in a lifetime, and whoever performs them more than once, it will be considered voluntary worship.\n\nAlso, Hajj and \'Umrah may become obligatory after making a vow (nadhr). If a person has made a vow before Allah to perform Hajj or \'Umrah, then it is obligatory to fulfill one\'s vow.\n\nIf a person has already begun to perform voluntary Hajj or \'Umrah, then he is obliged to complete them, for Allah said: \"Complete Hajj and \'Umrah for Allah.\" (Surah al-Baqarah, verse 196)\n\nThe performance of Hajj is obligatory due to evidence from the Quran and Sunnah, as well as by the consensus of Muslims (ijma\').\nAllah the Most High said: \"And [due] to Allah from the people is a pilgrimage to the House - for whoever is able to find thereto a way. But whoever disbelieves - then indeed, Allah is free from need of the worlds.\" (Surah Ali \'Imran, verse 97)\n\nThe Prophet, may Allah bless him and grant him peace, said: \"Islam is built on five (pillars): testifying that there is no deity worthy of worship except Allah and that Muhammad is the Messenger of Allah, performing prayer, paying zakat, performing Hajj and fasting in Ramadan.\" al-Bukhari, 8; Muslim, 16.\nAnd also: \"(The essence of) Islam is that you testify that there is no deity worthy of worship except Allah and that Muhammad is the Messenger of Allah, perform prayer, give zakat, fast during Ramadan and perform Hajj to the House, if you are able to do so.\" Muslim, 8.\n\nIt is also reported that Abu Huraira, may Allah be pleased with him, said: \"Once the Messenger of Allah, may Allah bless him and grant him peace, addressed us with a sermon and said: \'O people, Hajj has been made obligatory for you, so perform it.\' One man asked: \'Every year, O Messenger of Allah?\' - however, the Prophet, may Allah bless him and grant him peace, remained silent until he asked his question three times. Then the Messenger of Allah, may Allah bless him and grant him peace, said: \'If I say: \'Yes\' it will definitely become your obligation, but you will not be able to fulfill it.\'\" Muslim, 1337.\n\nAnd Muslims are unanimous that Hajj is obligatory for one in whom all the conditions of the obligation of Hajj are combined.'**
  String get hajjUmrahObligationObligationEvidence;

  /// No description provided for @hajjUmrahObligationEvidenceUmrahObligation.
  ///
  /// In en, this message translates to:
  /// **'As for \'Umrah, the following hadiths indicate its obligation:\n\n1 - It is reported that \'Aisha, may Allah be pleased with her, once asked: \"O Messenger of Allah, should women perform jihad?\" The Messenger of Allah, may Allah bless him and grant him peace, replied: \"Yes, they are obliged to perform jihad in which there is no fighting, and that is Hajj and \'Umrah.\" Ahmad, 6/165; Ibn Majah, 2901.\nAfter citing this hadith, Ibn Khuzaymah, may Allah have mercy on him, said: \"In the words of the Prophet, may Allah bless him and grant him peace: \'...they are obliged to perform jihad in which there is no fighting, and that is Hajj and \'Umrah,\' there is an explanation that \'Umrah is as obligatory as Hajj.\" See \"Sahih Ibn Khuzaymah,\" hadith No. 3074.\n\n2 - It is reported from \'Umar, may Allah be pleased with him, that the Messenger of Allah, may Allah bless him and grant him peace, said: \"The essence of Islam is that you testify that there is no deity worthy of worship except Allah and that Muhammad is the Messenger of Allah, and also perform prayer, give zakat, perform Hajj and \'Umrah, perform full ablution after sexual impurity, and also perform minor ablution properly and fast in the month of Ramadan.\" See \"Sahih Ibn Khuzaymah,\" hadith No. 3065. And also this hadith is in ad-Daraqutni, 2/282.\n\n3 - It is reported from Abu Razin al-\'Uqayli that once he came to the Prophet, may Allah bless him and grant him peace, and said: \"O Messenger of Allah, indeed, my father is very old and cannot perform either Hajj or \'Umrah, and cannot even sit in the saddle.\" The Prophet, may Allah bless him and grant him peace, replied: \"Perform Hajj and \'Umrah for your father.\" at-Tirmidhi, 930.\n\n4 - It is reported from as-Subay\'i ibn Ma\'bad that once he said to \'Umar ibn al-Khattab, may Allah be pleased with him: \"O Commander of the Faithful, indeed, I was a Bedouin and professed Christianity, and then I accepted Islam. I strive to go on jihad, but I found that Hajj and \'Umrah are prescribed for me. I asked about this from one person from my people, and he said to me: \'Perform Hajj and \'Umrah together and sacrifice an animal from what will be easy for you,\' and I performed them together.\" Then \'Umar said: \"You were guided to the Sunnah of your Prophet, may Allah bless him and grant him peace.\" Abu Dawud, 1799.'**
  String get hajjUmrahObligationEvidenceUmrahObligation;

  /// No description provided for @hajjUmrahObligationConcludingEvidence.
  ///
  /// In en, this message translates to:
  /// **'Hajj and \'Umrah are obligatory for those who have the conditions for performing them. Muslims are unanimous in the obligation of Hajj when all conditions are met. It is important to note that Hajj and \'Umrah that are performed after a vow or have been started must be completed.'**
  String get hajjUmrahObligationConcludingEvidence;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: 2024'**
  String get privacyPolicyLastUpdated;

  /// No description provided for @privacyPolicyIntroductionTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Introduction'**
  String get privacyPolicyIntroductionTitle;

  /// No description provided for @privacyPolicyIntroduction.
  ///
  /// In en, this message translates to:
  /// **'We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and protect information when you use our Umra Guide application.\n\nBy using this application, you agree to the terms of this Privacy Policy.'**
  String get privacyPolicyIntroduction;

  /// No description provided for @privacyPolicyDataCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Data Collection'**
  String get privacyPolicyDataCollectionTitle;

  /// No description provided for @privacyPolicyDataCollection.
  ///
  /// In en, this message translates to:
  /// **'Our application DOES NOT collect any data.\n\nAll data is stored only locally on your device:\n\n• Local Settings: language, theme, display preferences are stored only on your device\n• Tawaf Counter Data: stored locally on your device\n\nWe DO NOT collect and DO NOT transmit:\n• Personal data (name, email, phone)\n• Location data\n• Analytics or tracking data\n• Data about your app usage\n• Any other data'**
  String get privacyPolicyDataCollection;

  /// No description provided for @privacyPolicyDataUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Data Usage'**
  String get privacyPolicyDataUsageTitle;

  /// No description provided for @privacyPolicyDataUsage.
  ///
  /// In en, this message translates to:
  /// **'Since we do not collect data, all data is used solely locally on your device for:\n\n• Enabling app functionality (saving settings, tawaf counter)\n• Improving app performance (local settings for your convenience)\n\nAll data is stored only on your device and is never shared with third parties or external servers.'**
  String get privacyPolicyDataUsage;

  /// No description provided for @privacyPolicyThirdPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Third-Party Services'**
  String get privacyPolicyThirdPartyTitle;

  /// No description provided for @privacyPolicyThirdParty.
  ///
  /// In en, this message translates to:
  /// **'Our application may use the following third-party services:\n\n• Google Fonts: for loading fonts (if used). Google may collect technical information about font requests.\n\nWe do not control and are not responsible for the privacy policies of third-party services. We recommend reviewing their privacy policies.\n\nImportant: Even when using Google Fonts, no data about you or your app usage is transmitted to our servers or third parties.'**
  String get privacyPolicyThirdParty;

  /// No description provided for @privacyPolicyDataStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Data Storage'**
  String get privacyPolicyDataStorageTitle;

  /// No description provided for @privacyPolicyDataStorage.
  ///
  /// In en, this message translates to:
  /// **'All application data is stored locally on your device using:\n\n• SharedPreferences (for settings)\n• Device local storage\n\nData is not transmitted to external servers and is not synchronized between devices. When you delete the app, all data is deleted with it.'**
  String get privacyPolicyDataStorage;

  /// No description provided for @privacyPolicyUserRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Your Rights'**
  String get privacyPolicyUserRightsTitle;

  /// No description provided for @privacyPolicyUserRights.
  ///
  /// In en, this message translates to:
  /// **'In accordance with GDPR and other data protection laws, you have the right to:\n\n• Access your data: all data is stored on your device, you can view it in the app settings\n• Data deletion: you can delete all data by deleting the app from your device\n• Withdraw consent: you can stop using the app at any time\n\nSince we do not collect personal data and do not store it on servers, most rights are automatically respected.'**
  String get privacyPolicyUserRights;

  /// No description provided for @privacyPolicyChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Children'**
  String get privacyPolicyChildrenTitle;

  /// No description provided for @privacyPolicyChildren.
  ///
  /// In en, this message translates to:
  /// **'Our application has a 4+ age rating and is safe for children. We do not collect any personal data from users of any age, including children. All data is stored only locally on the device and is never transmitted anywhere.'**
  String get privacyPolicyChildren;

  /// No description provided for @privacyPolicyChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Changes to Privacy Policy'**
  String get privacyPolicyChangesTitle;

  /// No description provided for @privacyPolicyChanges.
  ///
  /// In en, this message translates to:
  /// **'We may periodically update this Privacy Policy. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last updated\" date at the beginning of this document.\n\nWe recommend that you periodically review this Privacy Policy for information on how we protect your data.'**
  String get privacyPolicyChanges;

  /// No description provided for @privacyPolicyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'9. Contact'**
  String get privacyPolicyContactTitle;

  /// No description provided for @privacyPolicyContact.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions or suggestions regarding this Privacy Policy, please contact us:\n\nEmail: saydulayev.wien@gmail.com\n\nWe will try to answer your questions as soon as possible.'**
  String get privacyPolicyContact;

  /// No description provided for @feedbackDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackDialogTitle;

  /// No description provided for @feedbackDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app.\n\nPlease copy the email address:'**
  String get feedbackDialogMessage;

  /// No description provided for @feedbackDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get feedbackDialogCancel;

  /// No description provided for @feedbackDialogCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get feedbackDialogCopy;

  /// No description provided for @feedbackEmailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email address copied to clipboard'**
  String get feedbackEmailCopied;

  /// No description provided for @feedbackEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Feedback from Umra App'**
  String get feedbackEmailSubject;

  /// No description provided for @feedbackEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Hello!\n\nI would like to share feedback about the Umra app:\n\n'**
  String get feedbackEmailBody;
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
