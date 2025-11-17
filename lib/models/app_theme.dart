import 'package:flutter/material.dart';

enum AppTheme {
  blue,
  green,
  gold,
  turquoise;

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
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFFE5EEFF);
      case AppTheme.green:
        return const Color(0xFFE6F3E6);
      case AppTheme.gold:
        return const Color(0xFFF2E6B3);
      case AppTheme.turquoise:
        return const Color(0xFFE6F2F2);
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
    }
  }

  Color get textBackgroundColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFFE5EEFF);
      case AppTheme.green:
        return const Color(0xFFE6F3E6);
      case AppTheme.gold:
        return const Color(0xFFF2E6B3);
      case AppTheme.turquoise:
        return const Color(0xFFE6F2F2);
    }
  }
}
