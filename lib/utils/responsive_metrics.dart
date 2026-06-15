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
  double get settingsTrailingMaxWidth => math.min(width * 0.36, 170);

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
  double get languageCardHeight =>
      (height * (isCompactPhone ? 0.22 : 0.26)).clamp(130.0, 260.0).toDouble();
  double get languageListMaxHeight => height * (isCompactPhone ? 0.36 : 0.30);
}
