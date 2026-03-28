#!/bin/bash
chosen=$(echo -e "󰐥 Schließen\n󰜉 Neustart\n󰌾 Sperren\n󰗼 Logout" | rofi -dmenu -p "System:")

case "$chosen" in
    "󰐥 Schließen") poweroff ;;
    "󰜉 Neustart") reboot ;;
    "󰌾 Sperren") hyprlock ;;
    "󰗼 Logout") niri msg action quit ;;
esac
