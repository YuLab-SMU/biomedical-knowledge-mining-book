# Reproducible and rolling build environment

The book follows the current R/Bioconductor and package releases rather than freezing one permanent environment. The versions below are the local validation baseline for the current source tree; they are provenance for this validation pass, not a compatibility ceiling or a lockfile.

| Component | Tested version |
|---|---|
| R | 4.6.1 |
| Bioconductor | 3.23 |
| `clusterProfiler` | 4.21.2 |
| `enrichit` | 0.2.5 |
| `enrichplot` | 1.99.6 |
| `GOSemSim` | 2.39.3 |
| `DOSE` | 4.7.3 |
| `ReactomePA` | 1.99.2 |
| `meshes` | 1.39.1 |
| `airway` | 1.32.0 |
| `DESeq2` | 1.52.0 |
| `org.Hs.eg.db` | 3.23.1 |

When R, Bioconductor, or a core package release changes, update the dependencies in the build environment, rerun the full book and validation checks, regenerate `de_table.tsv` only if the documented airway/DESeq2 source or design changes, and refresh this table with the new `sessionInfo()` output. For a release build, record:

```r
sessionInfo()
BiocManager::version()
```

The canonical table-first example is regenerated with:

```bash
Rscript scripts/make_airway_de_table.R
```

The generated table is committed so ordinary book rendering does not require the `airway` package or a DESeq2 rerun. If the source package or analysis design changes, regenerate the table, review its schema and row count, and update `datasets/readme.md`.

## Local validation

Run the same checks used by the repository workflows:

```bash
python3 scripts/check_navigation.py
python3 scripts/check_links.py
quarto render
```

`code-link` is disabled in `_quarto.yml` so the build does not depend on the CRAN package index. Function names remain linked through the book’s capability map and API index.

## Network-backed examples

The most unstable WikiPathways discovery, ORA, and GSEA calls are retained as real examples but marked `eval: false`; run those chunks explicitly when refreshing the service-backed examples. Other chapters retain real KEGG, Reactome, annotation, and external-result APIs where they are methodologically central. For service failures, releases, access dates, and offline fallbacks, use [external-service troubleshooting](troubleshooting.qmd#external-services).