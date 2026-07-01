import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'error_reporter.dart';

/// [CrashReportingBackend] реализация поверх Firebase Crashlytics.
///
/// Тонкий адаптер — весь остальной код приложения работает только через
/// [ErrorReporter] и ничего не знает про Crashlytics напрямую (см. комментарий
/// в error_reporter.dart). Благодаря этому бэкенд можно в любой момент
/// заменить (например, на Sentry) без правок в остальном коде.
///
/// Требует, чтобы `Firebase.initializeApp()` уже отработал к моменту вызова
/// [ErrorReporter.install] — это гарантируется порядком вызовов в `main.dart`.
class CrashlyticsBackend implements CrashReportingBackend {
  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) {
    return FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: fatal,
      reason: reason,
    );
  }

  @override
  Future<void> log(String message) {
    return FirebaseCrashlytics.instance.log(message);
  }
}
