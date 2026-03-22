class Chapter {
  final String id;
  final String titleKey;
  final List<SubChapter> subChapters;
  // If set, tapping this chapter opens content directly (no subchapter list)
  final String? directContentKey;

  const Chapter({
    required this.id,
    required this.titleKey,
    required this.subChapters,
    this.directContentKey,
  });
}

class SubChapter {
  final String id;
  final String titleKey;
  final String contentKey;

  const SubChapter({
    required this.id,
    required this.titleKey,
    required this.contentKey,
  });
}

// Примечание: Ключи локализации можно добавить в .arb файлы для полной поддержки локализации
class UsefulInfoChapters {
  static List<Chapter> getChapters() {
    return [
      const Chapter(
        id: 'etiquette',
        titleKey: 'etiquetteManners',
        subChapters: [
          SubChapter(
            id: 'sincerity',
            titleKey: 'sincerity',
            contentKey: 'etiquetteMannersText1',
          ),
          SubChapter(
            id: 'laws',
            titleKey: 'laws',
            contentKey: 'etiquetteMannersText2',
          ),
          SubChapter(
            id: 'companions',
            titleKey: 'choiceOfCompanions',
            contentKey: 'etiquetteMannersText3',
          ),
          SubChapter(
            id: 'financial',
            titleKey: 'financialIndependence',
            contentKey: 'etiquetteMannersText4',
          ),
          SubChapter(
            id: 'manners',
            titleKey: 'nobleManners',
            contentKey: 'etiquetteMannersText5',
          ),
          SubChapter(
            id: 'zikr',
            titleKey: 'zikrAndPrayers',
            contentKey: 'etiquetteMannersText6',
          ),
          SubChapter(
            id: 'caution',
            titleKey: 'cautionInRelationships',
            contentKey: 'etiquetteMannersText7',
          ),
        ],
      ),
      const Chapter(
        id: 'virtues',
        titleKey: 'hajjUmrahVirtues',
        subChapters: [
          SubChapter(
            id: 'atonement',
            titleKey: 'atonementAndRewards',
            contentKey: 'hajjUmrahVirtuesText1',
          ),
          SubChapter(
            id: 'women',
            titleKey: 'hajjForWomen',
            contentKey: 'hajjUmrahVirtuesText2',
          ),
          SubChapter(
            id: 'perfect',
            titleKey: 'perfectHajj',
            contentKey: 'hajjUmrahVirtuesText3',
          ),
          SubChapter(
            id: 'sunnah',
            titleKey: 'followingTheSunnah',
            contentKey: 'hajjUmrahVirtuesText4',
          ),
        ],
      ),
      const Chapter(
        id: 'safar',
        titleKey: 'safarSunnahsTitle',
        subChapters: [],
        directContentKey: 'safarSunnahsContent',
      ),
      const Chapter(
        id: 'obligation',
        titleKey: 'hajjUmrahObligation',
        subChapters: [
          SubChapter(
            id: 'hajj_evidence',
            titleKey: 'hajjObligationEvidence',
            contentKey: 'hajjUmrahObligationObligationEvidence',
          ),
          SubChapter(
            id: 'umrah_evidence',
            titleKey: 'umrahObligationEvidence',
            contentKey: 'hajjUmrahObligationEvidenceUmrahObligation',
          ),
          SubChapter(
            id: 'conclusion',
            titleKey: 'conclusion',
            contentKey: 'hajjUmrahObligationConcludingEvidence',
          ),
        ],
      ),
    ];
  }
}


