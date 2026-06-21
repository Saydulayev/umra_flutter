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
  double get largeTitleFontSize => isTablet ? 40.0 : 34.0;

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

  /// Размер шрифта для строк шагов/элементов в карточках-списках
  double get stepItemFontSize => isTablet ? 18.0 : 16.0;

  /// Заголовок шага (крупный, жирный)
  double get stepTitleFontSize => isTablet ? 28.0 : 26.0;

  // ── Adaptive text sizes ────────────────────────────────────────────────────

  /// Основной текст (параграфы, детали шагов, дуа)
  double get bodyFontSize => isTablet ? 20.0 : 18.0;

  /// Строки списков, элементы меню
  double get listFontSize => isTablet ? 19.0 : 17.0;

  /// Подписи, строки настроек
  double get captionFontSize => isTablet ? 17.0 : 15.0;

  /// Заголовки секций внутри экрана
  double get sectionTitleFontSize => isTablet ? 22.0 : 20.0;
}
