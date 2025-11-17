import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _selectedTheme = AppTheme.blue;

  AppTheme get selectedTheme => _selectedTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('selectedTheme') ?? 'blue';
    _selectedTheme = AppTheme.values.firstWhere(
      (theme) => theme.name == themeString,
      orElse: () => AppTheme.blue,
    );
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _selectedTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTheme', theme.name);
    notifyListeners();
  }
}


