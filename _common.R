library(yulab.utils)


svg2png <- function(path, options) {
  if (!grepl('[.]svg$', path)) {
    return(path)
  }

  if (file.size(path) / 1000000 < 1.2) {
    ## less than 1.2M
    return(path)
  }
  output <- sub(".svg$", ".png", path)
  system2("convert", paste("-density 150", path, output))
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
