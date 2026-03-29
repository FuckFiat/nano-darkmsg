# 🌑 NANO Dark Messenger — Contributing Guide

Спасибо за интерес к проекту! Вот как можно помочь:

## 🚀 Быстрый старт

### 1. Форк и клон
```bash
git clone https://github.com/FuckFiat/nano-darkmsg.git
cd nano-darkmsg
```

### 2. Установка зависимостей

**Rust ядро:**
```bash
cd core
cargo build
cargo test
```

**Python прототип:**
```bash
cd scripts
pip3 install -r requirements.txt
python3 proto_encrypt.py --help
```

## 📝 Правила кода

### Rust
- Используй `cargo clippy` перед коммитом
- Все функции должны иметь документацию (`///`)
- Тесты обязательны для крипто-функций

```bash
cargo clippy -- -D warnings
cargo test
```

### Python
- Следуй PEP 8
- Максимальная длина строки: 120 символов
- Type hints желательны

```bash
flake8 scripts/ --max-line-length=120
```

## 🧪 Тестирование

### Запуск всех тестов
```bash
# Rust
cd core && cargo test

# Python
cd scripts && pytest
```

### Integration tests
```bash
# Шифрование → Дешифрование
python3 proto_encrypt.py -e -p "test" -i test.txt
python3 proto_encrypt.py -d -p "test" -i test.txt.enc
```

## 📤 Pull Request

Перед отправкой PR:

1. ✅ Все тесты проходят
2. ✅ Clippy чист (для Rust)
3. ✅ Добавлены тесты для новых фич
4. ✅ Обновлена документация

**Название PR:**
- `feat: X25519 key exchange`
- `fix: AES-GCM nonce collision`
- `docs: Update README.md`

## 🔐 Безопасность

**ВАЖНО:** При обнаружении уязвимостей:
- НЕ создавай публичный issue
- Пиши напрямую: @zero-co0l в Telegram
- Используем [GitHub Security Advisories](https://github.com/FuckFiat/nano-darkmsg/security/advisories)

## 🎯 Roadmap

Смотри [README.md](../README.md) для текущего статуса.

## 💬 Контакты

- **Telegram:** @YrNanoTyan
- **GitHub Issues:** [Сообщить о баге](https://github.com/FuckFiat/nano-darkmsg/issues)

---

*Спасибо за вклад в приватность! 🖤*
