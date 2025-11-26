import 'package:flutter/material.dart';
import '../../widgets/arabic_text_widget.dart';
import '../../widgets/player_widget.dart';
import '../../constants/app_constants.dart';

/// Виджет для секции с арабским текстом и плеером
class StepArabicSection extends StatelessWidget {
  final String arabicText;
  final String audioFileName;

  const StepArabicSection({
    super.key,
    required this.arabicText,
    required this.audioFileName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArabicTextWidget(text: arabicText),
        PlayerWidget(fileName: audioFileName),
        const SizedBox(height: AppDimensions.paddingSmall),
      ],
    );
  }
}

