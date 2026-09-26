# Biomedical Knowledge Mining Toolkit

Source files and supporting code for **Biomedical Knowledge Mining using GOSemSim and clusterProfiler**, a book by Guangchuang Yu.

The chapters follow a complete analysis workflow:

```text
input evidence → analysis engine → biological knowledge
              → evidence integration → visualization
              → biological interpretation → reproducible report
```

## Topics covered

- **Data contract**: identifiers, ranked lists, background universes, custom annotations, and common result objects.
- **Enrichment engines**: Over-Representation Analysis (ORA), Gene Set Enrichment Analysis (GSEA), comparison, network-aware, weighted, and multi-omics methods.
- **Knowledge sources**: Gene Ontology, KEGG, Reactome, Disease Ontology, MeSH, MSigDB, WikiPathways, CellMarker, and user-defined gene sets.
- **GSON**: gene-set collections with identifiers, species, versions, and source metadata. Different knowledge bases can be used without changing the enrichment engine.
- **Evidence integration**: semantic similarity, term redundancy reduction, representative term selection, PPI networks, and contribution tracing.
- **Visualization and interpretation**: reusable plots, comparative profiles, evidence-guided biological interpretation, and optional AI-assisted reporting.

The main packages used throughout the book are `clusterProfiler`, `enrichit`, `gson`, `GOSemSim`, `DOSE`, `ReactomePA`, `meshes`, `enrichplot`, and `ChIPseeker`.

## Read online

Read the rendered book at:

<https://yulab-smu.top/biomedical-knowledge-mining-book/>

## Read the source book

To browse the source, start with the [book reorganization proposal](book-reorganization-proposal.md). The main entry points are:

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

`make fresh` reruns cached computations. The first workflow reads the committed `datasets/de_table.tsv`; regenerate it with `Rscript scripts/make_airway_de_table.R` when the documented airway/DESeq2 data need to be refreshed.

See [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md) for compatibility policy, validation versions, data provenance, network boundaries, and validation commands. `validate-book.yml` runs fast source checks; the publish workflow renders the book and checks navigation and links before deployment.

## Live interpretation examples

The cell-type annotation example in `interpretation.qmd` reads the local CellMarker spreadsheet, constructs marker profiles, runs `compareCluster()`/`enricher()`, and calls DeepSeek through `aisdk::set_model("deepseek:deepseek-v4-flash")`. It loads `.env` when available and skips only the LLM-dependent chunks when `DEEPSEEK_API_KEY` is absent. Remove `interpretation_cache/` to generate a fresh report.

The generated `docs/` site and `*_cache/` / `*_files/` directories are ignored by Git. Keep source data under `datasets/`, figures under `figures/`, and shared R helpers at the project root because Quarto chapters use these relative paths.

Chapter files use task-oriented names. `scripts/write_legacy_redirects.py` creates redirects for older numeric and package-oriented HTML URLs so existing links continue to work.

## Archive policy

Only move a legacy chapter to `_archive/` after removing it from the navigation and adding a redirect or migration note for its public anchors.

## Contributing

Contributions, bug reports, examples, and suggestions are welcome. Please open an issue or submit a pull request on the [GitHub repository](https://github.com/YuLab-SMU/biomedical-knowledge-mining-book/).
