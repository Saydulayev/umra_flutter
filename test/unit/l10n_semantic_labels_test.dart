import 'package:flutter_test/flutter_test.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';

/// Гарантирует, что l10n-ключи, используемые как semantic label / tooltip
/// (см. tap_target_labels_test.dart и semanticLabel в home_screen.dart),
/// непустые во ВСЕХ поддерживаемых локалях.
///
/// Guideline-тесты гоняются на одной локали — пустой перевод в конкретном
/// языке они не поймают, а скринридер в этой локали озвучит кнопку как
/// безымянную "Button". Этот тест закрывает дыру дёшево: без пампа виджетов,
/// прямым обходом сгенерированных локализаций.
void main() {
  // Ключ → извлечение значения. При добавлении нового лейбла — добавить сюда.
  final labelKeys = <String, String Function(AppLocalizations)>{
    'umra': (l) => l.umra,
    'hajj': (l) => l.hajj,
    'duaBookNavTitle': (l) => l.duaBookNavTitle,
    'prayerTimesTitle': (l) => l.prayerTimesTitle,
    'settingsString': (l) => l.settingsString,
    'notificationsString': (l) => l.notificationsString,
    'close': (l) => l.close,
    'font': (l) => l.font,
  };

  for (final locale in AppLocalizations.supportedLocales) {
    test('локаль $locale: все label-ключи непустые', () {
      final l10n = lookupAppLocalizations(locale);
      for (final entry in labelKeys.entries) {
        expect(
          entry.value(l10n).trim(),
          isNotEmpty,
          reason:
              'Ключ "${entry.key}" пуст в локали $locale — скринридер '
              'озвучит элемент как безымянную кнопку',
        );
      }
    });
  }
}
