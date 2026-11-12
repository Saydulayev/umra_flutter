import 'package:flutter/widgets.dart';

/// Single source of truth for which bundled font family the UI chrome uses.
///
/// `Lato` has no Arabic-script glyphs, so without this the `ar`/`ur` locales
/// silently fall back to the OS system font (Geeza Pro / Noto Naskh Arabic),
/// whose metrics render visibly smaller than Lato at the same `fontSize`.
/// `Cairo` is bundled locally (see pubspec.yaml) and covers Arabic, Urdu,
/// Latin and digits, so switching the whole UI to it keeps text uniform.
///
/// Это только шрифт интерфейса. Арабский текст в рамках (дуа, зикры, аяты)
/// рисует ArabicTextWidget своим шрифтом KFGQPCUthmanTahaNaskh — он от языка
/// интерфейса не зависит.
class AppFonts {
  AppFonts._();

  static const String latin = 'Lato';
  static const String arabic = 'Cairo';

  /// Языки интерфейса на арабской графике.
  static const Set<String> _arabicScriptLanguages = {'ar', 'ur'};

  static bool usesArabicScript(String languageCode) =>
      _arabicScriptLanguages.contains(languageCode);

  static String forLanguageCode(String languageCode) =>
      usesArabicScript(languageCode) ? arabic : latin;

  static String of(BuildContext context) =>
      forLanguageCode(Localizations.localeOf(context).languageCode);
}
