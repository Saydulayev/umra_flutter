import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';
import '../providers/theme_provider.dart';

class CustomToolbar extends StatelessWidget {
  const CustomToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.text_fields,
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
                    Icons.check,
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


