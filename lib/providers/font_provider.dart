import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider extends ChangeNotifier {
  List<String> fonts = [
    "Arial",
    "Helvetica",
    "Times New Roman",
    "Courier",
    "Verdana",
    "Arial Rounded MT Bold",
    "Chalkduster",
    "Georgia",
    "Palatino",
    "Trebuchet MS",
    "Comic Sans MS",
    "Futura",
    "Gill Sans",
    "Optima",
    "Copperplate",
    "Papyrus",
    "Marker Felt",
    "Bradley Hand",
    "Trattatello",
    "Baskerville",
    "American Typewriter",
    "Hoefler Text",
    "Didot",
    "Savoye LET",
    "Bodoni 72",
    "Lato",
    "Lato-Black",
    "Lato-Italic",
    "Lato-BlackItalic",
    "Lato-Bold"
  ];

  String _selectedFont = 'Lato';
  double _selectedFontSize = 20.0;

  String get selectedFont => _selectedFont;
  double get selectedFontSize => _selectedFontSize;

  double get dynamicFontSize {
    // Определяем размер шрифта на основе устройства
    // TODO: Добавить определение типа устройства
    return 20.0;
  }

  FontProvider() {
    _loadFontPreferences();
  }

  Future<void> _loadFontPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedFont = prefs.getString('SelectedFont') ?? 'Lato';
    _selectedFontSize = prefs.getDouble('SelectedFontSize') ?? 20.0;
    notifyListeners();
  }

  Future<void> setFont(String font) async {
    _selectedFont = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('SelectedFont', font);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _selectedFontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('SelectedFontSize', size);
    notifyListeners();
  }
}