#!/usr/bin/env Rscript
# check_api_names.R -- do the function names the book mentions actually exist?
#
# Why this exists: the book states APIs in inline code spans (`enrichGO()`,
# `clusterProfiler::bitr`) and in fenced examples (`createKEGGdb::create_kegg_db`).
# A name that never existed, or that a release removed, still renders fine and
# links to nothing, so check_links.py cannot see it - the text is not a URL. The
# audit that prompted this script found exactly that: `weighted_enrich()` in the
# API index and `createKEGGdb::createKEGGdb()` in a troubleshooting snippet,
# neither of which is a real function (the real API is `create_kegg_db()`).
#
# Method: collect the mentions from the root .qmd files, then resolve each one
# against the exported symbols of the book's own packages plus the base packages
# they lean on. Resolution is tiered so the common case stays fast:
#   A) read Meta/nsInfo.rds + NAMESPACE + Meta/data.rds of each package (no
#      namespace is loaded: ~0.2s for the whole pool);
#   B) only if a mention survives tier A, load that package's namespace and ask
#      getNamespaceExports() - needed for symbols a package re-exports dynamically.
# Anything still unresolved is reported with file:line.
#
# Offline: no network, no dependencies beyond base R. A package that is not
# installed here is skipped rather than treated as a failure.
#
#   Rscript scripts/check_api_names.R [--root DIR] [--quiet]
#
# Exit 1 only when an unknown name is not covered by the allowlist below.

# --------------------------------------------------------------------------
# Allowlist: legitimate non-exports the book mentions on purpose. Each entry is
# a hole in the check, so add one only with the reason in a comment.
ALLOWLIST <- c(
  # helpers defined in the book's own _common.R, not exported anywhere
  "retry",
  "retry_download",
  "clusterprofiler_enrichit_demo",
  "build_demo_network",
  # ggtext theme element; ggtext may be absent from the build library
  "element_markdown",
  # S3 method registered by enrichplot; named in prose about barplot dispatch
  "barplot.enrichResult",
  # internal helper of enrichit, quoted in prose about minGSSize/maxGSSize bounds
  "get_geneSet_index",
  # exported by ggtangle, which is not in the pool below
  "geom_edge",
  # exported by packages the book points at without depending on them
  "FindAllMarkers",           # Seurat
  "cosg",                     # Seurat
  "page_rank",                # STRINGdb-style API
  "carto_pal",                # rcartocolor
  "rainbow_hcl",              # colorspace
  "gost",                     # gprofiler2
  "enrichr",                  # enrichR
  "msigdbr_species",          # msigdbr helper
  "get_interactions",         # STRINGdb
  "get_proteins",             # STRINGdb
  "makeOrgPackage",           # AnnotationForge
  "makeOrgPackageFromNCBI",   # AnnotationForge
  "create_kegg_db",           # createKEGGdb, not installed here
  "createKEGGdb",             # the package name, mentioned as a package
  "install_github",           # remotes
  "new",                      # methods: S4 constructor, generic in prose
  "wget_set",                 # wget
  "load_dot_env",             # dotenv
  "read_tsv",                 # readr
  "makeGRangesFromDataFrame", # ChIPseeker/GenomicRanges helper
  # DOSE 4.7.0 removed these DisGeNET connectors; the book names them in a
  # callout whose whole point is that they no longer exist.
  "enrichDGN",
  "enrichDGNv",
  "gseDGN"
)

# The book's own packages and the tidyverse/annotation stack it teaches with.
POOL <- c(
  "clusterProfiler", "enrichplot", "enrichit", "gson", "GOSemSim", "DOSE",
  "ReactomePA", "meshes", "ChIPseeker", "pathview", "fgsea", "msigdbr",
  "yulab.utils", "aisdk", "dplyr", "ggplot2", "tidyr", "stringr", "readxl",
  "AnnotationDbi", "AnnotationHub", "biomaRt"
)

BASE_POOL <- c("base", "stats", "utils", "methods", "graphics", "grDevices",
               "knitr", "datasets", "tools")

# --------------------------------------------------------------------------
# Default repository root: the parent of the directory holding this script, so
# `Rscript scripts/check_api_names.R` works from the repo root as CI runs it.
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
  } else {
    stop("unrecognized argument: ", a)
  }
  i <- i + 1L
}
root <- normalizePath(root, mustWork = TRUE)

qmd_files <- sort(list.files(root, pattern = "\\.qmd$"))
if (!length(qmd_files)) stop("no root .qmd files under ", root)

# --------------------------------------------------------------------------
# Package directory index: name -> directory, across every library on the path.
pkg_dirs <- local({
  idx <- list()
  for (lp in .libPaths()) {
    d <- dir(lp, full.names = TRUE)
    for (p in d) {
      nm <- basename(p)
      if (file.exists(file.path(p, "DESCRIPTION")) && is.null(idx[[nm]])) idx[[nm]] <- p
    }
  }
  idx
})
installed_names <- names(pkg_dirs)

# ---- tier A: symbols without loading anything ------------------------------
ns_arg_name <- function(x) {
  if (is.name(x)) return(as.character(x))
  if (is.character(x)) return(x)
  NULL
}

# Walk a parsed NAMESPACE expression collecting export()/exportMethods()/
# exportClasses()/S3method() arguments, including the ones inside `if (...)`.
collect_namespace <- function(e, out) {
  if (!is.call(e)) return(out)
  fn <- tryCatch(as.character(e[[1]]), error = function(z) "")
  if (fn %in% c("export", "exportClasses", "exportMethods")) {
    if (length(e) >= 2L) {
      for (k in 2L:length(e)) {
        v <- ns_arg_name(e[[k]])
        if (!is.null(v)) out <- c(out, v)
      }
    }
    return(out)
  }
  if (fn == "S3method" && length(e) >= 3L) {
    g <- ns_arg_name(e[[2]]); cl <- ns_arg_name(e[[3]])
    if (!is.null(g) && !is.null(cl)) out <- c(out, paste0(g, ".", cl))
    return(out)
  }
  if (fn %in% c("if", "else", "{")) {
    for (k in seq_along(e)) out <- collect_namespace(e[[k]], out)
    return(out)
  }
  out
}

tier_a_exports <- function(pkg) {
  d <- pkg_dirs[[pkg]]
  if (is.null(d)) return(NULL)
  # The base packages ship no Meta/nsInfo.rds and no NAMESPACE, and they are
  # loaded in every R session, so asking the namespace directly is both the only
  # way and free. Nothing else is loaded at script start, so the rest still goes
  # through the metadata path below.
  if (isNamespaceLoaded(pkg) && !file.exists(file.path(d, "Meta", "nsInfo.rds"))) {
    return(unique(getNamespaceExports(pkg)))
  }
  meta <- character(0)
  patterns <- character(0)
  nsfile <- file.path(d, "Meta", "nsInfo.rds")
  if (file.exists(nsfile)) {
    ns <- tryCatch(readRDS(nsfile), error = function(e) NULL)
    if (!is.null(ns)) {
      em <- ns$exportMethods
      generics <- if (is.matrix(em) && nrow(em)) unique(as.character(em[, 1L])) else character(0)
      s3 <- ns$S3methods
      s3names <- if (is.matrix(s3) && nrow(s3)) unique(as.character(s3[, 1L])) else character(0)
      meta <- c(as.character(ns$exports), names(ns$exportClasses), generics, s3names)
      patterns <- unlist(ns$exportPatterns, use.names = FALSE)
    }
  }
  # The NAMESPACE file is the authority for what a package (re-)exports,
  # including symbols it imports from another package and re-exports.
  nf <- file.path(d, "NAMESPACE")
  parsed <- character(0)
  if (file.exists(nf)) {
    ex <- tryCatch(parse(nf, keep.source = FALSE), error = function(e) NULL)
    if (!is.null(ex)) for (k in seq_along(ex)) parsed <- collect_namespace(ex[[k]], parsed)
  }
  # Lazy-loaded datasets answer `pkg::geneList` style references.
  ds <- character(0)
  dfr <- file.path(d, "Meta", "data.rds")
  if (file.exists(dfr)) {
    m <- tryCatch(readRDS(dfr), error = function(e) NULL)
    if (is.matrix(m) && nrow(m)) {
      ds <- if ("Item" %in% colnames(m)) as.character(m[, "Item"]) else as.character(m[, 1L])
    }
  }
  # exportPatterns("...") needs the object index of the package database.
  objs <- character(0)
  rdx <- file.path(d, "R", paste0(pkg, ".rdx"))
  if (file.exists(rdx)) objs <- tryCatch(names(readRDS(rdx)), error = function(e) character(0))
  patterned <- if (length(patterns) && length(objs)) {
    objs[grepl(paste(patterns, collapse = "|"), objs)]
  } else character(0)
  unique(c(meta, parsed, ds, patterned))
}

# base/stats/utils/methods are attached or trivially available, so ask directly
# and cache; this avoids parsing their NAMESPACE files, which are generated.
tier_a_cache <- new.env(hash = TRUE, parent = emptyenv())
tier_a <- function(pkg) {
  if (!is.null(tier_a_cache[[pkg]])) return(tier_a_cache[[pkg]])
  out <- tier_a_exports(pkg)
  tier_a_cache[[pkg]] <- out
  out
}

pool_union <- character(0)
installed_pool <- character(0)
missing_pool <- character(0)
for (pkg in c(POOL, BASE_POOL)) {
  ex <- tier_a(pkg)
  if (is.null(ex)) {
    missing_pool <- c(missing_pool, pkg)
    next
  }
  installed_pool <- c(installed_pool, pkg)
  pool_union <- c(pool_union, ex)
}
pool_union <- unique(pool_union)

# Names documented in the package's own help index. Annotation and data packages
# (`GO.db`) export their objects at load time, so neither nsInfo.rds nor the
# NAMESPACE file lists them; the Rd alias table does, without loading anything.
rd_aliases <- function(pkg) {
  f <- file.path(pkg_dirs[[pkg]] %||% "", "Meta", "Rd.rds")
  if (!nzchar(f) || !file.exists(f)) return(character(0))
  r <- tryCatch(readRDS(f), error = function(e) NULL)
  if (is.null(r) || !is.matrix(r) || !"Aliases" %in% colnames(r)) return(character(0))
  al <- unlist(lapply(as.character(r[, "Aliases"]),
                      function(x) unlist(strsplit(x, "[[:space:]]*,[[:space:]]*"))),
               use.names = FALSE)
  unique(na.omit(al))
}
`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- tier B: load a namespace only when tier A cannot settle a name --------
tier_b_cache <- new.env(hash = TRUE, parent = emptyenv())
tier_b <- function(pkg) {
  key <- pkg
  if (!is.null(tier_b_cache[[key]])) return(tier_b_cache[[key]])
  out <- if (pkg %in% installed_names) {
    tryCatch(getNamespaceExports(loadNamespace(pkg)), error = function(e) character(0))
  } else NULL
  tier_b_cache[[key]] <- out
  out
}

# ---- collect the mentions --------------------------------------------------
QUALIFIED_RE <- "([A-Za-z][A-Za-z0-9._]*)::(`?)([A-Za-z][A-Za-z0-9._]*)"
BARE_RE <- "([A-Za-z][A-Za-z0-9._]*)\\(\\s*\\)"
SPAN_RE <- "`[^`\r\n]+`"

qualified_hits <- function(text) {
  ms <- regmatches(text, gregexpr(QUALIFIED_RE, text))[[1]]
  if (!length(ms)) return(NULL)
  do.call(rbind, lapply(ms, function(m) {
    pkg <- sub("::.*", "", m)
    name <- gsub("`", "", sub(".*::", "", m), fixed = TRUE)
    data.frame(pkg = pkg, name = name, raw = m, stringsAsFactors = FALSE)
  }))
}

bare_hits <- function(text) {
  ms <- regmatches(text, gregexpr(BARE_RE, text))[[1]]
  if (!length(ms)) return(NULL)
  do.call(rbind, lapply(ms, function(m) {
    data.frame(pkg = NA_character_, name = sub("\\(.*", "", m), raw = m,
               stringsAsFactors = FALSE)
  }))
}

inline_spans <- function(line) {
  ms <- regmatches(line, gregexpr(SPAN_RE, line))[[1]]
  if (!length(ms)) return(character(0))
  substr(ms, 2L, nchar(ms) - 1L)
}

mentions <- list()
add_mention <- function(df, file, line, where) {
  if (is.null(df)) return(invisible(NULL))
  for (k in seq_len(nrow(df))) {
    mentions[[length(mentions) + 1L]] <<- list(
      pkg = df$pkg[k], name = df$name[k], raw = df$raw[k],
      file = file, line = line, where = where)
  }
}

for (file in qmd_files) {
  lines <- tryCatch(
    readLines(file.path(root, file), warn = FALSE, encoding = "UTF-8"),
    error = function(e) character(0))
  lines <- enc2utf8(lines)
  in_fence <- FALSE
  for (idx in seq_along(lines)) {
    line <- lines[[idx]]
    if (grepl("^[ \t]*(```|~~~)", line)) {
      in_fence <- !in_fence
      next
    }
    if (in_fence) {
      # An example that says `pkg::name` claims that API exists, so qualified
      # names count here even in an eval: false chunk. Bare calls inside an
      # example may be objects of that session, so they are not book claims.
      add_mention(qualified_hits(line), file, idx, "an example")
      next
    }
    for (span in inline_spans(line)) {
      hits <- qualified_hits(span)
      add_mention(hits, file, idx, "prose")
      # `clusterProfiler::bitr()` is one claim, not two: remove the qualified
      # text before looking for a bare `name()` so it is not reported twice.
      rest <- span
      if (!is.null(hits)) for (raw in hits$raw) rest <- sub(raw, "", rest, fixed = TRUE)
      add_mention(bare_hits(rest), file, idx, "prose")
    }
  }
}

# Names the book itself uses as packages: `library(X)`, `requireNamespace("X")`,
# `package = "X"`, or an `X::` prefix somewhere in the corpus. A bare `X()` that
# matches one of these is prose calling a package by its headline function
# (`WebGestaltR()` returns a summary table), not a claim about the book's API.
# Decided from the source, so the result does not depend on which optional
# packages happen to be installed on the machine running the check.
pkg_like <- local({
  txt <- paste(vapply(qmd_files, function(f)
    paste(readLines(file.path(root, f), warn = FALSE, encoding = "UTF-8"), collapse = "\n"),
    character(1)), collapse = "\n")
  pat <- c("library\\(\\s*([A-Za-z][A-Za-z0-9._]*)\\s*\\)",
           "require\\(\\s*([A-Za-z][A-Za-z0-9._]*)\\s*\\)",
           "requireNamespace\\(\\s*[\"']([A-Za-z][A-Za-z0-9._]*)[\"']",
           "package\\s*=\\s*[\"']([A-Za-z][A-Za-z0-9._]*)[\"']",
           "[Pp]kg\\(\\s*[\"']([A-Za-z][A-Za-z0-9._]*)[\"']",
           "([A-Za-z][A-Za-z0-9._]*)::")
  out <- character(0)
  for (p in pat) {
    ms <- regmatches(txt, gregexpr(p, txt))[[1]]
    for (m in ms) {
      v <- regmatches(m, regexec(p, m))[[1]]
      if (length(v) >= 2L) out <- c(out, v[[2L]])
    }
  }
  unique(out)
})

# ---- resolve ---------------------------------------------------------------
unknown <- list()
unchecked <- character(0)
seen <- character(0)
for (m in mentions) {
  key <- paste0(m$where, " ", ifelse(is.na(m$pkg), "", m$pkg), " ", m$name)
  if (key %in% seen) next
  seen <- c(seen, key)

  if (is.na(m$pkg)) {
    # Bare `name()`.
    if (m$name %in% pool_union || m$name %in% ALLOWLIST) next
    if (m$name %in% pkg_like) next
    unknown[[length(unknown) + 1L]] <- m
    next
  }

  # Qualified `pkg::name`. The shape pkg::pkg (`createKEGGdb::createKEGGdb`) is
  # the package name standing where a function belongs, and it is the exact
  # defect this check was written for: the real API is `create_kegg_db()`. So it
  # is settled against the symbol universe alone and the allowlist - which lists
  # packages the book mentions *as* packages - must not excuse it. A genuine
  # data object of that shape (`GO.db::GO.db`) resolves on its own.
  if (identical(m$pkg, m$name) && !(m$name %in% pool_union)) {
    ex <- tier_a(m$pkg)
    if (is.null(ex) || !(m$name %in% ex)) {
      full <- if (!is.null(ex)) tier_b(m$pkg) else NULL
      if (is.null(full) || !(m$name %in% full)) {
        unknown[[length(unknown) + 1L]] <- m
        next
      }
    }
    next
  }

  if (m$name %in% pool_union || m$name %in% ALLOWLIST) next

  ex <- tier_a(m$pkg)
  if (!is.null(ex)) {
    # The package is installed: its own export list settles it, with tier B as
    # the backstop for symbols only a loaded namespace can reveal.
    if (m$name %in% ex) next
    if (m$name %in% ALLOWLIST) next
    full <- tier_b(m$pkg)
    if (!is.null(full) && m$name %in% full) next
    unknown[[length(unknown) + 1L]] <- m
    next
  }
  # Not installed: its own exports cannot be inspected offline, so the name is
  # not reported - but the gap is surfaced so a human can see what went unchecked.
  unchecked[[length(unchecked) + 1L]] <- sprintf("%s::%s", m$pkg, m$name)
}

# ---- report ----------------------------------------------------------------
if (!quiet) {
  message(sprintf("checking %d QMD file(s) against %d package(s); not installed, skipped: %s",
                  length(qmd_files), length(installed_pool),
                  if (length(missing_pool)) paste(missing_pool, collapse = ", ") else "none"))
  message(sprintf("%d distinct mention(s) collected", length(seen)))
  if (length(unchecked)) {
    message(sprintf("%d mention(s) against a package not installed here, cannot verify offline: %s",
                    length(unique(unchecked)), paste(unique(unchecked), collapse = ", ")))
  }
}

if (length(unknown)) {
  for (m in unknown) {
    disp <- if (is.na(m$pkg)) sprintf("`%s()`", m$name) else sprintf("`%s::%s`", m$pkg, m$name)
    cat(sprintf("ERROR: %s:%d mentions %s in %s, which no book package exports\n",
                m$file, m$line, disp, m$where), file = stderr())
    spots <- mentions[vapply(mentions, function(g) identical(g$name, m$name) &&
                               identical(g$pkg, m$pkg), logical(1))]
    if (length(spots) > 1L) {
      cat(sprintf("  also mentioned at: %s\n",
                  paste(vapply(spots, function(g) sprintf("%s:%d", g$file, g$line), character(1)),
                        collapse = ", ")), file = stderr())
    }
  }
  cat(sprintf("API name check failed: %d unknown name(s) of %d checked\n",
              length(unknown), length(seen)), file = stderr())
  quit(save = "no", status = 1L)
}

cat(sprintf("API name check passed: %d distinct mentions, %d packages, 0 errors\n",
            length(seen), length(installed_pool)))
