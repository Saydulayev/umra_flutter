import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('ru', '');
  bool _hasSelectedLanguage = false;

  Locale get currentLocale => _currentLocale;
  bool get hasSelectedLanguage => _hasSelectedLanguage;

  final List<Locale> supportedLocales = const [
    Locale('en', ''),
    Locale('ru', ''),
    Locale('de', ''),
    Locale('fr', ''),
    Locale('tr', ''),
    Locale('id', ''),
  ];

  LocalizationProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('selectedLanguage') ?? 'ru';
    _hasSelectedLanguage = prefs.getBool('hasSelectedLanguage') ?? false;
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    _hasSelectedLanguage = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
    await prefs.setBool('hasSelectedLanguage', true);
    notifyListeners();
  }

  void setHasSelectedLanguage(bool value) {
    _hasSelectedLanguage = value;
    notifyListeners();
  }
}
