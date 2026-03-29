import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_card.dart';

class ArabicTextWidget extends StatelessWidget {
  final String text;
  final bool addHorizontalPadding;

  const ArabicTextWidget({
    super.key,
    required this.text,
    this.addHorizontalPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    // iOS: 58pt iPad, 38pt iPhone
    final fontSize = isTablet ? 58.0 : 38.0;
    // iOS: 28pt iPad (tinted), 16pt iPhone
    final contentPadding = isTablet ? 28.0 : 18.0;
    // iOS: cornerRadius 24pt iPad, 20pt iPhone
    final cornerRadius = isTablet ? 24.0 : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: addHorizontalPadding ? 16 : 0),
      child: SizedBox(
        width: double.infinity,
        child: AppCard(
        theme: theme,
        cornerRadius: cornerRadius,
        shadows: [
          BoxShadow(
            color: theme.cardShadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        child: Padding(
          padding: EdgeInsets.all(contentPadding),
          child: Text(
            text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            locale: const Locale('ar'),
            style: TextStyle(
              fontFamily: 'KFGQPCUthmanTahaNaskh',
              fontFamilyFallback: const ['Scheherazade New', 'Amiri', 'Arial'],
              fontSize: fontSize,
              color: theme.textColor,
              height: 1.6,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
      ),
    );
  }
}
