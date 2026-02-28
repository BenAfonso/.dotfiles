#!/bin/bash

# Get current workspace ID
ws=$(hyprctl activeworkspace -j | jq '.id')

# Get current layout for the workspace
layout=$(hyprctl workspaces -j | jq -r ".[] | select(.id == $ws) | .layout")

# Toggle layout
if [[ "$layout" == "dwindle" ]]; then
        echo "AD"
    hyprctl dispatch layoutmsg "workspace,$ws,master"
else
        echo $ws
    hyprctl dispatch layoutmsg "workspace,$ws,dwindle"
fi
