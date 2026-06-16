import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../repositories/preferences_repository.dart';
import '../constants/app_constants.dart';

class FontProvider extends ChangeNotifier {
  List<String> fonts = [
    "Lato",        // Default — geometric sans-serif, high legibility
    "Roboto",      // Material standard, excellent readability
    "Open Sans",   // Neutral, wide character spacing
    "Merriweather", // Serif, comfortable for long-form reading
    "Lora",        // Elegant serif, good for body text
    "Noto Sans",   // Broad Unicode coverage including Arabic-adjacent scripts
    "Inter",       // Modern sans-serif, optimised for screens
  ];

  // Маппинг имен шрифтов на Google Fonts
  String? _getGoogleFontName(String fontName) {
    final fontMap = {
      'Lato': 'Lato',
      'Roboto': 'Roboto',
      'Open Sans': 'OpenSans',
      'Merriweather': 'Merriweather',
      'Lora': 'Lora',
      'Noto Sans': 'NotoSans',
      'Inter': 'Inter',
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
    final saved = await _prefsRepo.getString(PrefsKeys.selectedFont) ?? 'Lato';
    // Guard: if a previously saved font is no longer in the allowed list, reset to Lato
    _selectedFont = fonts.contains(saved) ? saved : 'Lato';
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