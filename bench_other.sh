#!/usr/bin/env bash
set -eux

BENCH="$PWD"
REPO="$1" # absolute path to the repo to be benchmarked
OUT="$2" # absolute path to the output jsonl file

# Limit memory (all values are in KiB)
mem_total="$(awk '/MemTotal/ { print $2 }' /proc/meminfo)"
mem_limit="$((mem_total * 90 / 100))"
ulimit -v "$mem_limit"

cd "$REPO"
cmake --preset release -DWFAIL=OFF

if make -C build/release help 2>/dev/null | grep -q bench-part2; then
  echo "Using the new bench suite."

  timeout -s KILL 30m \
    make -C build/release -j"$(nproc)" bench-part2

  mv tests/part2.measurements.jsonl "$OUT"
  "$BENCH/rename_metrics.py" "$OUT"

  exit
fi

echo "Could not find benchmark suite."
exit 1
