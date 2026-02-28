#!/bin/bash

# Settings
BAR_HEIGHT=10        # Max height of bars
INTERVAL=5           # seconds between samples
DURATION=60           # total run time
SAMPLES=$((DURATION / INTERVAL))

usage_history=()

# Read total and idle times from /proc/stat
read_cpu_times() {
  # Read the “cpu” line; fields are:
  # cpu user nice system idle iowait irq softirq steal guest guest_nice
  # We sum up all fields except guest & guest_nice for simplicity.
  awk '
    /^cpu / {
      # sum all fields
      total = 0
      for (i = 2; i <= NF; i++) {
        total += $i
      }
      idle = $5     # idle is the 5th field (user,nice,system,idle, …)
      print total, idle
      exit
    }
  ' /proc/stat
}

# Compute CPU usage in percent between two snapshots
# Usage = 100 * (1 - (idle2 - idle1) / (total2 - total1))
calc_usage() {
  total1=$1; idle1=$2
  total2=$3; idle2=$4

  dt=$(( total2 - total1 ))
  di=$(( idle2 - idle1 ))
  if (( dt > 0 )); then
    # multiply before division to avoid truncation too early
    # usage_percent = (dt - di) * 100 / dt
    usage=$(( (dt - di) * 100 / dt ))
    echo "$usage"
  else
    echo "0"
  fi
}

# Draw the bar graph
draw_graph() {
  clear
  echo "CPU Usage History (each bar = $INTERVAL s, total $DURATION s)"
  echo

  for ((row = BAR_HEIGHT; row >= 1; row--)); do
    for usage in "${usage_history[@]}"; do
      # sanity check usage is integer 0–100
      if [[ "$usage" =~ ^[0-9]+$ ]]; then
        level=$(( usage * BAR_HEIGHT / 100 ))
        if (( level >= row )); then
          printf " █ "
        else
          printf "   "
        fi
      else
        printf " ? "
      fi
    done
    echo
  done

  # x-axis
  for ((i = 0; i < ${#usage_history[@]}; i++)); do
    printf "---"
  done
  echo

  # labels
  for usage in "${usage_history[@]}"; do
    if [[ "$usage" =~ ^[0-9]+$ ]]; then
      printf "%3s%%" "$usage"
    else
      printf " ??%"
    fi
  done
  echo -e "\n"
}

# Main loop
# Take first snapshot
read -r t0 i0 < <(read_cpu_times)

for ((i = 0; i < SAMPLES; i++)); do
  sleep "$INTERVAL"
  read -r t1 i1 < <(read_cpu_times)

  usage=$(calc_usage "$t0" "$i0" "$t1" "$i1")

  # shift history if too long
  usage_history+=("$usage")

  # optionally limit to last N entries (make it sliding)
  # if (( ${#usage_history[@]} > SAMPLES )); then
  #   usage_history=("${usage_history[@]:1}")
  # fi

  draw_graph

  # slide snapshots
  t0=$t1; i0=$i1
done

