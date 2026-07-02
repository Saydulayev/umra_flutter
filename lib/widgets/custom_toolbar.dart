import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/font_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/platform_icons.dart';

class CustomToolbar extends StatelessWidget {
  const CustomToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      tooltip: l10n.font,
      icon: Icon(
        PlatformIcons.textFormat,
        color: themeProvider.selectedTheme.textColor,
      ),
      onSelected: (String font) {
        fontProvider.setFont(font);
      },
      itemBuilder: (BuildContext context) {
        return fontProvider.fonts.map((String font) {
          return PopupMenuItem<String>(
            value: font,
            child: Row(
              children: [
                if (fontProvider.selectedFont == font)
                  Icon(
                    PlatformIcons.check,
                    color: themeProvider.selectedTheme.primaryColor,
                    size: 20,
                  )
                else
                  const SizedBox(width: 20),
                Text(font),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
