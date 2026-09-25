Cell_marker_Human.xlsx: <http://yikedaxue.slwshop.cn/Cell_marker_Human.xlsx>

`de_table.tsv` is derived from the Bioconductor `airway` package (version 1.32.0) with `DESeq2`. It contains 63,677 Ensembl gene IDs and the differential-expression result for dexamethasone-treated (`trt`) versus untreated (`untrt`) airway smooth-muscle samples, using the design `~ cell + dex`. Columns are `gene_id`, `baseMean`, `log2FoldChange`, `lfcSE`, `stat`, `pvalue`, and `padj`. Recreate it with:

```bash
Rscript scripts/make_airway_de_table.R
```

The table is committed so the book examples can render without installing `airway` or rerunning DESeq2.
