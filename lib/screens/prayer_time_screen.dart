import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../utils/platform_icons.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/notification_preferences_provider.dart';
import '../models/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/notification_settings_sheet.dart';
import '../services/notification_service.dart';
import '../services/prayer_time_service.dart';
import '../utils/responsive_metrics.dart';
import '../l10n/app_localizations.dart';

class PrayerTimeScreen extends StatefulWidget {
  const PrayerTimeScreen({super.key});

  @override
  State<PrayerTimeScreen> createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
  PrayerTimeData? _prayerTimes;
  String _nextPrayerName = '';
  Duration _timeUntilNextPrayer = Duration.zero;
  String _currentCityKey = 'mecca';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _requestNotificationPermission();
  }

  void _requestNotificationPermission() async {
    if (!await NotificationService.hasPermission()) {
      await NotificationService.requestPermission();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prefs = Provider.of<UserPreferencesProvider>(context);
    final cityKey = prefs.prayerCity;
    if (_prayerTimes == null || cityKey != _currentCityKey) {
      _currentCityKey = cityKey;
      _recomputePrayerTimes(prayerCityFromString(cityKey));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCountdown();
      } else {
        timer.cancel();
      }
    });
  }

  void _recomputePrayerTimes(PrayerCity city) {
    setState(() {
      _prayerTimes = PrayerTimeService.getTodayPrayerTimes(city);
      if (_prayerTimes != null) {
        _nextPrayerName = PrayerTimeService.getNextPrayerName(_prayerTimes!);
        _timeUntilNextPrayer = PrayerTimeService.getTimeUntilNextPrayer(
          _prayerTimes!,
          city,
        );
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          final themeProvider = Provider.of<ThemeProvider>(
            context,
            listen: false,
          );
          final theme = themeProvider.selectedTheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.prayerTimeLoadError),
              duration: const Duration(seconds: 3),
              backgroundColor: theme.errorColor,
            ),
          );
        }
      }
    });
  }

  void _updateCountdown() {
    final city = prayerCityFromString(_currentCityKey);
    if (_prayerTimes != null) {
      setState(() {
        _nextPrayerName = PrayerTimeService.getNextPrayerName(_prayerTimes!);
        _timeUntilNextPrayer = PrayerTimeService.getTimeUntilNextPrayer(
          _prayerTimes!,
          city,
        );
      });
    }
  }

  Future<void> _onCityChanged(String cityKey) async {
    final prefs = Provider.of<UserPreferencesProvider>(context, listen: false);
    await prefs.setPrayerCity(cityKey);
    _currentCityKey = cityKey;
    _recomputePrayerTimes(prayerCityFromString(cityKey));
    if (!mounted) return;
    final notifPrefs = Provider.of<NotificationPreferencesProvider>(
      context,
      listen: false,
    );
    await notifPrefs.rescheduleForCity(prayerCityFromString(cityKey));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  String _formatTime(DateTime dateTime) {
    return PrayerTimeService.formatPrayerTime(dateTime);
  }

  String _getIslamicDate() {
    return PrayerTimeService.getIslamicDate();
  }

  String _getIslamicYear() {
    return PrayerTimeService.getIslamicYear();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getLocalizedPrayerName(String englishName, AppLocalizations l10n) {
    switch (englishName) {
      case 'Fajr':
        return l10n.fajr;
      case 'Sunrise':
        return l10n.sunrise;
      case 'Dhuhr':
        return l10n.dhuhr;
      case 'Asr':
        return l10n.asr;
      case 'Maghrib':
        return l10n.maghrib;
      case 'Isha':
        return l10n.isha;
      case 'Qiyam':
        return l10n.qiyam;
      default:
        return englishName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final prefs = Provider.of<UserPreferencesProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    if (_prayerTimes == null) {
      return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          backgroundColor: theme.backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.primaryColor),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
        actions: [
          IconButton(
            icon: Icon(PlatformIcons.notifications, color: theme.primaryColor),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const NotificationSettingsSheet(),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          final metrics = ResponsiveMetrics.of(context);
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  metrics.prayerHorizontalInset,
                  16,
                  metrics.prayerHorizontalInset,
                  bottomPadding + 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32 - bottomPadding,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: metrics.prayerCardMaxWidth,
                      ),
                      child: _buildCard(
                        theme: theme,
                        metrics: metrics,
                        child: Column(
                          children: [
                            // Заголовок: город + дата (Savoye LET 36pt → GreatVibes 36pt)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                '${_getIslamicDate()} ${_getIslamicYear()}',
                                style: GoogleFonts.greatVibes(
                                  fontSize: 36,
                                  color: theme.textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // VStack spacing 12pt + divider
                            const SizedBox(height: 12),
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              color: theme.textColor.withValues(alpha: 0.12),
                            ),
                            const SizedBox(height: 12),
                            // Переключатель города
                            _buildCitySegmentedControl(
                              context: context,
                              theme: theme,
                              l10n: l10n,
                              selectedCity: prefs.prayerCity,
                              onCityChanged: _onCityChanged,
                            ),
                            const SizedBox(height: 12),
                            // Блок обратного отсчёта (cardStyled: vertical 40pt outside)
                            SizedBox(
                              width: double.infinity,
                              child: _buildCountdownCard(
                                theme: theme,
                                l10n: l10n,
                              ),
                            ),
                            // Список намазов (rowsHorizontalPadding 16pt)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: metrics.isCompactPhone ? 8 : 16,
                              ),
                              child: Column(
                                children: _buildPrayerRows(theme, l10n),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Внешняя карточка — аналог iOS transparentStyled (standardCardFrame cornerRadius 20)
  Widget _buildCard({
    required AppTheme theme,
    required ResponsiveMetrics metrics,
    required Widget child,
  }) {
    return AppCard(
      theme: theme,
      cornerRadius: 20,
      shadows: [
        BoxShadow(
          color: theme.cardShadowColor,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: Padding(padding: metrics.prayerCardPadding, child: child),
    );
  }

  /// Блок обратного отсчёта — cardStyled iOS (standardCardFrame cornerRadius 20)
  Widget _buildCountdownCard({
    required AppTheme theme,
    required AppLocalizations l10n,
  }) {
    return AppCard(
      theme: theme,
      cornerRadius: 999,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      shadows: [
        BoxShadow(
          color: theme.cardShadowColor,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          _nextPrayerName.isEmpty
              ? '—'
              : '${_getLocalizedPrayerName(_nextPrayerName, l10n)} ${l10n.prayerTimeIn} ${_formatDuration(_timeUntilNextPrayer)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: theme.isDark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Список намазов. Порядок как в iOS: Fajr → Sunrise (капсула) → Dhuhr → Asr → Maghrib → Isha → Qiyam (капсула).
  List<Widget> _buildPrayerRows(AppTheme theme, AppLocalizations l10n) {
    final qiyamTime = PrayerTimeService.getQiyamTime(
      prayerCityFromString(_currentCityKey),
    );

    Widget plain(String name, String time) =>
        _buildPrayerTimeRow(name, time, theme: theme);

    Widget carded(String name, String time) => _buildCapsuleCard(
      theme: theme,
      child: _buildPrayerTimeRow(name, time, theme: theme),
    );

    return [
      plain(l10n.fajr, _formatTime(_prayerTimes!.fajr)),
      carded(l10n.sunrise, _formatTime(_prayerTimes!.sunrise)),
      plain(l10n.dhuhr, _formatTime(_prayerTimes!.dhuhr)),
      plain(l10n.asr, _formatTime(_prayerTimes!.asr)),
      plain(l10n.maghrib, _formatTime(_prayerTimes!.maghrib)),
      plain(l10n.isha, _formatTime(_prayerTimes!.isha)),
      if (qiyamTime != null) carded(l10n.qiyam, _formatTime(qiyamTime)),
    ];
  }

  /// capsuleStyled — standardCardFrame cornerRadius 20
  Widget _buildCapsuleCard({required AppTheme theme, required Widget child}) {
    return AppCard(
      theme: theme,
      cornerRadius: 20,
      margin: EdgeInsets.zero,
      shadows: [],
      child: child,
    );
  }

  /// Строка намаза — PrayerTimeRow iOS (.callout semibold)
  Widget _buildPrayerTimeRow(
    String prayerName,
    String prayerTime, {
    required AppTheme theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              prayerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: theme.isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            prayerTime,
            maxLines: 1,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: theme.isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Переключатель города
  Widget _buildCitySegmentedControl({
    required BuildContext context,
    required AppTheme theme,
    required AppLocalizations l10n,
    required String selectedCity,
    required Future<void> Function(String) onCityChanged,
  }) {
    final activeBg = theme.primaryColor;
    final activeText = Colors.white;
    final inactiveText = theme.textColor.withValues(alpha: 0.6);

    return AppCard(
      theme: theme,
      cornerRadius: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      shadows: [
        BoxShadow(
          color: theme.cardShadowColor,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onCityChanged('mecca'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: selectedCity == 'mecca' ? activeBg : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.mecca,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selectedCity == 'mecca' ? activeText : inactiveText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onCityChanged('medina'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: selectedCity == 'medina' ? activeBg : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.medina,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selectedCity == 'medina' ? activeText : inactiveText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
