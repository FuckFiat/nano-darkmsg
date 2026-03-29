#!/bin/bash
# NANO iOS Setup — Проверка и настройка окружения

echo "🔧 NANO Dark Messenger — iOS Setup Check"
echo "========================================"
echo ""

# Проверка Xcode
echo "1️⃣ Проверка Xcode..."
if xcode-select -p &> /dev/null; then
    echo "   ✅ Xcode Command Line Tools установлен"
    echo "   Путь: $(xcode-select -p)"
else
    echo "   ❌ Xcode Command Line Tools НЕ установлен"
    echo "   Установка: xcode-select --install"
fi

echo ""
echo "2️⃣ Проверка полного Xcode..."
if [ -d "/Applications/Xcode.app" ]; then
    echo "   ✅ Xcode установлен"
    XCODE_VERSION=$(xcodebuild -version | head -1)
    echo "   Версия: $XCODE_VERSION"
else
    echo "   ⚠️  Полный Xcode НЕ найден"
    echo ""
    echo "   📥 УСТАНОВКА XCODE:"
    echo "   Вариант 1: App Store"
    echo "   https://apps.apple.com/app/xcode/id497799835"
    echo ""
    echo "   Вариант 2: Прямая загрузка (нужен Apple ID)"
    echo "   https://developer.apple.com/download/all/"
    echo ""
    echo "   После установки:"
    echo "   sudo xcodebuild -runFirstLaunch"
    echo "   sudo xcodebuild -acceptLicense"
fi

echo ""
echo "3️⃣ Проверка инструментов..."

# XcodeGen
if command -v xcodegen &> /dev/null; then
    echo "   ✅ XcodeGen: $(xcodegen --version)"
else
    echo "   ❌ XcodeGen не найден"
    echo "   Установка: brew install xcodegen"
fi

# SwiftFormat
if command -v swiftformat &> /dev/null; then
    echo "   ✅ SwiftFormat: $(swiftformat --version)"
else
    echo "   ⚠️  SwiftFormat не найден (опционально)"
fi

# CocoaPods
if command -v pod &> /dev/null; then
    echo "   ✅ CocoaPods: $(pod --version)"
else
    echo "   ⚠️  CocoaPods не найден (опционально)"
fi

# Carthage
if command -v carthage &> /dev/null; then
    echo "   ✅ Carthage: $(carthage version)"
else
    echo "   ⚠️  Carthage не найден (опционально)"
fi

echo ""
echo "4️⃣ Проверка iOS симуляторов..."
if command -v xcrun &> /dev/null; then
    echo "   Доступные симуляторы:"
    xcrun simctl list devices available | grep -E "iPhone|iPad" | head -5
else
    echo "   ❌ xcrun не найден (нужен Xcode)"
fi

echo ""
echo "5️⃣ Проект NANO DarkMsg..."
if [ -f "NanoDarkMsg.xcodeproj/project.pbxproj" ]; then
    echo "   ✅ Xcode проект сгенерирован"
    echo "   Путь: $(pwd)/NanoDarkMsg.xcodeproj"
    echo ""
    echo "   🚀 ОТКРЫТЬ ПРОЕКТ:"
    echo "   open NanoDarkMsg.xcodeproj"
else
    echo "   ❌ Проект не найден"
    echo "   Генерация: xcodegen generate"
fi

echo ""
echo "========================================"
echo "📚 СЛЕДУЮЩИЕ ШАГИ:"
echo ""
echo "1. Установи Xcode (если не установлен)"
echo "2. Прими лицензию: sudo xcodebuild -acceptLicense"
echo "3. Открой проект: open NanoDarkMsg.xcodeproj"
echo "4. Выбери устройство (iPhone 15 Pro или реальное)"
echo "5. Нажми ⌘R для запуска"
echo ""
echo "💡 СОВЕТ: Для тестов на реальном устройстве"
echo "   нужен Apple ID в Xcode Preferences"
echo ""
