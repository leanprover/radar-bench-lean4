#!/usr/bin/env bash
set -eux

# Limit memory (all values are in KiB)
mem_total="$(awk '/MemTotal/ { print $2 }' /proc/meminfo)"
mem_limit="$((mem_total * 90 / 100))"
ulimit -v "$mem_limit"

cd "$RADAR_REPO"

if [[ -f tests/bench_other.sh ]]; then
  echo "Using tests/bench_other.sh"
  timeout -s KILL 30m tests/bench_other.sh
  "$RADAR_BENCH_REPO/rename_metrics.py" "$RADAR_OUT"
  exit
fi

cmake --preset release -DWFAIL=OFF
if make -C build/release help 2>/dev/null | grep -q bench-part2; then
  echo "Using the new bench suite."

  timeout -s KILL 30m \
    make -C build/release -j"$(nproc)" bench-part2

  mv tests/part2.measurements.jsonl "$RADAR_OUT"
  "$RADAR_BENCH_REPO/rename_metrics.py" "$RADAR_OUT"

  exit
fi

echo "Could not find benchmark suite."
exit 1
