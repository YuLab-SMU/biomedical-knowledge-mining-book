# Reproducible and rolling build environment

The book follows the current R/Bioconductor and package releases rather than freezing one permanent environment.

**Two environments are involved, and they are deliberately not identical:**

1. **Local validation baseline** — the table below. This is the environment the
   source tree was validated in, and what `Rscript scripts/check_versions.R`
   compares against. It is provenance for this validation pass, not a
   compatibility ceiling or a lockfile.
2. **CI build** — `.github/workflows/publish-book.yml` installs the core
   packages from `github::YuLab-SMU/*` rather than from CRAN or Bioconductor,
   so it tracks development versions that do not match the table: the deployed
   site has been built with `DOSE` 4.7.3.9000 and `GOSemSim` 2.39.4 while the
   table lists 4.7.3 and 2.39.3. The published build therefore carries its own
   provenance — CI writes `docs/SESSION-INFO.txt` on every successful render and
   that file is deployed with the site. It records the R session plus the
   versions of the packages the chapters use (clusterProfiler, enrichit,
   enrichplot, GOSemSim, DOSE, ReactomePA, meshes, ChIPseeker, gson, yulab.utils,
   aisdk, airway, DESeq2, fgsea, org.Hs.eg.db, org.Mm.eg.db). Read it for what
   the deployed pages actually ran against; read the table for what was
   validated here.

| Component | Tested version |
|---|---|
| R | 4.6.1 |
| Bioconductor | 3.23 |
| `clusterProfiler` | 4.21.3 |
| `enrichit` | 0.2.6 |
| `enrichplot` | 1.99.8 |
| `GOSemSim` | 2.39.3 |
| `DOSE` | 4.7.3 |
| `ReactomePA` | 1.99.2 |
| `meshes` | 1.39.1 |
| `ChIPseeker` | 1.48.0 |
| `gson` | 0.2.2 |
| `yulab.utils` | 0.2.5 |
| `aisdk` | 1.5.0 |
| `airway` | 1.32.0 |
| `DESeq2` | 1.52.0 |
| `fgsea` | 1.38.0 |
| `org.Hs.eg.db` | 3.23.1 |
| `org.Mm.eg.db` | 3.23.0 |

When R, Bioconductor, or a core package release changes, update the dependencies in the build environment, rerun the full book and validation checks, regenerate `de_table.tsv` only if the documented airway/DESeq2 source or design changes, and refresh this table with the new `sessionInfo()` output. `scripts/check_versions.R` fails while any row disagrees with the installed library, so a stale table is caught rather than drifting silently. For a release build, record:

```r
sessionInfo()
BiocManager::version()
```

The canonical table-first example is regenerated with:

```bash
Rscript scripts/make_airway_de_table.R
```

The generated table is committed so ordinary book rendering does not require the `airway` package or a DESeq2 rerun. If the source package or analysis design changes, regenerate the table, review its schema and row count, and update `datasets/readme.md`.

The three committed MeSH objects under `cache/` were built with `meshes` 1.39.3 from the human AnnotationHub record `AH122129` (MeSH v011, 2026). That is deliberately a different `meshes` version from the 1.39.1 in the table above: the caches were generated once and are loaded from disk by both MeSH chapters, because rebuilding them needs an AnnotationHub download plus a `meshdata()` call that runs for minutes. The build loads objects rather than re-deriving them; it does not exercise 1.39.3 code paths.

The package now bundles the NLM descriptor-name map needed because current MeSHDb records expose gene/MeSH mappings but no `MESHTERM` column. Regenerate the caches, and update this paragraph plus `cache/README.md`, whenever the annual NLM descriptor release changes or the `meshes` / `GOSemSim` version changes:

```bash
Rscript scripts/build_mesh_cache.R
```

The script prints the AnnotationHub record and MeSH release it resolved to. `cache/README.md` records each object's provenance as read from the object itself.

## Local validation

Run the same checks used by the repository workflows:

```bash
python3 scripts/check_navigation.py     # every root .qmd is in _quarto.yml
python3 scripts/check_links.py          # internal links, anchors, generated HTML
python3 scripts/check_bibliography.py   # duplicate/DOI/format checks on references.bib
python3 scripts/check_package_macros.py # Biocpkg()/CRANpkg() against the registry
Rscript scripts/check_api_names.R       # `foo()` mentions vs real package exports
Rscript scripts/check_versions.R        # version table vs the installed library
python3 scripts/check_figure_sizes.py   # per-image payload size, read from docs/
quarto render
```

The first four are the offline source gate that `validate-book.yml` runs on every push and pull request; none of them reaches the network. `check_api_names.R` and `check_figure_sizes.py` run in `publish-book.yml` after the render, because both read its output or need the installed packages. `check_versions.R` is a **local** check only: it compares this table against the local baseline, and CI installs `github::YuLab-SMU/*` development versions that are documented above to differ from it, so running it in CI would fail on a difference that is intended.

## Figure payload size

`check_figure_sizes.py` measures every image the rendered pages actually reference and fails above 4 MiB. It reads the generated HTML rather than walking `docs/`, because Quarto does not remove the previous build's figure files, so a directory scan keeps reporting images that no page links to. The limit is set above the heaviest legitimate vector figure (3.4 MB) and far below the defect it exists to catch (a four-panel `cnetplot()` at 13.2 MB, issue #41).

The remedy is always `#| fig-format: png` on the offending chunk, never the `svg2png()` helper in `_common.R`: ImageMagick's SVG renderer silently drops the curves and the ranked-list panel. `scripts/figure_size_allowlist.txt` exists for figures that genuinely cannot shrink; it is empty.

`code-link` is disabled in `_quarto.yml` so the build does not depend on the CRAN package index. Function names remain linked through the book’s capability map and API index.

## Network-backed examples

The most unstable WikiPathways discovery, ORA, and GSEA calls are retained as real examples but marked `eval: false`; run those chunks explicitly when refreshing the service-backed examples. Other chapters retain real KEGG, Reactome, annotation, and external-result APIs where they are methodologically central. For service failures, releases, access dates, and offline fallbacks, use [external-service troubleshooting](troubleshooting.qmd#external-services).