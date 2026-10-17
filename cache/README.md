# Committed cache files

These `.rds` files are build artifacts, but they are committed on purpose: the
object they hold takes minutes to derive from a remote database, and a book
build that re-derives it on every render trades one fragile dependency for
another. What that trade is worth depends on the files staying regenerable and
their provenance staying visible, which is what this note is for.

## Contents

| File | Object | Produced by | Used in |
|---|---|---|---|
| `hsamd.rds` | `GOSemSimDATA` — MeSH information content and gene annotations for *Homo sapiens*, category `A` (Anatomy), source `gendoo` | `meshes::meshdata(db, category="A", computeIC=TRUE, database="gendoo")` | `mesh-semantic-similarity.qmd` |
| `enrichMeSH.rds` | `enrichResult` — ORA over the top 100 DOSE demo genes, category `C` (Diseases), source `gendoo` | `meshes::enrichMeSH(de, MeSHDb=db, database="gendoo", category="C")` | `mesh-enrichment.qmd` |
| `gseMeSH.rds` | `gseaResult` — GSEA over the full DOSE demo ranking, category `G` (Phenomena and Processes), source `gene2pubmed` | `meshes::gseMeSH(geneList, MeSHDb=db, database="gene2pubmed", category="G")` | `mesh-enrichment.qmd` |

## Regenerating

Run from the repository root:

```bash
Rscript scripts/build_mesh_cache.R            # all three
Rscript scripts/build_mesh_cache.R hsamd      # one of them
```

The script resolves the species `MeSHDb` through `AnnotationHub`, prints the
MeSH release it resolved to, and saves each object. It needs network access.

## Provenance of the committed objects

Read these out of the objects themselves rather than trusting this table to stay
current:

```r
x <- readRDS("cache/hsamd.rds")
x@metadata                                    # MeSH release, sources, organism
packageVersion("meshes")
```

| Property | Value |
|---|---|
| MeSH release | 2026 |
| Organism | *Homo sapiens* |
| Sources | `Gendoo`, `gene2pubmed` |
| Annotation schema | `MeSH.Hsa.eg.db` 1.0 |
| Built with `meshes` | see `REPRODUCIBILITY.md` — that table is the authoritative record |

## When to regenerate

- A `meshes`, `GOSemSim`, or `DOSE` version change. `scripts/check_versions.R`
  fails the build when the `REPRODUCIBILITY.md` table disagrees with the
  installed library; regenerate the caches and update that table in the same
  commit so the objects and the recorded versions cannot drift apart.
- The MeSH release changes enough to alter the enriched term lists.

After regenerating, update the provenance rows above if any of them moved.