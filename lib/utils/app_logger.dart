import 'package:flutter/foundation.dart';

import '../services/error_reporter.dart';

/// Lightweight logging facade for the app.
///
/// Replaces ad-hoc `debugPrint` calls so that:
///   * informational logs are emitted **only in debug builds** ([d]) and never
///     leak into device logs in release;
///   * handled errors ([e]) are both printed in debug and forwarded to
///     [ErrorReporter] as non-fatal reports, so they show up in crash
///     reporting once a backend is wired in.
class AppLogger {
  AppLogger._();

  /// Debug-only informational log. No-op in profile/release builds.
  static void d(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Logs a handled error. Prints in debug and records a non-fatal report.
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint(error != null ? '$message: $error' : message);
    }
    if (error != null) {
      ErrorReporter.recordError(
        error,
        stackTrace,
        fatal: false,
        reason: message,
      );
    }
  }
}
