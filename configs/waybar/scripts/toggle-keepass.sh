#!/bin/bash

# pgrep -f '[o]bs'
# echo "pgrep exit code: $?"

if ! pgrep -f '[k]eepass' | grep -v -w $$ > /dev/null; then
  echo "Keepass not running — starting..."
  keepass &
else
  echo "Keepass already running — toggling workspace..."
  hyprctl dispatch togglespecialworkspace keepass &>/dev/null
fi

