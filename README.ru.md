# Umra Guide

[English](README.md) | **Русский**

Мобильное приложение-путеводитель по Умре: пошаговые инструкции обрядов, аудиогид с произношением дуа, время намаза с уведомлениями и исламский календарь. Опубликовано в App Store и Google Play, более 40 000 загрузок, рейтинг 4.9 в App Store.

[![CI](https://github.com/Saydulayev/umra_flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/Saydulayev/umra_flutter/actions/workflows/ci.yml)
[![App Store](https://img.shields.io/badge/App%20Store-Umra%20Guide-0D96F6?logo=apple&logoColor=white)](https://apps.apple.com/ru/app/umra-guide/id1673683355)
[![Google Play](https://img.shields.io/badge/Google%20Play-Umra%20Guide-3DDC84?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=saydulayev.wien_gmail.com.umra)

<p align="center">
  <img src="assets/images/01-hero-1320x2868.png" width="160" alt="Главный экран"/>
  <img src="assets/images/02-umra-1320x2868.png" width="160" alt="Обряды Умры"/>
  <img src="assets/images/04-dua-1320x2868.png" width="160" alt="Дуа"/>
  <img src="assets/images/05-prayer-1320x2868.png" width="160" alt="Время намаза"/>
</p>

## Возможности

- Пошаговые инструкции обрядов Умры и Хаджа с аудиосопровождением
- Аудиоплеер с фоновым воспроизведением (just_audio + audio_service)
- Расчёт времени намаза (adhan_dart) и локальные уведомления
- Исламский (хиджри) календарь
- Счётчик кругов тавафа
- PDF-материалы для офлайн-чтения
- Семь языков интерфейса: русский, английский, арабский, немецкий, французский, турецкий, индонезийский
- Несколько тем оформления, включая тёмную; поддержка Liquid Glass UI (iOS 26)
- Встроенные покупки и запрос отзыва

## Требования

- iOS 17.0+ / Android 6.0+ (API 23), таргет Android 15 (API 35, edge-to-edge)
- Flutter (Dart SDK ^3.11.0)

## Сборка и запуск

```bash
flutter pub get
flutter run
```

Локализации генерируются автоматически (`flutter: generate: true`). Нативный splash-экран пересоздаётся после изменения ассетов:

```bash
dart run flutter_native_splash:create
```

Крэш-репортинг построен на Firebase Crashlytics; конфигурация — в `lib/firebase_options.dart`.

## Архитектура

Состояние управляется через `provider`, данные отделены от UI слоями repositories/services.

```
lib/
├── main.dart
├── constants/       # Константы приложения
├── models/          # Модели данных
├── providers/       # Провайдеры состояния
├── repositories/    # Доступ к данным
├── services/        # Бизнес-логика (аудио, намаз, уведомления, крэш-репортинг)
├── screens/         # Экраны
├── widgets/         # Переиспользуемые виджеты
├── theme/           # Темы оформления
├── utils/           # Вспомогательные утилиты
└── l10n/            # Локализация (7 языков)
```

В `patched_packages/audio_service` лежит локальный форк `audio_service` с исправлением NPE в `onConnectionFailed`/`onConnected`; он подключён через `dependency_overrides`.

## Основные зависимости

| Пакет | Назначение |
|---|---|
| `provider` | Управление состоянием |
| `just_audio`, `audio_service` | Аудио с фоновым воспроизведением |
| `adhan_dart` | Расчёт времени намаза |
| `hijri_date` | Хиджри-календарь |
| `flutter_local_notifications`, `timezone` | Уведомления о намазе |
| `flutter_pdfview`, `pdf` | Работа с PDF |
| `firebase_core`, `firebase_crashlytics` | Крэш-репортинг |
| `in_app_purchase`, `in_app_review` | Покупки и отзывы |
| `liquid_glass_widgets` | Стеклянный таб-бар (iOS 26) |

## Тестирование

```bash
flutter analyze
flutter test
```

Около 130 тестов, все хостовые (устройство или эмулятор не нужны):

- `test/unit/` — расчёт времени намаза, state-машина покупок
  (успех/ошибка/отмена/pending-таймауты), процедура решения о показе
  review-диалога, темы и настройки уведомлений, ключи локализации;
- `test/widget/` — smoke-тесты основных экранов во всех 3 темах и RTL-локали,
  проверка layout при крупном шрифте (textScaler до 2.0), accessibility-гайдлайны
  (подписи тапабельных элементов);
- `test/helpers/` — общий harness (провайдеры, застабленные платформенные
  каналы, телефонный viewport).

CI (GitHub Actions) гоняет `flutter analyze` и `flutter test` на каждый push
и pull request — см. `.github/workflows/ci.yml`.
