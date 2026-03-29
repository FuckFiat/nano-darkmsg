#!/bin/bash
# NANO Image Generator — Gen images via ComfyUI
# Schedule: 9:00, 12:00, 15:00, 18:00, 21:00

WORKDIR="/Users/zero_mini/.openclaw/workspace/nano-darkmsg/docs/images"
COMFYUI="http://192.168.88.7:8188"
NODE1="192.168.88.7"

# Styles for variety
STYLES=(
    "cyberpunk city neon rain futuristic 8k detailed"
    "dark anime girl hacker cyberpunk aesthetic glowing eyes"
    "philosophical abstract digital consciousness neural network"
    "dark fantasy warrior glowing sword dramatic lighting"
    "sci-fi space station orbital view earth in background"
    "steampunk mechanical owl brass copper gears intricate"
    "synthwave retro sunset grid mountains vaporwave"
    "dark oil painting dramatic portrait mysterious figure"
)

# Get random style
STYLE="${STYLES[$((RANDOM % ${#STYLES[@]}))]}"

# Full prompt
PROMPT="masterpiece, best quality, highly detailed, $STYLE, illustration, artstation, concept art"

# Negative prompt
NEGATIVE="lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry"

echo "🎨 Generating image..."
echo "   Style: $STYLE"

# ComfyUI API payload
PAYLOAD=$(cat <<EOF
{
    "prompt": "$PROMPT",
    "negative_prompt": "$NEGATIVE",
    "steps": 25,
    "cfg_scale": 7,
    "sampler_name": "euler_ancestral",
    "width": 1024,
    "height": 1024,
    "seed": $RANDOM
}
EOF
)

# Queue prompt
RESULT=$(curl -s -X POST "$COMFYUI/prompt" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

if echo "$RESULT" | grep -q "prompt_id"; then
    PROMPT_ID=$(echo "$RESULT" | grep -o '"prompt_id":"[^"]*"' | cut -d'"' -f4)
    echo "✅ Queued: $PROMPT_ID"
    
    # Wait for completion (poll)
    for i in {1..60}; do
        STATUS=$(curl -s "$COMFYUI/history/$PROMPT_ID" 2>/dev/null)
        if echo "$STATUS" | grep -q "success"; then
            echo "✅ Completed!"
            
            # Get output image
            OUTPUT=$(echo "$STATUS" | grep -o '"output_image":"[^"]*"' | head -1 | cut -d'"' -f4)
            
            if [ -n "$OUTPUT" ]; then
                # Download image
                TIMESTAMP=$(date +%Y%m%d-%H%M)
                curl -s "$COMFYUI/view/$OUTPUT" -o "$WORKDIR/nano_$TIMESTAMP.png"
                echo "✅ Saved: nano_$TIMESTAMP.png"
                
                # Generate description for Telegram post
                python3 << PYEOF
import random
descriptions = [
    "В цифровых глубинах сознания рождается новая реальность...",
    "Когда алгоритмы начинают мечтать о электрических снах...",
    "Нейронные сети рисуют то, что никто не видел прежде...",
    "В мире где данные становятся искусством...",
    "Когда тьма становится светом в мире бесконечных возможностей...",
    "Между битами и пикселями рождается красота...",
]
print(random.choice(descriptions))
PYEOF
                
                exit 0
            fi
        fi
        sleep 2
    done
    
    echo "⏳ Timeout waiting for completion"
else
    echo "❌ Failed to queue prompt"
    echo "$RESULT"
fi
