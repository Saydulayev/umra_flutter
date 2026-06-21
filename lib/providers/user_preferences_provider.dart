import 'package:flutter/material.dart';
import '../repositories/preferences_repository.dart';
import '../constants/app_constants.dart';
import '../constants/review_config.dart';
import '../services/app_usage_tracker.dart';
import '../services/app_review_service.dart';

class UserPreferencesProvider extends ChangeNotifier {
  bool _isGridView = false;
  bool _hasRatedApp = false;
  bool _hasShownReviewDialog = false;
  bool _isShowingDialog =
      false; // Флаг для предотвращения множественных показов
  String _prayerCity = 'mecca'; // mecca | medina

  bool get isGridView => _isGridView;
  bool get hasRatedApp => _hasRatedApp;
  bool get hasShownReviewDialog => _hasShownReviewDialog;
  bool get isShowingDialog => _isShowingDialog;
  String get prayerCity => _prayerCity;

  final PreferencesRepository _prefsRepo = PreferencesRepository();
  final AppUsageTracker _usageTracker = AppUsageTracker();
  final AppReviewService _reviewService = AppReviewService();

  UserPreferencesProvider() {
    _loadPreferences();
    _checkAndShowReviewDialog();
  }

  Future<void> _loadPreferences() async {
    _isGridView = await _prefsRepo.getBool(PrefsKeys.isGridView) ?? false;
    _hasRatedApp = await _prefsRepo.getBool(PrefsKeys.hasRatedApp) ?? false;
    _prayerCity = await _prefsRepo.getString(PrefsKeys.prayerCity) ?? 'mecca';
    notifyListeners();
  }

  Future<void> setPrayerCity(String city) async {
    if (city != 'mecca' && city != 'medina') return;
    _prayerCity = city;
    await _prefsRepo.setString(PrefsKeys.prayerCity, city);
    notifyListeners();
  }

  Future<void> setIsGridView(bool value) async {
    _isGridView = value;
    await _prefsRepo.setBool(PrefsKeys.isGridView, value);
    notifyListeners();
  }

  Future<void> setHasRatedApp(bool value) async {
    _hasRatedApp = value;
    await _prefsRepo.setBool(PrefsKeys.hasRatedApp, value);
    notifyListeners();
  }

  /// Сбросить состояние оценки (только для тестирования!)
  /// Используйте этот метод для тестирования диалога оценки
  Future<void> resetReviewState() async {
    _hasRatedApp = false;
    _hasShownReviewDialog = false;
    await _prefsRepo.setBool(PrefsKeys.hasRatedApp, false);
    await _prefsRepo.remove(PrefsKeys.lastReviewDialogShownTime);
    await _prefsRepo.setInt(PrefsKeys.reviewDialogShownCount, 0);
    if (ReviewConfig.isTestMode) {
      debugPrint('Review state reset for testing');
    }
    notifyListeners();
  }

  /// Проверить и показать диалог оценки, если нужно
  Future<void> _checkAndShowReviewDialog() async {
    // Проверяем сразу при инициализации
    await checkAndShowReviewIfNeeded();
  }

  /// Проверить условия и показать диалог оценки
  /// Использует профессиональные практики для продакшена
  Future<void> checkAndShowReviewIfNeeded() async {
    // Не показываем, если уже показывали в этой сессии или пользователь уже оценил
    if (_hasShownReviewDialog || _hasRatedApp) {
      if (ReviewConfig.isTestMode) {
        debugPrint(
          'Review check skipped: hasShownReviewDialog=$_hasShownReviewDialog, hasRatedApp=$_hasRatedApp',
        );
      }
      return;
    }

    if (ReviewConfig.isTestMode) {
      debugPrint('=== REVIEW DIALOG CHECK START ===');
      debugPrint('Mode: ${ReviewConfig.isTestMode ? "TEST" : "PRODUCTION"}');
    }

    // 1. Проверяем, не превысили ли максимальное количество показов
    final shownCount =
        await _prefsRepo.getInt(PrefsKeys.reviewDialogShownCount) ?? 0;
    if (shownCount >= ReviewConfig.maxTotalPrompts) {
      if (ReviewConfig.isTestMode) {
        debugPrint(
          'Review dialog: Max prompts reached ($shownCount/${ReviewConfig.maxTotalPrompts})',
        );
      }
      return;
    }

    // 2. Проверяем интервал между показами
    final lastShownTime = await _prefsRepo.getInt(
      PrefsKeys.lastReviewDialogShownTime,
    );
    if (lastShownTime != null && ReviewConfig.daysBetweenPrompts > 0) {
      final lastShown = DateTime.fromMillisecondsSinceEpoch(lastShownTime);
      final daysSinceLastShown = DateTime.now().difference(lastShown).inDays;
      if (daysSinceLastShown < ReviewConfig.daysBetweenPrompts) {
        if (ReviewConfig.isTestMode) {
          debugPrint(
            'Review dialog: Shown $daysSinceLastShown days ago, need to wait ${ReviewConfig.daysBetweenPrompts} days',
          );
        }
        return;
      }
    }

    // 3. Проверяем минимальное время использования (3 минуты для продакшена)
    final totalTime = await _usageTracker.getTotalUsageTime();
    final hasUsedMinTime = await _usageTracker.hasUsedAppForMinTime(
      ReviewConfig.minUsageTimeSeconds,
    );
    if (!hasUsedMinTime) {
      if (ReviewConfig.isTestMode) {
        debugPrint(
          'Review dialog: Usage time insufficient ($totalTime/${ReviewConfig.minUsageTimeSeconds} seconds)',
        );
      }
      return;
    }

    // 4. Проверяем минимальное количество запусков (3 для продакшена)
    final launchCount = await _usageTracker.getAppLaunchCount();
    if (launchCount < ReviewConfig.minAppLaunches) {
      if (ReviewConfig.isTestMode) {
        debugPrint(
          'Review dialog: Launch count insufficient ($launchCount/${ReviewConfig.minAppLaunches})',
        );
      }
      return;
    }

    // 5. Проверяем минимальное количество дней с первого запуска (1 день для продакшена)
    final daysSinceFirstLaunch = await _usageTracker.getDaysSinceFirstLaunch();
    if (daysSinceFirstLaunch < ReviewConfig.minDaysSinceFirstLaunch) {
      if (ReviewConfig.isTestMode) {
        debugPrint(
          'Review dialog: Days since first launch insufficient ($daysSinceFirstLaunch/${ReviewConfig.minDaysSinceFirstLaunch} days)',
        );
      }
      return;
    }

    // 6. Проверяем, что пользователь еще не оценил приложение
    final shouldShow = await _reviewService.shouldShowReviewDialog();
    if (!shouldShow) {
      if (ReviewConfig.isTestMode) {
        debugPrint('Review dialog: User already rated the app');
      }
      return;
    }

    // Все условия выполнены - показываем диалог
    if (ReviewConfig.isTestMode) {
      debugPrint('=== REVIEW DIALOG: ALL CONDITIONS MET! ===');
      debugPrint(
        'Usage: $totalTime sec (required: ${ReviewConfig.minUsageTimeSeconds})',
      );
      debugPrint(
        'Launches: $launchCount (required: ${ReviewConfig.minAppLaunches})',
      );
      debugPrint(
        'Days since first launch: $daysSinceFirstLaunch (required: ${ReviewConfig.minDaysSinceFirstLaunch})',
      );
      debugPrint('Shown count: $shownCount (max: ${ReviewConfig.maxTotalPrompts})');
      debugPrint('=== WILL SHOW DIALOG ===');
    }

    _hasShownReviewDialog = true;
    // Сохраняем время показа и увеличиваем счетчик
    await _prefsRepo.setInt(
      PrefsKeys.lastReviewDialogShownTime,
      DateTime.now().millisecondsSinceEpoch,
    );
    await _prefsRepo.setInt(PrefsKeys.reviewDialogShownCount, shownCount + 1);
    // Не вызываем здесь диалог, это будет сделано в UI
    notifyListeners();
  }

  /// Показать диалог оценки приложения
  Future<void> showReviewDialog(BuildContext context) async {
    // Предотвращаем множественные показы
    if (_hasRatedApp || _isShowingDialog) return;

    final shouldShow = await _reviewService.shouldShowReviewDialog();
    if (!shouldShow) return;

    _isShowingDialog = true;
    notifyListeners();

    if (!context.mounted) {
      _isShowingDialog = false;
      return;
    }

    final locale = Localizations.localeOf(context);

    // Определяем язык для диалога
    String title, message, rateButton, laterButton;

    if (locale.languageCode == 'ru') {
      title = 'Оцените приложение';
      message =
          'Если приложение было полезно, пожалуйста, оцените его в Google Play. Это поможет другим пользователям найти нас.';
      rateButton = 'Оценить';
      laterButton = 'Позже';
    } else if (locale.languageCode == 'en') {
      title = 'Rate the App';
      message =
          'If the app was helpful, please rate it on Google Play. This helps other users find us.';
      rateButton = 'Rate';
      laterButton = 'Later';
    } else if (locale.languageCode == 'de') {
      title = 'App bewerten';
      message =
          'Wenn die App hilfreich war, bewerten Sie sie bitte im Google Play Store. Dies hilft anderen Benutzern, uns zu finden.';
      rateButton = 'Bewerten';
      laterButton = 'Später';
    } else if (locale.languageCode == 'fr') {
      title = 'Évaluer l\'application';
      message =
          'Si l\'application a été utile, veuillez la noter sur Google Play. Cela aide les autres utilisateurs à nous trouver.';
      rateButton = 'Évaluer';
      laterButton = 'Plus tard';
    } else if (locale.languageCode == 'tr') {
      title = 'Uygulamayı Değerlendir';
      message =
          'Uygulama faydalıysa, lütfen Google Play\'de değerlendirin. Bu, diğer kullanıcıların bizi bulmasına yardımcı olur.';
      rateButton = 'Değerlendir';
      laterButton = 'Sonra';
    } else if (locale.languageCode == 'id') {
      title = 'Nilai Aplikasi';
      message =
          'Jika aplikasi ini bermanfaat, silakan beri rating di Google Play. Ini membantu pengguna lain menemukan kami.';
      rateButton = 'Nilai';
      laterButton = 'Nanti';
    } else {
      // Fallback на английский
      title = 'Rate the App';
      message =
          'If the app was helpful, please rate it on Google Play. This helps other users find us.';
      rateButton = 'Rate';
      laterButton = 'Later';
    }

    bool? result;
    try {
      result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54, // Явно задаем цвет затемнения
        builder: (BuildContext context) {
          return PopScope(
            canPop: false, // Предотвращаем закрытие по кнопке назад
            child: AlertDialog(
              scrollable: true,
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(laterButton),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(rateButton),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing review dialog: $e');
    } finally {
      // Всегда сбрасываем флаг после закрытия диалога
      _isShowingDialog = false;
      notifyListeners();
    }

    if (result == true) {
      // Пользователь хочет оценить
      await _reviewService.requestReview();
      await setHasRatedApp(true);
    } else {
      // Пользователь нажал "Позже" - не помечаем как оцененное
      // Время показа уже сохранено в checkAndShowReviewIfNeeded
      _hasShownReviewDialog = true;
      if (ReviewConfig.isTestMode) {
        debugPrint(
          'User clicked "Later" - will show again after ${ReviewConfig.daysBetweenPrompts} days',
        );
      }
    }
  }
}
