// TODO: Реализовать расчет времени намаза
// Можно использовать пакет muslim_calendar или написать собственный расчет
class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  PrayerTimes({
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
  
  // TODO: Реализовать расчет времени намаза для Мекки
  // Временно возвращаем заглушку
  static PrayerTimes? getTodayPrayerTimes() {
    // Это заглушка - нужно реализовать правильный расчет
    final now = DateTime.now();
    return PrayerTimes(
      fajr: now.copyWith(hour: 4, minute: 30),
      sunrise: now.copyWith(hour: 5, minute: 45),
      dhuhr: now.copyWith(hour: 12, minute: 0),
      asr: now.copyWith(hour: 15, minute: 30),
      maghrib: now.copyWith(hour: 18, minute: 15),
      isha: now.copyWith(hour: 19, minute: 45),
    );
  }
  
  static PrayerTimes? getTomorrowPrayerTimes() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return PrayerTimes(
      fajr: tomorrow.copyWith(hour: 4, minute: 30),
      sunrise: tomorrow.copyWith(hour: 5, minute: 45),
      dhuhr: tomorrow.copyWith(hour: 12, minute: 0),
      asr: tomorrow.copyWith(hour: 15, minute: 30),
      maghrib: tomorrow.copyWith(hour: 18, minute: 15),
      isha: tomorrow.copyWith(hour: 19, minute: 45),
    );
  }
  
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
  
  static String getNextPrayerName(PrayerTimes prayerTimes) {
    final now = DateTime.now();
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
    
    return 'Fajr';
  }
  
  static Duration getTimeUntilNextPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    final nextPrayerName = getNextPrayerName(prayerTimes);
    
    DateTime nextPrayerTime;
    switch (nextPrayerName) {
      case 'Fajr':
        nextPrayerTime = prayerTimes.fajr;
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
        nextPrayerTime = prayerTimes.fajr.add(const Duration(days: 1));
    }
    
    return nextPrayerTime.difference(now);
  }
}
