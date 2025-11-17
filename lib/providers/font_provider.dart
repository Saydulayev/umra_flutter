import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class FontProvider extends ChangeNotifier {
  List<String> fonts = [
    "Lato",
    "Roboto",
    "Open Sans",
    "Montserrat",
    "Poppins",
    "Raleway",
    "Ubuntu",
    "Oswald",
    "Playfair Display",
    "Merriweather",
    "Source Sans Pro",
    "Lora",
    "Nunito",
    "Crimson Text",
    "Dancing Script",
    "Pacifico",
    "Indie Flower",
    "Shadows Into Light",
    "Amatic SC",
    "Bebas Neue",
    "Comfortaa",
    "Fira Sans",
    "Inter",
    "Noto Sans",
    "PT Sans",
    "Quicksand",
    "Work Sans",
  ];

  // Маппинг имен шрифтов на Google Fonts
  String? _getGoogleFontName(String fontName) {
    final fontMap = {
      'Lato': 'Lato',
      'Roboto': 'Roboto',
      'Open Sans': 'OpenSans',
      'Montserrat': 'Montserrat',
      'Poppins': 'Poppins',
      'Raleway': 'Raleway',
      'Ubuntu': 'Ubuntu',
      'Oswald': 'Oswald',
      'Playfair Display': 'PlayfairDisplay',
      'Merriweather': 'Merriweather',
      'Source Sans Pro': 'SourceSansPro',
      'Lora': 'Lora',
      'Nunito': 'Nunito',
      'Crimson Text': 'CrimsonText',
      'Dancing Script': 'DancingScript',
      'Pacifico': 'Pacifico',
      'Indie Flower': 'IndieFlower',
      'Shadows Into Light': 'ShadowsIntoLight',
      'Amatic SC': 'AmaticSC',
      'Bebas Neue': 'BebasNeue',
      'Comfortaa': 'Comfortaa',
      'Fira Sans': 'FiraSans',
      'Inter': 'Inter',
      'Noto Sans': 'NotoSans',
      'PT Sans': 'PTSans',
      'Quicksand': 'Quicksand',
      'Work Sans': 'WorkSans',
    };
    return fontMap[fontName];
  }

  // Получить TextStyle с выбранным шрифтом
  TextStyle? getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
  }) {
    final googleFontName = _getGoogleFontName(_selectedFont);
    if (googleFontName != null) {
      try {
        return GoogleFonts.getFont(
          googleFontName,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          fontStyle: fontStyle,
        );
      } catch (e) {
        // Если шрифт не найден, возвращаем null
        return null;
      }
    }
    return null;
  }

  String _selectedFont = 'Lato';
  double _selectedFontSize = 20.0;

  String get selectedFont => _selectedFont;
  double get selectedFontSize => _selectedFontSize;

  double get dynamicFontSize {
    // Определяем размер шрифта на основе устройства
    // Для планшетов используем больший размер шрифта
    // Это будет определяться в UI через MediaQuery
    return _selectedFontSize;
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