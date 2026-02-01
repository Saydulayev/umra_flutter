import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../models/app_theme.dart';
import '../services/prayer_time_service.dart';
import '../l10n/app_localizations.dart';

class PrayerTimeScreen extends StatefulWidget {
  const PrayerTimeScreen({super.key});

  @override
  State<PrayerTimeScreen> createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
  PrayerTimeData? _prayerTimes;
  String _nextPrayerName = 'Fajr';
  Duration _timeUntilNextPrayer = Duration.zero;
  String _currentCityKey = 'mecca';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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

  // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Добавляем dispose для отмены таймера
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

  String _cityTitle(AppLocalizations l10n) {
    return _currentCityKey == 'medina' ? l10n.medina : l10n.mecca;
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
      ),
      body: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 16,
                bottom: bottomPadding + 16,
                left: 16,
                right: 16,
              ),
              child: _buildTransparentStyled(
                theme: theme,
                child: Column(
                  children: [
                    // Заголовок (календарь): город и дата — фиксированная высота, чтобы не сдвигалось при смене Мекка/Медина
                    SizedBox(
                      height: 44,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _cityTitle(l10n),
                              style: GoogleFonts.greatVibes(
                                fontSize: 36,
                                color: theme.textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getIslamicDate(),
                              style: GoogleFonts.greatVibes(
                                fontSize: 36,
                                color: theme.textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getIslamicYear(),
                              style: GoogleFonts.greatVibes(
                                fontSize: 36,
                                color: theme.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Дивайдер внизу календаря (тонкая светло-серая линия)
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.textColor.withValues(alpha: 0.12),
                      ),
                    ),
                    // Переключатель города: Мекка | Медина
                    _buildCitySegmentedControl(
                      context: context,
                      theme: theme,
                      l10n: l10n,
                      selectedCity: prefs.prayerCity,
                      onCityChanged: _onCityChanged,
                    ),
                    // Блок обратного отсчёта — форма «таблетки», сильное скругление
                    _buildCountdownPill(theme: theme, l10n: l10n),
                    // Список времени намазов с разделителями между строками
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _buildPrayerListWithDividers(theme, l10n),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransparentStyled({
    required AppTheme theme,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.isDark
                  ? theme.textColor.withValues(alpha: 0.15)
                  : theme.textColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(3, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Фоновый цвет
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              // Белый прямоугольник с blur эффектом (смещенный)
              Positioned(
                left: -8,
                top: -8,
                right: 8,
                bottom: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.lightBackgroundColor.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ),
              // Градиентный слой
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.gradientTopColor,
                      theme.lightBackgroundColor,
                    ],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.borderColor,
                      width: 1,
                    ),
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Блок обратного отсчёта до следующего намаза — в рамке как у арабского текста (градиентная обводка, скругление).
  /// Тень внизу слева создаёт эффект «витания». Все слои одного размера — ровное закругление без изгибов.
  Widget _buildCountdownPill({required AppTheme theme, required AppLocalizations l10n}) {
    const radius = 50.0;
    const borderWidth = 2.0;
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 24),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: theme.isDark
                ? theme.textColor.withValues(alpha: 0.25)
                : theme.textColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(-4, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: theme.textBackgroundColor),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.lightBackgroundColor.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(borderWidth),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius - borderWidth),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.gradientTopColor,
                        theme.lightBackgroundColor,
                      ],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius - borderWidth),
                      color: theme.lightBackgroundColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                    '${_getLocalizedPrayerName(_nextPrayerName, l10n)} ${l10n.prayerTimeIn} ${_formatDuration(_timeUntilNextPrayer)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  /// Список намазов (без линий между строками).
  List<Widget> _buildPrayerListWithDividers(AppTheme theme, AppLocalizations l10n) {
    final rows = <Widget>[
      _buildPrayerTimeRow(l10n.fajr, _formatTime(_prayerTimes!.fajr), textColor: theme.textColor, theme: theme),
      _buildCapsuleStyled(
        theme: theme,
        child: _buildPrayerTimeRow(
          l10n.sunrise,
          _formatTime(_prayerTimes!.sunrise),
          textColor: theme.textColor,
          theme: theme,
        ),
      ),
      _buildPrayerTimeRow(l10n.dhuhr, _formatTime(_prayerTimes!.dhuhr), textColor: theme.textColor, theme: theme),
      _buildPrayerTimeRow(l10n.asr, _formatTime(_prayerTimes!.asr), textColor: theme.textColor, theme: theme),
      _buildPrayerTimeRow(l10n.maghrib, _formatTime(_prayerTimes!.maghrib), textColor: theme.textColor, theme: theme),
      _buildPrayerTimeRow(l10n.isha, _formatTime(_prayerTimes!.isha), textColor: theme.textColor, theme: theme),
    ];
    if (PrayerTimeService.getQiyamTime(prayerCityFromString(_currentCityKey)) != null) {
      rows.add(
        _buildCapsuleStyled(
          theme: theme,
          child: _buildPrayerTimeRow(
            l10n.qiyam,
            _formatTime(PrayerTimeService.getQiyamTime(prayerCityFromString(_currentCityKey))!),
            textColor: theme.textColor,
            theme: theme,
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildCapsuleStyled({required AppTheme theme, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Фоновый цвет
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            // Белый прямоугольник с blur эффектом (смещенный)
            Positioned(
              left: -8,
              top: -8,
              right: 8,
              bottom: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.lightBackgroundColor.withValues(alpha: 0.9),
                      ),
                    ),
                ),
              ),
            ),
            // Градиентный слой
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.gradientTopColor, theme.lightBackgroundColor],
                ),
                border: Border.all(
                  color: theme.borderColor,
                  width: 1,
                ),
              ),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeRow(
    String prayerName,
    String prayerTime, {
    Color? textColor,
    AppTheme? theme,
  }) {
    final color = textColor ?? (theme?.textColor ?? const Color(0xFF1F2937));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            prayerTime,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Переключатель города: цвета из темы (активный/неактивный фон и текст, тень).
  Widget _buildCitySegmentedControl({
    required BuildContext context,
    required AppTheme theme,
    required AppLocalizations l10n,
    required String selectedCity,
    required Future<void> Function(String) onCityChanged,
  }) {
    final inactiveBg = theme.gradientTopColor;
    final activeBg = theme.textColor;
    final inactiveText = theme.secondaryTextColor;
    final activeText = theme.lightBackgroundColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: inactiveBg,
        border: Border.all(color: theme.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.isDark
                ? theme.textColor.withValues(alpha: 0.12)
                : theme.textColor.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onCityChanged('mecca'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: selectedCity == 'mecca' ? activeBg : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.mecca,
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
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: selectedCity == 'medina' ? activeBg : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.medina,
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
