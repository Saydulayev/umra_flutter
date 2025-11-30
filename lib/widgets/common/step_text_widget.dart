import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/font_provider.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_constants.dart';

/// Виджет для текста шагов
class StepTextWidget extends StatelessWidget {
  final String text;

  const StepTextWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;

    return SelectableText(
      text,
      style: fontProvider.getTextStyle(
        fontSize: AppDimensions.fontSizeMedium,
        color: theme.textColor,
      ),
    );
  }
}

