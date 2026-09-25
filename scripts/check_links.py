#!/usr/bin/env python3
"""Check local Quarto links, anchors, and unfinished capability placeholders."""
from pathlib import Path
import html
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


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


qmd = sorted(ROOT.glob("*.qmd"))
errors = check_documents(qmd)
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
