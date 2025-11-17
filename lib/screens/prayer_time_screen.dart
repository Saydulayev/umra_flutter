import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../services/prayer_time_service.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    if (_prayerTimes == null) {
      return Scaffold(
        backgroundColor: theme.lightBackgroundColor,
        appBar: AppBar(
          title: const Text('Prayer Times'),
          backgroundColor: theme.lightBackgroundColor,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        title: const Text('Prayer Times'),
        backgroundColor: theme.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Местоположение и дата
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Mecca, ',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: 'Savoye LET',
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _getIslamicDate(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontFamily: 'Savoye LET',
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              // Следующая молитва
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.gradientTopColor, Colors.white],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$_nextPrayerName in ${_formatDuration(_timeUntilNextPrayer)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Список времени молитв
              _buildPrayerTimeRow(
                'Fajr',
                _formatTime(_prayerTimes!.fajr),
                theme,
              ),
              const SizedBox(height: 8),
              _buildPrayerTimeRow(
                'Sunrise',
                _formatTime(_prayerTimes!.sunrise),
                theme,
                isSpecial: true,
              ),
              const SizedBox(height: 8),
              _buildPrayerTimeRow(
                'Dhuhr',
                _formatTime(_prayerTimes!.dhuhr),
                theme,
              ),
              const SizedBox(height: 8),
              _buildPrayerTimeRow('Asr', _formatTime(_prayerTimes!.asr), theme),
              const SizedBox(height: 8),
              _buildPrayerTimeRow(
                'Maghrib',
                _formatTime(_prayerTimes!.maghrib),
                theme,
              ),
              const SizedBox(height: 8),
              _buildPrayerTimeRow(
                'Isha',
                _formatTime(_prayerTimes!.isha),
                theme,
              ),
              const SizedBox(height: 8),
              if (PrayerTimeService.getQiyamTime() != null)
                _buildPrayerTimeRow(
                  'Qiyam',
                  _formatTime(PrayerTimeService.getQiyamTime()!),
                  theme,
                  isSpecial: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimeRow(
    String prayerName,
    String prayerTime,
    theme, {
    bool isSpecial = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isSpecial
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withOpacity(0.2),
                  theme.gradientTopColor,
                ],
              )
            : null,
        color: isSpecial ? null : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            prayerTime,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSpecial ? theme.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
