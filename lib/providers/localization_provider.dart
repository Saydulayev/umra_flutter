import 'package:flutter/material.dart';
import '../repositories/preferences_repository.dart';
import '../constants/app_constants.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('ru', '');
  bool _hasSelectedLanguage = false;

  Locale get currentLocale => _currentLocale;
  bool get hasSelectedLanguage => _hasSelectedLanguage;

  final PreferencesRepository _prefsRepo = PreferencesRepository();

  final List<Locale> supportedLocales = const [
    Locale('en', ''),
    Locale('ru', ''),
    Locale('de', ''),
    Locale('fr', ''),
    Locale('tr', ''),
    Locale('id', ''),
    Locale('ar', ''),
  ];

  LocalizationProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final languageCode =
        await _prefsRepo.getString(PrefsKeys.selectedLanguage) ?? 'ru';
    _hasSelectedLanguage =
        await _prefsRepo.getBool(PrefsKeys.hasSelectedLanguage) ?? false;
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    _hasSelectedLanguage = true;
    await _prefsRepo.setString(PrefsKeys.selectedLanguage, languageCode);
    await _prefsRepo.setBool(PrefsKeys.hasSelectedLanguage, true);
    notifyListeners();
  }

  void setHasSelectedLanguage(bool value) {
    _hasSelectedLanguage = value;
    notifyListeners();
  }
}
