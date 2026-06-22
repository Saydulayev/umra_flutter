import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umra_flutter/providers/font_provider.dart';

void main() {
  setUp(() {
    // FontProvider reads persisted preferences on construction.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Arabic locale forces the bundled Cairo font, ignoring user choice', () {
    final provider = FontProvider();
    provider.setLanguageCode('ar');

    final style = provider.getTextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF000000),
    );

    expect(style.fontFamily, 'Cairo');
    expect(style.fontSize, 18);
    expect(style.fontWeight, FontWeight.w600);
  });

  test('setLanguageCode is idempotent and notifies only on real changes', () {
    final provider = FontProvider();
    provider.setLanguageCode('ar'); // establish a known state

    var notifications = 0;
    provider.addListener(() => notifications++);

    provider.setLanguageCode('ar'); // unchanged -> must not notify
    expect(notifications, 0);

    provider.setLanguageCode('en'); // changed -> notifies once
    expect(notifications, 1);
  });
}
