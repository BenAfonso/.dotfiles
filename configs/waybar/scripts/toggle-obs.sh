#!/bin/bash

pgrep -f '[o]bs'
echo "pgrep exit code: $?"

if ! pgrep -f '[o]bs' | grep -v -w $$ > /dev/null; then
  echo "OBS not running — starting..."
  sudo /sbin/modprobe v4l2loopback
  obs &
else
  echo "OBS already running — toggling workspace..."
  hyprctl dispatch togglespecialworkspace obs &>/dev/null
fi

