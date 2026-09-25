#!/usr/bin/env python3
"""Validate that every root QMD chapter is navigated exactly once."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
config = (ROOT / "_quarto.yml").read_text(encoding="utf-8")
nav = set(re.findall(r"^\s*-\s+(?:part:\s+)?([^\s#]+\.qmd)\s*$", config, re.M))
qmd = {path.name for path in ROOT.glob("*.qmd")}

missing = sorted(qmd - nav)
unknown = sorted(nav - qmd)
if missing or unknown:
    if missing:
        print("Missing from _quarto.yml:", ", ".join(missing))
    if unknown:
        print("Referenced but not found:", ", ".join(unknown))
    raise SystemExit(1)

for path in ROOT.glob("*.qmd"):
    if "TODO-" in path.read_text(encoding="utf-8", errors="replace"):
        raise SystemExit(f"unfinished TODO anchor in {path.name}")

print(f"Navigation and TODO checks passed: {len(qmd)} QMD files")
