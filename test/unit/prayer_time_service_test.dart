import 'package:flutter_test/flutter_test.dart';
import 'package:umra_flutter/services/prayer_time_service.dart';

/// Фиксированная дата для детерминированных расчётов.
/// 15 марта 2025 — вдали от границ рамадана/переходов, чтобы тесты
/// не зависели от календарных особенностей конкретного года.
final _fixedDate = DateTime(2025, 3, 15);

PrayerTimeData _times({
  required DateTime fajr,
  required DateTime sunrise,
  required DateTime dhuhr,
  required DateTime asr,
  required DateTime maghrib,
  required DateTime isha,
}) => PrayerTimeData(
  fajr: fajr,
  sunrise: sunrise,
  dhuhr: dhuhr,
  asr: asr,
  maghrib: maghrib,
  isha: isha,
);

/// Реалистичный набор времён для тестов getNextPrayerName /
/// getTimeUntilNextPrayer (значения не обязаны совпадать с расчётными —
/// важен только порядок).
final _sample = _times(
  fajr: DateTime(2025, 3, 15, 5, 0),
  sunrise: DateTime(2025, 3, 15, 6, 20),
  dhuhr: DateTime(2025, 3, 15, 12, 25),
  asr: DateTime(2025, 3, 15, 15, 45),
  maghrib: DateTime(2025, 3, 15, 18, 30),
  isha: DateTime(2025, 3, 15, 20, 0),
);

void main() {
  group('getTodayPrayerTimes', () {
    for (final city in PrayerCity.values) {
      test('порядок времён корректен для $city', () {
        final t = PrayerTimeService.getTodayPrayerTimes(city, _fixedDate);
        expect(t, isNotNull);
        expect(t!.fajr.isBefore(t.sunrise), isTrue);
        expect(t.sunrise.isBefore(t.dhuhr), isTrue);
        expect(t.dhuhr.isBefore(t.asr), isTrue);
        expect(t.asr.isBefore(t.maghrib), isTrue);
        expect(t.maghrib.isBefore(t.isha), isTrue);
      });

      test('все времена приходятся на запрошенную дату для $city', () {
        final t = PrayerTimeService.getTodayPrayerTimes(city, _fixedDate);
        expect(t, isNotNull);
        for (final time in [t!.fajr, t.sunrise, t.dhuhr, t.asr, t.maghrib]) {
          expect(time.year, _fixedDate.year);
          expect(time.month, _fixedDate.month);
          expect(time.day, _fixedDate.day);
        }
      });
    }

    test('Мекка и Медина дают разное время (координаты реально используются)', () {
      final mecca = PrayerTimeService.getTodayPrayerTimes(
        PrayerCity.mecca,
        _fixedDate,
      );
      final medina = PrayerTimeService.getTodayPrayerTimes(
        PrayerCity.medina,
        _fixedDate,
      );
      expect(mecca, isNotNull);
      expect(medina, isNotNull);
      // Медина западнее → магриб стабильно позже (~60 сек). Фаджр здесь
      // сознательно НЕ сравниваем: на некоторые даты (в т.ч. 2025-03-15)
      // разница между городами меньше минуты, и после округления до минуты
      // времена совпадают — это не баг, а особенность округления.
      expect(mecca!.maghrib, isNot(equals(medina!.maghrib)));
    });

    test('фаджр в правдоподобном утреннем интервале (тайм-зона применена)', () {
      final t = PrayerTimeService.getTodayPrayerTimes(
        PrayerCity.mecca,
        _fixedDate,
      );
      expect(t, isNotNull);
      // Фаджр в Мекке круглый год между 03:00 и 06:30 по местному (UTC+3).
      // Если смещение UTC+3 потеряется, время уедет на часы — тест поймает.
      expect(t!.fajr.hour, inInclusiveRange(3, 6));
      // Магриб — вечером.
      expect(t.maghrib.hour, inInclusiveRange(17, 20));
    });

    test('результат детерминирован для одной и той же даты', () {
      final a = PrayerTimeService.getTodayPrayerTimes(
        PrayerCity.mecca,
        _fixedDate,
      );
      final b = PrayerTimeService.getTodayPrayerTimes(
        PrayerCity.mecca,
        _fixedDate,
      );
      expect(a!.fajr, b!.fajr);
      expect(a.isha, b.isha);
    });
  });

  group('getTomorrowPrayerTimes', () {
    test('возвращает времена на следующий день', () {
      final tomorrow = PrayerTimeService.getTomorrowPrayerTimes(
        PrayerCity.mecca,
        _fixedDate,
      );
      expect(tomorrow, isNotNull);
      expect(tomorrow!.fajr.day, _fixedDate.day + 1);
    });

    test('совпадает с getTodayPrayerTimes для даты+1', () {
      final tomorrow = PrayerTimeService.getTomorrowPrayerTimes(
        PrayerCity.mecca,
        _fixedDate,
      );
      final nextDay = PrayerTimeService.getTodayPrayerTimes(
        PrayerCity.mecca,
        _fixedDate.add(const Duration(days: 1)),
      );
      expect(tomorrow!.fajr, nextDay!.fajr);
      expect(tomorrow.isha, nextDay.isha);
    });
  });

  group('getQiyamTime', () {
    for (final city in PrayerCity.values) {
      test('начало последней трети ночи между магрибом и фаджром ($city)', () {
        final today = PrayerTimeService.getTodayPrayerTimes(city, _fixedDate)!;
        final tomorrow = PrayerTimeService.getTomorrowPrayerTimes(
          city,
          _fixedDate,
        )!;
        final qiyam = PrayerTimeService.getQiyamTime(city, _fixedDate);

        expect(qiyam, isNotNull);
        expect(qiyam!.isAfter(today.maghrib), isTrue);
        expect(qiyam.isBefore(tomorrow.fajr), isTrue);

        // Ровно 2/3 интервала магриб→фаджр (последняя треть ночи).
        final night = tomorrow.fajr.difference(today.maghrib);
        final expected = today.maghrib.add(
          Duration(milliseconds: (night.inMilliseconds * 2 / 3).round()),
        );
        expect(qiyam, expected);
      });
    }
  });

  group('getNextPrayerName (фиксированное текущее время)', () {
    test('до фаджра → Fajr', () {
      final now = DateTime(2025, 3, 15, 4, 0);
      expect(PrayerTimeService.getNextPrayerName(_sample, now), 'Fajr');
    });

    test('ровно в момент фаджра → уже Sunrise (граница не включается)', () {
      expect(
        PrayerTimeService.getNextPrayerName(_sample, _sample.fajr),
        'Sunrise',
      );
    });

    test('за секунду до магриба → Maghrib', () {
      final now = _sample.maghrib.subtract(const Duration(seconds: 1));
      expect(PrayerTimeService.getNextPrayerName(_sample, now), 'Maghrib');
    });

    test('между зухром и асром → Asr', () {
      final now = DateTime(2025, 3, 15, 14, 0);
      expect(PrayerTimeService.getNextPrayerName(_sample, now), 'Asr');
    });

    test('после иши → Fajr (завтрашний)', () {
      final now = DateTime(2025, 3, 15, 23, 0);
      expect(PrayerTimeService.getNextPrayerName(_sample, now), 'Fajr');
    });
  });

  group('getTimeUntilNextPrayer (фиксированное текущее время)', () {
    test('до фаджра — положительный интервал до сегодняшнего фаджра', () {
      final now = DateTime(2025, 3, 15, 4, 30);
      final d = PrayerTimeService.getTimeUntilNextPrayer(
        _sample,
        PrayerCity.mecca,
        now,
      );
      expect(d, const Duration(minutes: 30));
    });

    test('за секунду до магриба — одна секунда', () {
      final now = _sample.maghrib.subtract(const Duration(seconds: 1));
      final d = PrayerTimeService.getTimeUntilNextPrayer(
        _sample,
        PrayerCity.mecca,
        now,
      );
      expect(d, const Duration(seconds: 1));
    });

    test('после иши — до завтрашнего фаджра, интервал положительный и < суток', () {
      final now = DateTime(2025, 3, 15, 23, 0);
      final d = PrayerTimeService.getTimeUntilNextPrayer(
        _sample,
        PrayerCity.mecca,
        now,
      );
      expect(d.isNegative, isFalse);
      expect(d, lessThan(const Duration(hours: 24)));
      // Завтрашний фаджр — раннее утро: от 23:00 до него 4–8 часов.
      expect(d, greaterThan(const Duration(hours: 3)));
      expect(d, lessThan(const Duration(hours: 9)));
    });
  });

  group('getIslamicDate / getIslamicYear', () {
    test('не падают и возвращают непустые строки', () {
      final date = PrayerTimeService.getIslamicDate(_fixedDate);
      final year = PrayerTimeService.getIslamicYear(_fixedDate);
      expect(date, isNotEmpty);
      expect(year, isNotEmpty);
    });

    test('исламский год для 2025 — 1446 или 1447', () {
      final year = int.tryParse(
        PrayerTimeService.getIslamicYear(_fixedDate),
      );
      expect(year, isNotNull);
      expect(year, inInclusiveRange(1446, 1447));
    });

    test('детерминированы для фиксированной даты', () {
      expect(
        PrayerTimeService.getIslamicDate(_fixedDate),
        PrayerTimeService.getIslamicDate(_fixedDate),
      );
    });
  });

  group('prayerCityFromString', () {
    test('парсит medina, всё остальное — mecca', () {
      expect(prayerCityFromString('medina'), PrayerCity.medina);
      expect(prayerCityFromString('mecca'), PrayerCity.mecca);
      expect(prayerCityFromString(null), PrayerCity.mecca);
      expect(prayerCityFromString('garbage'), PrayerCity.mecca);
    });
  });
}
