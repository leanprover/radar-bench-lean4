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
cmake --preset release

if make -C build/release help 2>/dev/null | grep -q bench-part2; then
  echo "Using the new bench suite."

  timeout -s KILL 30m \
    make -C build/release -j"$(nproc)" bench-part2

  mv tests/part2.measurements.jsonl "$OUT"
  "$BENCH/rename_metrics.py" "$OUT"

  exit
fi

# We benchmark against stage2/bin to test new optimizations.
timeout -s KILL 1h time make -C build/release -j$(nproc) stage2
export PATH=$PWD/build/release/stage2/bin:$PATH

cd tests/bench

timeout -s KILL 1h \
  time temci exec \
  --config speedcenter.yaml \
  --in speedcenter.exec.velcom.yaml \
  --included_blocks other

temci report run_output.yaml --reporter codespeed2 \
  | python "$BENCH/convert_results.py" > "$OUT"

"$BENCH/rename_metrics.py" "$OUT"
