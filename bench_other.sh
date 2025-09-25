#!/usr/bin/env bash
set -euxo pipefail

BENCH=$PWD
REPO=$1 # absolute path to the repo to be benchmarked
OUT=$2 # absolute path to the output jsonl file

cd "$REPO"
cmake --preset release

# We benchmark against stage2/bin to test new optimizations.
timeout -s KILL 1h time make -C build/release -j$(nproc) stage2
export PATH=$PWD/build/release/stage2/bin:$PATH

cd tests/bench

# Patch temci config on older commits
if cmp -s speedcenter.exec.velcom.yaml "$BENCH/speedcenter.exec.velcom.yaml.old"; then
  cp "$BENCH/speedcenter.exec.velcom.yaml.new" speedcenter.exec.velcom.yaml
fi

timeout -s KILL 1h \
  time temci exec \
  --config speedcenter.yaml \
  --in speedcenter.exec.velcom.yaml \
  --included_blocks other

temci report run_output.yaml --reporter codespeed2 \
  | python "$BENCH/convert_results.py" > "$OUT"
