#!/usr/bin/env python3
"""Check local Quarto links, anchors, chunk labels, and unfinished placeholders."""
from pathlib import Path
import argparse
import html
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

BRACE_ID_RE = re.compile(r"\{#([A-Za-z0-9_.:-]+)\}")
RAW_ID_RE = re.compile(r'<a\s+id=["\']([^"\']+)')


def slugify(text):
    text = re.sub(r"[`*_]", "", text)
    text = re.sub(r"<[^>]+>", "", text)
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9 -]", "", text)
    return re.sub(r"[- ]+", "-", text).strip("-")


def anchors(path):
    text = path.read_text(encoding="utf-8", errors="replace")
    found = set(re.findall(r"\{#([A-Za-z0-9_.:-]+)\}", text))
    found.update(re.findall(r'<a\s+id=["\']([^"\']+)', text))
    for line in text.splitlines():
        heading = re.match(r"^#{1,6}\s+(.+?)(?:\s+\{#.*\})?\s*$", line)
        if heading:
            found.add(slugify(heading.group(1)))
    for label in re.findall(r"#\|\s+label:\s*([A-Za-z0-9_.-]+)", text):
        found.add(label)
        found.add(f"fig-{label}")
    return found


def check_documents(paths):
    errors = []
    known = {p.resolve(): anchors(p) for p in paths}
    for path in paths:
        text = path.read_text(encoding="utf-8", errors="replace")
        for href in re.findall(r"\[[^\]]+\]\(([^)]+)\)", text):
            if href.startswith(("http://", "https://", "mailto:")):
                continue
            target_name, _, fragment = href.partition("#")
            target = (path.parent / target_name).resolve() if target_name else path.resolve()
            if target_name and not target.exists():
                errors.append(f"{path.name}: missing target {href}")
            if fragment and target in known and fragment not in known[target]:
                errors.append(f"{path.name}: missing anchor {href}")
    return errors


def check_anchor_uniqueness(paths, compat):
    """Cross-file `{#anchor}` uniqueness.

    Quarto renders every root .qmd into one book, and a `{#id}` heading attribute
    claims that id for the whole book, so two files using the same one produce one
    id that silently wins and the other anchor resolves to the wrong section - the
    kind of defect a link check cannot see because both links are valid.

    A raw `<a id="...">` in another file is a different thing: it is the
    compatibility-alias style used by the legacy landing pages. It counts as a
    claim only when it does not route to the file that owns the `{#id}`, which is
    how the deliberate aliases on enrichplot.qmd read. Anchors listed in
    scripts/anchor_compat.txt may appear more than once regardless: they are
    intentional aliases kept for old deep links.
    """
    brace_owner = {}
    raw_claims = {}
    for path in paths:
        text = path.read_text(encoding="utf-8", errors="replace")
        lines = text.splitlines()
        for anchor in set(BRACE_ID_RE.findall(text)):
            brace_owner.setdefault(anchor, set()).add(path.name)
        for lineno, line in enumerate(lines, 1):
            for anchor in RAW_ID_RE.findall(line):
                # Look ahead a few lines for the routing link of an alias block.
                routed = any(re.search(r"\]\([^)]*#%s\)" % re.escape(anchor), tail)
                             for tail in lines[lineno:lineno + 4])
                if routed:
                    continue
                raw_claims.setdefault(anchor, []).append((path.name, lineno))

    errors = []
    for anchor in sorted(brace_owner):
        if anchor in compat:
            continue
        claimants = set(brace_owner[anchor]) | {f for f, _ in raw_claims.get(anchor, [])}
        if len(claimants) > 1:
            owners = ", ".join(sorted(brace_owner[anchor]))
            extra = ", ".join(f"{f}:{n}" for f, n in raw_claims.get(anchor, []))
            detail = f"owned by {owners}"
            if extra:
                detail += f" and claimed by a raw <a id> at {extra}"
            errors.append(f"anchor '{anchor}' is used in more than one file "
                          f"({detail}); add it to scripts/anchor_compat.txt if the "
                          f"second one is a deliberate compatibility alias")
    for anchor in sorted(raw_claims):
        if anchor in compat or anchor in brace_owner:
            continue
        if len({f for f, _ in raw_claims[anchor]}) > 1:
            where = ", ".join(f"{f}:{n}" for f, n in raw_claims[anchor])
            errors.append(f"anchor id '{anchor}' is declared with <a id> in more "
                          f"than one file ({where})")
    return errors


def load_compat(root):
    path = root / "scripts" / "anchor_compat.txt"
    if not path.exists():
        return set()
    allowed = set()
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        entry = line.split("#", 1)[0].strip()
        if entry:
            allowed.add(entry)
    return allowed


parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
parser.add_argument("--root", type=Path, default=ROOT,
                    help="repository root to check (default: parent of scripts/)")
args = parser.parse_args()
ROOT = args.root.resolve()

qmd = sorted(ROOT.glob("*.qmd"))
errors = check_documents(qmd)
errors += check_anchor_uniqueness(qmd, load_compat(ROOT))

# Chunk labels are book-wide identifiers too: knitr/Quarto resolve them across
# the whole book, so two chapters reusing `load-packages` is the same latent
# defect as a duplicate {#anchor}. Nothing references them with @ref today,
# which is why the collision went unnoticed.
label_owners = {}
for path in qmd:
    text = path.read_text(encoding="utf-8", errors="replace")
    for label in re.findall(r"#\|\s+label:\s*([A-Za-z0-9_.-]+)", text):
        label_owners.setdefault(label, set()).add(path.name)
for label, owners in sorted(label_owners.items()):
    if len(owners) > 1:
        errors.append(f"chunk label '{label}' is used in more than one file "
                      f"({', '.join(sorted(owners))})")

for path in qmd:
    if "TODO-" in path.read_text(encoding="utf-8", errors="replace"):
        errors.append(f"{path.name}: unfinished TODO anchor")

if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)

print(f"Book source link check passed: {len(qmd)} QMD files")

# If docs exist, also check generated HTML file targets.
docs = ROOT / "docs"
if docs.exists():
    html_files = sorted(docs.glob("*.html"))
    html_errors = []
    for page in html_files:
        text = page.read_text(encoding="utf-8", errors="replace")
        ids = set(re.findall(r'\bid=["\']([^"\']+)', text))
        for href in re.findall(r'href=["\']([^"\']+)["\']', text):
            if href.startswith(("http://", "https://", "mailto:", "#", "javascript:")):
                continue
            target_name, _, fragment = href.partition("#")
            target = page.parent / html.unescape(target_name)
            if not target.exists():
                html_errors.append(f"{page.name}: missing target {href}")
            elif fragment and target.suffix == ".html":
                target_ids = set(re.findall(r'\bid=["\']([^"\']+)', target.read_text(encoding="utf-8", errors="replace")))
                if fragment not in target_ids:
                    html_errors.append(f"{page.name}: missing generated anchor {href}")
    if html_errors:
        print("\n".join(html_errors), file=sys.stderr)
        raise SystemExit(1)
    print(f"Generated HTML link check passed: {len(html_files)} pages")
