import 'package:flutter/material.dart';

import '../utils/responsive_metrics.dart';

/// Единый набор типографических ролей приложения.
///
/// Все размеры текста выводятся из одного непрерывного масштаба
/// [ResponsiveMetrics.fontScale] и единственного набора базовых констант
/// (`*Base` в [ResponsiveMetrics]). Это единый источник правды для размеров
/// текста: новый код использует роли отсюда, а не литералы `fontSize`.
///
/// Роли (база при 390 dp → диапазон телефон…планшет):
/// - [display]  34 — hero / крупный заголовок экрана
/// - [title]    26 — заголовок шага
/// - [section]  20 — заголовок секции
/// - [body]     18 — основной текст для чтения
/// - [callout]  17 — строки списков, кнопки
/// - [caption]  15 — подписи, настройки
/// - [overline] 11 — метки, лейблы
/// - [tabLabel] 10 — подпись нижней навигации
class AppType {
  final ResponsiveMetrics m;

  const AppType(this.m);

  factory AppType.of(BuildContext context) =>
      AppType(ResponsiveMetrics.of(context));

  double get display => m.scaled(ResponsiveMetrics.displayBase);
  double get title => m.scaled(ResponsiveMetrics.titleBase);
  double get section => m.scaled(ResponsiveMetrics.sectionBase);
  double get body => m.scaled(ResponsiveMetrics.bodyBase);
  double get callout => m.scaled(ResponsiveMetrics.calloutBase);
  double get caption => m.scaled(ResponsiveMetrics.captionBase);
  double get overline => m.scaled(ResponsiveMetrics.overlineBase);
  double get tabLabel => m.scaled(ResponsiveMetrics.tabLabelBase);

  /// Применяет адаптивные размеры ролей к [ThemeData], чтобы системные
  /// компоненты Flutter (AppBar, Dialog, кнопки, базовый TextTheme) тоже
  /// масштабировались по размеру экрана. Меняются только размеры — цвета,
  /// насыщенность и семейства шрифтов берутся из [base].
  ThemeData applyToTheme(ThemeData base) {
    final tt = base.textTheme;

    final scaledTextTheme = tt.copyWith(
      displayLarge: tt.displayLarge?.copyWith(fontSize: display),
      headlineMedium: tt.headlineMedium?.copyWith(fontSize: title),
      titleLarge: (tt.titleLarge ?? const TextStyle()).copyWith(
        fontSize: section,
      ),
      bodyLarge: (tt.bodyLarge ?? const TextStyle()).copyWith(fontSize: body),
      bodyMedium: (tt.bodyMedium ?? const TextStyle()).copyWith(
        fontSize: callout,
      ),
      bodySmall: (tt.bodySmall ?? const TextStyle()).copyWith(
        fontSize: caption,
      ),
      labelLarge: (tt.labelLarge ?? const TextStyle()).copyWith(
        fontSize: callout,
      ),
      labelSmall: (tt.labelSmall ?? const TextStyle()).copyWith(
        fontSize: overline,
      ),
    );

    return base.copyWith(
      textTheme: scaledTextTheme,
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: (base.appBarTheme.titleTextStyle ?? const TextStyle())
            .copyWith(fontSize: body),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        titleTextStyle:
            (base.dialogTheme.titleTextStyle ?? const TextStyle()).copyWith(
              fontSize: body,
            ),
        contentTextStyle:
            (base.dialogTheme.contentTextStyle ?? const TextStyle()).copyWith(
              fontSize: caption,
            ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: (base.elevatedButtonTheme.style ?? const ButtonStyle()).copyWith(
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Lato',
              fontSize: callout,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: (base.textButtonTheme.style ?? const ButtonStyle()).copyWith(
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Lato',
              fontSize: caption,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
