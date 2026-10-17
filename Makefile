# Build entry points for the book. Deployment is handled by the GitHub Actions
# publish workflow, so there is deliberately no local `publish` target: a manual
# push to gh-pages/ would be overwritten by the next CI run.
#
# README documents `make book` and `make fresh`. Keep the list short -- a target
# that cannot run is worse than no target.

book:
	quarto render

fresh:
	quarto render --cache-refresh

# Drop every knitr cache so the next build recomputes every chunk. The
# committed MeSH objects under cache/ are not knitr caches and are left alone;
# rebuild them with `Rscript scripts/build_mesh_cache.R` -- see cache/README.md.
clean-cache:
	find . -type d -name '*_cache' -prune -exec rm -rf {} +

clean:
	quarto clean

# There is deliberately no `pdfbook` target: _quarto.yml declares no PDF format,
# so `quarto render --to pdf` has nothing to resolve, and no TeX toolchain is
# assumed in this environment. Adding one means configuring a format in
# _quarto.yml and checking the output, not just wiring up a command.