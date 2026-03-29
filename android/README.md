# NANO Dark Messenger — Android App

Android application for NANO Dark Messenger with end-to-end encryption.

## Features

- ✅ AES-256-GCM encryption
- ✅ X25519 key exchange (planned)
- ✅ SMTP/IMAP transport
- ✅ Material 3 design
- ✅ Jetpack Compose UI

## Build

```bash
cd android
./gradlew assembleDebug
```

APK will be in `app/build/outputs/apk/debug/`

## Requirements

- Android 8.0+ (API 26)
- Kotlin 1.9.20
- Android Gradle Plugin 8.1.2

## Dependencies

- **Jetpack Compose** — Modern UI
- **Bouncy Castle** — Crypto primitives
- **Tink** — Google crypto library
- **JavaMail** — SMTP/IMAP

## Architecture

```
app/src/main/java/com/zerocool/nanodarkmsg/
├── MainActivity.kt        # Main UI (Compose)
├── CryptoManager.kt       # AES-256-GCM encryption
├── SMTPTransport.kt       # Email transport (TODO)
└── KeyExchange.kt         # X25519 key exchange (TODO)
```

## TODO

- [ ] Implement X25519 key exchange
- [ ] QR code scanner for key sharing
- [ ] Background service for email sync
- [ ] Biometric authentication
- [ ] Message database (Room)
- [ ] Push notifications

## Security Notes

- Keys stored in Android Keystore (TODO)
- No messages stored on servers
- E2E encryption by default
- Open source crypto (no black boxes)
