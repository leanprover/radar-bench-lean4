#!/usr/bin/env python3

import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("measurements", type=Path)
args = parser.parse_args()

measurements_file: Path = args.measurements
measurements: list[str] = []

renamings_file: Path = Path(__file__).parent / "renamings.json"
renamings: dict[str, str] = json.loads(renamings_file.read_text())

with open(measurements_file) as f:
    for line in f:
        measurement = json.loads(line)

        metric = measurement["metric"]
        while metric in renamings:
            metric = renamings[metric]
        measurement["metric"] = metric

        measurements.append(json.dumps(measurement))

with open(measurements_file, "w") as f:
    for line in measurements:
        f.write(f"{line}\n")
