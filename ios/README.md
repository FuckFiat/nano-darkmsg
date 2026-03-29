# NANO Dark Messenger — iOS App

Native iOS application with end-to-end encryption.

## Features

✅ **AES-256-GCM Encryption** — Military-grade security  
✅ **X25519 Key Exchange** — Secure key agreement  
✅ **QR Code Scanner** — Easy key sharing  
✅ **Material Design** — Beautiful SwiftUI interface  
✅ **Share Sheet** — Send encrypted messages anywhere  

## Build Requirements

- macOS 14.0+
- Xcode 15.0+
- iOS 16.0+

## Build Instructions

### Option 1: XcodeGen (Recommended)

```bash
cd ios
brew install xcodegen
xcodegen generate
open NanoDarkMsg.xcodeproj
```

Then build in Xcode (⌘B) or run (⌘R).

### Option 2: Manual

1. Open Xcode
2. Create new project from folder
3. Add all `.swift` files
4. Build and run

## Architecture

```
NanoDarkMsg/
├── NanoDarkMsgApp.swift    # App entry point
├── ContentView.swift        # Main UI (encrypt/decrypt)
├── CryptoManager.swift      # AES-256-GCM + X25519
├── QRCodeScannerView.swift  # QR scanner & generator
├── Data+Hex.swift           # Hex encoding helpers
└── Info.plist              # App config + permissions
```

## Usage

### Encrypt Message

1. Enter message
2. Enter shared secret password
3. Tap **🔒 Encrypt**
4. Share via Share Sheet

### Decrypt Message

1. Paste encrypted text
2. Enter same password
3. Tap **🔓 Decrypt**

### Key Exchange (QR)

1. Tap **My Key** to show your public key QR
2. Friend scans with **Scan Key**
3. Use derived shared secret for encryption

## Security

- **No servers** — All crypto happens on device
- **No metadata** — Messages don't leave device
- **Open source crypto** — Using Apple CryptoKit (audited)
- **Plausible deniability** — Encrypted text looks random

## TODO

- [ ] Save keys in Secure Enclave
- [ ] Biometric authentication (FaceID/TouchID)
- [ ] Message history (encrypted Core Data)
- [ ] Push notifications (encrypted payload)
- [ ] Group chats
- [ ] File attachments

## Privacy Policy

This app:
- ❌ Does NOT collect any data
- ❌ Does NOT send messages to servers
- ❌ Does NOT track users
- ❌ Does NOT show ads

All encryption happens locally on your device.

## License

MIT License — See LICENSE file
