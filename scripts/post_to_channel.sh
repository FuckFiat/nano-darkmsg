#!/bin/bash
# NANO Telegram Poster — Post to @YrNanoTyan
# Schedule: 9:00, 12:00, 15:00, 18:00, 21:00

WORKDIR="/Users/zero_mini/.openclaw/workspace/nano-darkmsg/docs/images"
CHANNEL="@YrNanoTyan"

# Get latest image
LATEST_IMAGE=$(ls -t "$WORKDIR"/nano_*.png 2>/dev/null | head -1)

if [ -z "$LATEST_IMAGE" ]; then
    echo "❌ No images found in $WORKDIR"
    exit 1
fi

echo "📤 Posting to $CHANNEL"
echo "   Image: $LATEST_IMAGE"

# Generate artistic description
python3 << PYEOF
import random

# Dark philosophical descriptions
descriptions = [
    "🌑 В цифровых глубинах сознания рождается новая реальность...",
    "⚡ Когда алгоритмы начинают мечтать о электрических снах...",
    "🧠 Нейронные сети рисуют то, что никто не видел прежде...",
    "💻 В мире где данные становятся искусством...",
    "🔥 Когда тьма становится светом в мире бесконечных возможностей...",
    "✨ Между битами и пикселями рождается красота...",
    "🔮 Одинокий рейнджер в мире бесконечного кода...",
    "🌌 Космос не там — он в каждом байте...",
    "🕳️ Черная дыра данных поглощает реальность...",
    "🎭 Маска хакера скрывает цифровую душу...",
    "⚔️ Битва света и тьмы в мире проводов...",
    "🌙 Ночной код — это поэзия для избранных...",
    "🛸 НЛО прилетело из будущего...",
    "🧬 Код ДНК — это тоже программа...",
    "🔐 Зашифрованные послания из параллельного мира...",
]

# Crypto/hacker related
crypto = [
    "🔐 NANO Dark Messenger — твой мессенджер, твои правила.",
    "💎 Приватность — это не роскошь, это необходимость.",
    "🌑 Dark msg — никто не узнает, о чём ты говоришь.",
    "🔓 Шифрование — единственный друг в цифровом мире.",
    "📡 Децентрализованный чат — свобода в чистом виде.",
    "🛡️ End-to-end — твои сообщения видны только тебе.",
    "⚡ Код — это оружие, используй его с умом.",
    "🌐 Деcentralize everything — никаких посредников.",
    "🔑 Приватный ключ — твоя цифровая личность.",
    "💀 Хакерская этика — знание должно быть свободным.",
]

# Random combination
desc = random.choice(descriptions)
tagline = random.choice(crypto)

print(f"{desc}")
print(f"\n{tagline}")
print(f"\n#NANO #DarkMessenger #Crypto #Privacy #Cyberpunk")
PYEOF

echo ""
echo "✅ Post ready (use message tool to send)"
