class UmraStep {
  final String id;
  final String
  imageName; // Оставляем для обратной совместимости, но не используем
  final String iconText; // Текст для иконки (например, "IHRAM")
  final String titleKey;
  final int stepNumber;

  const UmraStep({
    required this.id,
    required this.imageName,
    required this.iconText,
    required this.titleKey,
    required this.stepNumber,
  });
}

class HajjStep {
  final String id;
  final String iconText; // Текст для иконки (например, "TARWIYAH")
  final String titleKey; // Ключ для локализации заголовка
  final String?
  subtitleKey; // Ключ для локализации подзаголовка (может быть null)
  final int stepNumber;

  const HajjStep({
    required this.id,
    required this.iconText,
    required this.titleKey,
    this.subtitleKey,
    required this.stepNumber,
  });
}

// Все шаги Умры
class UmraSteps {
  static const List<UmraStep> allSteps = [
    UmraStep(
      id: 'step1',
      imageName: 'image 1',
      iconText: 'IHRAM',
      titleKey: 'titleIhramScreen',
      stepNumber: 1,
    ),
    UmraStep(
      id: 'step2',
      imageName: 'image 2',
      iconText: 'TAWAF',
      titleKey: 'titleRoundKaabaScreen',
      stepNumber: 2,
    ),
    UmraStep(
      id: 'step3',
      imageName: 'image 3',
      iconText: 'MAQAM\nIBRAHIM',
      titleKey: 'titlePlaceIbrohimStandScreen',
      stepNumber: 3,
    ),
    UmraStep(
      id: 'step4',
      imageName: 'image 4',
      iconText: 'ZAMZAM',
      titleKey: 'titleWaterZamzamScreen',
      stepNumber: 4,
    ),
    UmraStep(
      id: 'step5',
      imageName: 'image 5',
      iconText: 'ISTILAM',
      titleKey: 'titleBlackStoneScreen',
      stepNumber: 5,
    ),
    UmraStep(
      id: 'step6',
      imageName: 'image 6',
      iconText: "SA'I",
      titleKey: 'titleSafaAndMarvaScreen',
      stepNumber: 6,
    ),
    UmraStep(
      id: 'step7',
      imageName: 'image 7',
      iconText: 'HALQ\nTAQSIR',
      titleKey: 'titleShaveHeadScreen',
      stepNumber: 7,
    ),
    UmraStep(
      id: 'useful',
      imageName: 'image 8',
      iconText: 'INFO',
      titleKey: 'usefulTitle',
      stepNumber: 8,
    ),
  ];
}

// Все шаги Хаджа
class HajjSteps {
  static const List<HajjStep> allSteps = [
    HajjStep(
      id: 'hajj_tarwiyah',
      iconText: 'TARWIYAH',
      titleKey: 'hajjTarwiyahTitle',
      subtitleKey: 'hajjTarwiyahSubtitle',
      stepNumber: 1,
    ),
    HajjStep(
      id: 'hajj_arafat',
      iconText: 'ARAFAT',
      titleKey: 'hajjArafatTitle',
      subtitleKey: 'hajjArafatSubtitle',
      stepNumber: 2,
    ),
    HajjStep(
      id: 'hajj_nahr',
      iconText: 'NAHR',
      titleKey: 'hajjNahrTitle',
      subtitleKey: 'hajjNahrSubtitle',
      stepNumber: 3,
    ),
    HajjStep(
      id: 'hajj_tashriq',
      iconText: 'TASHRIQ',
      titleKey: 'hajjTashriqTitle',
      subtitleKey: 'hajjTashriqSubtitle',
      stepNumber: 4,
    ),
    HajjStep(
      id: 'hajj_wada',
      iconText: "WADA'",
      titleKey: 'hajjWadaTitle',
      subtitleKey: null, // Нет подзаголовка для WADA'
      stepNumber: 5,
    ),
  ];
}
