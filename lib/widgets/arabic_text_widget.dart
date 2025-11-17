import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';

class ArabicTextWidget extends StatelessWidget {
  final String text;

  const ArabicTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    // Динамический размер шрифта: 58 для планшета, 38 для телефона
    final fontSize = isTablet ? 58.0 : 38.0;

    // Динамический padding: 32 для планшета, 16 для телефона
    final customPadding = isTablet ? 32.0 : 16.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(20, 20),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Фоновый цвет
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: theme.textBackgroundColor),
              ),
              // Белый прямоугольник с blur эффектом (смещенный)
              Positioned(
                left: -8,
                top: -8,
                right: 8,
                bottom: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
              ),
              // Градиентный слой с padding
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.gradientTopColor, Colors.white],
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(customPadding),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: fontSize,
                      height: 1.4,
                      fontFamily: GoogleFonts.notoNaskhArabic().fontFamily,
                    ),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        foreground: Paint()
                          ..color = Colors.black87
                          ..style = PaintingStyle.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
