# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests>=2.32.5",
# ]
# ///

import argparse
import json
from pathlib import Path
import requests

parser = argparse.ArgumentParser()
parser.add_argument("renamings", type=Path)
parser.add_argument("admin_token", type=str)
args = parser.parse_args()

renamings_file: Path = args.renamings
admin_token: str = args.admin_token

renamings = json.loads(renamings_file.read_text())

requests.post(
    "https://radar.lean-lang.org/api/admin/repos/lean4/metrics/rename/",
    json={"metrics": renamings},
    auth=("admin", admin_token),
)
