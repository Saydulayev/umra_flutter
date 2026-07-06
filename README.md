# Umra Guide

**English** | [Русский](README.ru.md)

A mobile companion for performing Umrah: step-by-step ritual instructions, an audio guide with du'a pronunciation, prayer times with notifications, and an Islamic calendar. Published on the App Store and Google Play with over 40,000 downloads and a 4.9 rating on the App Store.

[![CI](https://github.com/Saydulayev/umra_flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/Saydulayev/umra_flutter/actions/workflows/ci.yml)
[![App Store](https://img.shields.io/badge/App%20Store-Umra%20Guide-0D96F6?logo=apple&logoColor=white)](https://apps.apple.com/ru/app/umra-guide/id1673683355)
[![Google Play](https://img.shields.io/badge/Google%20Play-Umra%20Guide-3DDC84?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=saydulayev.wien_gmail.com.umra)

<p align="center">
  <img src="assets/images/01-hero-1320x2868.png" width="160" alt="Home screen"/>
  <img src="assets/images/02-umra-1320x2868.png" width="160" alt="Umrah rituals"/>
  <img src="assets/images/04-dua-1320x2868.png" width="160" alt="Du'a"/>
  <img src="assets/images/05-prayer-1320x2868.png" width="160" alt="Prayer times"/>
</p>

## Features

- Step-by-step Umrah and Hajj ritual instructions with audio narration
- Audio player for ritual narration (just_audio)
- Prayer time calculation (adhan_dart) with local notifications
- Islamic (Hijri) calendar
- Tawaf lap counter
- PDF materials for offline reading
- Seven interface languages: English, Russian, Arabic, German, French, Turkish, Indonesian
- Multiple themes including dark mode; Liquid Glass UI support (iOS 26)
- In-app purchases and review prompts

## Requirements

- iOS 17.0+ / Android 6.0+ (API 23), targeting Android 15 (API 35, edge-to-edge)
- Flutter (Dart SDK ^3.11.0)

## Build and run

```bash
flutter pub get
flutter run
```

Localizations are generated automatically (`flutter: generate: true`). The native splash screen must be regenerated after changing its assets:

```bash
dart run flutter_native_splash:create
```

Crash reporting is built on Firebase Crashlytics; configuration lives in `lib/firebase_options.dart`.

## Architecture

State is managed with `provider`; data access is separated from the UI via repository and service layers.

```
lib/
├── main.dart
├── constants/       # App constants
├── models/          # Data models
├── providers/       # State providers
├── repositories/    # Data access
├── services/        # Business logic (audio, prayer times, notifications, crash reporting)
├── screens/         # Screens
├── widgets/         # Reusable widgets
├── theme/           # Themes
├── utils/           # Helpers
└── l10n/            # Localization (7 languages)
```

## Key dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `just_audio` | Audio playback |
| `adhan_dart` | Prayer time calculation |
| `hijri_date` | Hijri calendar |
| `flutter_local_notifications`, `timezone` | Prayer notifications |
| `flutter_pdfview`, `pdf` | PDF handling |
| `firebase_core`, `firebase_crashlytics` | Crash reporting |
| `in_app_purchase`, `in_app_review` | Purchases and reviews |
| `liquid_glass_widgets` | Glass tab bar (iOS 26) |

## Testing

```bash
flutter analyze
flutter test
```

Around 130 tests, all host-side (no device or emulator required):

- `test/unit/` — prayer time calculations, purchase state machine
  (success/error/cancellation/pending timeouts), the in-app review decision
  procedure, theme and notification preferences, localization label keys;
- `test/widget/` — smoke tests of the main screens across all 3 themes and
  RTL locales, large-font (textScaler up to 2.0) layout checks, and
  accessibility guideline checks (labeled tap targets);
- `test/helpers/` — shared harness (providers, mocked platform channels,
  phone-sized viewport).

CI (GitHub Actions) runs `flutter analyze` and `flutter test` on every push
and pull request — see `.github/workflows/ci.yml`.
