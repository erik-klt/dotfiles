#!/bin/bash
ACTION=$1

case $ACTION in
    up)
        brightnessctl -q s 5%+
        ;;
    down)
        brightnessctl -q s 5%-
        ;;
esac

# Explicitly target ONLY the screen backlight (-c backlight) and strip the % sign
PCT=$(brightnessctl -c backlight -m | awk -F, '{print $4}' | tr -d '%')

# Use a case-insensitive check just to be safe
if pgrep -i "qs" > /dev/null; then
    qs ipc call qsIpc showOsd B "$PCT"
else
    # Fallback
    echo "$PCT" > $XDG_RUNTIME_DIR/wob.fifo
fi
