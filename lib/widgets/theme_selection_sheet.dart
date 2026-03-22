import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';

class ThemeSelectionSheet extends StatelessWidget {
  const ThemeSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    final hPad = isTablet ? 28.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.textColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header: title + close button
          Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 28 : 20,
              isTablet ? 22 : 18,
              isTablet ? 28 : 20,
              isTablet ? 20 : 16,
            ),
            child: Row(
              children: [
                Text(
                  l10n.themeSelectTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.cancel,
                    size: 26,
                    color: theme.textColor.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
          ),

          // Theme list — single card with dividers between rows
          Padding(
            padding: EdgeInsets.fromLTRB(
              hPad,
              0,
              hPad,
              (isTablet ? 32.0 : 24.0) + bottomPadding,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: theme.isEmerald ? null : theme.lightBackgroundColor,
                gradient: theme.cardGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.borderColor, width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildRows(
                  context: context,
                  themeProvider: themeProvider,
                  theme: theme,
                  l10n: l10n,
                  isTablet: isTablet,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRows({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required AppTheme theme,
    required AppLocalizations l10n,
    required bool isTablet,
  }) {
    final themes = AppTheme.values;
    final widgets = <Widget>[];

    for (int i = 0; i < themes.length; i++) {
      final appTheme = themes[i];
      final isSelected = themeProvider.selectedTheme == appTheme;

      widgets.add(
        _ThemeRow(
          appTheme: appTheme,
          themeName: _getThemeName(appTheme, l10n),
          isSelected: isSelected,
          currentTheme: theme,
          isTablet: isTablet,
          onTap: () {
            themeProvider.setTheme(appTheme);
            Navigator.pop(context);
          },
        ),
      );

      if (i < themes.length - 1) {
        widgets.add(
          Divider(
            height: 1,
            thickness: 0.5,
            indent: isTablet ? 20 : 16,
            endIndent: isTablet ? 20 : 16,
            color: theme.borderColor,
          ),
        );
      }
    }

    return widgets;
  }

  String _getThemeName(AppTheme theme, AppLocalizations l10n) {
    switch (theme) {
      case AppTheme.nur:
        return l10n.themeHeavenly;
      case AppTheme.layl:
        return l10n.themeOasis;
      case AppTheme.emerald:
        return l10n.themeGold;
    }
  }
}

class _ThemeRow extends StatelessWidget {
  final AppTheme appTheme;
  final String themeName;
  final bool isSelected;
  final AppTheme currentTheme;
  final bool isTablet;
  final VoidCallback onTap;

  const _ThemeRow({
    required this.appTheme,
    required this.themeName,
    required this.isSelected,
    required this.currentTheme,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 16,
          vertical: isTablet ? 16 : 14,
        ),
        child: Row(
          children: [
            _ThemeCircle(appTheme: appTheme, size: isTablet ? 22 : 18),
            SizedBox(width: isTablet ? 14 : 12),
            Text(
              themeName,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: currentTheme.textColor,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.check,
                color: currentTheme.primaryColor,
                size: isTablet ? 20 : 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCircle extends StatelessWidget {
  final AppTheme appTheme;
  final double size;

  const _ThemeCircle({required this.appTheme, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors(),
        ),
        border: _needsBorder()
            ? Border.all(
                color: Colors.black.withValues(alpha: 0.12),
                width: 0.5,
              )
            : null,
      ),
    );
  }

  List<Color> _gradientColors() {
    switch (appTheme) {
      case AppTheme.nur:
        // Light: white → light gray
        return [Colors.white, const Color(0xFFE0E0E2)];
      case AppTheme.layl:
        // Dark: near-black → dark charcoal
        return [const Color(0xFF101010), const Color(0xFF2D2D30)];
      case AppTheme.emerald:
        // Emerald: dark emerald bg → green accent
        return [const Color(0xFF0C0F0E), appTheme.primaryColor];
    }
  }

  bool _needsBorder() => appTheme == AppTheme.nur;
}
