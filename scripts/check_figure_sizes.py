#!/usr/bin/env python3
"""Check that no figure the reader has to download is unreasonably large.

Enrichment plots draw one graphical element per gene, so their SVG output grows
with the size of the gene set: a four-panel cnetplot() of a compareCluster()
result came out at 13.2 MB, and a single large figure was enough to make the
page take minutes to render (issue #41). The pages themselves stay small --
the weight is entirely in the referenced image.

Measuring every file under docs/ would be wrong. Quarto does not remove the
previous build's figure files, so a directory scan sees stale artifacts that
nothing links to and reports problems that no reader has. This walks the
generated HTML instead and measures only the images a page actually references,
which is the same set the browser downloads.

The fix for an oversized figure is in _common.R: add `#| fig-format: png` (and
usually `#| fig-dpi: 150`) so R draws a raster directly. Do NOT reach for the
svg2png() helper there -- ImageMagick's SVG renderer silently drops the curves
and the ranked-list panel, turning a heavy figure into an empty one.
"""
from pathlib import Path
import argparse
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

IMG_SRC_RE = re.compile(r"<img[^>]*\ssrc=[\"']([^\"']+)[\"']", re.I)

# 4 MiB. The heaviest figure that is fine as a vector was 3.4 MB; the defect
# this exists to catch was 13.2 MB. A limit set just under the defect would also
# flag the 3.4 MB figure and teach everyone to ignore the check.
DEFAULT_LIMIT = 4 * 1024 * 1024


def referenced_images(docs: Path):
    """Map each page to the images it references, resolved to real paths."""
    for html_file in sorted(docs.glob("*.html")):
        text = html_file.read_text(encoding="utf-8", errors="replace")
        for src in IMG_SRC_RE.findall(text):
            if re.match(r"^(?:[a-z]+:|//|data:)", src, re.I):
                continue  # external or inline, not a build artifact
            path = (docs / src.split("#")[0]).resolve()
            yield html_file, path


def load_allowlist(path: Path):
    """Figure names that may exceed the limit, one per line, with a reason."""
    allowed = {}
    if not path.exists():
        return allowed
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        name, _, reason = line.partition("#")
        allowed[name.strip()] = reason.strip()
    return allowed


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--docs", default=str(ROOT / "docs"), help="rendered site directory")
    ap.add_argument("--limit", type=int, default=DEFAULT_LIMIT,
                    help=f"per-image byte limit (default {DEFAULT_LIMIT})")
    ap.add_argument("--allowlist", default=str(ROOT / "scripts" / "figure_size_allowlist.txt"))
    ap.add_argument("--top", type=int, default=5, help="how many largest images to list")
    args = ap.parse_args()

    docs = Path(args.docs)
    if not docs.exists():
        raise SystemExit(f"Rendered site directory does not exist: {docs}\n"
                         f"Run `quarto render` first -- this check reads its output.")

    allowlist = load_allowlist(Path(args.allowlist))

    sizes = {}          # path -> size in bytes
    pages = {}          # path -> set of pages referencing it
    missing = []
    for html_file, image in referenced_images(docs):
        if not image.exists():
            missing.append((html_file, image))
            continue
        sizes[image] = image.stat().st_size
        pages.setdefault(image, set()).add(html_file.name)

    if missing:
        for html_file, image in missing[:5]:
            print(f"ERROR: {html_file.name} references a missing image: {image.name}",
                  file=sys.stderr)
        print(f"figure size check failed: {len(missing)} broken image reference(s)",
              file=sys.stderr)
        return 1

    oversized = [(size, path) for path, size in sizes.items() if size > args.limit]
    oversized.sort(reverse=True)
    hard = []
    for size, path in oversized:
        if path.name in allowlist:
            continue
        hard.append((size, path))

    largest = sorted(((size, path) for path, size in sizes.items()), reverse=True)
    print(f"measured {len(sizes)} referenced image(s) across {len(list(docs.glob('*.html')))} pages; "
          f"total {sum(sizes.values()) / 1048576:.1f} MB, limit {args.limit / 1048576:.1f} MB per image")
    for size, path in largest[: args.top]:
        note = " (allowlisted)" if path.name in allowlist else ""
        print(f"  {size / 1048576:7.2f} MB  {path.name}{note}")

    if hard:
        for size, path in hard:
            where = ", ".join(sorted(pages[path]))
            print(f"ERROR: {path.name} is {size / 1048576:.2f} MB, over the "
                  f"{args.limit / 1048576:.1f} MB limit (referenced by {where}).\n"
                  f"  Add `#| fig-format: png` to that chunk, or list the figure in\n"
                  f"  {args.allowlist} with the reason it cannot be made smaller.",
                  file=sys.stderr)
        print(f"figure size check failed: {len(hard)} oversized image(s)", file=sys.stderr)
        return 1

    print("figure size check passed: 0 oversized images")
    return 0


if __name__ == "__main__":
    sys.exit(main())