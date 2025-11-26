import 'package:flutter/foundation.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import 'package:hijri_date/hijri_date.dart';

class PrayerTimeData {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  PrayerTimeData({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });
}

class PrayerTimeService {
  // Координаты Мекки
  static const double meccaLatitude = 21.4225;
  static const double meccaLongitude = 39.8262;
  
  // Часовой пояс Мекки (UTC+3)
  static const int meccaTimeZoneOffset = 3;
  
  // Получить время молитв на сегодня
  static PrayerTimeData? getTodayPrayerTimes() {
    try {
    final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      
      // Координаты Мекки
      final coordinates = Coordinates(meccaLatitude, meccaLongitude);
      
      // Параметры расчета: UmmAlQura с мадхабом Shafi
      final params = CalculationMethodParameters.ummAlQura();
      params.madhab = Madhab.shafi;
      
      // Получаем время молитв из adhan_dart
      // adhan_dart возвращает DateTime в локальном времени устройства
      // Но для координат Мекки это будет время в часовом поясе Мекки
      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
      );
      
      // adhan_dart возвращает время в UTC, нужно конвертировать в часовой пояс Мекки (UTC+3)
      final meccaOffset = Duration(hours: meccaTimeZoneOffset);
      
      return PrayerTimeData(
        fajr: prayerTimes.fajr.add(meccaOffset),
        sunrise: prayerTimes.sunrise.add(meccaOffset),
        dhuhr: prayerTimes.dhuhr.add(meccaOffset),
        asr: prayerTimes.asr.add(meccaOffset),
        maghrib: prayerTimes.maghrib.add(meccaOffset),
        isha: prayerTimes.isha.add(meccaOffset),
      );
    } catch (e) {
      debugPrint(
        'Error calculating today prayer times for Mecca: $e. '
        'Coordinates: ($meccaLatitude, $meccaLongitude)',
      );
      return null;
    }
  }
  
  // Получить время молитв на завтра
  static PrayerTimeData? getTomorrowPrayerTimes() {
    try {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
      final date = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      
      // Координаты Мекки
      final coordinates = Coordinates(meccaLatitude, meccaLongitude);
      
      // Параметры расчета: UmmAlQura с мадхабом Shafi
      final params = CalculationMethodParameters.ummAlQura();
      params.madhab = Madhab.shafi;
      
      // Получаем время молитв из adhan_dart
      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
      );
      
      // adhan_dart возвращает время в UTC, нужно конвертировать в часовой пояс Мекки (UTC+3)
      final meccaOffset = Duration(hours: meccaTimeZoneOffset);
      
      return PrayerTimeData(
        fajr: prayerTimes.fajr.add(meccaOffset),
        sunrise: prayerTimes.sunrise.add(meccaOffset),
        dhuhr: prayerTimes.dhuhr.add(meccaOffset),
        asr: prayerTimes.asr.add(meccaOffset),
        maghrib: prayerTimes.maghrib.add(meccaOffset),
        isha: prayerTimes.isha.add(meccaOffset),
      );
    } catch (e) {
      debugPrint(
        'Error calculating tomorrow prayer times for Mecca: $e. '
        'Coordinates: ($meccaLatitude, $meccaLongitude)',
      );
      return null;
    }
  }
  
  // Получить время Qiyam (последняя треть ночи)
  static DateTime? getQiyamTime() {
    final today = getTodayPrayerTimes();
    final tomorrow = getTomorrowPrayerTimes();
    
    if (today == null || tomorrow == null) return null;
    
    final maghribToFajrInterval = tomorrow.fajr.difference(today.maghrib);
    final lastThirdStart = today.maghrib.add(
      Duration(milliseconds: (maghribToFajrInterval.inMilliseconds * 2 / 3).round()),
    );
    
    return lastThirdStart;
  }
  
  // Получить текущее время в часовом поясе Мекки (UTC+3)
  static DateTime _getCurrentMeccaTime() {
    final now = DateTime.now().toUtc();
    return now.add(Duration(hours: meccaTimeZoneOffset));
  }
  
  // Получить название следующей молитвы
  static String getNextPrayerName(PrayerTimeData prayerTimes) {
    final now = _getCurrentMeccaTime();
    final prayers = [
      ('Fajr', prayerTimes.fajr),
      ('Sunrise', prayerTimes.sunrise),
      ('Dhuhr', prayerTimes.dhuhr),
      ('Asr', prayerTimes.asr),
      ('Maghrib', prayerTimes.maghrib),
      ('Isha', prayerTimes.isha),
    ];
    
    for (var prayer in prayers) {
      if (prayer.$2.isAfter(now)) {
        return prayer.$1;
      }
    }
    
    // Если все молитвы прошли, следующая - Fajr завтра
    return 'Fajr';
  }
  
  // Получить время до следующей молитвы
  static Duration getTimeUntilNextPrayer(PrayerTimeData prayerTimes) {
    final now = _getCurrentMeccaTime();
    final nextPrayerName = getNextPrayerName(prayerTimes);
    
    DateTime nextPrayerTime;
    switch (nextPrayerName) {
      case 'Fajr':
        // Проверяем, прошла ли уже сегодняшняя Fajr
        if (prayerTimes.fajr.isBefore(now)) {
          // Берем Fajr завтра
          final tomorrow = getTomorrowPrayerTimes();
          nextPrayerTime = tomorrow?.fajr ?? prayerTimes.fajr.add(const Duration(days: 1));
        } else {
        nextPrayerTime = prayerTimes.fajr;
        }
        break;
      case 'Sunrise':
        nextPrayerTime = prayerTimes.sunrise;
        break;
      case 'Dhuhr':
        nextPrayerTime = prayerTimes.dhuhr;
        break;
      case 'Asr':
        nextPrayerTime = prayerTimes.asr;
        break;
      case 'Maghrib':
        nextPrayerTime = prayerTimes.maghrib;
        break;
      case 'Isha':
        nextPrayerTime = prayerTimes.isha;
        break;
      default:
        // Если все молитвы прошли, следующая - Fajr завтра
        final tomorrow = getTomorrowPrayerTimes();
        nextPrayerTime = tomorrow?.fajr ?? prayerTimes.fajr.add(const Duration(days: 1));
    }
    
    return nextPrayerTime.difference(now);
  }
  
  // Форматировать время в формате HH:mm
  static String formatPrayerTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
  
  // Получить исламскую дату по календарю UmmAlQura
  static String getIslamicDate() {
    try {
      final now = DateTime.now();
      
      // Используем библиотеку hijri_date для конвертации в исламский календарь
      final hijriDate = HijriDate.fromDate(now);
      
      // Форматируем дату в формате "d MMMM" (день и месяц)
      // Используем longMonthName из библиотеки для правильного названия месяца
      return '${hijriDate.hDay} ${hijriDate.longMonthName}';
    } catch (e) {
      // В случае ошибки возвращаем григорианскую дату
      return DateFormat('d MMMM', 'en').format(DateTime.now());
    }
  }
  
  // Получить исламский год
  static String getIslamicYear() {
    try {
      final now = DateTime.now();
      final hijriDate = HijriDate.fromDate(now);
      return hijriDate.hYear.toString();
    } catch (e) {
      // В случае ошибки возвращаем григорианский год
      return DateTime.now().year.toString();
    }
  }
}
