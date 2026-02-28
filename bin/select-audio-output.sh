#!/usr/bin/env bash

select_output() {
  local selection=$1
  if [ -n "$selection" ]; then
    device=$(pactl list sinks | grep -C2 -F "Description: $selection" | grep Name | grep -v "alsa_output" | cut -d: -f2 | xargs)
    if pactl set-default-sink "$device"; then
      notify-send -t 2000 -r 8 -u low "Activated: $selection"
    else
      notify-send -t 2000 -r 8 -u critical "Error activating $selection"
    fi
  else
    pactl list sinks | grep -ie "Description:" | awk -F ': ' '{print $2}' | sort
  fi
}


selected_output=$(select_output | rofi -dmenu -theme "output-selector")
select_output "${selected_output}"
