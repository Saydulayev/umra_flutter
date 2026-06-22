import 'package:flutter_test/flutter_test.dart';
import 'package:umra_flutter/theme/app_fonts.dart';

void main() {
  group('AppFonts.forLanguageCode', () {
    test('uses bundled Cairo for Arabic so glyphs are not system-fallback', () {
      expect(AppFonts.forLanguageCode('ar'), AppFonts.arabic);
      expect(AppFonts.forLanguageCode('ar'), 'Cairo');
    });

    test('uses Lato for every non-Arabic supported locale', () {
      for (final code in const ['en', 'ru', 'de', 'fr', 'tr', 'id']) {
        expect(
          AppFonts.forLanguageCode(code),
          AppFonts.latin,
          reason: 'locale "$code" should render with the Latin font',
        );
      }
    });
  });
}
