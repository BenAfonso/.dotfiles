#!/usr/bin/env bash
# ~/.config/eww/scripts/net/net_vpn_status.sh
# Show VPN status + country (for Eww)

if /usr/bin/nordvpn status 2>/dev/null | grep -q "Connected"; then
  country=$(curl -s ifconfig.co/country 2>/dev/null)
  [[ -z "$country" ]] && country="UNKNOWN"
  echo "[ФАНТОМ]"
else
  echo "KAPUTT"
fi

