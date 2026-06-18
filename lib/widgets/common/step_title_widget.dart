import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/font_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/responsive_metrics.dart';

/// Виджет для заголовков шагов
class StepTitleWidget extends StatelessWidget {
  final String text;

  const StepTitleWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final metrics = ResponsiveMetrics.of(context);

    return Text(
      text.trim(),
      style: fontProvider.getTextStyle(
        fontSize: metrics.stepTitleFontSize,
        fontWeight: FontWeight.bold,
        color: theme.textColor,
      ),
    );
  }
}
