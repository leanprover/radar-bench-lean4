#!/usr/bin/env bash
set -eux

# Limit memory (all values are in KiB)
mem_total="$(awk '/MemTotal/ { print $2 }' /proc/meminfo)"
mem_limit="$((mem_total * 90 / 100))"
ulimit -v "$mem_limit"

cd "$RADAR_REPO"

if [[ -f tests/bench_build.sh ]]; then
  echo "Using tests/bench_build.sh"
  timeout -s KILL 30m tests/bench_build.sh
  "$RADAR_BENCH_REPO/rename_metrics.py" "$RADAR_OUT"
  exit
fi

echo "Could not find benchmark suite."
exit 1
