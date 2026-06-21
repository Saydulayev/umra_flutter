import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResponsiveMetrics {
  final Size size;
  final double textScale;

  const ResponsiveMetrics._({required this.size, required this.textScale});

  factory ResponsiveMetrics.of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return ResponsiveMetrics._(
      size: mediaQuery.size,
      textScale: mediaQuery.textScaler.scale(1.0),
    );
  }

  static const double maxTextScale = 1.3;

  double get width => size.width;
  double get height => size.height;
  double get shortestSide => size.shortestSide;
  bool get isTablet => shortestSide >= 600;
  bool get isCompactPhone => shortestSide < 380 || height < 700;

  // ── Единый непрерывный масштаб типографики ─────────────────────────────────
  //
  // Один множитель, выводимый из РАЗМЕРА ЭКРАНА (shortestSide), применяемый ко
  // всем размерам текста через [scaled]. Заменяет дискретную модель
  // «телефон/планшет»: размер растёт плавно, без скачка на границе 600 dp,
  // и крупнее на больших планшетах.
  //
  // Важно: [fontScale] зависит только от размера экрана и НЕ связан с
  // [textScale] (системной настройкой пользователя). Flutter применяет
  // textScaler к итоговому fontSize самостоятельно, поэтому здесь его
  // умножать нельзя — иначе масштаб задвоится.

  /// Референсная ширина макета (стандартный смартфон ~390 dp → множитель 1.0).
  static const double _refWidth = 390.0;

  /// Базовые размеры ролей (при [fontScale] == 1.0, т.е. на 390 dp).
  /// Единственный источник правды для всех размеров текста в приложении.
  static const double displayBase = 34.0; // hero / крупный заголовок экрана
  static const double titleBase = 26.0; // заголовок шага
  static const double sectionBase = 20.0; // заголовок секции
  static const double bodyBase = 18.0; // основной текст для чтения
  static const double calloutBase = 17.0; // строки списков, кнопки, callout
  static const double captionBase = 15.0; // подписи, настройки, вторичный текст
  static const double overlineBase = 11.0; // метки «ШАГ 1», лейблы
  static const double tabLabelBase = 10.0; // подпись нижней навигации

  /// Непрерывный множитель размера шрифта от размера экрана.
  /// Диапазон: телефоны ≈ 0.88–1.14, планшеты ≈ 1.14–1.34 (плавно, без разрыва).
  double get fontScale {
    final s = shortestSide;
    if (s <= _refWidth) {
      // Маленькие/стандартные телефоны: 320→0.92 (пол), 390→1.0.
      // Пол 0.92 не даёт тексту для чтения становиться слишком мелким на SE.
      return (s / _refWidth).clamp(0.92, 1.0).toDouble();
    }
    if (s < 600) {
      // Большие телефоны: 390..600 → 1.0..1.14 (непрерывно к планшетам)
      return 1.0 + (s - _refWidth) / (600 - _refWidth) * 0.14;
    }
    // Планшеты: 600..1024 → 1.14..1.32, далее мягкий потолок 1.34
    return (1.14 + (s - 600) / (1024 - 600) * 0.18).clamp(1.14, 1.34).toDouble();
  }

  /// Адаптивный размер: задаёшь «дизайнерский» базовый размер (под 390 dp) —
  /// получаешь размер, пропорциональный текущему экрану.
  double scaled(double base) => base * fontScale;

  /// Альбомная ориентация (ширина больше высоты)
  bool get isLandscape => width > height;

  double get homeBadgeSize {
    if (isTablet) return 60;
    if (isCompactPhone) return 50;
    return 56;
  }

  double get homeRowHorizontalPadding => isCompactPhone ? 16 : 20;
  double get homeRowVerticalPadding => isCompactPhone ? 12 : 14;
  double get homeRowGap => isCompactPhone ? 12 : 16;

  double get bottomTabBarWidth {
    final maxWidth = isTablet ? 340.0 : 280.0;
    final targetWidth = width * (isTablet ? 0.36 : 0.62);
    return math.min(width - 32, targetWidth.clamp(220.0, maxWidth).toDouble());
  }

  double get arabicFontSize {
    final minSize = isCompactPhone ? 30.0 : 34.0;
    final maxSize = isTablet ? 58.0 : 42.0;
    return (width * 0.095).clamp(minSize, maxSize).toDouble();
  }

  double get arabicContentPadding {
    if (isTablet) return 28;
    if (isCompactPhone) return 14;
    return 18;
  }

  double get arabicCardRadius => isTablet ? 24 : 20;

  double get playerControlSize {
    if (isTablet) return 70;
    if (isCompactPhone) return 58;
    return 64;
  }

  double get playerControlGap => isCompactPhone ? 12 : 16;

  double get prayerCardMaxWidth => isTablet ? 520 : double.infinity;
  EdgeInsets get prayerCardPadding {
    if (isCompactPhone) {
      return const EdgeInsets.symmetric(horizontal: 18, vertical: 24);
    }
    if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 40);
    }
    return const EdgeInsets.symmetric(horizontal: 25, vertical: 32);
  }

  double get prayerHorizontalInset => isCompactPhone ? 12 : 16;

  /// Максимальная ширина значения справа в строках настроек
  /// (название языка/темы). Увеличено, чтобы длинные значения, например
  /// «Bahasa Indonesia», реже усекались на узких телефонах.
  double get settingsTrailingMaxWidth =>
      math.min(width * 0.42, 190).toDouble();

  double get languageHorizontalPadding {
    if (isTablet) return 72;
    if (width > 500) return 48;
    return isCompactPhone ? 16 : 20;
  }

  double get languageTopPadding => height > 800 ? 48 : 20;
  double get languageBottomPadding => height > 800 ? 32 : 14;
  double get languageCardWidth => (width * (isTablet ? 0.46 : 0.72))
      .clamp(220.0, isTablet ? 380.0 : 320.0)
      .toDouble();

  /// Высота карточки приветственного изображения. В альбомной ориентации
  /// уменьшается, чтобы освободить место для прокручиваемого списка языков
  /// и исключить переполнение по вертикали.
  double get languageCardHeight {
    final fraction = isCompactPhone ? 0.22 : 0.26;
    final minH = isLandscape ? 100.0 : 130.0;
    final maxH = isLandscape ? 170.0 : 260.0;
    return (height * fraction).clamp(minH, maxH).toDouble();
  }

  // ── Tablet content layout ──────────────────────────────────────────────────

  /// Максимальная ширина текстового контента (для читаемости на iPad)
  double get contentMaxWidth => isTablet ? 680.0 : double.infinity;

  /// Крупный заголовок экрана (Umra / Hajj)
  double get largeTitleFontSize => scaled(displayBase);

  /// Горизонтальный отступ для списочных экранов (карточки-списки)
  double get listScreenHPad => isTablet ? 24.0 : 16.0;

  /// Горизонтальный отступ внутри экранов с деталями (шаги, дуа, текст).
  /// На телефонах увеличено с 10 до 16, чтобы текст не прижимался к краю.
  double get stepDetailHPad => isTablet ? 24.0 : 16.0;

  /// Размер иконки-бейджа в списке дуа
  double get duaBadgeSize => isTablet ? 48.0 : 40.0;

  /// Ширина арабского превью в строке списка дуа
  double get duaArabicPreviewWidth => isTablet ? 120.0 : 80.0;

  /// Размер шрифта арабского превью в строке списка дуа
  double get duaArabicPreviewFontSize => isTablet ? 20.0 : 16.0;

  // ── Legacy-обёртки над единым масштабом ────────────────────────────────────
  // Сохранены для обратной совместимости и делегируют в [scaled]. Новый код
  // должен использовать AppType (lib/theme/app_type.dart). Единый источник
  // правды — *Base-константы выше, поэтому второй системы типографики нет.

  /// Размер шрифта для строк шагов/элементов в карточках-списках
  double get stepItemFontSize => scaled(calloutBase);

  /// Заголовок шага (крупный, жирный)
  double get stepTitleFontSize => scaled(titleBase);

  /// Основной текст (параграфы, детали шагов, дуа)
  double get bodyFontSize => scaled(bodyBase);

  /// Строки списков, элементы меню
  double get listFontSize => scaled(calloutBase);

  /// Подписи, строки настроек
  double get captionFontSize => scaled(captionBase);

  /// Заголовки секций внутри экрана
  double get sectionTitleFontSize => scaled(sectionBase);
}
