#!/bin/bash
# NANO Image Generator — Gen images via ComfyUI
# Schedule: 9:00, 12:00, 15:00, 18:00, 21:00

WORKDIR="/Users/zero_mini/.openclaw/workspace/nano-darkmsg/docs/images"
COMFYUI="http://192.168.88.7:8188"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Styles for variety
STYLES=(
    "cyberpunk city neon rain futuristic"
    "dark anime girl hacker cyberpunk aesthetic glowing eyes"
    "philosophical abstract digital consciousness neural network"
    "dark fantasy warrior glowing sword dramatic lighting"
    "sci-fi space station orbital view earth in background"
    "steampunk mechanical owl brass copper gears intricate"
    "synthwave retro sunset grid mountains vaporwave"
)

# Get random style
STYLE="${STYLES[$((RANDOM % ${#STYLES[@]}))]}"
SEED=$((RANDOM * RANDOM))

echo "🎨 Generating image..."
echo "   Style: $STYLE"
echo "   Seed: $SEED"

# Read workflow template
WORKFLOW_TEMPLATE=$(cat "$SCRIPT_DIR/comfyui_workflow.json")

# Update workflow with dynamic values
WORKFLOW_TEMPLATE=$(echo "$WORKFLOW_TEMPLATE" | sed "s/cyberpunk city neon rain futuristic/$STYLE/g")
WORKFLOW_TEMPLATE=$(echo "$WORKFLOW_TEMPLATE" | sed "s/\"seed\": 42/\"seed\": $SEED/g")

# Wrap in prompt format
PAYLOAD="{\"prompt\": $WORKFLOW_TEMPLATE}"

# Queue prompt
RESULT=$(curl -s -X POST "$COMFYUI/prompt" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

echo "   API Response: ${RESULT:0:200}..."

if echo "$RESULT" | grep -q "prompt_id"; then
    PROMPT_ID=$(echo "$RESULT" | grep -o '"prompt_id":"[^"]*"' | cut -d'"' -f4)
    echo "✅ Queued: $PROMPT_ID"
    
    # Wait for completion (poll)
    for i in {1..60}; do
        STATUS=$(curl -s "$COMFYUI/history/$PROMPT_ID" 2>/dev/null)
        if echo "$STATUS" | grep -q "\"$PROMPT_ID\""; then
            echo "✅ Completed!"
            
            # Extract image filename from history
            IMAGE_DATA=$(echo "$STATUS" | grep -o '"images":\[[^]]*\]' | head -1)
            FILENAME=$(echo "$IMAGE_DATA" | grep -o '"filename":"[^"]*"' | head -1 | cut -d'"' -f4)
            SUBFOLDER=$(echo "$IMAGE_DATA" | grep -o '"subfolder":"[^"]*"' | head -1 | cut -d'"' -f4)
            
            if [ -n "$FILENAME" ]; then
                # Download image
                TIMESTAMP=$(date +%Y%m%d-%H%M)
                if [ -n "$SUBFOLDER" ]; then
                    curl -s "$COMFYUI/view?filename=$FILENAME&subfolder=$SUBFOLDER" -o "$WORKDIR/nano_$TIMESTAMP.png"
                else
                    curl -s "$COMFYUI/view?filename=$FILENAME" -o "$WORKDIR/nano_$TIMESTAMP.png"
                fi
                
                if [ -f "$WORKDIR/nano_$TIMESTAMP.png" ] && [ -s "$WORKDIR/nano_$TIMESTAMP.png" ]; then
                    echo "✅ Saved: nano_$TIMESTAMP.png"
                    ls -lh "$WORKDIR/nano_$TIMESTAMP.png"
                    
                    # Generate description
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
                else
                    echo "❌ Download failed or empty file"
                fi
            else
                echo "❌ No filename in response"
                echo "$IMAGE_DATA"
            fi
            break
        fi
        echo "   Waiting... ($i/60)"
        sleep 2
    done
    
    echo "⏳ Timeout waiting for completion"
else
    echo "❌ Failed to queue prompt"
    echo "$RESULT"
fi
