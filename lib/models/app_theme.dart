import 'package:flutter/material.dart';

enum AppTheme {
  nur, // Light theme (Nur = Light in Arabic)
  layl, // Dark theme (Layl = Night in Arabic)
  emerald; // Premium dark emerald theme

  String get name {
    switch (this) {
      case AppTheme.nur:
        return 'nur';
      case AppTheme.layl:
        return 'layl';
      case AppTheme.emerald:
        return 'emerald';
    }
  }

  bool get isDark => this == AppTheme.layl || this == AppTheme.emerald;

  bool get isEmerald => this == AppTheme.emerald;

  // Gradient for emerald card backgrounds (null for nur/layl)
  LinearGradient? get cardGradient {
    if (!isEmerald) return null;
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        const Color(0xFF1A2420), // Dark, desaturated green-black — barely visible
        lightBackgroundColor,    // #161818 neutral dark
      ],
    );
  }

  // Primary accent — emerald green
  Color get primaryColor {
    switch (this) {
      case AppTheme.nur:
        return const Color(0xFF10B981);
      case AppTheme.layl:
        return const Color(0xFF34D399);
      case AppTheme.emerald:
        return const Color(0xFF32C698);
    }
  }

  // Secondary accent — gold
  Color get secondaryColor {
    switch (this) {
      case AppTheme.nur:
        return const Color(0xFFCFAF5A);
      case AppTheme.layl:
        return const Color(0xFFE6C878);
      case AppTheme.emerald:
        return const Color(0xFFD8B565);
    }
  }

  // Page / scaffold background
  Color get backgroundColor {
    switch (this) {
      case AppTheme.nur:
        return const Color(0xFFF7F7F7);
      case AppTheme.layl:
        return const Color(0xFF101010);
      case AppTheme.emerald:
        return const Color(0xFF0C0F0E);
    }
  }

  // Card / surface background
  Color get lightBackgroundColor {
    switch (this) {
      case AppTheme.nur:
        return const Color(0xFFFFFFFF);
      case AppTheme.layl:
        return const Color(0xFF1A1A1A);
      case AppTheme.emerald:
        return const Color(0xFF161818);
    }
  }

  // Primary text
  Color get textColor {
    switch (this) {
      case AppTheme.nur:
        return const Color(0xFF1C1C1E);
      case AppTheme.layl:
        return const Color(0xFFEAEAEC);
      case AppTheme.emerald:
        return const Color(0xFFEEF1EF);
    }
  }

  // Secondary / muted text
  Color get secondaryTextColor {
    switch (this) {
      case AppTheme.nur:
        return const Color(0xFF6B7280);
      case AppTheme.layl:
        return const Color(0xFF9CA3AF);
      case AppTheme.emerald:
        return const Color(0xFF9CA3AF);
    }
  }

  // Gradient top color (used in theme previews)
  Color get gradientTopColor {
    switch (this) {
      case AppTheme.nur:
        return const Color(0xFFF7F7F7);
      case AppTheme.layl:
        return const Color(0xFF101010);
      case AppTheme.emerald:
        return const Color(0xFF0D1110);
    }
  }

  // Circle preview color in theme selector
  Color get previewColor {
    switch (this) {
      case AppTheme.nur:
        return const Color(0xFF10B981);
      case AppTheme.layl:
        return const Color(0xFF34D399);
      case AppTheme.emerald:
        return const Color(0xFF32C698);
    }
  }

  // Text section background (same as page background)
  Color get textBackgroundColor => backgroundColor;

  // Active button color
  Color get activeButtonColor => primaryColor;

  // Card tint for emerald (subtle green overlay)
  Color get cardTintColor {
    switch (this) {
      case AppTheme.nur:
        return Colors.white.withValues(alpha: 0.6);
      case AppTheme.layl:
        return Colors.white.withValues(alpha: 0.06);
      case AppTheme.emerald:
        return const Color(0xFFD4EEE1).withValues(alpha: 0.10);
    }
  }

  // Border color (theme-appropriate opacity)
  Color get borderColor {
    switch (this) {
      case AppTheme.nur:
        return Colors.black.withValues(alpha: 0.14);
      case AppTheme.layl:
        return Colors.white.withValues(alpha: 0.12);
      case AppTheme.emerald:
        return Colors.white.withValues(alpha: 0.13);
    }
  }

  // Card shadow color
  Color get cardShadowColor {
    switch (this) {
      case AppTheme.nur:
        return Colors.black.withValues(alpha: 0.10);
      case AppTheme.layl:
        return Colors.black.withValues(alpha: 0.45);
      case AppTheme.emerald:
        return Colors.black.withValues(alpha: 0.52);
    }
  }

  Color get errorColor {
    if (isDark) return const Color(0xFFEF4444);
    return const Color(0xFFDC2626);
  }

  Color get successColor {
    if (isDark) return const Color(0xFF34D399);
    return const Color(0xFF10B981);
  }

  Color get disabledButtonBackgroundColor {
    if (isDark) return const Color(0xFF374151);
    return const Color(0xFFE5E7EB);
  }

  Color get disabledButtonForegroundColor {
    if (isDark) return const Color(0xFF6B7280);
    return const Color(0xFF9CA3AF);
  }
}
