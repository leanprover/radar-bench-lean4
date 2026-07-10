#!/usr/bin/env bash
set -eux

export LAKEPROF_UPLOAD_URL="https://speed.lean-lang.org/lean4-out/"

# Limit memory (all values are in KiB)
mem_total="$(awk '/MemTotal/ { print $2 }' /proc/meminfo)"
mem_limit="$((mem_total * 90 / 100))"
ulimit -v "$mem_limit"

cd "$RADAR_REPO"
timeout -s KILL 30m tests/bench_build.sh
"$RADAR_BENCH_REPO/rename_metrics.py" "$RADAR_OUT"
