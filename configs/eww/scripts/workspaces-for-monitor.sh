monitorID="${1:-1}"
hyprctl workspaces -j | jq -r ".[] | select(.monitorID == $monitorID and .id >= 0)"
