#!/usr/bin/env python3
"""Keep chunk options in one syntax.

Quarto accepts both the R Markdown fenced options

    ```{r eval=FALSE, include=FALSE}
    ```

and the line-based form

    ```{r}
    #| eval: false
    ```

They are equivalent, so a chunk can declare the same option twice in two
different syntaxes. Tools that scan only one form then disagree with what knitr
actually does: the earlier audit produced a false positive by reading
`eval=FALSE` fences as executable, and missed chunks whose disabled state was
written in the other syntax.

This check enforces one form for the whole book: `#|` lines only, no options in
the fence. It also rejects duplicate keys inside a single chunk. Standard
library only, offline.

Run from the repo root:  python3 scripts/check_chunk_options.py [--root DIR]
Exit 1 on any finding.
"""
from pathlib import Path
import argparse
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

OPEN_RE = re.compile(r"^```\{r(.*)\}\s*$")
PIPE_RE = re.compile(r"^#\|\s*([A-Za-z][A-Za-z0-9_.-]*)\s*:")


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", type=Path, default=ROOT,
                    help="repository root to check (default: parent of scripts/)")
    args = ap.parse_args()
    root = Path(args.root).resolve()

    qmd_paths = sorted(root.glob("*.qmd"))
    if not qmd_paths:
        raise SystemExit(f"no root .qmd files under {root}")

    errors = []
    chunks = 0
    for path in qmd_paths:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        i = 0
        while i < len(lines):
            m = OPEN_RE.match(lines[i])
            if not m:
                i += 1
                continue
            chunks += 1
            header = m.group(1).strip()
            if header:
                errors.append(f"{path.name}:{i + 1}: options in the chunk "
                              f"header ({header!r}); move them to #| lines")
            keys = {}
            j = i + 1
            while j < len(lines) and lines[j].startswith("#|"):
                km = PIPE_RE.match(lines[j])
                if km:
                    key = km.group(1)
                    if key in keys:
                        errors.append(f"{path.name}:{j + 1}: option '{key}' "
                                      f"is declared twice in one chunk")
                    keys[key] = j + 1
                j += 1
            i = j

    if errors:
        print("\n".join(errors), file=sys.stderr)
        raise SystemExit(1)

    print(f"Chunk option check passed: {chunks} chunk(s), #| syntax only")


if __name__ == "__main__":
    main()
