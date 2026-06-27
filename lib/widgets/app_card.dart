import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/app_theme.dart';

/// Универсальный виджет-карточка с многослойным фоном Emerald,
/// точно соответствующим SwiftUI-реализации EmeraldRoundedCardBackground.
///
/// Заменяет паттерн:
///   Container(
///     decoration: BoxDecoration(
///       color: theme.isEmerald ? null : theme.lightBackgroundColor,
///       gradient: theme.cardGradient,
///       ...
///     ),
///   )
class AppCard extends StatelessWidget {
  final AppTheme theme;
  final double cornerRadius;
  final double borderWidth;
  final List<BoxShadow> shadows;
  final EdgeInsetsGeometry? margin;
  final Widget child;

  const AppCard({
    super.key,
    required this.theme,
    required this.cornerRadius,
    required this.child,
    this.borderWidth = 1.0,
    this.shadows = const [],
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(cornerRadius);

    Widget card;

    if (theme.isEmerald) {
      card = _EmeraldCard(
        theme: theme,
        cornerRadius: cornerRadius,
        borderWidth: borderWidth,
        shadows: shadows,
        child: child,
      );
    } else {
      card = Container(
        decoration: BoxDecoration(
          color: theme.lightBackgroundColor,
          borderRadius: radius,
          border: Border.all(color: theme.borderColor, width: borderWidth),
          boxShadow: shadows,
        ),
        child: ClipRRect(borderRadius: radius, child: child),
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}

// ─── Emerald card (multi-layer gradient, matching SwiftUI) ────────────────────

class _EmeraldCard extends StatelessWidget {
  final AppTheme theme;
  final double cornerRadius;
  final double borderWidth;
  final List<BoxShadow> shadows;
  final Widget child;

  const _EmeraldCard({
    required this.theme,
    required this.cornerRadius,
    required this.borderWidth,
    required this.shadows,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(cornerRadius);

    // Outer container carries shadow only
    return Container(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: _EmeraldPainter(theme: theme),
          child: Container(
            foregroundDecoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: theme.borderColor, width: borderWidth),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── CustomPainter — точная копия SwiftUI EmeraldRoundedCardBackground ────────

class _EmeraldPainter extends CustomPainter {
  final AppTheme theme;

  const _EmeraldPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Base fill: cardColor @ 94%  (isDarkAppearance = true для Emerald)
    canvas.drawRect(
      rect,
      Paint()..color = theme.lightBackgroundColor.withValues(alpha: 0.94),
    );

    // 2. Linear gradient: cardTintColor @ 18% → primaryColor @ 7%
    //    topLeading → bottomTrailing
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardTintColor.withValues(alpha: 0.18),
            theme.primaryColor.withValues(alpha: 0.07),
          ],
        ).createShader(rect),
    );

    // 3. Radial gradient: primaryColor @ 16% at topTrailing, radius 12–180
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width, 0), // topTrailing
          180.0,
          [theme.primaryColor.withValues(alpha: 0.16), Colors.transparent],
          [0.066, 1.0], // startRadius=12/180 ≈ 0.066
        ),
    );

    // 4. Radial gradient: secondaryColor @ 10% at bottomLeading, radius 12–150
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(0, size.height), // bottomLeading
          150.0,
          [theme.secondaryColor.withValues(alpha: 0.10), Colors.transparent],
          [0.08, 1.0], // startRadius=12/150 ≈ 0.08
        ),
    );

    // 5. White highlight: white @ 5% → clear, topLeading → center
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [Colors.white.withValues(alpha: 0.05), Colors.transparent],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _EmeraldPainter old) => old.theme != theme;
}
