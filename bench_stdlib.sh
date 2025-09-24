#!/usr/bin/env bash
set -euxo pipefail

BENCH=$PWD
REPO=$1 # absolute path to the repo to be benchmarked
OUT=$2 # absolute path to the output jsonl file

cd "$REPO"
cmake --preset release

# We benchmark against stage2/bin to test new optimizations.
timeout -s KILL 1h time make -C build/release -j$(nproc) stage3
export PATH=$PWD/build/release/stage2/bin:$PATH

# The extra opts used to be passed to the Makefile during benchmarking only but
# with Lake it is easier to configure them statically.
cmake \
  -B build/release/stage3 \
  -S src \
  -DLEAN_EXTRA_LAKEFILE_TOML='weakLeanArgs=["-Dprofiler=true", "-Dprofiler.threshold=9999999", "--stats"]'

cd tests/bench

# Patch temci config on older commits
if cmp -s speedcenter.exec.velcom.yaml "$BENCH/speedcenter.exec.velcom.yaml.old"; then
  cp "$BENCH/speedcenter.exec.velcom.yaml.new" speedcenter.exec.velcom.yaml
fi

timeout -s KILL 1h \
  time temci exec \
  --config speedcenter.yaml \
  --in speedcenter.exec.velcom.yaml \
  --included_blocks stdlib

temci report run_output.yaml --reporter codespeed2 \
  | python "$BENCH/convert_results.py" > "$OUT"
