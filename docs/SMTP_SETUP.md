# NANO SMTP Transport Module

Email-based messaging for NANO Dark Messenger (Delta Chat compatible).

## Features

- Send encrypted messages via SMTP
- Receive and decrypt incoming messages
- PGP-compatible key exchange
- Works with any email provider (Yandex, Mail.ru, Gmail)

## Setup

### Yandex Mail
```python
smtp_server = "smtp.yandex.ru"
smtp_port = 587
imap_server = "imap.yandex.ru"
imap_port = 993
```

### Mail.ru
```python
smtp_server = "smtp.mail.ru"
smtp_port = 587
imap_server = "imap.mail.ru"
imap_port = 993
```

## Usage

```python
from nano_smtp import NANOTransport

# Initialize
transport = NANOTransport(
    email="user@yandex.ru",
    password="app_password",  # NOT regular password!
    smtp_server="smtp.yandex.ru"
)

# Send encrypted message
transport.send_message(
    to="friend@mail.ru",
    message="Secret message",
    password="shared_secret"
)

# Check for new messages
messages = transport.fetch_messages()
for msg in messages:
    print(msg.decrypt("shared_secret"))
```

## App Password Setup

### Yandex
1. Go to https://passport.yandex.ru/profile
2. Security → App passwords
3. Create new password for "Mail"
4. Use this password (NOT your main password!)

### Mail.ru
1. Go to Account settings
2. Security → App passwords
3. Generate for "Other apps"

## Security Notes

- Always use **app passwords**, not main passwords
- Enable 2FA on your email account
- Messages are E2E encrypted (email provider sees only ciphertext)
- Subject line: "NANO:encrypted" (for easy filtering)
