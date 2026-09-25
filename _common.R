library(yulab.utils)


## Retry a network call, returning NULL if it keeps failing.
##
## The book build depends on several third-party services (Europe PMC, KEGG,
## Enrichr, ...). A transient 5xx from one of them should not fail a scheduled
## publication, so those calls are wrapped in retry() and the chunk degrades
## gracefully instead of halting the render. A real bug still surfaces: retry()
## only swallows the failure of the expression it is given, and it warns.
##
## The expression is captured unevaluated and re-evaluated on every attempt.
## Passing it straight to tryCatch() would evaluate the promise once, and R
## would then emit "restarting interrupted promise evaluation" on each retry.
retry <- function(expr, times = 3, wait = 5) {
  expr <- substitute(expr)
  env <- parent.frame()
  for (attempt in seq_len(times)) {
    res <- tryCatch(eval(expr, env), error = function(e) e)
    if (!inherits(res, "error")) {
      return(res)
    }
    if (attempt < times) {
      Sys.sleep(wait)
    }
  }
  warning(conditionMessage(res), call. = FALSE)
  NULL
}


## TRUE if the file begins with an HTML tag, i.e. a web page was saved where a
## data file was expected. Compares raw bytes so it is safe on any encoding.
is_html_response <- function(path) {
  bytes <- readBin(path, "raw", n = 512L)
  bytes <- bytes[!bytes %in% charToRaw(" \t\r\n")]
  length(bytes) > 0 && bytes[1] == charToRaw("<")
}

## Download a file, retrying transient failures, and return its path -- or NULL
## if the service stays unavailable.
##
## `download.file()` is inconsistent across backends: the "wget"/"curl" methods
## warn and return a non-zero exit status, whereas the internal and libcurl
## methods raise an error. Both are normalised into an error here so that
## retry() can actually retry.
##
## A successful status is not sufficient either. Enrichr answers an unknown
## library name with an HTML error page under HTTP 200, so download.file()
## reports success and read.gmt() then returns an empty data frame -- a silently
## wrong table rather than a visible failure. Such responses are treated as
## failures. This assumes the caller wants a data file, which is the case for
## every download in this book (GMT, GAF, xlsx).
retry_download <- function(url, destfile, ...) {
  retry({
    status <- suppressWarnings(download.file(url, destfile = destfile, ...))
    if (!identical(as.integer(status), 0L)) {
      stop("download.file() returned status ", status, " for ", url)
    }
    if (file.exists(destfile) && is_html_response(destfile)) {
      stop("the server returned an HTML page instead of a file: ", url)
    }
    destfile
  })
}


## Safe HTML formatting for live interpretation reports.
##
## The package print methods intentionally emit Markdown headings. That is useful
## at the console, but unsafe in a Quarto `results: asis` chunk because those
## headings become book-level TOC entries. These helpers render a structured
## preview with HTML elements and keep the original print output escaped inside
## a collapsed block.
html_escape <- function(x) {
  x <- paste(as.character(x), collapse = "\n")
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  x
}

html_paragraphs <- function(x) {
  x <- html_escape(x)
  x <- gsub("\n[[:space:]]*\n", "</p><p>", x)
  x <- gsub("\n", "<br />", x)
  paste0("<p>", x, "</p>")
}

html_list <- function(x, empty = "<p>None returned.</p>") {
  values <- unlist(x, use.names = FALSE)
  values <- values[!is.na(values)]
  if (!length(values)) {
    return(empty)
  }
  paste0(
    "<ul>",
    paste0("<li>", vapply(values, html_escape, character(1)), "</li>", collapse = ""),
    "</ul>"
  )
}

html_named_fields <- function(x) {
  if (is.null(x)) {
    return("")
  }
  if (!is.list(x) || is.null(names(x))) {
    return(html_paragraphs(x))
  }
  paste0(
    vapply(seq_along(x), function(i) {
      label <- names(x)[i]
      value <- x[[i]]
      if (is.list(value)) {
        value <- paste(unlist(value, use.names = FALSE), collapse = ", ")
      }
      prefix <- if (!is.null(label) && nzchar(label)) {
        paste0("<strong>", html_escape(label), ":</strong> ")
      } else {
        ""
      }
      paste0("<p>", prefix, html_escape(value), "</p>")
    }, character(1)),
    collapse = ""
  )
}

html_report_field <- function(label, value, kind = c("text", "list", "named")) {
  kind <- match.arg(kind)
  body <- switch(
    kind,
    text = html_paragraphs(value),
    list = html_list(value),
    named = html_named_fields(value)
  )
  paste0("<p><strong>", html_escape(label), ":</strong></p>", body)
}

render_interpretation_block <- function(report, index = NULL) {
  if (is.null(report)) {
    return("<details class=\"interpretation-report\" open><summary>Empty interpretation report</summary></details>")
  }

  cluster <- if (!is.null(report$cluster)) report$cluster else NULL
  confidence <- if (!is.null(report$confidence)) report$confidence else "Not returned"
  raw <- paste(capture.output(print(report)), collapse = "\n")
  fields <- character()

  if (!is.null(report$cell_type)) {
    title <- paste0("Cell type: ", report$cell_type)
    if (!is.null(cluster)) title <- paste0("Cluster ", cluster, ": ", title)
    fields <- c(
      html_report_field("Cell type", report$cell_type),
      if (!is.null(report$refinement_status)) html_report_field("Status", report$refinement_status),
      html_report_field("Confidence", confidence),
      html_report_field("Reasoning", if (!is.null(report$reasoning)) report$reasoning else "No reasoning returned."),
      html_report_field("Supporting markers/pathways", report$markers, "list")
    )
  } else if (!is.null(report$phenotype)) {
    title <- paste0("Phenotype: ", report$phenotype)
    if (!is.null(cluster)) title <- paste0("Group ", cluster, ": ", title)
    fields <- c(
      html_report_field("Phenotype", report$phenotype),
      html_report_field("Confidence", confidence),
      html_report_field("Reasoning", if (!is.null(report$reasoning)) report$reasoning else "No reasoning returned."),
      html_report_field("Key processes", report$key_processes, "list")
    )
  } else {
    title <- if (!is.null(cluster)) paste0("Interpretation — cluster ", cluster) else "Interpretation report"
    if (!is.null(report$overview)) fields <- c(fields, html_report_field("Overview", report$overview))
    if (!is.null(report$regulatory_drivers)) fields <- c(fields, html_report_field("Regulatory drivers", report$regulatory_drivers, "list"))
    if (!is.null(report$key_mechanisms)) fields <- c(fields, html_report_field("Key mechanisms", report$key_mechanisms, "named"))
    if (!is.null(report$crosstalk)) fields <- c(fields, html_report_field("Crosstalk and interactions", report$crosstalk))
    if (!is.null(report$hypothesis)) fields <- c(fields, html_report_field("Hypothesis", report$hypothesis, if (is.list(report$hypothesis)) "named" else "text"))
    if (!is.null(report$narrative)) fields <- c(fields, html_report_field("Narrative draft", report$narrative))
    if (!is.null(report$network_evidence)) fields <- c(fields, html_report_field("Network evidence", report$network_evidence))
    if (!length(fields) && !is.null(report$overview)) fields <- html_paragraphs(report$overview)
  }

  if (!length(fields)) {
    fields <- html_paragraphs("No structured fields were returned.")
  }

  paste0(
    '<details class="interpretation-report" open>',
    "<summary><strong>", html_escape(title), "</strong> <span class=\"interpretation-confidence\">(",
    html_escape(confidence), ")</span></summary>",
    '<div style="border: 1px solid #dee2e6; border-radius: .4rem; padding: 1rem; margin: .75rem 0 1rem 0;">',
    paste(fields, collapse = ""),
    '<details><summary>Raw object print</summary><pre><code>',
    html_escape(raw),
    "</code></pre></details>",
    "</div></details>"
  )
}

render_interpretation_blocks <- function(reports) {
  is_single <- !is.list(reports) || inherits(reports, "interpretation") ||
    !is.null(reports$cell_type) || !is.null(reports$phenotype) || !is.null(reports$overview)
  items <- if (is_single) list(reports) else reports
  paste(vapply(seq_along(items), function(i) {
    render_interpretation_block(items[[i]], index = i)
  }, character(1)), collapse = "\n")
}


## Rasterise oversized figures.
##
## NOTE: do NOT enable this via `fig.process`. It is kept only for reference.
##
## The idea was sound: several enrichment plots (gseaplot2() in particular) draw
## one graphical element per gene in the ranked list, so their SVG output runs
## to tens of megabytes. A single figure can contain >20,000 <path> elements and
## one path whose `d` attribute is ~290 kB of coordinates, which makes the page
## take minutes to render and often never finish (issue #41).
##
## But ImageMagick's built-in SVG renderer cannot parse these files. It reports
##
##   convert-im6.q16: unbalanced graphic context push-pop `graphic-context'
##   convert-im6.q16: non-conforming drawing primitive definition `use'
##
## and writes a PNG containing only the axes: the curves, hit ticks and
## ranked-list panel are all silently dropped. Enabling this would therefore
## replace heavy figures with empty ones.
##
## The figures are rasterised properly by letting R draw them as PNG in the
## first place -- add `#| fig-format: png` to the offending chunk (see the
## gseaplot2 chunks in enrichplot.qmd). That is 60x smaller and needs no
## external converter.
svg2png <- function(path, options) {
  if (!grepl('[.]svg$', path)) {
    return(path)
  }

  if (file.size(path) / 1000000 < 1.2) {
    ## less than 1.2M
    return(path)
  }

  output <- sub(".svg$", ".png", path)
  status <- system2("convert",
                    c("-density", "150", shQuote(path), shQuote(output)),
                    stdout = FALSE, stderr = FALSE)

  if (status != 0 || !file.exists(output)) {
    ## Keep the SVG rather than deleting it: a failed conversion should make
    ## the page heavy, not remove the figure altogether.
    warning("svg2png(): could not convert '", path, "'; keeping the SVG")
    return(path)
  }

  file.remove(path)
  return(output)
}


library(knitr)
opts_chunk$set(
  message = FALSE,
  warning = FALSE,
  eval = TRUE,
  echo = TRUE,
  cache = TRUE,
  dev = "svg",
  out.width = "98%" #,
  #fig.process = svg2png
)

build_demo_network <- function(ids) {
  stopifnot(length(ids) >= 4)
  rbind(
    data.frame(
      from = ids[-length(ids)],
      to = ids[-1],
      weight = 1,
      stringsAsFactors = FALSE
    ),
    data.frame(
      from = ids[-c(length(ids) - 1, length(ids))],
      to = ids[-c(1, 2)],
      weight = 0.5,
      stringsAsFactors = FALSE
    )
  )
}

clusterprofiler_enrichit_demo <- function(n = 300) {
  data(geneList, package = "DOSE")

  demo_ids <- names(sort(abs(geneList), decreasing = TRUE))[seq_len(n)]
  demo_signed <- sort(geneList[demo_ids], decreasing = TRUE)
  demo_evidence <- sort(abs(demo_signed), decreasing = TRUE)
  demo_network <- build_demo_network(names(demo_evidence))
  demo_network_2 <- demo_network
  demo_network_2$weight <- demo_network_2$weight * 1.2

  demo_couplings <- data.frame(
    from_layer = "RNA",
    from_id = names(demo_evidence),
    to_layer = "PROT",
    to_id = names(demo_evidence),
    weight = 0.2,
    stringsAsFactors = FALSE
  )

  demo_seed_list <- list(
    RNA = demo_evidence,
    PROT = demo_evidence * 0.8
  )

  demo_kegg_sets <- list(
    hsa_demo_04110 = names(demo_evidence)[1:35],
    hsa_demo_04010 = names(demo_evidence)[21:70],
    hsa_demo_04910 = names(demo_evidence)[61:120]
  )
  demo_kegg_gsid2gene <- do.call(
    rbind,
    lapply(names(demo_kegg_sets), function(id) {
      data.frame(
        gsid = id,
        gene = demo_kegg_sets[[id]],
        stringsAsFactors = FALSE
      )
    })
  )
  demo_kegg_gsid2name <- data.frame(
    gsid = names(demo_kegg_sets),
    name = c(
      "Cell cycle (demo)",
      "MAPK signaling pathway (demo)",
      "Insulin signaling pathway (demo)"
    ),
    stringsAsFactors = FALSE
  )
  demo_kegg_gson <- gson::gson(
    gsid2gene = demo_kegg_gsid2gene,
    gsid2name = demo_kegg_gsid2name,
    species = "Homo sapiens",
    gsname = "KEGG",
    version = "demo",
    accessed_date = as.character(Sys.Date()),
    keytype = "ncbi-geneid"
  )

  list(
    geneList_signed = demo_signed,
    geneList_evidence = demo_evidence,
    network = demo_network,
    network_2 = demo_network_2,
    couplings = demo_couplings,
    seed_list = demo_seed_list,
    kegg_gson = demo_kegg_gson
  )
}
