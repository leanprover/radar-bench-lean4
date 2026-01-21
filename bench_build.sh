#!/usr/bin/env bash
set -euxo pipefail

BENCH="$PWD"
REPO="$1" # absolute path to the repo to be benchmarked
OUT="$2" # absolute path to the output jsonl file

cd "$REPO"
touch build_upload_lakeprof_report

# Execute benchmark suite
if [ -f tests/bench-radar/run_build ]; then
  echo "Using the bench-radar suite."
  tests/bench-radar/run_build
elif [ -f tests/bench/run_build ]; then
  echo "Using the bench suite."
  tests/bench/run_build
else
  echo "Could not find benchmark suite."
  exit 1
fi

# Pass on measurements to radar
if [ -f measurements.jsonl ]; then
  mv measurements.jsonl "$OUT"
elif [ -f radar.jsonl ]; then
  mv radar.jsonl "$OUT"
else
  echo "Could not find benchmark results."
  exit 2
fi
