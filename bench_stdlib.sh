#!/usr/bin/env bash
set -euxo pipefail

BENCH="$PWD"
REPO="$1" # absolute path to the repo to be benchmarked
OUT="$2" # absolute path to the output jsonl file

cd "$REPO"

if [ -d "tests/bench-radar" ]; then
  echo Using the bench-radar suite
  tests/bench-radar/run_stdlib
elif [ -d "tests/bench" ] && [ -f "tests/bench/run_stdlib" ]; then
  echo Using the bench suite
  tests/bench/run_stdlib
else
  echo Bringing my own copy of the bench-radar suite
  cp -r "$BENCH/bench-radar" tests/bench-radar
  tests/bench-radar/run_stdlib
fi

mv radar.jsonl "$OUT"
