#!/usr/bin/env Rscript

# Derive the stable differential-expression table used by first-workflow.qmd.
# The table is committed so the book does not need airway or DESeq2 at render time.

suppressPackageStartupMessages({
    library(airway)
    library(DESeq2)
})

output <- file.path("datasets", "de_table.tsv")

data(airway)

# The airway example compares dexamethasone-treated and untreated samples while
# accounting for the donor-derived cell line.
airway$dex <- relevel(airway$dex, ref = "untrt")
dds <- DESeqDataSet(airway, design = ~ cell + dex)
dds <- DESeq(dds, quiet = TRUE)
res <- results(
    dds,
    contrast = c("dex", "trt", "untrt"),
    independentFiltering = FALSE
)

de_table <- data.frame(
    gene_id = rownames(res),
    as.data.frame(res),
    check.names = FALSE,
    row.names = NULL
)

write.table(
    de_table,
    file = output,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE,
    na = "NA"
)

cat("Wrote", nrow(de_table), "rows to", output, "\n")
