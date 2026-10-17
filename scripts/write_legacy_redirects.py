#!/usr/bin/env python3
"""Create compatibility HTML pages for renamed book chapters after Quarto renders.

Each entry maps an old page name to either a single new page, or to a tuple of
(label, target) pairs when one old chapter became several new ones. The fragment
of the incoming URL is always appended to whichever target the reader lands on,
so a deep link such as /020-enrichment-algorithms.html#ora-algorithm still
resolves: every anchor of the old chapter survived the split.

AGENTS.md section 3 requires a compatibility entry for any publicly reachable
URL, so a deleted chapter that once had a page is never simply dropped.
"""
from pathlib import Path
from html import escape

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"

# A split destination: readers see the routing list before the redirect lands.
SPLIT_020 = (
    ("Enrichment foundations: ORA and GSEA", "enrichment-foundations.html"),
    ("Network-aware and weighted enrichment", "enrichment-network.html"),
    ("Multi-omics enrichment integration", "enrichment-multiomics.html"),
)

REDIRECTS = {
    "01-semantic-similarity.html": "semantic-similarity.html",
    "011-GOSemSim.html": "go-semantic-similarity.html",
    "012-DOSE-semantic-similarity.html": "do-semantic-similarity.html",
    "013-meshes-semantic-similarity.html": "mesh-semantic-similarity.html",
    "02-Enrichment.html": "enrichment-overview.html",
    "020-enrichment-algorithms.html": SPLIT_020,
    "021-go.html": "go-enrichment.html",
    "022-kegg.html": "kegg-enrichment.html",
    "023-other-dbs.html": "other-databases.html",
    "023-wikipathways.html": "other-databases.html",
    "024-reactome.html": "reactome-enrichment.html",
    "025-do-enrichment.html": "disease-enrichment.html",
    "026-meshes-enrichment.html": "mesh-enrichment.html",
    "027-universal-enrichment.html": "universal-enrichment.html",
    "028-chipseeker.html": "chipseeker-enrichment.html",
    "029-compareCluster.html": "comparecluster-analysis.html",
    "030-interpretation.html": "interpretation.html",
    "PPI.html": "ppi.html",
    "FAQ.html": "troubleshooting.html",
    "dplyr.html": "result-objects.html",
    "utilities.html": "identifier-utilities.html",
    "misc.html": "leading-edge-nonmodel.html",
}

if not DOCS.exists():
    raise SystemExit(f"Quarto output directory does not exist: {DOCS}")


def redirect_page(primary, body):
    """A meta-refresh page that preserves the incoming #fragment."""
    url = escape(primary, quote=True)
    return (
        "<!doctype html>\n"
        '<meta charset="utf-8">\n'
        '<meta http-equiv="refresh" content="0; url=' + url + '">\n'
        '<link rel="canonical" href="' + url + '">\n'
        "<title>Moved to " + escape(primary) + "</title>\n"
        + body
        + "<script>location.replace(" + repr(primary) + " + location.hash);</script>\n"
    )


written = 0
for old, new in REDIRECTS.items():
    if isinstance(new, tuple):
        primary = new[0][1]
        items = "\n".join(
            '<li><a href="' + escape(t, quote=True) + '">' + escape(label) + "</a></li>"
            for label, t in new
        )
        primary_url = escape(primary, quote=True)
        body = (
            "<p>This chapter was split into "
            + str(len(new))
            + " chapters. If nothing happens, follow one of these links:</p>\n"
            "<ul>\n"
            + items
            + "\n</ul>\n"
            '<p>Most readers want <a href="'
            + primary_url
            + '">'
            + escape(primary)
            + "</a>.</p>\n"
        )
    else:
        primary = new
        body = (
            '<p>This chapter moved to <a href="'
            + escape(new, quote=True)
            + '">'
            + escape(new)
            + "</a>.</p>\n"
        )

    (DOCS / old).write_text(redirect_page(primary, body), encoding="utf-8")
    written += 1

print(f"Wrote {written} legacy chapter redirects to {DOCS}")