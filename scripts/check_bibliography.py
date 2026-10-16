#!/usr/bin/env python3
"""Offline source checks for references.bib and the book's citation keys.

check_links.py and check_navigation.py only validate link targets and the
nav list, so this set of defects used to slip through a green CI:

  * two bib entries sharing one key (the second silently wins in BibTeX);
  * a `doi` field holding an ISSN-article id, a PMID, or a CiteSeerX id;
  * a key cited in prose that no bib entry defines;
  * an author item written `Surname Given` without a comma, which BibTeX
    reads as given=Surname, family=Given, mis-attributing the work;
  * mojibake from a lost encoding (B?hm, K?lbl, T?rne) in a name or title;
  * empty fields and keys that only survive inside an HTML comment;
  * the same key cited twice in one paragraph.

Run from the repo root:  python3 scripts/check_bibliography.py [--root DIR]
Exit 1 when any ERROR-level finding exists. WARN findings are printed but do
not fail. Standard library only, no network, no R.
"""
from pathlib import Path
import argparse
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

DOI_RE = re.compile(r"^10\.[0-9]{4,9}/")
# A citation key is `@key` standing on its own. The lookbehind rejects S4 slot
# access, which always glues an identifier to the `@` (`res@result`, `x@keytype`).
CITE_RE = re.compile(r"(?<![A-Za-z0-9_.\-])@([A-Za-z][A-Za-z0-9_.\-]*)")
FIELD_RE = re.compile(r"[A-Za-z]\w*[ \t]*=[ \t]*")
FENCE_RE = re.compile(r"^[ \t]*(```|~~~).*?^[ \t]*\1[ \t]*$", re.M | re.S)
COMMENT_RE = re.compile(r"<!--.*?-->", re.S)
# `letter?letter` is the signature of a non-ASCII letter destroyed by a wrong
# encoding: B?hm for B\"ohm, K?lbl for K\"olbl, T?rne for T\"orne.
MOJIBAKE_RE = re.compile(r"[A-Za-z\xc0-\xff]\?[A-Za-z\xc0-\xff]")

# S4 slot access (`res@result`, `x@keytype`, `edox2@termsim`) and Quarto
# cross-references (`@sec-`, `@fig-`, `@tbl-`) look like citations but are not.
# `@media` is CSS and `@hku.hk` is an e-mail fragment.
NON_CITE_PREFIXES = ("sec-", "fig-", "tbl-")
NON_CITE_TOKENS = {"keytype", "result", "ontology", "media", "hku"}
# Also slot access: the token before the dot is a slot name.
NON_CITE_DOTTED_HEADS = NON_CITE_TOKENS

# Audited exemptions for check (5). These entries are written in
# `Given Family` order throughout, so BibTeX's last-word-is-surname rule reads
# them correctly and the missing comma is not a defect. The exemption is keyed
# by bib key and only applies while EVERY item of the list is comma-less, so a
# newly added inverted name (`Resnik Philip`) in a `Family, Given` entry is
# still an ERROR. Drop a key from this list when its author field is
# normalized to `Family, Given`.
FIRST_LAST_AUTHOR_KEYS = {
    "jiang_semantic_1997",
    "lin_information-theoretic_1998",
    "lord_semantic_2003",
    "schlicker_new_2006",
    "wang_new_2007",
    "yu2010",
}

NAME_FIELDS = ("author", "editor")
TEXT_FIELDS = ("author", "title", "subtitle", "shorttitle", "journal", "journaltitle")


# --------------------------------------------------------------- bib parsing

def _match_close(text, open_idx):
    """Index of the brace closing the one at open_idx, or -1 if unbalanced."""
    depth = 0
    for i in range(open_idx, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return i
    return -1


def _top_level_comma(body):
    depth = 0
    for i, ch in enumerate(body):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        elif ch == "," and depth == 0:
            return i
    return -1


def split_fields(fields):
    """Split a bib entry body into [(name, raw_value)] at brace depth 0."""
    out = []
    i = 0
    n = len(fields)
    while i < n:
        m = FIELD_RE.match(fields, i)
        if not m:
            i += 1
            continue
        name = m.group(0).split("=")[0].strip().lower()
        j = value_start = m.end()
        depth = 0
        while j < n:
            ch = fields[j]
            if ch == "{":
                depth += 1
            elif ch == "}":
                if depth == 0:
                    break
                depth -= 1
            elif ch == "," and depth == 0:
                break
            j += 1
        out.append((name, fields[value_start:j].strip()))
        i = j + 1
    return out


def parse_bib(text):
    """Return [(key, kind, line, [(field, value)])] for every top-level entry."""
    entries = []
    i = 0
    while True:
        at = text.find("@", i)
        if at < 0:
            break
        head = re.match(r"@[A-Za-z]+\{", text[at:])
        if not head:
            i = at + 1
            continue
        brace = at + head.end() - 1
        close = _match_close(text, brace)
        if close < 0:
            break
        body = text[brace + 1:close]
        kind = text[at + 1:brace].strip().lower()
        comma = _top_level_comma(body)
        key = (body[:comma] if comma >= 0 else body).strip()
        fields = split_fields(body[comma + 1:]) if comma >= 0 else []
        entries.append((key, kind, text.count("\n", 0, at) + 1, fields))
        i = close + 1
    return entries


def clean_value(raw):
    """Strip the outer brace or quote wrapper of a field value."""
    v = raw.strip()
    if v.startswith("{") and v.endswith("}"):
        return v[1:-1]
    if v.startswith('"') and v.endswith('"'):
        return v[1:-1]
    return v


def split_authors(value):
    """Split a BibTeX author list on the literal " and " at brace depth 0."""
    parts = []
    depth = 0
    buf = []
    i = 0
    while i < len(value):
        ch = value[i]
        if ch == "{":
            depth += 1
            buf.append(ch)
            i += 1
        elif ch == "}":
            depth -= 1
            buf.append(ch)
            i += 1
        elif depth == 0 and value.startswith(" and ", i):
            parts.append("".join(buf).strip())
            buf = []
            i += 5
        else:
            buf.append(ch)
            i += 1
    parts.append("".join(buf).strip())
    return [p for p in parts if p]


# ------------------------------------------------------------------- prose

def strip_prose(text):
    """Remove fenced code blocks and HTML comment blocks from a .qmd body."""
    return COMMENT_RE.sub(" ", FENCE_RE.sub("", text))


def is_citation_token(token):
    if token.startswith(NON_CITE_PREFIXES):
        return False
    if token in NON_CITE_TOKENS:
        return False
    if "." in token and token.split(".", 1)[0] in NON_CITE_DOTTED_HEADS:
        return False
    return True


def citation_tokens(text):
    return [t for t in CITE_RE.findall(text) if is_citation_token(t)]


def paragraphs(text):
    """Consecutive non-blank lines, code blocks and comments already removed."""
    return [p for p in re.split(r"\n[ \t]*\n", text) if p.strip()]


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", type=Path, default=ROOT,
                    help="repository root to check (default: parent of scripts/)")
    args = ap.parse_args()
    root = Path(args.root).resolve()

    bib_path = root / "references.bib"
    if not bib_path.exists():
        raise SystemExit(f"missing bibliography file: {bib_path}")
    bib_text = bib_path.read_text(encoding="utf-8", errors="replace")
    qmd_paths = sorted(root.glob("*.qmd"))
    if not qmd_paths:
        raise SystemExit(f"no root .qmd files under {root}")

    errors = []
    warnings = []

    entries = parse_bib(bib_text)
    bib_keys = set()

    # (1) duplicate keys
    by_key = {}
    for key, kind, line, fields in entries:
        by_key.setdefault(key, []).append(line)
        bib_keys.add(key)
    for key in sorted(k for k, v in by_key.items() if len(v) > 1):
        places = ", ".join(f"line {n}" for n in by_key[key])
        errors.append(f"references.bib: duplicate bib key '{key}' defined "
                      f"{len(by_key[key])} times ({places})")

    for key, kind, line, fields in entries:
        for name, raw in fields:
            value = clean_value(raw)
            where = f"references.bib:{line} [{key}] {name}"
            # (2) DOIs
            if name == "doi" and not DOI_RE.match(value):
                errors.append(f"{where}: DOI '{value}' does not match "
                              f"^10\\.[0-9]{{4,9}}/ (not a DOI)")
            # (5) comma-less author items
            items = split_authors(value) if name in NAME_FIELDS else []
            if name in NAME_FIELDS:
                nocomma = [i for i in items if "," not in i]
                if key in FIRST_LAST_AUTHOR_KEYS:
                    # Exemption only holds while the WHOLE list is Given-Last.
                    if nocomma and len(nocomma) != len(items):
                        errors.append(f"{where}: mixed author styles - "
                                      f"{len(nocomma)} of {len(items)} items have "
                                      f"no comma ({'; '.join(nocomma)}); BibTeX "
                                      f"takes the last word as the surname")
                else:
                    for item in nocomma:
                        surname = item.split()[-1] if item.split() else item
                        errors.append(f"{where}: author '{item}' has no comma; "
                                      f"BibTeX takes '{surname}' as the surname")
            # (6) mojibake
            if name in TEXT_FIELDS:
                hits = sorted({w.strip(",.;:(){}\"'") for w in value.split()
                               if MOJIBAKE_RE.search(w)})
                if hits:
                    errors.append(f"{where}: mojibake signature in "
                                  f"{', '.join(hits)} - a non-ASCII letter was "
                                  f"destroyed by a wrong encoding")
            # (7) empty fields
            if raw.replace("{", "").replace("}", "").strip() == "":
                warnings.append(f"{where}: empty field")

    # (3)(4)(8) citation keys in prose
    cited = {}
    for path in qmd_paths:
        raw_text = path.read_text(encoding="utf-8", errors="replace")
        body = strip_prose(raw_text)
        for token in citation_tokens(body):
            cited.setdefault(token, set()).add(path.name)
        # (4) keys buried in a retired comment block
        commented = set()
        for block in COMMENT_RE.findall(raw_text):
            commented.update(citation_tokens(block))
        for token in sorted(commented):
            warnings.append(f"{path.name}: key '@{token}' appears inside an "
                            f"HTML comment block (retired example?)")
        # (8) same key cited twice in one paragraph
        for para in paragraphs(body):
            counts = {}
            for token in citation_tokens(para):
                if token in bib_keys:
                    counts[token] = counts.get(token, 0) + 1
            for token in sorted(counts):
                if counts[token] > 1:
                    head = para.strip().splitlines()[0][:70]
                    warnings.append(f"{path.name}: '@{token}' cited "
                                    f"{counts[token]}x in one paragraph ({head!r})")

    for key in sorted(set(cited) - bib_keys):
        errors.append(f"prose cites '@{key}', which no references.bib entry "
                      f"defines (cited in {', '.join(sorted(cited[key]))})")
    for key in sorted(bib_keys - set(cited)):
        warnings.append(f"references.bib: entry '{key}' is never cited in prose")

    for msg in errors:
        print(f"ERROR: {msg}", file=sys.stderr)
    for msg in warnings:
        print(f"WARN:  {msg}")

    if errors:
        print(f"bibliography check failed: {len(entries)} entries, "
              f"{len(errors)} errors, {len(warnings)} warnings", file=sys.stderr)
        raise SystemExit(1)

    print(f"bibliography check passed: {len(entries)} entries, 0 errors "
          f"({len(warnings)} warnings, {len(cited)} keys cited, "
          f"{len(qmd_paths)} QMD files)")


if __name__ == "__main__":
    main()
