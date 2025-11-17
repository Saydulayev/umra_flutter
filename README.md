# 🕌 Umra Flutter - Android/iOS версия

Flutter версия приложения Umra Guide для помощи мусульманам в совершении Умры.

## ✅ Что уже готово

- ✅ Flutter проект создан и настроен
- ✅ Структура папок создана (models, services, providers, screens, widgets)
- ✅ Базовые провайдеры (ThemeProvider, LocalizationProvider, UserPreferencesProvider)
- ✅ Модели (AppTheme с 4 темами)
- ✅ Сервисы (AudioService, PrayerTimeService)
- ✅ Счетчик тавафов (CounterTapWidget) - портирован из iOS
- ✅ Экран выбора языка
- ✅ Главный экран (базовая версия)

## 📦 Установленные зависимости

- `provider` - управление состоянием
- `just_audio` - проигрывание аудио
- `in_app_purchase` - покупки в приложении
- `flutter_local_notifications` - уведомления
- `flutter_pdfview` - просмотр PDF
- `shared_preferences` - хранение настроек
- `vibration` - вибрация
- и другие...

## 🚀 Запуск проекта

```bash
cd ~/Desktop/for\ GitHub/umra_flutter

# Убедитесь, что Flutter в PATH
export PATH="$PATH:$HOME/flutter/bin"

# Запустите приложение
flutter run
```

## 📁 Структура проекта

```
umra_flutter/
├── lib/
│   ├── main.dart                    # Точка входа
│   ├── models/
│   │   └── app_theme.dart           # Темы приложения
│   ├── providers/
│   │   ├── theme_provider.dart      # Управление темами
│   │   ├── localization_provider.dart
│   │   └── user_preferences_provider.dart
│   ├── services/
│   │   ├── audio_service.dart       # Аудио сервис
│   │   └── prayer_time_service.dart # Время намаза (TODO: реализовать расчет)
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── language_selection_screen.dart
│   └── widgets/
│       └── counter_tap_widget.dart  # Счетчик тавафов
├── assets/
│   ├── images/                      # TODO: перенести изображения
│   ├── audio/                       # TODO: перенести MP3 файлы
│   ├── pdf/                         # TODO: перенести PDF файлы
│   └── fonts/                       # TODO: перенести шрифты Lato
└── pubspec.yaml
```

## 📝 Что нужно сделать дальше

1. **Перенести ресурсы:**
   ```bash
   # Из iOS проекта в Flutter
   cp umra/Assets.xcassets/image*.imageset/*.jpg umra_flutter/assets/images/
   cp umra/MP3Voice/*.mp3 umra_flutter/assets/audio/
   cp umra/PDF/*.pdf umra_flutter/assets/pdf/
   cp umra/Font/*.ttf umra_flutter/assets/fonts/
   ```

2. **Портировать экраны шагов:**
   - Step 1-7 (шаги Умры)
   - Settings Screen
   - Prayer Time Screen
   - PDF Viewer Screen
   - Donation Screen

3. **Реализовать PlayerWidget** - аудио плеер

4. **Настроить локализацию:**
   - Конвертировать .strings файлы в .arb формат
   - Настроить flutter_localizations

5. **Реализовать расчет времени намаза:**
   - Найти подходящий пакет или написать собственный расчет
   - Обновить PrayerTimeService

6. **Настроить уведомления:**
   - Реализовать NotificationService
   - Настроить уведомления о времени намаза

7. **Настроить покупки:**
   - Настроить Google Play Billing (Android)
   - Настроить App Store Connect (iOS)

## 🔧 Текущий статус

Проект готов к разработке. Базовая структура создана, основные провайдеры работают. 
Можно запустить приложение и увидеть экран выбора языка и счетчик тавафов.

## 📱 Платформы

- ✅ iOS (поддержка планируется)
- ✅ Android (основная цель)
- 📝 Web (опционально)

## 📄 Лицензия

MIT License
