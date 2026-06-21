import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import '../utils/platform_icons.dart';
import '../widgets/app_card.dart';
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
      // Прокрутка нужна, чтобы лист не переполнялся по высоте, когда
      // места мало (например, в landscape, где высота bottom sheet ограничена).
      child: SingleChildScrollView(
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
                    PlatformIcons.cancel,
                    size: 26,
                    color: theme.textColor.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
          ),

          // Theme list — single card with dividers
          Padding(
            padding: EdgeInsets.fromLTRB(
              hPad,
              0,
              hPad,
              (isTablet ? 32.0 : 24.0) + bottomPadding,
            ),
            child: AppCard(
              theme: theme,
              cornerRadius: 18,
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
    final preferences = ThemePreference.values;
    final widgets = <Widget>[];

    for (int i = 0; i < preferences.length; i++) {
      final pref = preferences[i];
      final isSelected = themeProvider.themePreference == pref;

      widgets.add(
        _ThemeRow(
          preference: pref,
          themeName: _getThemeName(pref, l10n),
          isSelected: isSelected,
          currentTheme: theme,
          isTablet: isTablet,
          onTap: () {
            themeProvider.setTheme(pref);
            Navigator.pop(context);
          },
        ),
      );

      if (i < preferences.length - 1) {
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

  String _getThemeName(ThemePreference pref, AppLocalizations l10n) {
    switch (pref) {
      case ThemePreference.auto:
        return l10n.themeAuto;
      case ThemePreference.nur:
        return l10n.themeHeavenly;
      case ThemePreference.layl:
        return l10n.themeOasis;
      case ThemePreference.emerald:
        return l10n.themeGold;
    }
  }
}

class _ThemeRow extends StatelessWidget {
  final ThemePreference preference;
  final String themeName;
  final bool isSelected;
  final AppTheme currentTheme;
  final bool isTablet;
  final VoidCallback onTap;

  const _ThemeRow({
    required this.preference,
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
            _ThemeCircle(preference: preference, size: isTablet ? 22 : 18),
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
                PlatformIcons.check,
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
  final ThemePreference preference;
  final double size;

  const _ThemeCircle({required this.preference, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _gradient(),
        border: _hasBorder()
            ? Border.all(
                color: Colors.black.withValues(alpha: 0.14),
                width: 0.5,
              )
            : null,
      ),
    );
  }

  LinearGradient _gradient() {
    switch (preference) {
      case ThemePreference.auto:
        // Nur backgroundColor → Layl backgroundColor, left → right (как в SwiftUI)
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFF7F7F7), Color(0xFF101010)],
        );
      case ThemePreference.nur:
        // white → light gray, top-left → bottom-right
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFE0E0E5)],
        );
      case ThemePreference.layl:
        // dark → charcoal, top-left → bottom-right
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101010), Color(0xFF2E2E33)],
        );
      case ThemePreference.emerald:
        // emerald bg → primaryColor, top-left → bottom-right
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C0F0E), Color(0xFF32C698)],
        );
    }
  }

  bool _hasBorder() =>
      preference == ThemePreference.nur || preference == ThemePreference.auto;
}
