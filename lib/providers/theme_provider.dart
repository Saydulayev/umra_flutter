import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../repositories/preferences_repository.dart';
import '../constants/app_constants.dart';

/// What the user has chosen in settings (includes Auto).
enum ThemePreference { auto, nur, layl, emerald }

extension ThemePreferenceName on ThemePreference {
  String get prefName {
    switch (this) {
      case ThemePreference.auto:
        return 'auto';
      case ThemePreference.nur:
        return 'nur';
      case ThemePreference.layl:
        return 'layl';
      case ThemePreference.emerald:
        return 'emerald';
    }
  }
}

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemePreference _themePreference = ThemePreference.auto;
  Brightness _systemBrightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  final PreferencesRepository _prefsRepo = PreferencesRepository();

  ThemePreference get themePreference => _themePreference;

  /// The actual resolved theme used throughout the app.
  AppTheme get selectedTheme {
    switch (_themePreference) {
      case ThemePreference.auto:
        return _systemBrightness == Brightness.dark
            ? AppTheme.layl
            : AppTheme.nur;
      case ThemePreference.nur:
        return AppTheme.nur;
      case ThemePreference.layl:
        return AppTheme.layl;
      case ThemePreference.emerald:
        return AppTheme.emerald;
    }
  }

  ThemeProvider() {
    WidgetsBinding.instance.addObserver(this);
    _loadTheme();
  }

  @override
  void didChangePlatformBrightness() {
    final newBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (_systemBrightness != newBrightness) {
      _systemBrightness = newBrightness;
      if (_themePreference == ThemePreference.auto) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadTheme() async {
    final saved = await _prefsRepo.getString(PrefsKeys.selectedTheme) ?? 'auto';
    _themePreference = ThemePreference.values.firstWhere(
      (p) => p.prefName == saved,
      orElse: () => ThemePreference.auto,
    );
    notifyListeners();
  }

  Future<void> setTheme(ThemePreference preference) async {
    _themePreference = preference;
    await _prefsRepo.setString(PrefsKeys.selectedTheme, preference.prefName);
    notifyListeners();
  }
}
