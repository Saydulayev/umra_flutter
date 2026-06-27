import 'package:shared_preferences/shared_preferences.dart';

/// Репозиторий для работы с SharedPreferences
/// Централизует доступ к настройкам приложения
class PreferencesRepository {
  static final PreferencesRepository _instance =
      PreferencesRepository._internal();
  factory PreferencesRepository() => _instance;
  PreferencesRepository._internal();

  SharedPreferences? _prefs;

  /// Инициализация репозитория
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Получить SharedPreferences экземпляр
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // String методы
  Future<String?> getString(String key) async {
    final preferences = await prefs;
    return preferences.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    final preferences = await prefs;
    return await preferences.setString(key, value);
  }

  // Bool методы
  Future<bool?> getBool(String key) async {
    final preferences = await prefs;
    return preferences.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    final preferences = await prefs;
    return await preferences.setBool(key, value);
  }

  // Double методы
  Future<double?> getDouble(String key) async {
    final preferences = await prefs;
    return preferences.getDouble(key);
  }

  Future<bool> setDouble(String key, double value) async {
    final preferences = await prefs;
    return await preferences.setDouble(key, value);
  }

  // Int методы
  Future<int?> getInt(String key) async {
    final preferences = await prefs;
    return preferences.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    final preferences = await prefs;
    return await preferences.setInt(key, value);
  }

  // Удаление ключа
  Future<bool> remove(String key) async {
    final preferences = await prefs;
    return await preferences.remove(key);
  }

  // Очистка всех данных
  Future<bool> clear() async {
    final preferences = await prefs;
    return await preferences.clear();
  }
}
