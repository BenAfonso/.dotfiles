#!/usr/bin/env bash

# Check if Discord process is running (case-insensitive)
if pgrep -ix discord > /dev/null; then
    # 1. Focus the left monitor (and silence the "ok" output)
    hyprctl dispatch focusmonitor l > /dev/null
    
    # 2. Grab the name of the active workspace on that left monitor
    WS=$(hyprctl activeworkspace -j | jq -r '.name')
    
    # 3. Focus the Discord window using classic dispatcher syntax (case-insensitive regex)
    hyprctl dispatch focuswindow 'class:^[Dd]iscord$' > /dev/null
    
    # 4. Teleport it to the active left workspace
    hyprctl dispatch movetoworkspace "$WS" > /dev/null
else
    # If completely closed, focus left monitor and spawn it fresh
    hyprctl dispatch focusmonitor l > /dev/null
    discord &
fi
