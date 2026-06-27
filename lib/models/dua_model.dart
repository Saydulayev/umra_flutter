// Data models for the Dua Book feature.

class Dua {
  final String id;
  final String arabic;
  final String titleKey;
  final String translitKey;
  final String transKey;
  final String? audioFile;

  const Dua({
    required this.id,
    required this.arabic,
    required this.titleKey,
    required this.translitKey,
    required this.transKey,
    this.audioFile,
  });
}

class DuaCategory {
  final String id;
  final String titleKey;
  final List<Dua> duas;

  const DuaCategory({
    required this.id,
    required this.titleKey,
    required this.duas,
  });
}

// MARK: - Static data

abstract class DuaBookData {
  static const List<DuaCategory> categories = [umrahCategory, hajjCategory];

  // ── Umrah ─────────────────────────────────────────────────────────────────

  static const umrahCategory = DuaCategory(
    id: 'umrah',
    titleKey: 'duaCategoryUmrah',
    duas: [
      Dua(
        id: 'niyyah_umrah',
        arabic: 'لَبَّيْكَ اللَّهُمَّ بِعُمْرَةَ',
        titleKey: 'duaNiyyahUmrahTitle',
        translitKey: 'duaNiyyahUmrahTranslit',
        transKey: 'duaNiyyahUmrahTrans',
        audioFile: '1',
      ),
      Dua(
        id: 'ihram_umrah',
        arabic: 'اَللَّهُمَّ هَذِهِ عُمْرَةٌ لَا رِيَاءَ فِيهَا وَلَا سُمْعَةَ',
        titleKey: 'duaIhramUmrahTitle',
        translitKey: 'duaIhramUmrahTranslit',
        transKey: 'duaIhramUmrahTrans',
        audioFile: '2',
      ),
      Dua(
        id: 'talbiyah',
        arabic:
            'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ،\nإِنَّ الْحَمْدَ، وَالنِّعْمَةَ، لَكَ وَالْمُلْكَ، لاَ شَرِيكَ لَكَ',
        titleKey: 'duaTalbiyahTitle',
        translitKey: 'duaTalbiyahTranslit',
        transKey: 'duaTalbiyahTrans',
        audioFile: '3',
      ),
      Dua(
        id: 'masjid_enter',
        arabic:
            'اَللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَسَلِّمْ،\nاَللَّهُمَّ افْتَحْ لِي اَبْوَابَ رَحْمَتِكَ',
        titleKey: 'duaMasjidEnterTitle',
        translitKey: 'duaMasjidEnterTranslit',
        transKey: 'duaMasjidEnterTrans',
        audioFile: '4',
      ),
      Dua(
        id: 'condition',
        arabic: 'اَللَّهُمَّ مَحِلِّي حَيْثُ حَبَسْتَنِي',
        titleKey: 'duaConditionTitle',
        translitKey: 'duaConditionTranslit',
        transKey: 'duaConditionTrans',
        audioFile: '5',
      ),
      Dua(
        id: 'rabbana_atina',
        arabic:
            'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً\nوَقِنَا عَذَابَ النَّارِ',
        titleKey: 'duaRabbanaTitle',
        translitKey: 'duaRabbanaTranslit',
        transKey: 'duaRabbanaTrans',
        audioFile: '7',
      ),
      Dua(
        id: 'maqam_ibrahim',
        arabic: 'وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّى',
        titleKey: 'duaMaqamIbrahimTitle',
        translitKey: 'duaMaqamIbrahimTranslit',
        transKey: 'duaMaqamIbrahimTrans',
        audioFile: '13',
      ),
      Dua(
        id: 'safa_ayah',
        arabic:
            'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللهِ ۖ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ\nفَلَا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا ۚ وَمَنْ تَطَوَّعَ خَيْرًا\nفَإِنَّ اللهَ شَاكِرٌ عَلِيمٌ',
        titleKey: 'duaSafaAyahTitle',
        translitKey: 'duaSafaAyahTranslit',
        transKey: 'duaSafaAyahTrans',
        audioFile: '8',
      ),
      Dua(
        id: 'nabdau',
        arabic: 'نَبْدَأُ بِمَا بَدَأَ اللهُ بِهِ',
        titleKey: 'duaNabdauTitle',
        translitKey: 'duaNabdauTranslit',
        transKey: 'duaNabdauTrans',
        audioFile: '9',
      ),
      Dua(
        id: 'zikr_safa',
        arabic:
            'اَللهُ أَكْبَرُ اَللهُ أَكْبَرُ اَللهُ أَكْبَرُ،\nلٰا إِلَهَ إِلَّا اللهُ وَحْدَهُ لٰا شَرِيكَ لَهُ،\nلَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ،\nوَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ،\nلَا إِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ،\nأَنْجَزَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَهَزَمَ الْأَحْزَابَ وَحْدَهُ',
        titleKey: 'duaZikrSafaTitle',
        translitKey: 'duaZikrSafaTranslit',
        transKey: 'duaZikrSafaTrans',
        audioFile: '10',
      ),
      Dua(
        id: 'rabbi_ighfir',
        arabic:
            'رَبِّ اغْفِرْ وَارْحَمْ، إِنَّكَ أَنْتَ الْأَعَزُّ الْأَكْرَمُ',
        titleKey: 'duaRabbiIghfirTitle',
        translitKey: 'duaRabbiIghfirTranslit',
        transKey: 'duaRabbiIghfirTrans',
        audioFile: '11',
      ),
      Dua(
        id: 'masjid_exit',
        arabic:
            'اَللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَسَلِّمْ،\nاَللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
        titleKey: 'duaMasjidExitTitle',
        translitKey: 'duaMasjidExitTranslit',
        transKey: 'duaMasjidExitTrans',
        audioFile: '12',
      ),
    ],
  );

  // ── Hajj ──────────────────────────────────────────────────────────────────

  static const hajjCategory = DuaCategory(
    id: 'hajj',
    titleKey: 'duaCategoryHajj',
    duas: [
      Dua(
        id: 'niyyah_hajj',
        arabic: 'لَبَّيْكَ اللَّهُمَّ بِحَجٍّ',
        titleKey: 'duaNiyyahHajjTitle',
        // Reuses existing ARB key
        translitKey: 'hajj_step1_ihram_transliteration',
        transKey: 'duaNiyyahHajjTrans',
        audioFile: '14',
      ),
      Dua(
        id: 'ihram_hajj',
        arabic: 'اللَّهُمَّ هَذِهِ حِجَّةٌ لَا رِيَاءَ فِيهَا وَلَا سُمْعَةَ',
        titleKey: 'duaIhramHajjTitle',
        // Reuses existing ARB keys
        translitKey: 'hajj_step1_ihram_dua_transliteration',
        transKey: 'hajj_step1_ihram_dua_translation',
        audioFile: '15',
      ),
      Dua(
        id: 'condition_hajj',
        arabic: 'اَللَّهُمَّ مَحِلِّي حَيْثُ حَبَسْتَنِي',
        titleKey: 'duaConditionTitle',
        translitKey: 'duaConditionTranslit',
        transKey: 'duaConditionTrans',
        audioFile: '5',
      ),
      Dua(
        id: 'talbiyah_hajj',
        arabic:
            'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ،\nإِنَّ الْحَمْدَ، وَالنِّعْمَةَ، لَكَ وَالْمُلْكَ، لاَ شَرِيكَ لَكَ',
        titleKey: 'duaTalbiyahTitle',
        // Reuses existing ARB keys
        translitKey: 'hajj_step1_talbiyah_transliteration',
        transKey: 'hajj_step1_talbiyah_translation',
        audioFile: '3',
      ),
      Dua(
        id: 'arafat',
        arabic:
            'لَا إِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ،\nلَهُ الْمُلْكُ وَلَهُ الْحَمْدُ،\nوَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        titleKey: 'duaArafatTitle',
        // Reuses existing ARB keys
        translitKey: 'hajj_step2_dua_transliteration',
        transKey: 'hajj_step2_dua_translation',
        audioFile: '16',
      ),
    ],
  );
}
