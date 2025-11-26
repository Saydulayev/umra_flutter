import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../repositories/preferences_repository.dart';
import '../constants/app_constants.dart';

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
  // Всегда возвращает валидный TextStyle с fallback на системный шрифт
  TextStyle getTextStyle({
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
        // Если шрифт не найден, возвращаем системный шрифт
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          fontStyle: fontStyle,
        );
      }
    }
    // Fallback на системный шрифт
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
    );
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

  final PreferencesRepository _prefsRepo = PreferencesRepository();

  FontProvider() {
    _loadFontPreferences();
  }

  Future<void> _loadFontPreferences() async {
    _selectedFont =
        await _prefsRepo.getString(PrefsKeys.selectedFont) ?? 'Lato';
    _selectedFontSize =
        await _prefsRepo.getDouble(PrefsKeys.selectedFontSize) ?? 20.0;
    notifyListeners();
  }

  Future<void> setFont(String font) async {
    _selectedFont = font;
    await _prefsRepo.setString(PrefsKeys.selectedFont, font);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _selectedFontSize = size;
    await _prefsRepo.setDouble(PrefsKeys.selectedFontSize, size);
    notifyListeners();
  }
}