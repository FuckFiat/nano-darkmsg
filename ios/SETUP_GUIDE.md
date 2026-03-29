# 🍎 NANO Dark Messenger — iOS Setup Guide

## 📋 Что уже установлено ✅

- ✅ **Xcode Command Line Tools**
- ✅ **XcodeGen** 2.45.3 (генерация проектов)
- ✅ **SwiftFormat** 0.60.1 (форматирование кода)
- ✅ **CocoaPods** 1.16.2 (зависимости)
- ✅ **Carthage** 0.40.0 (альтернативные зависимости)
- ✅ **Xcode проект** сгенерирован

---

## ⚠️ ТРЕБУЕТСЯ: Полный Xcode

### Способ 1: App Store (Рекомендуется)

1. Открой **App Store** на Mac
2. Найди **"Xcode"**
3. Нажми **"Get"** / **"Install"**
4. Дождись загрузки (~15 GB)

**Ссылка:** https://apps.apple.com/app/xcode/id497799835

### Способ 2: Apple Developer (Для продвинутых)

1. Зайди на https://developer.apple.com/download/all/
2. Войди с Apple ID
3. Скачай последнюю версию Xcode (.xip файл)
4. Распакуй и перетащи в `/Applications`

---

## 🚀 После установки Xcode

### Шаг 1: Первый запуск

```bash
sudo xcodebuild -runFirstLaunch
```

### Шаг 2: Принятие лицензии

```bash
sudo xcodebuild -acceptLicense
```

### Шаг 3: Установка iOS SDK

```bash
# Проверка доступных SDK
xcodebuild -showsdks

# Если нужно, установи компоненты
sudo xcodebuild -runFirstLaunch
```

---

## 📱 Запуск проекта

### Вариант 1: Через Xcode (Рекомендуется)

```bash
cd /Users/zero_mini/.openclaw/workspace/nano-darkmsg/ios
open NanoDarkMsg.xcodeproj
```

В Xcode:
1. Выбери схему **NanoDarkMsg** (сверху)
2. Выбери устройство:
   - **iPhone 15 Pro** (симулятор)
   - Твоё реальное устройство (нужен Apple ID)
3. Нажми **⌘R** (Run)

### Вариант 2: Command Line Build

```bash
cd /Users/zero_mini/.openclaw/workspace/nano-darkmsg/ios
xcodebuild -project NanoDarkMsg.xcodeproj -scheme NanoDarkMsg -sdk iphonesimulator -configuration Debug build
```

---

## 🧪 Тесты на реальном устройстве

### Требования:
- Apple ID (бесплатный аккаунт подходит)
- USB кабель
- Доверенное устройство

### Настройка:

1. Открой **Xcode → Preferences → Accounts**
2. Добавь свой **Apple ID**
3. Подключи iPhone/iPad по USB
4. В проекте выбери своё устройство вместо симулятора
5. Xcode автоматически создаст provisioning profile
6. Нажми **⌘R**

### Если ошибка "No signing certificate":

1. В проекте: **Signing & Capabilities**
2. Выбери свою **Team** (Apple ID)
3. Bundle Identifier: `com.zerocool.nanodarkmsg`
4. Xcode сам зарегистрирует устройство

---

## 🛠️ Полезные команды

### Пересобрать проект

```bash
cd ios
xcodegen generate  # Если изменился project.yml
```

### Форматировать код

```bash
swiftformat ios/NanoDarkMsg/
```

### Очистить сборку

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/NanoDarkMsg-*
```

### Проверить логи

```bash
# Console.app → фильтруй по "NANO"
# Или в Xcode: View → Debug Area → Activate Console
```

---

## 📦 Зависимости

Проект использует только стандартные фреймворки Apple:
- **CryptoKit** — AES-256-GCM, X25519
- **SwiftUI** — UI framework
- **AVFoundation** — Camera для QR scanner

**Сторонние зависимости НЕ требуются!**

---

## 🐛 Troubleshooting

### Ошибка: "Xcode is not installed"

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### Ошибка: "Command Line Tools missing"

```bash
xcode-select --install
```

### Ошибка: "Provisioning profile not found"

1. Xcode → Preferences → Accounts
2. Выбери Apple ID
3. Нажми "Download Manual Profiles"
4. Пересобери проект

### Симулятор тормозит

1. В симуляторе: **Debug → Slow Animations** (выключи)
2. **I/O → Color Blended Layers** (выключи)
3. Используй реальное устройство для тестов

---

## 📚 Ресурсы

- [Official Xcode Docs](https://developer.apple.com/xcode/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [CryptoKit Documentation](https://developer.apple.com/documentation/cryptokit)
- [NANO DarkMsg README](../README.md)

---

## ✅ Чеклист готовности

- [ ] Xcode установлен из App Store
- [ ] Лицензия принята (`sudo xcodebuild -acceptLicense`)
- [ ] Проект открыт в Xcode
- [ ] Выбрано устройство (симулятор или реальное)
- [ ] Первая сборка успешна (⌘R)
- [ ] Тесты шифрования работают

**После этого — переходим на NANOcoin!** 💎🚀
