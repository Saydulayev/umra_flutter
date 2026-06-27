import 'dart:async';
import '../repositories/preferences_repository.dart';
import '../constants/app_constants.dart';

/// Сервис для отслеживания времени использования приложения
class AppUsageTracker {
  static final AppUsageTracker _instance = AppUsageTracker._internal();
  factory AppUsageTracker() => _instance;
  AppUsageTracker._internal();

  final PreferencesRepository _prefsRepo = PreferencesRepository();
  Timer? _usageTimer;
  DateTime? _sessionStartTime;
  bool _isTracking = false;

  /// Инициализация трекера
  Future<void> initialize() async {
    await _prefsRepo.init();
    await _initializeFirstLaunch();
    _startTracking();
  }

  /// Инициализация времени первого запуска
  Future<void> _initializeFirstLaunch() async {
    final firstLaunchTime = await _prefsRepo.getInt(
      PrefsKeys.firstAppLaunchTime,
    );
    if (firstLaunchTime == null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _prefsRepo.setInt(PrefsKeys.firstAppLaunchTime, now);
      await _prefsRepo.setInt(PrefsKeys.totalAppUsageTime, 0);
      await _prefsRepo.setInt(PrefsKeys.appLaunchCount, 0);
    }
    // Увеличиваем счетчик запусков
    final currentCount = await _prefsRepo.getInt(PrefsKeys.appLaunchCount) ?? 0;
    await _prefsRepo.setInt(PrefsKeys.appLaunchCount, currentCount + 1);
  }

  /// Возобновить отслеживание после возврата из фона.
  /// Вызывается из lifecycle-обработчика (AppLifecycleState.resumed).
  void resumeTracking() => _startTracking();

  /// Начать отслеживание сессии
  void _startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    _sessionStartTime = DateTime.now();

    // Периодически сбрасываем накопленное время сессии на диск. 30с — баланс
    // между точностью (порог «минимальное время использования» измеряется
    // минутами) и количеством операций записи в SharedPreferences.
    _usageTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _flushSession();
    });
  }

  /// Сбросить накопленное время текущей сессии в хранилище и перезапустить
  /// отсчёт интервала. Безопасно вызывать вне таймера (например, при уходе в фон).
  Future<void> _flushSession() async {
    if (_sessionStartTime == null) return;
    final sessionDuration = DateTime.now().difference(_sessionStartTime!);
    final currentTotal =
        await _prefsRepo.getInt(PrefsKeys.totalAppUsageTime) ?? 0;
    await _prefsRepo.setInt(
      PrefsKeys.totalAppUsageTime,
      currentTotal + sessionDuration.inSeconds,
    );
    _sessionStartTime = DateTime.now(); // отсчёт для следующего интервала
  }

  /// Остановить отслеживание сессии. Перед остановкой фиксируем накопленное
  /// время, чтобы не потерять текущую сессию при уходе приложения в фон.
  Future<void> stopTracking() async {
    if (!_isTracking) return;
    _usageTimer?.cancel();
    _usageTimer = null;
    await _flushSession();
    _isTracking = false;
    _sessionStartTime = null;
  }

  /// Получить общее время использования в секундах
  Future<int> getTotalUsageTime() async {
    final totalTime = await _prefsRepo.getInt(PrefsKeys.totalAppUsageTime) ?? 0;
    // Добавляем текущую сессию, если она активна
    int currentSessionTime = 0;
    if (_isTracking && _sessionStartTime != null) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!);
      currentSessionTime = sessionDuration.inSeconds;
    }
    final total = totalTime + currentSessionTime;
    return total;
  }

  /// Проверить, прошло ли минимальное время использования
  Future<bool> hasUsedAppForMinTime(int minSeconds) async {
    final totalTime = await getTotalUsageTime();
    return totalTime >= minSeconds;
  }

  /// Получить количество запусков приложения
  Future<int> getAppLaunchCount() async {
    return await _prefsRepo.getInt(PrefsKeys.appLaunchCount) ?? 0;
  }

  /// Получить количество дней с первого запуска
  Future<int> getDaysSinceFirstLaunch() async {
    final firstLaunchTime = await _prefsRepo.getInt(
      PrefsKeys.firstAppLaunchTime,
    );
    if (firstLaunchTime == null) return 0;
    final firstLaunch = DateTime.fromMillisecondsSinceEpoch(firstLaunchTime);
    return DateTime.now().difference(firstLaunch).inDays;
  }

  /// Сбросить время использования (для тестирования)
  Future<void> resetUsageTime() async {
    await _prefsRepo.setInt(PrefsKeys.totalAppUsageTime, 0);
    await _prefsRepo.setInt(
      PrefsKeys.firstAppLaunchTime,
      DateTime.now().millisecondsSinceEpoch,
    );
    await _prefsRepo.setInt(PrefsKeys.appLaunchCount, 0);
  }
}
