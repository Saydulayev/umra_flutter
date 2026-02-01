/// Константы приложения Umra Flutter
class AppConstants {
  AppConstants._(); // Предотвращает создание экземпляра
}

/// Ключи для SharedPreferences
class PrefsKeys {
  PrefsKeys._(); // Предотвращает создание экземпляра

  // Тема
  static const String selectedTheme = 'selectedTheme';

  // Локализация
  static const String selectedLanguage = 'selectedLanguage';
  static const String hasSelectedLanguage = 'hasSelectedLanguage';

  // Пользовательские настройки
  static const String isGridView = 'isGridView';
  static const String hasRatedApp = 'hasRatedApp';
  static const String firstAppLaunchTime = 'firstAppLaunchTime';
  static const String totalAppUsageTime = 'totalAppUsageTime';
  static const String lastReviewDialogShownTime = 'lastReviewDialogShownTime';
  static const String appLaunchCount = 'appLaunchCount';
  static const String reviewDialogShownCount = 'reviewDialogShownCount';

  // Шрифты
  static const String selectedFont = 'SelectedFont';
  static const String selectedFontSize = 'SelectedFontSize';

  // Город для расчёта времени намаза (mecca / medina)
  static const String prayerCity = 'prayerCity';
}

/// Размеры и отступы приложения
class AppDimensions {
  AppDimensions._(); // Предотвращает создание экземпляра

  // Отступы
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 10.0;
  static const double paddingLarge = 16.0;
  static const double paddingExtraLarge = 24.0;

  // Размеры шрифтов
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 18.0;
  static const double fontSizeLarge = 26.0;

  // Размеры виджетов
  static const double iconSizeSmall = 14.0;
  static const double iconSizeMedium = 24.0;
  static const double buttonSize = 70.0;
}

/// Строковые константы
class AppStrings {
  AppStrings._(); // Предотвращает создание экземпляра

  // Контакты
  static const String contactEmail = 'saydulayev.wien@gmail.com';

  // URL
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=saydulayev.wien_gmail.com.umra';
}

/// Ключи локализации для шагов
class LocalizationKeys {
  LocalizationKeys._(); // Предотвращает создание экземпляра

  static const String titleIhramScreen = 'titleIhramScreen';
  static const String titleRoundKaabaScreen = 'titleRoundKaabaScreen';
  static const String titlePlaceIbrohimStandScreen =
      'titlePlaceIbrohimStandScreen';
  static const String titleWaterZamzamScreen = 'titleWaterZamzamScreen';
  static const String titleBlackStoneScreen = 'titleBlackStoneScreen';
  static const String titleSafaAndMarvaScreen = 'titleSafaAndMarvaScreen';
  static const String titleShaveHeadScreen = 'titleShaveHeadScreen';
  static const String usefulTitle = 'usefulTitle';
}
