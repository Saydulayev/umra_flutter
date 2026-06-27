/// Константы приложения Umra Flutter
class AppConstants {
  AppConstants._(); // Предотвращает создание экземпляра
}

/// Высота, которую плавающий нижний таб-бар «занимает» снизу экрана.
/// Контент скролл-вью должен резервировать это пространство, чтобы не
/// прятаться под баром. Используется на всех экранах-табах.
const double kBottomTabBarReservedSpace = 88.0;

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

  // Настройки уведомлений намаза
  static const String notifAtTime = 'notifAtTime';
  static const String notifBefore = 'notifBefore';
  static const String notifSunrise = 'notifSunrise';
}

/// Размеры и отступы приложения
class AppDimensions {
  AppDimensions._(); // Предотвращает создание экземпляра

  // Отступы
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 10.0;
  static const double paddingLarge = 16.0;
  static const double paddingExtraLarge = 24.0;

  // Размеры шрифтов вынесены в единую систему типографики:
  // ResponsiveMetrics (*Base-константы + fontScale) и AppType (роли).
  // См. lib/utils/responsive_metrics.dart и lib/theme/app_type.dart.

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

  // Google Play (Android)
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=saydulayev.wien_gmail.com.umra';

  // App Store (iOS)
  /// Числовой идентификатор приложения в App Store
  /// (из ссылки apps.apple.com/app/id<этот идентификатор>).
  static const String appStoreId = '1673683355';
  static const String appStoreUrl =
      'https://apps.apple.com/app/id$appStoreId';

  /// Прямая ссылка на форму написания отзыва в App Store
  /// (открывает экран оценки сразу, а не просто страницу приложения).
  static const String appStoreReviewUrl =
      '$appStoreUrl?action=write-review';
}

/// Поддерживаемые языки интерфейса — единый источник правды.
///
/// Раньше пара (код языка, отображаемое имя) дублировалась в
/// language_selection_screen, settings_screen (список + _getLanguageName).
/// Добавление языка теперь — одна строка здесь. Названия намеренно заданы
/// на самом языке (endonym), а не локализованы, чтобы пользователь узнавал
/// свой язык независимо от текущей локали приложения.
class AppLanguages {
  AppLanguages._();

  /// Порядок отражает порядок в UI выбора языка.
  static const List<({String code, String name})> all = [
    (code: 'ru', name: 'Русский'),
    (code: 'en', name: 'English'),
    (code: 'de', name: 'Deutsch'),
    (code: 'fr', name: 'Français'),
    (code: 'tr', name: 'Türkçe'),
    (code: 'id', name: 'Bahasa Indonesia'),
    (code: 'ar', name: 'العربية'),
  ];

  /// Отображаемое имя языка по коду. Если код неизвестен — возвращает сам код.
  static String nameFor(String code) {
    for (final lang in all) {
      if (lang.code == code) return lang.name;
    }
    return code;
  }
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
