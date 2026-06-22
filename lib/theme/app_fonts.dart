import 'package:flutter/widgets.dart';

/// Single source of truth for which bundled font family the UI chrome uses.
///
/// `Lato` has no Arabic glyphs, so without this the `ar` locale silently
/// falls back to the OS system Arabic font (Geeza Pro / Noto Naskh Arabic),
/// whose metrics render visibly smaller than Lato at the same `fontSize`.
/// `Cairo` is bundled locally (see pubspec.yaml) and covers Arabic, Latin
/// and digits, so switching the whole UI to it for `ar` keeps text uniform.
class AppFonts {
  AppFonts._();

  static const String latin = 'Lato';
  static const String arabic = 'Cairo';

  static String forLanguageCode(String languageCode) =>
      languageCode == 'ar' ? arabic : latin;

  static String of(BuildContext context) =>
      forLanguageCode(Localizations.localeOf(context).languageCode);
}
