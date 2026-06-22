import argparse
import json
import urllib.request
from pathlib import Path
from typing import TypedDict


def prompt(message: str, options: str = "Yn") -> str:
    default: str | None = None
    for c in options:
        if c.isupper():
            default = c.lower()
            break

    options = options.lower()
    options_display = "/".join(c.upper() if c == default else c for c in options)

    while True:
        response = input(f"{message} [{options_display}]: ").strip().lower()
        if not response and default:
            return default
        elif response in options.lower():
            return response
        else:
            print(f"Please enter {options_display}.")


class Args:
    first: str
    second: str


parser = argparse.ArgumentParser()
parser.add_argument("first", help="first commit sha")
parser.add_argument("second", help="second commit sha")
args = parser.parse_args(namespace=Args())


renamings_file: Path = Path(__file__).parent / "renamings.json"
renamings: dict[str, str | None] = json.loads(renamings_file.read_text())

ignorings_file: Path = Path(__file__).parent / "ignorings.json"
ignorings: set[str] = set(json.loads(ignorings_file.read_text()))


def save_renamings():
    renamings_file.write_text(json.dumps(renamings, indent=2, sort_keys=True) + "\n")


def save_ignorings():
    ignorings_file.write_text(
        json.dumps(list(sorted(ignorings)), indent=2, sort_keys=True) + "\n"
    )


def rename(metric: str) -> str:
    while (new_metric := renamings.get(metric)) is not None:
        metric = new_metric
    return metric


class Measurement(TypedDict):
    metric: str
    first: float | None
    second: float | None


def fetch_measurements(first: str, second: str) -> list[Measurement]:
    url = f"https://radar.lean-lang.org/api/compare/lean4/{first}/{second}/"
    with urllib.request.urlopen(url) as response:
        data = json.load(response)
    return data["comparison"]["measurements"]


measurements = fetch_measurements(args.first, args.second)

metrics_first = {rename(m["metric"]) for m in measurements if m["first"] is not None}
metrics_second = {rename(m["metric"]) for m in measurements if m["second"] is not None}

only_in_first = metrics_first - metrics_second - ignorings
topics: dict[str, str] = {}
for metric in sorted(only_in_first):
    topic, *category = metric.rsplit("//", 1)
    if topic in topics:
        while topic in topics:
            topic = topics[topic]
        new_metric = "//".join([topic] + category)
        renamings[metric] = new_metric
        save_renamings()

        print(f"{metric} :: {new_metric}")
        continue

    print()
    print(f"{metric} :: ???")
    answer = prompt("[r]ename, rename [t]opic, [i]gnore?", "rTi")

    if answer == "r":
        new_metric = input("New metric: ").strip()
        print()

        renamings[metric] = new_metric
        save_renamings()

        print(f"{metric} :: {new_metric}")
        continue

    if answer == "t":
        new_topic = input("New topic: ").strip()
        print()

        topics[topic] = new_topic
        new_metric = "//".join([new_topic] + category)
        renamings[metric] = new_metric
        save_renamings()

        print(f"{metric} :: {new_metric}")
        continue

    assert answer == "i"
    ignorings.add(metric)
    save_ignorings()

# Just to be sure
save_renamings()
save_ignorings()
