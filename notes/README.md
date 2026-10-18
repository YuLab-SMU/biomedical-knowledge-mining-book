# Working notes

Review and bookkeeping material that is useful to the author but is not book
source. Nothing here is referenced by `_quarto.yml`, rendered by Quarto, or
checked by `scripts/check_*.py`.

| File | What it is |
|---|---|
| `todo.md` | Running list of issues and follow-up work collected from the GitHub issue tracker and elsewhere. |
| `book-issues.md` | Audit log from the 2026-09-21 review pass. |
| `book-issues-20261016.md` | Audit log of the pass that started 2026-10-16 against baseline `e9c4af3` and ran through 2026-10-17: four batches of issues plus two follow-up rounds, all closed and published. |
| `book-issues-20261017.md` | Audit log of the pass against baseline `d59e5df`. 19 findings (N1–N18 + N5b), all outside the coverage of the seven self-checks that were green at that commit. All 19 fixed 2026-10-18. |

These audit logs are tracked, so the review history travels with the book source;
`.gitignore` no longer lists them.

Build artifacts of a different kind — knitr caches, generated HTML, the MeSH
objects under `cache/` — are not here. Those live where the build expects them
and are documented in `cache/README.md` and `REPRODUCIBILITY.md`.