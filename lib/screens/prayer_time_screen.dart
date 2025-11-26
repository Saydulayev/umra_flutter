import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import '../services/prayer_time_service.dart';

class PrayerTimeScreen extends StatefulWidget {
  const PrayerTimeScreen({super.key});

  @override
  State<PrayerTimeScreen> createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
  PrayerTimeData? _prayerTimes;
  String _nextPrayerName = 'Fajr';
  Duration _timeUntilNextPrayer = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updatePrayerTimes();
    // Обновляем каждую секунду
    Future.microtask(() => _startTimer());
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateCountdown();
        _startTimer();
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось загрузить время молитв. Пожалуйста, попробуйте позже.'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;

    if (_prayerTimes == null) {
      return Scaffold(
        backgroundColor: theme.lightBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.lightBackgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.primaryColor),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                          'Mecca',
                          style: GoogleFonts.greatVibes(
                            fontSize: 36,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getIslamicDate(),
                          style: GoogleFonts.greatVibes(
                            fontSize: 36,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getIslamicYear(),
                          style: GoogleFonts.greatVibes(
                            fontSize: 36,
                            color: Colors.black87,
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
                        '$_nextPrayerName in ${_formatDuration(_timeUntilNextPrayer)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                          'Fajr',
                          _formatTime(_prayerTimes!.fajr),
                        ),
                        _buildCapsuleStyled(
                          theme: theme,
                          child: _buildPrayerTimeRow(
                            'Sunrise',
                            _formatTime(_prayerTimes!.sunrise),
                          ),
                        ),
                        _buildPrayerTimeRow(
                          'Dhuhr',
                          _formatTime(_prayerTimes!.dhuhr),
                        ),
                        _buildPrayerTimeRow(
                          'Asr',
                          _formatTime(_prayerTimes!.asr),
                        ),
                        _buildPrayerTimeRow(
                          'Maghrib',
                          _formatTime(_prayerTimes!.maghrib),
                        ),
                        _buildPrayerTimeRow(
                          'Isha',
                          _formatTime(_prayerTimes!.isha),
                        ),
                        if (PrayerTimeService.getQiyamTime() != null)
                          _buildCapsuleStyled(
                            theme: theme,
                            child: _buildPrayerTimeRow(
                              'Qiyam',
                              _formatTime(PrayerTimeService.getQiyamTime()!),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
                        color: Colors.white.withValues(alpha: 0.9),
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
                    colors: [theme.gradientTopColor, Colors.white],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
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
                        color: Colors.white.withValues(alpha: 0.9),
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
                    colors: [theme.gradientTopColor, Colors.white],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
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
                      color: Colors.white.withValues(alpha: 0.9),
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
                  colors: [theme.gradientTopColor, Colors.white],
                ),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.08),
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

  Widget _buildPrayerTimeRow(String prayerName, String prayerTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            prayerTime,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
