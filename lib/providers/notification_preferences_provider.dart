import 'package:flutter/foundation.dart';
import '../repositories/preferences_repository.dart';
import '../constants/app_constants.dart';
import '../services/notification_service.dart';
import '../services/prayer_time_service.dart';

class NotificationPreferencesProvider extends ChangeNotifier {
  bool _atTimeEnabled = false;
  bool _beforeEnabled = false;
  bool _sunriseEnabled = true;

  bool get atTimeEnabled => _atTimeEnabled;
  bool get beforeEnabled => _beforeEnabled;
  bool get sunriseEnabled => _sunriseEnabled;

  final _repo = PreferencesRepository();

  NotificationPreferencesProvider() {
    _load();
  }

  Future<void> _load() async {
    _atTimeEnabled = await _repo.getBool(PrefsKeys.notifAtTime) ?? false;
    _beforeEnabled = await _repo.getBool(PrefsKeys.notifBefore) ?? false;
    _sunriseEnabled = await _repo.getBool(PrefsKeys.notifSunrise) ?? true;
    notifyListeners();
  }

  Future<void> setAtTime(bool v, PrayerCity city) async {
    _atTimeEnabled = v;
    await _repo.setBool(PrefsKeys.notifAtTime, v);
    notifyListeners();
    await _reschedule(city);
  }

  Future<void> setBefore(bool v, PrayerCity city) async {
    _beforeEnabled = v;
    await _repo.setBool(PrefsKeys.notifBefore, v);
    notifyListeners();
    await _reschedule(city);
  }

  Future<void> setSunrise(bool v, PrayerCity city) async {
    _sunriseEnabled = v;
    await _repo.setBool(PrefsKeys.notifSunrise, v);
    notifyListeners();
    await _reschedule(city);
  }

  Future<void> rescheduleForCity(PrayerCity city) => _reschedule(city);

  Future<void> _reschedule(PrayerCity city) => NotificationService.scheduleAll(
        city: city,
        atTimeEnabled: _atTimeEnabled,
        beforeEnabled: _beforeEnabled,
        sunriseEnabled: _sunriseEnabled,
      );
}
