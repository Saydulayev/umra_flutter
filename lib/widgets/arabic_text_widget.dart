import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ArabicTextWidget extends StatelessWidget {
  final String text;

  const ArabicTextWidget({super.key, required this.text});

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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(contentPadding),
        decoration: BoxDecoration(
          color: theme.lightBackgroundColor,
          borderRadius: BorderRadius.circular(cornerRadius),
          border: Border.all(color: theme.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.cardShadowColor,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'KFGQPCUthmanTahaNaskh',
            fontSize: fontSize,
            color: theme.textColor,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
