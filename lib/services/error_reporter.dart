import 'dart:async';

import 'package:flutter/foundation.dart';

/// Vendor-agnostic crash-reporting backend.
///
/// The application code never depends on a concrete provider (Firebase
/// Crashlytics, Sentry, …) — it only depends on [ErrorReporter]. To enable a
/// real backend for production, implement this interface in a thin adapter and
/// pass it to [ErrorReporter.install]. Until then the app ships with a no-op
/// backend and errors are still surfaced in the console in debug builds.
abstract class CrashReportingBackend {
  /// Records an error. [fatal] distinguishes crashes (uncaught) from handled
  /// (non-fatal) errors that the app recovered from.
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal,
    String? reason,
  });

  /// Adds a breadcrumb / log line attached to the next report.
  Future<void> log(String message);
}

/// Central entry point for global error handling and crash reporting.
///
/// Install once, as early as possible, from inside the zone that runs the app
/// (see `main.dart`). It wires the three sources of uncaught errors in a
/// Flutter app:
///   1. [FlutterError.onError]            — framework errors (build/layout/paint)
///   2. [PlatformDispatcher.onError]      — uncaught async/platform errors
///   3. `runZonedGuarded`                 — anything escaping the root zone
class ErrorReporter {
  ErrorReporter._();

  static CrashReportingBackend? _backend;

  /// Whether a real reporting backend has been registered.
  static bool get hasBackend => _backend != null;

  /// Installs the global Flutter/platform error handlers and registers an
  /// optional [backend]. Safe to call once during startup.
  static void install({CrashReportingBackend? backend}) {
    _backend = backend;

    // Errors caught by the Flutter framework.
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // Preserve default behaviour (red screen / console dump in debug).
      previousOnError?.call(details);
      recordError(
        details.exception,
        details.stack,
        fatal: true,
        reason: details.context?.toString(),
      );
    };

    // Uncaught errors that bubble up from the engine / platform side.
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack, fatal: true);
      return true; // handled — prevents the engine from crashing the isolate
    };
  }

  /// Reports an [error] to the backend (if any) and prints it in debug builds.
  /// Use [fatal] = false for errors the app handled gracefully.
  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[ErrorReporter${fatal ? ':FATAL' : ''}] '
        '${reason != null ? '$reason — ' : ''}$error',
      );
      if (stack != null) debugPrint(stack.toString());
    }
    try {
      await _backend?.recordError(error, stack, fatal: fatal, reason: reason);
    } catch (_) {
      // Never let the reporter itself throw.
    }
  }

  /// Adds a breadcrumb to the next crash report.
  static Future<void> log(String message) async {
    try {
      await _backend?.log(message);
    } catch (_) {
      // Ignore reporter failures.
    }
  }
}
