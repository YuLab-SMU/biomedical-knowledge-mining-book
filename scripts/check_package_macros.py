#!/usr/bin/env python3
"""Verify the Quarto package macros in the book's prose against a registry.

`r Biocpkg("X")` renders a link to bioconductor.org and `r CRANpkg("X")` a link
to cran.r-project.org, so a macro that names the wrong registry sends readers to
a page that either 404s or - as happened with `Biocpkg("gson")` - returns HTTP
200 while displaying Bioconductor's *Removed Packages* notice. Neither
check_links.py nor check_navigation.py can see this: the URL is well-formed and
resolves.

Ground truth lives in scripts/package_registry.yml (`key: cran|bioconductor|github`,
hand-maintained). A package absent from the registry is reported as UNCHECKED so
that adding a package to the book is not a hard CI failure.

Run from the repo root:  python3 scripts/check_package_macros.py [--root DIR]
Exit 1 on any contradiction. Standard library only, no network, no R.
"""
from pathlib import Path
import argparse
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

MACRO_RE = re.compile(r"\br\s+(Biocpkg|CRANpkg|Githubpkg)\(\s*[\"']([^\"']+)[\"']\s*\)")
MACRO_REGISTRY = {
    "Biocpkg": "bioconductor",
    "CRANpkg": "cran",
    "Githubpkg": "github",
}


def load_registry(path):
    """Parse the flat `key: value` YAML by hand - stdlib only."""
    registry = {}
    for lineno, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        text = line.split("#", 1)[0].strip()
        if not text or ":" not in text:
            continue
        key, _, value = text.partition(":")
        key, value = key.strip(), value.strip().lower()
        if not key:
            continue
        if value not in ("cran", "bioconductor", "github"):
            raise SystemExit(f"{path.name}:{lineno}: registry value '{value}' "
                             f"must be cran, bioconductor or github")
        registry[key] = value
    return registry


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", type=Path, default=ROOT,
                    help="repository root to check (default: parent of scripts/)")
    args = ap.parse_args()
    root = Path(args.root).resolve()

    registry_path = root / "scripts" / "package_registry.yml"
    if not registry_path.exists():
        raise SystemExit(f"missing registry: {registry_path}")
    registry = load_registry(registry_path)

    qmd_paths = sorted(root.glob("*.qmd"))
    if not qmd_paths:
        raise SystemExit(f"no root .qmd files under {root}")

    errors = []
    notes = []
    unchecked = set()
    usages = 0

    for path in qmd_paths:
        for lineno, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
            for macro, package in MACRO_RE.findall(line):
                usages += 1
                expected = registry.get(package)
                if expected is None:
                    unchecked.add(package)
                    continue
                used = MACRO_REGISTRY[macro]
                if used != expected:
                    errors.append(
                        f"{path.name}:{lineno}: {macro}(\"{package}\") points at "
                        f"{used}, but scripts/package_registry.yml says {package} "
                        f"is {expected} -> use "
                        f"{'Biocpkg' if expected == 'bioconductor' else 'CRANpkg' if expected == 'cran' else 'Githubpkg'}(\"{package}\")")

    for package in sorted(unchecked):
        notes.append(f"UNCHECKED: '{package}' is mentioned by a macro but has no "
                     f"entry in scripts/package_registry.yml")

    for msg in errors:
        print(f"ERROR: {msg}", file=sys.stderr)
    for msg in notes:
        print(msg)

    if errors:
        print(f"package macro check failed: {usages} macro usages scanned, "
              f"{len(errors)} errors", file=sys.stderr)
        raise SystemExit(1)

    print(f"package macro check passed: {usages} macro usages across "
          f"{len(qmd_paths)} QMD files, {len(registry)} registry entries, "
          f"0 errors ({len(unchecked)} unchecked)")


if __name__ == "__main__":
    main()
