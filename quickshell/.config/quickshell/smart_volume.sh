#!/bin/bash
ACTION=$1

case $ACTION in
    up)
        # -l 1.0 prevents the volume from going over 100%
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
esac

# Fetch the current volume information
VOL_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

# Check if the output contains the [MUTED] string
if [[ "$VOL_INFO" == *"[MUTED]"* ]]; then
    PCT=0
else
    # Extract the decimal (e.g., 0.55) and convert it to a whole number percentage
    PCT=$(echo "$VOL_INFO" | awk '{print int($2 * 100 + 0.5)}')
fi

# Send to OSD
if pgrep -x "qs" > /dev/null; then
    # Changed 'B' to 'V' assuming qs uses V for Volume
    qs ipc call qsIpc showOsd V "$PCT"
else
    # In battery mode, wob is running
    echo "$PCT" > "$XDG_RUNTIME_DIR/wob.fifo"
fi
