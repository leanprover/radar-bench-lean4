# Lean4 benchmark suite

This directory contains the new lean4 benchmark suite.
It is built around [radar](github.com/leanprover/radar)
and benchmark results can be viewed on the [Lean FRO radar instance](https://radar.lean-lang.org/repos/lean4).
To run the entire benchmark suite, execute the script called `run`.

Benchmarks are organized into subdirectories.
Each benchmark directory must contain a script called `run` that executes the benchmark,
as well as any additional benchmark-specific required files.
Ideally, each benchmark directory also contains a `README.md` explaining the benchmark.

A benchmark's `run` script emits measurements as JSON objects
as defined by radar's [bench repo specification](https://github.com/leanprover/radar?tab=readme-ov-file#bench-repo-specification).
It can emit the measurement in one of two ways:

1. Append the measurement to the file `radar.jsonl` in the repository root.
   This file follows the [JSON Lines](https://jsonlines.org/) format.
2. Print a line on stdout or stderr containing `radar::measurement=` followed by the measurement.
   After the measurement, only whitespace is allowed.
