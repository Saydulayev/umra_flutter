import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:umra_flutter/theme/app_fonts.dart';
import 'package:umra_flutter/utils/script_detection.dart';

Map<String, String> _loadArb(String locale) {
  final raw =
      jsonDecode(File('l10n/app_$locale.arb').readAsStringSync())
          as Map<String, dynamic>;
  return {
    for (final e in raw.entries)
      if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
  };
}

void main() {
  group('containsUrduLetters', () {
    test('арабские тексты всех существующих языков не считаются урду', () {
      // Гарантия, что проверка не меняет разбор «арабских строк в рамке»
      // для арабского и остальных языков.
      for (final locale in ['ar', 'en', 'ru', 'de', 'fr', 'tr', 'id']) {
        final arb = _loadArb(locale);
        for (final entry in arb.entries) {
          expect(
            containsUrduLetters(entry.value),
            isFalse,
            reason: '$locale:${entry.key}',
          );
        }
      }
    });

    test('проза на урду распознаётся', () {
      expect(containsUrduLetters('قبلہ رخ ہو کر کہیں'), isTrue);
    });

    test('арабский текст в app_ur.arb совпадает с оригиналом', () {
      final en = _loadArb('en');
      final ur = _loadArb('ur');
      expect(ur.keys.toSet(), en.keys.toSet());
      for (final key in en.keys.where((k) => k.endsWith('Arabic'))) {
        expect(ur[key], en[key], reason: key);
      }
    });
  });

  group('AppFonts', () {
    test('ar и ur используют Cairo, остальные — Lato', () {
      expect(AppFonts.forLanguageCode('ar'), AppFonts.arabic);
      expect(AppFonts.forLanguageCode('ur'), AppFonts.arabic);
      expect(AppFonts.forLanguageCode('ru'), AppFonts.latin);
      expect(AppFonts.forLanguageCode('en'), AppFonts.latin);
    });
  });
}
