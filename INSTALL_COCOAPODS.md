# Установка CocoaPods для iOS разработки

## Проблема
CocoaPods требует Ruby версии >= 3.1, но у вас установлена версия 2.6.10.

## Решение 1: Установка через sudo (рекомендуется)

Выполните в терминале:

```bash
sudo gem install cocoapods
```

Введите пароль администратора, когда будет запрошен.

После установки проверьте:

```bash
pod --version
```

Затем в папке проекта:

```bash
cd ~/Desktop/for\ GitHub/umra_flutter
pod install
```

## Решение 2: Использовать системную версию Ruby (если доступна)

```bash
/usr/bin/ruby -v
# Если версия >= 3.1, то:
/usr/bin/ruby -S gem install cocoapods
```

## Решение 3: Использовать Homebrew (если установлен)

```bash
brew install cocoapods
```

## Решение 4: Временно запустить на macOS или Chrome

Можно протестировать приложение на macOS или в Chrome, которые не требуют CocoaPods:

```bash
cd ~/Desktop/for\ GitHub/umra_flutter
flutter run -d macos  # для macOS
# или
flutter run -d chrome  # для Chrome
```

## После установки CocoaPods

1. Перейдите в папку iOS:
```bash
cd ~/Desktop/for\ GitHub/umra_flutter/ios
pod install
```

2. Вернитесь в корень проекта и запустите:
```bash
cd ~/Desktop/for\ GitHub/umra_flutter
flutter run -d 3  # или номер вашего iPhone
```



