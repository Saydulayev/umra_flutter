# Настройка Fastlane

Это руководство описывает, как запустить автоматическую сборку и публикацию umra_flutter в Google Play (internal testing) и TestFlight с твоего Mac, и как позже включить тот же процесс в GitHub Actions.

Файлы уже добавлены в проект: `Gemfile`, `fastlane/Appfile`, `fastlane/Fastfile`, `fastlane/ExportOptions.plist`, `fastlane/.env.default` и заготовка `.github/workflows/release.yml`. Ниже — что нужно сделать руками, чтобы это заработало.

## 1. Установка

Fastlane ставится через Ruby Bundler, чтобы версия была одинаковой у всех и в CI.

```bash
brew install rbenv ruby-build   # если Ruby ещё не через rbenv/asdf
gem install bundler
bundle install                  # поставит fastlane из Gemfile
```

Проверка: `bundle exec fastlane --version`.

## 2. Google Play: сервисный аккаунт

Fastlane заливает сборки в Play Console через API, а не через твой личный логин, поэтому нужен сервисный аккаунт.

1. В [Google Play Console](https://play.google.com/console) открой **Настройки → Доступ к API (API access)** и подключи (или создай) проект Google Cloud.
2. В Google Cloud Console для этого проекта создай сервисный аккаунт: **IAM & Admin → Service Accounts → Create Service Account**. Роль не обязательна на этом шаге.
3. Вернись в Play Console → API access, найди созданный сервисный аккаунт и нажми **Grant access**. Дай права как минимум на раздел **Release** (для загрузки сборок в internal testing) для umra_flutter.
4. В Google Cloud Console у этого сервисного аккаунта создай ключ: **Keys → Add key → JSON**. Скачается `.json`-файл.
5. Положи его в проект как `fastlane/play-store-credentials.json` (этот путь уже в `.gitignore`, в git не попадёт).

## 3. App Store Connect: API Key

Аналогично для iOS — вместо ручного логина Apple ID используется API-ключ.

1. Зайди в [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access → Integrations → App Store Connect API**.
2. Нажми **Generate API Key**, роль — **App Manager** (этого достаточно для заливки в TestFlight).
3. Скачай `.p8`-файл **сразу** — Apple даёт скачать его только один раз. Сохрани как `fastlane/AuthKey_<KEY_ID>.p8`.
4. Запиши `Key ID` и `Issuer ID`, которые показаны на той же странице.

## 4. Заполнение переменных окружения

```bash
cp fastlane/.env.default fastlane/.env
```

Открой `fastlane/.env` и заполни:

- `APPLE_ID` — email твоего аккаунта в App Store Connect.
- `ASC_KEY_ID`, `ASC_ISSUER_ID` — из шага 3.
- `ASC_KEY_FILEPATH` — `fastlane/AuthKey_<KEY_ID>.p8`.
- `GOOGLE_PLAY_JSON_KEY_PATH` — можно оставить по умолчанию (`fastlane/play-store-credentials.json`), если положил файл туда же.

`fastlane/.env` в `.gitignore` — не попадёт в git.

Для iOS-подписи используется тот же сертификат/профиль, что уже настроен у тебя в Xcode (Automatic Signing, команда `93NA5FP2X8`) — отдельно ничего настраивать не нужно, если сборка уже собиралась и публиковалась вручную из Xcode раньше.

## 5. Локальный запуск

Из корня проекта:

```bash
# Android → Google Play, дорожка internal testing
bundle exec fastlane android internal

# iOS → TestFlight
bundle exec fastlane ios beta
```

Оба lane сами прогоняют `flutter pub get` и `flutter build appbundle`/`flutter build ipa --release`, так что отдельно собирать приложение не нужно.

Когда набор internal-сборок в Play Console стабилен и готов к продакшену:

```bash
bundle exec fastlane android promote_to_production
```

## 6. Включение в CI (когда будешь готов)

`.github/workflows/release.yml` уже в репозитории, но запускается только вручную (кнопка **Run workflow** во вкладке Actions) — пока не добавлены секреты, ничего не сломается.

Чтобы включить:

1. В настройках репозитория **Settings → Secrets and variables → Actions** добавь секреты, перечисленные в комментариях внутри `release.yml` (по одному на каждый файл/пароль: keystore в base64, `key.properties`-поля, JSON-ключ Google Play, `.p8`-ключ App Store Connect в base64, экспортированный `.p12`-сертификат iOS и `.mobileprovision`-профиль).
2. Проверь workflow вручную через **Run workflow** на тестовой ветке.
3. Когда всё стабильно проходит — раскомментируй блок `push: tags:` в `release.yml`, чтобы публикация запускалась автоматически по тегу `vX.Y.Z`.

iOS-джоба в CI импортирует сертификат и профиль во временный keychain на macOS-раннере — это стандартный способ подписывать сборки без интерактивного Xcode. Если позже подключишь несколько разработчиков/машин, имеет смысл заменить это на [fastlane match](https://docs.fastlane.tools/actions/match/), который хранит сертификаты в приватном git-репозитории или облаке.
