#!/usr/bin/env Rscript
# check_versions.R -- does REPRODUCIBILITY.md still describe this library?
#
# REPRODUCIBILITY.md carries a table of the versions the book was validated
# against. When the local library moves (a Bioconductor point release, a CRAN
# bump) the table goes stale silently: the book renders, the numbers are wrong,
# and the provenance claim becomes false. This script reads the table and
# compares each row against the version actually installed here.
#
# The table is parsed generically - component name from the first cell, version
# from the last cell that looks like a version - so it keeps working if a column
# is added or removed later.
#
# Offline: no network, base R only.
#
#   Rscript scripts/check_versions.R [--root DIR] [--quiet]
#
# Exit 1 on drift (a mismatched version or a listed package that is missing).

# Default repository root: the parent of the directory holding this script, so
# `Rscript scripts/check_versions.R` works from the repo root as CI runs it.
script_path <- local({
  a <- commandArgs(FALSE)
  hit <- grep("^--file=", a, value = TRUE)
  if (length(hit)) sub("^--file=", "", hit[[1L]]) else ""
})
default_root <- if (nzchar(script_path) && file.exists(script_path)) {
  dirname(dirname(normalizePath(script_path)))
} else {
  "."
}

args <- commandArgs(trailingOnly = TRUE)
root <- default_root
quiet <- FALSE
i <- 1L
while (i <= length(args)) {
  a <- args[[i]]
  if (a == "--root") {
    i <- i + 1L
    if (i > length(args)) stop("--root needs a directory")
    root <- args[[i]]
  } else if (a %in% c("--quiet", "-q")) {
    quiet <- TRUE
  } else if (a %in% c("--help", "-h")) {
    cat("usage: Rscript scripts/check_versions.R [--root DIR] [--quiet]\n")
    quit(save = "no", status = 0L)
  } else {
    stop("unrecognized argument: ", a)
  }
  i <- i + 1L
}
root <- normalizePath(root, mustWork = TRUE)

md <- file.path(root, "REPRODUCIBILITY.md")
if (!file.exists(md)) stop("missing ", md)

# A version: digits with at least one dot (1.99.8, 26.1.1, 4.6.1) or a bare
# major number. Deliberately permissive because the first column of the table is
# "Component" and holds R and Bioconductor as well as packages.
VERSION_RE <- "^[0-9]+(\\.[0-9]+)+$"
ROW_RE <- "^\\s*\\|(.*)\\|\\s*$"

looks_like_version <- function(x) grepl(VERSION_RE, x)

# A markdown cell is `` `name` `` in this table; strip backticks and whitespace.
clean_cell <- function(x) trimws(gsub("`", "", x, fixed = TRUE))

lines <- readLines(md, warn = FALSE, encoding = "UTF-8")
lines <- enc2utf8(lines)

rows <- list()
for (idx in seq_along(lines)) {
  m <- regmatches(lines[[idx]], regexec(ROW_RE, lines[[idx]]))[[1]]
  if (length(m) < 2L) next
  inner <- m[[2L]]
  cells <- strsplit(inner, "|", fixed = TRUE)[[1]]
  cells <- unname(vapply(cells, clean_cell, character(1)))
  cells <- cells[nzchar(cells)]
  if (length(cells) < 2L) next
  # skip the separator row (|---|---|) and the header row
  if (all(grepl("^:?-{2,}:?$", cells))) next
  if (!any(vapply(cells, looks_like_version, logical(1)))) next
  name <- cells[[1L]]
  if (grepl("(?i)^component$", name, perl = TRUE)) next
  version_cells <- cells[vapply(cells, looks_like_version, logical(1))]
  rows[[length(rows) + 1L]] <- list(name = name, claimed = tail(version_cells, 1L),
                                    line = idx)
}

if (!length(rows)) stop("no version rows found in ", md)

# Versions that are not R packages cannot be resolved from a library.
NON_PACKAGE <- c("R", "Bioconductor", "Quarto", "Pandoc")

installed <- installed.packages()
avail <- rownames(installed)

drift <- list()
missing <- list()
for (r in rows) {
  nm <- r$name
  if (nm %in% NON_PACKAGE) {
    # R itself and the Bioconductor release are not packages in the library, but
    # both are still checkable.
    actual <- if (identical(nm, "R")) {
      as.character(getRversion())
    } else {
      tryCatch(as.character(BiocManager::version()), error = function(e) NA_character_)
    }
    if (!is.na(actual) && !identical(actual, r$claimed)) {
      drift[[length(drift) + 1L]] <- list(name = nm, claimed = r$claimed,
                                          actual = actual, line = r$line)
    }
    next
  }
  actual <- tryCatch(as.character(packageVersion(nm)), error = function(e) NA_character_)
  if (is.na(actual)) {
    missing[[length(missing) + 1L]] <- r
    next
  }
  if (!identical(actual, r$claimed)) {
    drift[[length(drift) + 1L]] <- list(name = nm, claimed = r$claimed,
                                        actual = actual, line = r$line)
  }
}

if (!quiet) {
  message(sprintf("comparing %d row(s) of %s against %d installed package(s)",
                  length(rows), basename(md), length(avail)))
}

if (length(missing) || length(drift)) {
  for (r in missing) {
    cat(sprintf("ERROR: REPRODUCIBILITY.md:%d lists `%s` %s, which is not installed here\n",
                r$line, r$name, r$claimed), file = stderr())
  }
  for (d in drift) {
    cat(sprintf("ERROR: REPRODUCIBILITY.md:%d claims `%s` %s, installed version is %s\n",
                d$line, d$name, d$claimed, d$actual), file = stderr())
  }
  cat(sprintf("version check failed: %d drift(s), %d not installed\n",
              length(drift), length(missing)), file = stderr())
  quit(save = "no", status = 1L)
}

cat(sprintf("version check passed: %d row(s) match the installed library, 0 errors\n",
            length(rows)))
