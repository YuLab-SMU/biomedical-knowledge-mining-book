pkg_dir <- "e:/YuNotebooks/01_Development/source/mycran/enrichit"

suppressPackageStartupMessages({
  library(devtools)
  load_all(pkg_dir, quiet = TRUE)
})

message("Checking Brown aggregation...")
set.seed(123)
gene_ids <- paste0("Gene", seq_len(80))

rna_p <- runif(80, 0.05, 1)
prot_p <- runif(80, 0.05, 1)
rna_p[1:8] <- c(1e-4, 5e-4, 0.002, 0.004, 0.006, 0.008, 0.01, 0.02)
prot_p[1:8] <- c(2e-4, 8e-4, 0.003, 0.005, 0.007, 0.009, 0.015, 0.03)

p_mat <- cbind(RNA = rna_p, PROT = prot_p)
rownames(p_mat) <- gene_ids
cov_mat <- matrix(c(4, 1.2, 1.2, 4), nrow = 2)

brown_res <- aggregate_omics(
  x = p_mat,
  method = "brown",
  input = "pvalue",
  cov_matrix = cov_mat
)

stopifnot(inherits(brown_res, "omics_aggregated"))
stopifnot(length(brown_res$score) == length(gene_ids))
stopifnot(all(names(head(sort(brown_res$score, decreasing = TRUE), 5)) %in% gene_ids[1:8]))

message("Checking late fusion...")
pathways <- list(
  SharedPath = gene_ids[1:8],
  RNAPath = gene_ids[9:16],
  ProtPath = gene_ids[17:24]
)

rna_sig <- c(gene_ids[1:6], gene_ids[9:13])
prot_sig <- c(gene_ids[c(1:4, 7:8)], gene_ids[17:21])

rna_res <- ora(
  gene = rna_sig,
  universe = gene_ids,
  gene_sets = pathways
)
prot_res <- ora(
  gene = prot_sig,
  universe = gene_ids[c(1:60)],
  gene_sets = pathways
)

late_res <- aggregate_enrichment(
  res_list = list(RNA = rna_res, PROT = prot_res),
  method = "brown"
)

stopifnot(methods::is(late_res, "enrichResult"))
stopifnot("SharedPath" %in% late_res@result$ID)
stopifnot(all(c("p.adjust", "geneID", "Count") %in% colnames(late_res@result)))

message("Checking multi-layer NSEA...")
networks <- list(
  RNA = data.frame(
    from = c("Gene1", "Gene2", "Gene3"),
    to = c("Gene2", "Gene3", "Gene4"),
    weight = c(1, 1, 1),
    stringsAsFactors = FALSE
  ),
  PROT = data.frame(
    from = c("Gene1", "Gene3", "Gene4"),
    to = c("Gene3", "Gene4", "Gene1"),
    weight = c(1, 1, 1),
    stringsAsFactors = FALSE
  )
)

couplings <- data.frame(
  from_layer = c("RNA", "RNA", "RNA"),
  from_id = c("Gene1", "Gene3", "Gene4"),
  to_layer = c("PROT", "PROT", "PROT"),
  to_id = c("Gene1", "Gene3", "Gene4"),
  weight = c(1, 1, 1),
  stringsAsFactors = FALSE
)

seed_list <- list(
  RNA = c(Gene1 = 1.5, Gene2 = 0.8, Gene4 = -0.9),
  PROT = c(Gene1 = 0.5, Gene3 = 1.2, Gene4 = -0.4)
)

ml_gene_sets <- list(
  SignalPath = c("Gene1", "Gene2", "Gene3"),
  DownPath = c("Gene4")
)

mnsea_res <- mnsea(
  seed_list = seed_list,
  networks = networks,
  couplings = couplings,
  gene_sets = ml_gene_sets,
  mode = "signed",
  collapse = "weighted_mean",
  layer_weights = c(RNA = 1, PROT = 1.5),
  minGSSize = 1,
  maxGSSize = 10,
  method = "sample",
  nPerm = 30,
  verbose = FALSE
)

stopifnot(methods::is(mnsea_res, "mnseaResult"))
stopifnot(nrow(mnsea_res@result) > 0)
stopifnot(nrow(mnsea_res@pathway_contribution) > 0)
stopifnot(nrow(mnsea_res@feature_contribution) > 0)

pathway_tbl <- get_mnsea_contribution(mnsea_res, level = "pathway")
feature_tbl <- get_mnsea_contribution(mnsea_res, pathway_id = pathway_tbl$ID[1], level = "feature")
subnet <- extract_mnsea_subnetwork(mnsea_res, pathway_id = pathway_tbl$ID[1])

stopifnot(is.data.frame(pathway_tbl))
stopifnot(is.data.frame(feature_tbl))
stopifnot(all(c("nodes", "edges") %in% names(subnet)))
stopifnot(nrow(subnet$nodes) > 0)

message("All enrichit feature checks passed.")
