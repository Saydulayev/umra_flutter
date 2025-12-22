import 'package:flutter/material.dart';

enum AppTheme {
  blue,
  green,
  gold,
  turquoise,
  dark;

  String get name {
    switch (this) {
      case AppTheme.blue:
        return 'theme_heavenly';
      case AppTheme.green:
        return 'theme_oasis';
      case AppTheme.gold:
        return 'theme_gold';
      case AppTheme.turquoise:
        return 'theme_turquoise';
      case AppTheme.dark:
        return 'theme_dark';
    }
  }

  Color get primaryColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFF4D99E6); // RGB: 0.3, 0.6, 0.9
      case AppTheme.green:
        return const Color(0xFF33B34D); // RGB: 0.2, 0.7, 0.3
      case AppTheme.gold:
        return const Color(0xFFCC991A); // RGB: 0.8, 0.6, 0.1
      case AppTheme.turquoise:
        return const Color(0xFF1AB3B3); // RGB: 0.1, 0.7, 0.7
      case AppTheme.dark:
        return const Color(0xFF6B7280); // Gray-blue accent
    }
  }

  Color get gradientTopColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFFF0F7FF);
      case AppTheme.green:
        return const Color(0xFFF2FAF5);
      case AppTheme.gold:
        return const Color(0xFFFAF2E0);
      case AppTheme.turquoise:
        return const Color(0xFFF2FAFA);
      case AppTheme.dark:
        return const Color(0xFF1F2937); // Dark gray
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFFE5EEFF);
      case AppTheme.green:
        return const Color(0xFFE6F3E6);
      case AppTheme.gold:
        return const Color(0xFFFAF7ED);
      case AppTheme.turquoise:
        return const Color(0xFFE6F2F2);
      case AppTheme.dark:
        return const Color(0xFF111827); // Dark background
    }
  }

  Color get lightBackgroundColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFFFCFDFF);
      case AppTheme.green:
        return const Color(0xFFFCFDFC);
      case AppTheme.gold:
        return const Color(0xFFFFFDF8);
      case AppTheme.turquoise:
        return const Color(0xFFFCFDFD);
      case AppTheme.dark:
        return const Color(0xFF1F2937); // Slightly lighter dark
    }
  }

  Color get activeButtonColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFF0080FF);
      case AppTheme.green:
        return const Color(0xFF00CC00);
      case AppTheme.gold:
        return const Color(0xFFFFCC00);
      case AppTheme.turquoise:
        return const Color(0xFF00CCCC);
      case AppTheme.dark:
        return const Color(0xFF3B82F6); // Bright blue accent
    }
  }

  Color get previewColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFF7FB3D3);
      case AppTheme.green:
        return const Color(0xFF66BB6A);
      case AppTheme.gold:
        return const Color(0xFFD4AF37);
      case AppTheme.turquoise:
        return const Color(0xFF26A69A);
      case AppTheme.dark:
        return const Color(0xFF374151); // Dark gray for preview
    }
  }

  Color get textBackgroundColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFFE5EEFF);
      case AppTheme.green:
        return const Color(0xFFE6F3E6);
      case AppTheme.gold:
        return const Color(0xFFFAF7ED);
      case AppTheme.turquoise:
        return const Color(0xFFE6F2F2);
      case AppTheme.dark:
        return const Color(0xFF1F2937); // Dark text background
    }
  }

  /// Returns true if this is a dark theme
  bool get isDark => this == AppTheme.dark;

  /// Text color appropriate for this theme
  Color get textColor =>
      isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937);

  /// Secondary text color appropriate for this theme
  Color get secondaryTextColor =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
}
