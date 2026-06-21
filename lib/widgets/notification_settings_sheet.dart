import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/platform_icons.dart';
import '../providers/notification_preferences_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../services/prayer_time_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_card.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';

class NotificationSettingsSheet extends StatelessWidget {
  const NotificationSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final notifs = Provider.of<NotificationPreferencesProvider>(context);
    final prefs = Provider.of<UserPreferencesProvider>(context);
    final city = prayerCityFromString(prefs.prayerCity);
    final l10n = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final hPad = isTablet ? 28.0 : 20.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Прокрутка нужна, чтобы лист не переполнялся по высоте, когда
      // места мало (например, в landscape).
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.textColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, isTablet ? 28 : 22, hPad, isTablet ? 28 : 24),
            child: Text(
              l10n.notificationSheetTitle,
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Toggle block
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: AppCard(
              theme: theme,
              cornerRadius: 18,
              shadows: [
                BoxShadow(
                  color: theme.isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SwitchRow(
                    label: l10n.thirtyMinuteNotifications,
                    value: notifs.beforeEnabled,
                    theme: theme,
                    isTablet: isTablet,
                    onChanged: (v) async {
                      final granted = await _ensurePermission(context);
                      if (!granted) return;
                      await notifs.setBefore(v, city);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: theme.borderColor,
                  ),
                  _SwitchRow(
                    label: l10n.prayerTimeNotifications,
                    value: notifs.atTimeEnabled,
                    theme: theme,
                    isTablet: isTablet,
                    onChanged: (v) async {
                      final granted = await _ensurePermission(context);
                      if (!granted) return;
                      await notifs.setAtTime(v, city);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: theme.borderColor,
                  ),
                  _SwitchRow(
                    label: l10n.sunriseNotifications,
                    value: notifs.sunriseEnabled,
                    theme: theme,
                    isTablet: isTablet,
                    onChanged: (v) => notifs.setSunrise(v, city),
                  ),
                ],
              ),
            ),
          ),

          // Settings link
          Padding(
            padding: EdgeInsets.symmetric(vertical: isTablet ? 28 : 22),
            child: GestureDetector(
              onTap: () => _openSystemSettings(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.notificationSettingsLink,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w500,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    PlatformIcons.settings,
                    color: theme.primaryColor,
                    size: isTablet ? 22 : 19,
                  ),
                ],
              ),
            ),
          ),

          // Divider + Close button
          Divider(height: 1, thickness: 0.5, color: theme.borderColor),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: 18,
                bottom: 18 + bottomPadding,
              ),
              child: Text(
                l10n.close,
                style: TextStyle(
                  fontSize: isTablet ? 19 : 17,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Future<bool> _ensurePermission(BuildContext context) async {
    if (await NotificationService.hasPermission()) return true;
    return await NotificationService.requestPermission();
  }

  Future<void> _openSystemSettings(BuildContext context) async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final dynamic theme;
  final bool isTablet;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.isTablet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 14 : 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 17 : 16,
                fontWeight: FontWeight.w400,
                color: theme.textColor,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }
}
