class UmraStep {
  final String id;
  final String imageName;
  final String titleKey;
  final int stepNumber;

  const UmraStep({
    required this.id,
    required this.imageName,
    required this.titleKey,
    required this.stepNumber,
  });
}

// Все шаги Умры
class UmraSteps {
  static const List<UmraStep> allSteps = [
    UmraStep(
      id: 'step1',
      imageName: 'image 1',
      titleKey: 'titleIhramScreen',
      stepNumber: 1,
    ),
    UmraStep(
      id: 'step2',
      imageName: 'image 2',
      titleKey: 'titleRoundKaabaScreen',
      stepNumber: 2,
    ),
    UmraStep(
      id: 'step3',
      imageName: 'image 3',
      titleKey: 'titlePlaceIbrohimStandScreen',
      stepNumber: 3,
    ),
    UmraStep(
      id: 'step4',
      imageName: 'image 4',
      titleKey: 'titleWaterZamzamScreen',
      stepNumber: 4,
    ),
    UmraStep(
      id: 'step5',
      imageName: 'image 5',
      titleKey: 'titleBlackStoneScreen',
      stepNumber: 5,
    ),
    UmraStep(
      id: 'step6',
      imageName: 'image 6',
      titleKey: 'titleSafaAndMarvaScreen',
      stepNumber: 6,
    ),
    UmraStep(
      id: 'step7',
      imageName: 'image 7',
      titleKey: 'titleShaveHeadScreen',
      stepNumber: 7,
    ),
    UmraStep(
      id: 'useful',
      imageName: 'image 8',
      titleKey: 'usefulTitle',
      stepNumber: 8,
    ),
  ];
}
