import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesProvider extends ChangeNotifier {
  bool _hasSelectedLanguage = false;
  bool _isGridView = false;
  bool _hasRatedApp = false;

  bool get hasSelectedLanguage => _hasSelectedLanguage;
  bool get isGridView => _isGridView;
  bool get hasRatedApp => _hasRatedApp;

  UserPreferencesProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSelectedLanguage = prefs.getBool('hasSelectedLanguage') ?? false;
    _isGridView = prefs.getBool('isGridView') ?? false;
    _hasRatedApp = prefs.getBool('hasRatedApp') ?? false;
    notifyListeners();
  }

  Future<void> setHasSelectedLanguage(bool value) async {
    _hasSelectedLanguage = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSelectedLanguage', value);
    notifyListeners();
  }

  Future<void> setIsGridView(bool value) async {
    _isGridView = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView', value);
    notifyListeners();
  }

  Future<void> setHasRatedApp(bool value) async {
    _hasRatedApp = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasRatedApp', value);
    notifyListeners();
  }
}


