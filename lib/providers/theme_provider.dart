import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../repositories/preferences_repository.dart';
import '../constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _selectedTheme = AppTheme.nur;

  AppTheme get selectedTheme => _selectedTheme;

  final PreferencesRepository _prefsRepo = PreferencesRepository();

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeString =
        await _prefsRepo.getString(PrefsKeys.selectedTheme) ?? 'nur';
    _selectedTheme = AppTheme.values.firstWhere(
      (theme) => theme.name == themeString,
      orElse: () => AppTheme.nur,
    );
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _selectedTheme = theme;
    await _prefsRepo.setString(PrefsKeys.selectedTheme, theme.name);
    notifyListeners();
  }
}
