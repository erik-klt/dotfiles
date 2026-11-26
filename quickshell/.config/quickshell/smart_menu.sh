#!/bin/bash
if pgrep -x "qs" > /dev/null; then
    # Performance Mode: Use Quickshell IPC
    qs ipc call qsIpc toggleAppLauncher
else
    # Battery Mode: Fallback to Tofi/Legacy
    rofi-drun --drun-launch=true
fi
