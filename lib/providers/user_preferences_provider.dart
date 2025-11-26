import 'package:flutter/material.dart';
import '../repositories/preferences_repository.dart';
import '../constants/app_constants.dart';

class UserPreferencesProvider extends ChangeNotifier {
  bool _isGridView = false;
  bool _hasRatedApp = false;

  bool get isGridView => _isGridView;
  bool get hasRatedApp => _hasRatedApp;

  final PreferencesRepository _prefsRepo = PreferencesRepository();

  UserPreferencesProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _isGridView = await _prefsRepo.getBool(PrefsKeys.isGridView) ?? false;
    _hasRatedApp = await _prefsRepo.getBool(PrefsKeys.hasRatedApp) ?? false;
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
}


