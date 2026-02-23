# 告别全局 topN！教你用 split 和 autofacet 轻松搞定 GO 富集条形图的分面展示

做富集分析（GO/KEGG）时，我们常用 `barplot()` 展示显著通路。默认情况下，`barplot()` 会根据 p 值或 q 值排序，展示“全局最显著”的 N 个通路。

但这种展示方式有个痛点：**不同本体（BP/CC/MF）的通路数量可能极不平衡。** 比如，可能前 20 个显著通路里，18 个都是 BP（生物学过程），而 CC（细胞组分）和 MF（分子功能）几乎被挤没了。

这时候，我们往往希望：**每个本体各取前 N 个，然后分面展示。**

以前可能需要自己处理数据、用 ggplot2 手画，但现在 `enrichplot` 的 `barplot()` 已经原生支持这个功能了！只需一个参数 `split` 加上 `autofacet`，就能轻松实现。

今天就带大家看两个实用的例子。

---

## 准备数据

首先，我们用 `DOSE` 包里的示例数据，跑一个包含三个本体（BP/CC/MF）的 GO 富集分析。

```r
library(DOSE)
data(geneList, package = "DOSE")
de <- names(geneList)[1:300]

library(clusterProfiler)
library(org.Hs.eg.db)

# 跑一个 GO 富集，注意 ont = "ALL"
ego_all <- enrichGO(
  gene = de,
  OrgDb = org.Hs.eg.db,
  keyType = "ENTREZID",
  ont = "ALL",
  readable = TRUE
)
```

## 场景一：不想分面，只想把三个本体的 topN 混在一起画

如果你不想分面，只是希望“BP、CC、MF 各取前 5 个”画在一张图里，直接在 `barplot()` 里加上 `split = "ONTOLOGY"` 即可。

注意：`split` 参数不仅帮你做分组筛选，还会把分组信息（这里是 `ONTOLOGY` 列）保留在数据里，方便后续映射颜色。

```r
library(enrichplot)
library(ggplot2)

p_nofacet <- barplot(
  ego_all,
  x = "Count",
  showCategory = 5,     # 每个分类取前 5 个
  split = "ONTOLOGY"    # 按 ONTOLOGY 分组取 topN
) +
  aes(fill = ONTOLOGY) + # 映射颜色
  scale_fill_brewer(palette = "Set2")

# 调整一下 y 轴标签（防止太长被自动换行影响阅读，这里强制不换行）
p_nofacet + 
  geom_text(aes(label = Count), nudge_x = 2) + 
  scale_y_discrete()
```

**关键点：**
*   `split="ONTOLOGY"`：告诉 `barplot` 不要全局取 topN，而是按 `ONTOLOGY` 分组，每组取 `showCategory` 指定的数量。
*   `scale_y_discrete()`：默认情况下 `barplot` 会为了美观自动把很长的通路名换行（wrap），如果你希望能完整显示（哪怕图变宽），加上这个图层可以覆盖默认设置。

---

## 场景二：我想分面！每个本体一张子图

这才是终极需求！既然都按 `ONTOLOGY` 取好了，分面展示显然逻辑更清晰。

这时候，神器 `enrichplot::autofacet()` 就派上用场了。只要你的数据里有分组列（刚才 `split="ONTOLOGY"` 已经生成了 `ONTOLOGY` 列），它就能自动识别并分面。

```r
p_facet <- barplot(
  ego_all,
  x = "Count",
  showCategory = 5, 
  split = "ONTOLOGY"
) +
  aes(fill = ONTOLOGY) +
  scale_fill_brewer(palette = "Set2") +
  enrichplot::autofacet(by = "row", scales = "free") # 一行代码搞定分面

p_facet
```

**关键点：**
*   `enrichplot::autofacet(by = "row", scales = "free")`：
    *   会自动检测数据中的 `ONTOLOGY` 列进行分面。
    *   `by = "row"` 表示按行分面（即上下排列），适合长条形图，方便横向对比。
    *   `scales = "free"` 很重要，因为不同本体的通路数量和 Count 范围可能不同，释放标尺能让图更紧凑。

---

## 总结

1.  **拒绝被淹没**：用 `split="ONTOLOGY"`，确保 BP/CC/MF 都能露脸。
2.  **自动分面**：`+ enrichplot::autofacet()` 是绝配，省去了手写 `facet_grid` 的麻烦。
3.  **标签控制**：觉得标签换行难看？`+ scale_y_discrete()` 把它改回来。

以后画 GO 富集图，记得试试这套组合拳！

---

*参考资料：enrichplot 文档*
