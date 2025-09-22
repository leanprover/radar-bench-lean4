# Convert the output of the codespeed2 reporter of Kha's temci fork to the
# output format expected by radar.
#
# https://temci.readthedocs.io/en/latest/temci_report.html
# https://github.com/leanprover/velcom/blob/main/docs/bench_repo_specification.md


import json
import sys

data = json.loads(sys.stdin.read())

for benchmark, metrics in data.items():
    for metric, measurements in metrics.items():
        print(f"{benchmark=!r} {metric=!r} {measurements=!r}")
