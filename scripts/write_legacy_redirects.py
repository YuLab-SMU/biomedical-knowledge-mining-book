#!/usr/bin/env python3
"""Create compatibility HTML pages for renamed book chapters after Quarto renders."""
from pathlib import Path
from html import escape

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
REDIRECTS = {
    "01-semantic-similarity.html": "semantic-similarity.html",
    "011-GOSemSim.html": "go-semantic-similarity.html",
    "012-DOSE-semantic-similarity.html": "do-semantic-similarity.html",
    "013-meshes-semantic-similarity.html": "mesh-semantic-similarity.html",
    "02-Enrichment.html": "enrichment-overview.html",
    "021-go.html": "go-enrichment.html",
    "022-kegg.html": "kegg-enrichment.html",
    "023-other-dbs.html": "other-databases.html",
    "024-reactome.html": "reactome-enrichment.html",
    "025-do-enrichment.html": "disease-enrichment.html",
    "026-meshes-enrichment.html": "mesh-enrichment.html",
    "027-universal-enrichment.html": "universal-enrichment.html",
    "028-chipseeker.html": "chipseeker-enrichment.html",
    "PPI.html": "ppi.html",
    "FAQ.html": "troubleshooting.html",
    "dplyr.html": "result-objects.html",
    "utilities.html": "identifier-utilities.html",
    "misc.html": "leading-edge-nonmodel.html",
}

if not DOCS.exists():
    raise SystemExit(f"Quarto output directory does not exist: {DOCS}")

for old, new in REDIRECTS.items():
    target = DOCS / old
    destination = escape(new, quote=True)
    target.write_text(
        "<!doctype html>\n"
        "<meta charset=\"utf-8\">\n"
        f"<meta http-equiv=\"refresh\" content=\"0; url={destination}\">\n"
        f"<link rel=\"canonical\" href=\"{destination}\">\n"
        f"<title>Moved to {escape(new)}</title>\n"
        f"<p>This chapter moved to <a href=\"{destination}\">{escape(new)}</a>.</p>\n"
        "<script>location.replace(" + repr(new) + " + location.hash);</script>\n",
        encoding="utf-8",
    )

print(f"Wrote {len(REDIRECTS)} legacy chapter redirects to {DOCS}")
