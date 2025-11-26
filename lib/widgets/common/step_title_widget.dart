import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/font_provider.dart';
import '../../constants/app_constants.dart';

/// Виджет для заголовков шагов
class StepTitleWidget extends StatelessWidget {
  final String text;

  const StepTitleWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);

    return SelectableText(
      text,
      style: fontProvider.getTextStyle(
        fontSize: AppDimensions.fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

