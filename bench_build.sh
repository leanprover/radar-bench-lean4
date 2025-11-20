#!/usr/bin/env bash
set -euxo pipefail

BENCH="$PWD"
REPO="$1" # absolute path to the repo to be benchmarked
OUT="$2" # absolute path to the output jsonl file

cd "$REPO"
touch build_upload_lakeprof_report

if [ -d "tests/bench-radar" ]; then
  echo Using the bench-radar suite
  tests/bench-radar/run_build
elif [ -d "tests/bench" ] && [ -f "tests/bench/run_build" ]; then
  echo Using the bench suite
  tests/bench/run_build
else
  echo Bringing my own copy of the bench-radar suite
  cp -r "$BENCH/bench-radar" tests/bench-radar
  tests/bench-radar/run_build
fi

mv radar.jsonl "$OUT"
