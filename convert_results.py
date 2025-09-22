# Convert the output of the codespeed2 reporter of Kha's temci fork to the
# output format expected by radar.
#
# https://temci.readthedocs.io/en/latest/temci_report.html
# https://github.com/leanprover/velcom/blob/main/docs/bench_repo_specification.md


import json
import statistics
import sys


def eprint(*args) -> None:
    print(*args, file=sys.stderr)


def parse_direction(name: str | None) -> int:
    if not name:
        return 0
    return {"LESS_IS_BETTER": -1, "MORE_IS_BETTER": 1}.get(name, 0)


DIRECTIONS = {
    "LESS_IS_BETTER": -1,
    "MORE_IS_BETTER": 1,
    "NEUTRAL": 0,
}

data = json.loads(sys.stdin.read())

for benchmark, metrics in data.items():
    for metric, measurements in metrics.items():
        if "error" in measurements:
            eprint(f"Error in {benchmark!r} {metric!r}: {measurements['error']}")
            continue

        values: list[int | float] = measurements["results"]
        value = statistics.fmean(values)

        unit: str | None = measurements.get("unit")
        unit = unit if unit else None  # "" -> None

        direction_str: str = measurements.get("resultInterpretation", "")
        direction = DIRECTIONS.get(direction_str, 0)

        result = {
            "metric": f"{benchmark}//{metric}",
            "value": value,
            "unit": unit,
            "direction": direction,
        }
        print(json.dumps(result))
