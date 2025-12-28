import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
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

  // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Добавляем Timer для правильной отмены
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updatePrayerTimes();
    // Обновляем каждую секунду
    _startTimer();
  }

  void _startTimer() {
    // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Используем Timer.periodic вместо рекурсивного Future.delayed
    _timer?.cancel(); // Отменяем предыдущий таймер, если есть
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCountdown();
      } else {
        timer.cancel();
      }
    });
  }

  void _updatePrayerTimes() {
    setState(() {
      _prayerTimes = PrayerTimeService.getTodayPrayerTimes();
      if (_prayerTimes != null) {
        _nextPrayerName = PrayerTimeService.getNextPrayerName(_prayerTimes!);
        _timeUntilNextPrayer = PrayerTimeService.getTimeUntilNextPrayer(
          _prayerTimes!,
        );
      } else {
        // Показываем ошибку пользователю, если не удалось загрузить время молитв
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
    if (_prayerTimes != null) {
      setState(() {
        _nextPrayerName = PrayerTimeService.getNextPrayerName(_prayerTimes!);
        _timeUntilNextPrayer = PrayerTimeService.getTimeUntilNextPrayer(
          _prayerTimes!,
        );
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                    // Местоположение и дата
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.mecca,
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
                    const Divider(),
                    // Следующая молитва (cardStyled)
                    _buildCardStyled(
                      theme: theme,
                      child: Center(
                        child: Text(
                          '${_getLocalizedPrayerName(_nextPrayerName, l10n)} ${l10n.prayerTimeIn} ${_formatDuration(_timeUntilNextPrayer)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Список времени молитв
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildPrayerTimeRow(
                            l10n.fajr,
                            _formatTime(_prayerTimes!.fajr),
                            textColor: theme.textColor,
                            theme: theme,
                          ),
                          _buildCapsuleStyled(
                            theme: theme,
                            child: _buildPrayerTimeRow(
                              l10n.sunrise,
                              _formatTime(_prayerTimes!.sunrise),
                              textColor: theme.textColor,
                              theme: theme,
                            ),
                          ),
                          _buildPrayerTimeRow(
                            l10n.dhuhr,
                            _formatTime(_prayerTimes!.dhuhr),
                            textColor: theme.textColor,
                            theme: theme,
                          ),
                          _buildPrayerTimeRow(
                            l10n.asr,
                            _formatTime(_prayerTimes!.asr),
                            textColor: theme.textColor,
                            theme: theme,
                          ),
                          _buildPrayerTimeRow(
                            l10n.maghrib,
                            _formatTime(_prayerTimes!.maghrib),
                            textColor: theme.textColor,
                            theme: theme,
                          ),
                          _buildPrayerTimeRow(
                            l10n.isha,
                            _formatTime(_prayerTimes!.isha),
                            textColor: theme.textColor,
                            theme: theme,
                          ),
                          if (PrayerTimeService.getQiyamTime() != null)
                            _buildCapsuleStyled(
                              theme: theme,
                              child: _buildPrayerTimeRow(
                                l10n.qiyam,
                                _formatTime(PrayerTimeService.getQiyamTime()!),
                                textColor: theme.textColor,
                                theme: theme,
                              ),
                            ),
                        ],
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
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: -2,
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

  Widget _buildCardStyled({required AppTheme theme, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Фоновый цвет
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
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
                  padding: const EdgeInsets.all(16),
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
    final color = textColor ?? (theme?.textColor ?? Colors.black87);
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
}
