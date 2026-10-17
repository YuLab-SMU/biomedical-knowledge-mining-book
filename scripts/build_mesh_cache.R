#!/usr/bin/env Rscript
## Regenerate the MeSH cache files committed under cache/.
##
## The two MeSH chapters load their worked examples from cache/*.rds instead of
## running the analysis live. That is deliberate: building them requires an
## AnnotationHub download plus a meshdata() call that takes minutes, so making
## every book build pay that cost would trade one fragile remote dependency for
## another. The cache turns a fragile step into a committed artifact -- but only
## if it is regenerable, which is what this script is for.
##
## Usage:
##   Rscript scripts/build_mesh_cache.R            # rewrite all three files
##   Rscript scripts/build_mesh_cache.R hsamd      # rewrite one of them
##
## After regenerating, update cache/README.md with the MESHVERSION reported below
## and re-run scripts/check_versions.R, so the table in REPRODUCIBILITY.md and
## the committed objects cannot drift apart silently.

suppressPackageStartupMessages({
  library(meshes)
})

## Run from the repository root, like every other script in this project.
ROOT <- "."
if (!dir.exists(file.path(ROOT, "cache"))) {
  stop("Run this from the repository root: Rscript scripts/build_mesh_cache.R", call. = FALSE)
}

target <- commandArgs(trailingOnly = TRUE)
if (!length(target)) target <- c("hsamd", "enrichMeSH", "gseMeSH")

cache_dir <- file.path(ROOT, "cache")
dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)

## Report what the installed stack is, because the objects below are only
## loadable by a meshes/GOSemSim/DOSE at or near these versions.
cat("meshes      :", as.character(packageVersion("meshes")), "\n")
cat("GOSemSim    :", as.character(packageVersion("GOSemSim")), "\n")
cat("DOSE        :", as.character(packageVersion("DOSE")), "\n")

## The MeSH database itself is fetched from AnnotationHub. Everything downstream
## depends on which MeSHDb release this resolves to, so log it rather than
## trusting that "latest" is stable.
load_mesh_db <- function(species = "Homo sapiens") {
  suppressPackageStartupMessages({
    library(AnnotationHub)
    library(MeSHDbi)
  })
  ah <- AnnotationHub(localHub = TRUE)
  hits <- query(ah, c("MeSHDb", species))
  db <- MeSHDbi::MeSHDb(hits[[1]])
  cat("MeSHDb      :", as.character(hits[[1]]), "\n")
  db
}

if ("hsamd" %in% target) {
  cat("\n-- building hsamd.rds (meshes::meshdata, category A, gendoo) --\n")
  db <- load_mesh_db()
  hsamd <- meshdata(db, category = "A", computeIC = TRUE, database = "gendoo")
  print(hsamd@metadata)
  cat("MeSH release:", unique(as.character(hsamd@metadata$VALUE[hsamd@metadata$NAME == "MESHVERSION"])), "\n")
  saveRDS(hsamd, file.path(cache_dir, "hsamd.rds"))
  cat("wrote", file.path(cache_dir, "hsamd.rds"), "\n")
}

if (any(c("enrichMeSH", "gseMeSH") %in% target)) {
  ## Both enrichment caches are built against the same MeSHDb as hsamd.rds.
  db <- load_mesh_db()
  data(geneList, package = "DOSE")
  de <- names(geneList)[1:100]
}

if ("enrichMeSH" %in% target) {
  cat("\n-- building enrichMeSH.rds (ORA, gendoo, category C) --\n")
  x <- enrichMeSH(de, MeSHDb = db, database = "gendoo", category = "C")
  saveRDS(x, file.path(cache_dir, "enrichMeSH.rds"))
  cat("wrote", file.path(cache_dir, "enrichMeSH.rds"), "with", nrow(as.data.frame(x)), "terms\n")
}

if ("gseMeSH" %in% target) {
  cat("\n-- building gseMeSH.rds (GSEA, gene2pubmed, category G) --\n")
  y <- gseMeSH(geneList, MeSHDb = db, database = "gene2pubmed", category = "G")
  saveRDS(y, file.path(cache_dir, "gseMeSH.rds"))
  cat("wrote", file.path(cache_dir, "gseMeSH.rds"), "with", nrow(as.data.frame(y)), "terms\n")
}

cat("\nDone. Remember to refresh cache/README.md if the MeSH release changed.\n")