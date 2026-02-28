#!/bin/bash
# set-hdmi-output.sh

CARD="alsa_card.pci-0000_01_00.1"

case "$1" in
  screens) PROFILE="output:hdmi-stereo" ;;
  tv) PROFILE="output:hdmi-stereo-extra2" ;;
  *) echo "Usage: $0 [screens|tv]"; exit 1 ;;
esac

pactl set-card-profile "$CARD" "$PROFILE"
