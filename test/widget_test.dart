import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:umra_flutter/main.dart';

void main() {
  testWidgets('App starts on language selection when no language is selected', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('UMRA GUIDE'), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);
  });
}
