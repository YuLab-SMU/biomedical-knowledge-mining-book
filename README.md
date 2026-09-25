# Biomedical Knowledge Mining Toolkit

This repository contains the source code and content for the book **Biomedical Knowledge Mining using GOSemSim and clusterProfiler**, authored by Guangchuang Yu.

The book documents a coordinated toolkit for turning omics evidence into interpretable biological knowledge. It is organized around the analysis workflow rather than around a list of packages:

```text
input evidence → analysis engine → biological knowledge
              → evidence integration → visualization
              → biological interpretation → reproducible report
```

## What the toolkit covers

- **Data contract**: identifiers, ranked lists, background universes, custom annotations, and common result objects.
- **Enrichment engines**: Over-Representation Analysis (ORA), Gene Set Enrichment Analysis (GSEA), comparison, network-aware, weighted, and multi-omics methods.
- **Knowledge sources**: Gene Ontology, KEGG, Reactome, Disease Ontology, MeSH, MSigDB, WikiPathways, CellMarker, and user-defined gene sets.
- **GSON knowledge packaging**: standardized, metadata-aware knowledge objects that allow multiple knowledge bases to be combined without changing the enrichment engine.
- **Evidence integration**: semantic similarity, term redundancy reduction, representative term selection, PPI networks, and contribution tracing.
- **Visualization and interpretation**: reusable plots, comparative profiles, evidence-guided biological interpretation, and optional AI-assisted reporting.

The main implementation modules are `clusterProfiler`, `enrichit`, `gson`, `GOSemSim`, `DOSE`, `ReactomePA`, `meshes`, `enrichplot`, and `ChIPseeker`. They are presented as cooperating layers of one system, not as unrelated package chapters.

## Read online

The compiled and up-to-date version of the book is available at:

<https://yulab-smu.top/biomedical-knowledge-mining-book/>

## Read the source book

Start with the [book reorganization proposal](book-reorganization-proposal.md) for the information architecture, then use the following entry points:

1. `first-workflow.qmd` for a complete minimal analysis;
2. `data-contract.qmd` for input preparation and result objects;
3. `choose-a-route.qmd` for selecting an analysis design;
4. `gson.qmd` for combining and versioning knowledge sources;
5. `interpretation-reading.qmd` for reading enrichment evidence;
6. `reproducible-report.qmd` for preserving the analysis record;
7. `recipes.qmd` for common input-to-next-step routes;
8. `capability-map.qmd` for locating a package or function in the toolkit;
9. `glossary-api-index.qmd` for terminology, function lookup, citations, and version records;
10. `enrichplot.qmd` for the visualization map, then the task chapters for summary, networks, GSEA, comparison, specialized views, and external-result import.

## Build locally

The book is built with [Quarto](https://quarto.org/) and R:

```bash
make book
```

Use `make fresh` when cached computations need to be refreshed. The first workflow reads the committed `datasets/de_table.tsv`; regenerate it with `Rscript scripts/make_airway_de_table.R` when the documented airway/DESeq2 source needs to be refreshed.

For the tested R/Bioconductor snapshot, data provenance, network boundaries, and validation commands, see [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md). The repository runs fast source checks in `validate-book.yml`; the existing publish workflow performs the complete R/Quarto render and then repeats the navigation/link checks before deployment.

## Live interpretation examples

The cell-type annotation example in `interpretation.qmd` is a real workflow: it reads the local CellMarker spreadsheet, constructs marker profiles, runs `compareCluster()`/`enricher()`, and calls DeepSeek through `aisdk::set_model("deepseek:deepseek-v4-flash")`. The chunk loads `.env` locally when available, never prints the key, and skips only the LLM-dependent chunks when `DEEPSEEK_API_KEY` is absent. Clear `interpretation_cache/` when a fresh report is intentionally required.

The generated `docs/` site and `*_cache/` / `*_files/` directories are build artifacts and are ignored by Git. Source data remain under `datasets/`, figures under `figures/`, and reusable R helpers remain at the project root because Quarto chapters refer to them by relative path.

The source chapters now use task-oriented filenames. After each Quarto build, `scripts/write_legacy_redirects.py` creates redirects for the previous numeric and package-oriented HTML URLs, so existing links remain usable.

## Archive policy

All 50 current `.qmd` files are referenced by `_quarto.yml`; no unused source chapter was found in this pass, so no chapter was moved to `_archive/`. A future legacy chapter should be moved there only after removing it from the navigation and adding a redirect or migration note for its public anchors.

## Contributing

Contributions, bug reports, examples, and suggestions are welcome. Please open an issue or submit a pull request on the [GitHub repository](https://github.com/YuLab-SMU/biomedical-knowledge-mining-book/).
