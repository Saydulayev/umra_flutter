import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import 'package:hijri_date/hijri_date.dart';

import '../utils/app_logger.dart';

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

/// Город для расчёта времени намаза
enum PrayerCity { mecca, medina }

extension PrayerCityExtension on PrayerCity {
  String get value => name;
}

PrayerCity prayerCityFromString(String? value) {
  if (value == PrayerCity.medina.value) return PrayerCity.medina;
  return PrayerCity.mecca;
}

class PrayerTimeService {
  // Координаты Мекки
  static const double meccaLatitude = 21.4225;
  static const double meccaLongitude = 39.8262;

  // Координаты Медины
  static const double medinaLatitude = 24.4672;
  static const double medinaLongitude = 39.6111;

  // Часовой пояс (Мекка и Медина: Asia/Riyadh UTC+3)
  static const int meccaTimeZoneOffset = 3;

  static Coordinates _coordinatesFor(PrayerCity city) {
    switch (city) {
      case PrayerCity.mecca:
        return Coordinates(meccaLatitude, meccaLongitude);
      case PrayerCity.medina:
        return Coordinates(medinaLatitude, medinaLongitude);
    }
  }

  // Получить время молитв на сегодня для выбранного города
  static PrayerTimeData? getTodayPrayerTimes([
    PrayerCity city = PrayerCity.mecca,
  ]) {
    try {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      final coordinates = _coordinatesFor(city);

      final params = CalculationMethodParameters.ummAlQura();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
      );

      final offset = Duration(hours: meccaTimeZoneOffset);

      return PrayerTimeData(
        fajr: prayerTimes.fajr.add(offset),
        sunrise: prayerTimes.sunrise.add(offset),
        dhuhr: prayerTimes.dhuhr.add(offset),
        asr: prayerTimes.asr.add(offset),
        maghrib: prayerTimes.maghrib.add(offset),
        isha: prayerTimes.isha.add(offset),
      );
    } catch (e) {
      AppLogger.e('Error calculating today prayer times for $city', e);
      return null;
    }
  }

  // Получить время молитв на завтра для выбранного города
  static PrayerTimeData? getTomorrowPrayerTimes([
    PrayerCity city = PrayerCity.mecca,
  ]) {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final date = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      final coordinates = _coordinatesFor(city);

      final params = CalculationMethodParameters.ummAlQura();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
      );

      final offset = Duration(hours: meccaTimeZoneOffset);

      return PrayerTimeData(
        fajr: prayerTimes.fajr.add(offset),
        sunrise: prayerTimes.sunrise.add(offset),
        dhuhr: prayerTimes.dhuhr.add(offset),
        asr: prayerTimes.asr.add(offset),
        maghrib: prayerTimes.maghrib.add(offset),
        isha: prayerTimes.isha.add(offset),
      );
    } catch (e) {
      AppLogger.e('Error calculating tomorrow prayer times for $city', e);
      return null;
    }
  }

  // Получить время Qiyam (последняя треть ночи) для выбранного города
  static DateTime? getQiyamTime([PrayerCity city = PrayerCity.mecca]) {
    final today = getTodayPrayerTimes(city);
    final tomorrow = getTomorrowPrayerTimes(city);

    if (today == null || tomorrow == null) return null;

    final maghribToFajrInterval = tomorrow.fajr.difference(today.maghrib);
    final lastThirdStart = today.maghrib.add(
      Duration(
        milliseconds: (maghribToFajrInterval.inMilliseconds * 2 / 3).round(),
      ),
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

  // Получить время до следующей молитвы (city нужен для Fajr завтра)
  static Duration getTimeUntilNextPrayer(
    PrayerTimeData prayerTimes, [
    PrayerCity city = PrayerCity.mecca,
  ]) {
    final now = _getCurrentMeccaTime();
    final nextPrayerName = getNextPrayerName(prayerTimes);

    DateTime nextPrayerTime;
    switch (nextPrayerName) {
      case 'Fajr':
        if (prayerTimes.fajr.isBefore(now)) {
          final tomorrow = getTomorrowPrayerTimes(city);
          nextPrayerTime =
              tomorrow?.fajr ?? prayerTimes.fajr.add(const Duration(days: 1));
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
        final tomorrow = getTomorrowPrayerTimes(city);
        nextPrayerTime =
            tomorrow?.fajr ?? prayerTimes.fajr.add(const Duration(days: 1));
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
