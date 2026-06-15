import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_metrics.dart';
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
    final metrics = ResponsiveMetrics.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: addHorizontalPadding ? 16 : 0),
      child: SizedBox(
        width: double.infinity,
        child: AppCard(
          theme: theme,
          cornerRadius: metrics.arabicCardRadius,
          shadows: [
            BoxShadow(
              color: theme.cardShadowColor,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          child: Padding(
            padding: EdgeInsets.all(metrics.arabicContentPadding),
            child: Text(
              text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              locale: const Locale('ar'),
              style: TextStyle(
                fontFamily: 'KFGQPCUthmanTahaNaskh',
                fontFamilyFallback: const [
                  'Scheherazade New',
                  'Amiri',
                  'Arial',
                ],
                fontSize: metrics.arabicFontSize,
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
