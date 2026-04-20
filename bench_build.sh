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

if make -C build/release help 2>/dev/null | grep -q bench-part1; then
  echo "Using the new bench suite."

  timeout -s KILL 30m \
    make -C build/release -j"$(nproc)" bench-part1

  mv tests/part1.measurements.jsonl "$OUT"
  "$BENCH/rename_metrics.py" "$OUT"

  pushd tests/bench/build
  if [[ -f run_upload_lakeprof_report ]]; then
    ./run_upload_lakeprof_report
  else
    ./lakeprof_report_upload.py
  fi
  popd

  exit
fi

if [[ -f tests/bench-radar/run_build ]]; then
  echo "Using the bench-radar suite."

  # `cmake` doesn't like to be called more than once before `make` is called.
  # https://github.com/leanprover/lean4/pull/12598
  rm -rf build

  touch build_upload_lakeprof_report

  timeout -s KILL 1h \
    tests/bench-radar/run_build

  mv measurements.jsonl "$OUT"
  "$BENCH/rename_metrics.py" "$OUT"

  exit
fi

echo "Could not find benchmark suite."
exit 1
