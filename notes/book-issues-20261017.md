# biomedical-knowledge-mining-book — 审核问题清单（2026-10-17）

> 审核对象：<https://github.com/YuLab-SMU/biomedical-knowledge-mining-book>（本地 `biomedical-knowledge-mining-book/`）
> 审核基线：`d59e5df`（master 与 origin 同步、工作树干净），R 4.6.1 / Bioconductor 3.23 / quarto 1.10.18
> 审核方式：五套机械扫描（参数名 / chunk 解析 / 对象流 / 渲染产物 / 外链）+ 5 路子代理分章深读（1 路交付，其余 4 路在模型切换中中断，其线索由主代理自行实测闭环）
> 上一份清单：[`book-issues-20261016.md`](book-issues-20261016.md)（第 1–4 批 + 第 5、6 轮，全部收口）

**一句话结论**：上一轮之后，**七项自检脚本在 HEAD 上全部绿灯**（`check_navigation` / `check_links` / `check_bibliography` / `check_package_macros` / `check_api_names.R` / `check_versions.R` / `check_figure_sizes.py`，本轮逐一重跑确认）。但本轮仍找到 **19 个问题（N1–N18 + N5b），全部落在脚本覆盖面之外**，其中 4 个是"读者照抄即错/即被误导"的硬伤：

1. **N1** `enrichDAVID(listType=...)` —— 参数在当前 clusterProfiler 里**根本不存在**，实测报 `unused argument`；
2. **N2** `enrichment-network.qmd` 的加权富集示例 —— 教的 `weight` 写法在名字不匹配时**静默退化为不加权**，且唯一报警通路被该书自己的 `warning=FALSE` 掐死；
3. **N11** `enrichplot-networks.qmd` 说 `emapplot()` 节点色在 **fill** 上，实测在 **colour** 上；该章 `:414/:419` 的示例是**空操作**（且用的正好是默认色，所以看起来"生效"）；
4. **N12** 同章把 `node_label="> 1"` 说成按**绝对值**过滤，实测是**带符号**——照字面用会静默丢掉所有下调基因。

外加 `index.qmd` 一个未注册的 DOI、4 处失效自述/矛盾、3 个零输出的引擎章节（**21 个块里 19 个实测不碰网络，其中一段 `nseGO` 已在别的章节真跑出表**）、19 个永不执行的 ```` ```r ```` 围栏等。

---

## 严重度与批次划分

| 批次 | 主题 | 条数 | 是否需要重跑构建 |
|---|---|---|---|
| **第 1 批** | 内容硬错误（照抄即错 / 即被误导） | N1、N2、N11、N12、N13、N17、N18 | 需要（重渲染 5 章） |
| **第 2 批** | 断言失效与自相矛盾 | N3、N4、N5、N5b | 否 |
| **第 3 批** | "结果必须由代码产生"的回归 | N6、N7 | 需要（全书级） |
| **第 4 批** | 工具盲区 / 卫生 | N8、N9、N10 | 否 |
| **第 5 批** | 知识连接器章（sources 评审） | N13–N18（N14/N15/N16 只在本批；N13/N17/N18 与第 1 批重叠） | 需要 |

去重后共 **19 项**（第 1–4 批 16 项，第 5 批新增 N14/N15/N16 三项；N13/N17/N18 与第 1 批重复计一次）。

状态标记：⬜ 未开始（本清单只建档，未动任何文件）

**第 1 批硬伤的共同形态值得单独记一句**：N1 会直接报错，而 N2 / N11 / N12 / N13 / N17(下半) / N18 **都不报错或只把手打输出当真**——加权静默退回不加权、`scale_fill_*` 对 emapplot 是空操作、`node_label="> 1"` 静默丢下调基因、水稻 keyType 案例把"支持"写成"不支持"、`subset()` 对 S4 静默走 default 分支、150→149 的归因写错但数字对。N11 尤其典型：示例的 low/high 正好等于默认调色板端点，所以它连"看起来变了"都自证了。**"能渲染、数字对得上"不等于"是对的"**——第 6 轮那条教训在内容层的复现。

**本轮零改动**：`git status` 全程干净；所有结论均以 `Rscript` 实测或 `docs/*.html` 渲染产物为准，未采信任何子代理未复核的转述。

---

# 第 1 批 — 内容硬错误

## N11 `emapplot()` 的节点颜色走的是 `colour`，不是 `fill`——本章示例是个自我掩盖的 no-op

**位置**：`enrichplot-networks.qmd:257-259`（正文规则）与 `:414`、`:419`（示例）

正文写：
> For `emapplot()`, node colors are mapped to **the fill aesthetic**, so use `scale_fill_manual(values = ...)` (or `scale_fill_gradient*()`) there to customize the node colors.

**实测**（enrichplot 1.99.8 + ggplot2 4.0.3，`pairwise_termsim(enrichGO(...))` 真对象）：

```
layer2 geom: GeomPoint
layer2 aes : colour=p.adjust  size=size      ← 节点色在 colour 上
built layer2: fill 列 distinct = 1（全 NA）；colour 列 distinct = 24
默认调色板 #E06663 / #327EBA 出现在 colour，不在 fill

+scale_fill_continuous(low="black", high="white", trans="log10")
   fill changed?   FALSE
   colour changed? FALSE      ← 整个标度对出图毫无作用
+scale_colour_continuous(...)  -> 节点色改变（26 distinct）
```

**为什么一直没被发现**：该章 `:414`/`:419` 示例里 `scale_fill_continuous(low="#e06663", high="#327eba")` 用的**恰好就是默认调色板的两个端点色**。执行它、渲染它、看图——颜色"确实变了"，因为脚本本来就是默认色。这是一个能跑通、能出图、但**语义上是空操作**的示例，比死代码更危险：读者换成自己的颜色时才会发现改不动。

**边界（重要，别一刀切）**：`emapplot(compareClusterResult, pie=...)` 的节点层是 `GeomArcBar`，aes 含 `x0,y0,r,r0,fill,amount,group`——**饼图分支确实用 fill**。因此 `comparecluster-visualization.qmd:219`（"Pie colors are mapped to `Cluster`，可用 `ggplot2::scale_fill_manual()`"）是**正确的**。错的是 `enrichplot-networks.qmd` 把这个分支的规则错误地推广到了 `emapplot()` 全体。

**改法**：`:257-259` 改为"`emapplot(enrichResult)` 的节点色映射在 **colour** 上，用 `scale_colour_*()`；只有 `pie=` 的 compareCluster 分支才在 fill 上，用 `scale_fill_*()`"；`:414`/`:419` 的两处 `scale_fill_continuous` 改成 `scale_colour_continuous`。
**验收**：改后把 low/high 换成两个显眼的非默认色（如 black/white），图必须肉眼可见地变——用这个办法可以一次性证明"标度真的接上了"。

## N12 `node_label = "> 1"` 是**带符号**过滤，正文却写成按绝对值

**位置**：`enrichplot-networks.qmd:94`

> **Conditional filtering**: Use comparison operators to filter genes based on fold change, e.g., `node_label = "> 1"` or `node_label = "< -1"` to label genes with **absolute fold change greater than 1**

**实测**（`readable=TRUE`，label 为 SYMBOL，再映回 fold change 数值；`geneList` 12439 个可映射基因，范围 −4.3…4.57）：

```
node_label="> 1"   labels=32   全为正 (pos=32, neg=0)   区间 [2.02, 4.14]
node_label="< -1"  labels=1    全为负                  值 −2.44
```

判据在这里：`"< -1"` 那组证明**同一批被显示的 term 里确实存在 fc < −1 的基因**（那个 −2.44 的），而 `"> 1"` 没有把它标出来。若真是"绝对值 > 1"，|−2.44| > 1 必然入选。所以两个条件各自是**带符号**阈值，`"> 1"` = 上调且 >1，`"< -1"` = 下调且 <−1；二者并集才等于"|fc|>1"。

**为什么危险**：读者照字面写 `node_label = "> 1"` 想标出"变化剧烈的基因"，实际**静默丢掉所有下调基因**，而图上看不出来被丢过。这与 N2 同属"不报错、结果静默不对"这一类。

**改法**：改成"按**带符号** fold change 过滤：`"> 1"` 只标上调超过 1 倍的基因，`\"< -1\"` 只标下调的；需要两端都标就写 `node_label = c(...)` 或分别取并集"。
**验收**：`grep -n "absolute fold change" enrichplot-networks.qmd` → 0。

## N1 `enrichDAVID()` 的 `listType` 参数在当前版本不存在，照抄即报错

**位置**：`other-databases.qmd:82-86`（label `enrichdavid-example`）与 `:118-121`（label `enrichdavid-universe`）

```r
david = enrichDAVID(gene = gene,
                    idType="ENTREZ_GENE_ID",
                    listType="Gene",           # ← 不存在
                    annotation="KEGG_PATHWAY",
                    david.user = "clusterProfiler@hku.hk")
```

**实测**（安装版本 clusterProfiler 4.21.3）：

```
formals(clusterProfiler::enrichDAVID):
gene, idType, universe, minGSSize, maxGSSize, annotation,
pvalueCutoff, pAdjustMethod, qvalueCutoff, species, david.user     ← 无 listType，无 ...

enrichDAVID(gene=c("1","2"), listType="Gene")
→ ERROR: unused argument (listType = "Gene")
```

**背景**：两处 chunk 都 `eval: false`，所以**构建永远不会抓到它**——这正是上一轮 §2.12 给 DAVID 加 callout 时的设计（"calling convention 不变"）。但约定**已经变了**：clusterProfiler 把 `enrichDAVID` 重构成统一 enricher API 后删掉了 `listType`。callout 里那句"the calling convention does not change with an outage"现在是**错误的承诺**——读者恢复网络后照抄，第一下就撞在参数上而不是网络问题上。

**改法**：两处删掉 `listType=` 行（`idType` 已经承担了该语义）；把 callout 那句改成"calling convention 以当前 clusterProfiler 的 formals 为准"。
**验收**：把 N9 的内联/API 检查补上后此条应自动报错；临时可跑：

```bash
grep -rn "listType" *.qmd   # 期望 0
```

## N2 加权富集示例教的 `weight` 写法会**静默不加权**，且本书自身把唯一的报警通路掐死了

**位置**：`enrichment-network.qmd:203-223`（Weighted ORA / Weighted GSEA）

```r
net_ig  <- get_ppi_network(9606, output = "igraph")   # 节点 = 真实 Entrez ID
pr_weights <- page_rank(net_ig)$vector                 # names = Entrez 数字字符串
res_wora <- ora(gene = de_genes, gene_sets = pathways,
                universe = all_genes, weight = pr_weights)   # ← 这三个对象全章从未定义
res_wgsea<- gsea(geneList = stats, gene_sets = pathways, weight = pr_weights)
```

**四层问题，逐层实测**：

(a) **示例是悬空的**。`de_genes / pathways / all_genes / stats / signed_stats` 全章 grep 无任何定义点（`grep -nE 'de_genes <-' → 0`）。前面 chunk 只用注释 `# (Assuming 'stats' is ...)` 带过。对"eval: false 的示意代码"这尚可容忍，但叠加 (b)(c) 后就是误导。

(b) **`pr_weights` 的名字空间与全书其余示例天然错配——而且本书在别处亲自承认过。** `get_ppi_network()` 的 igraph 分支实测（body 第 31-32 行）直接 `igraph::graph_from_data_frame(links[, c("protein1","protein2", ...)])`，**节点名就是 STRING 原始 ID**（`9606.ENSP…`，Ensembl protein）。于是 `page_rank(net_ig)$vector` 的 names 全是 `9606.ENSP…`。而 clusterProfiler 各知识连接器消费的 `gene/universe` 是 **Entrez**。本书 `go-semantic-similarity.qmd:149-153` 恰恰专门演示了这一步：

```r
# Clean up STRING IDs
ppi$from <- vapply(ppi$from, function(e) strsplit(e, "9606.")[[1]][2], character(1))
```

也就是说，**本书知道这类命名空间错配会咬人、并且在别的章节专门处理过**——`ppi.qmd:88-93` 的注释写得明明白白（"'y' was setReadable, the nodes in 'g' are gene symbols. We need to match the IDs"），随后用 `mapIds(org.Hs.eg.db, ..., column="SYMBOL", keytype="ENTREZID")` 做对齐；`go-semantic-similarity.qmd:149-153` 也专门剥离 `9606.` 前缀。**唯独加权富集这一例把这一环整个略过了**：没有映射、没有 `bitr()`、也没有说明 `de_genes` 属于哪个命名空间。读者照抄时权重向量与基因向量必然对不上。这是**同一本书内对同一风险的两种处理口径**，不是单纯漏写注释。

(c) **对不上时，ORA 侧是静默降级，不是报错。** 构造实测（`enrichit` 0.2.6）：

```
no weight       : 0.000000 0.046325 1.000000
w names ok      : 0.000000 0.069592 1.000000     ← 加权生效
w no overlap    : 0.000000 0.046325 1.000000     ← 与不加权逐位相同
```

`weight` 的 names 与 universe 零交集时，`enrichit::ora()` 只发一条 **warning**（"Some background genes do not have weights. Assigning median weight."）然后**返回与不加权完全一致的 p 值**——"做了加权、看不出没做"。GSEA 侧则硬报错（`No common genes found between geneList and weight`）。两个入口对同一个错误给出两种反馈（一边静默一边报错），本身就是必须在书里写明的不对称；而书里两处都没提。

(d) **书自己把唯一的报警掐死了**。该章第 6 行：

```r
knitr::opts_chunk$set(message=FALSE, warning=FALSE, eval=FALSE)
```

`warning=FALSE` 正是吞掉 (c) 那条 warning 的开关。读者在本章语境里跑这段，将**什么提示都看不到**，只拿到一组不加权的 p 值。AGENTS.md §6 明确要求"必须说明……失败模式"，这里恰是失败模式没写。

**改法**：
- **直接复用本书已有的共享离线夹具**：`_common.R:317 clusterprofiler_enrichit_demo()` 实测返回 `geneList_signed / geneList_evidence / network / network_2 / couplings / seed_list / kegg_gson`，且 **命名空间全程对齐**（geneList names、network 节点、gson 基因 ID 同为 Entrez：`4312, 8318, 10874…`，`keytype = "ncbi-geneid"`）。`go-enrichment.qmd:184` 与 `kegg-enrichment.qmd:332` 已经是这么做的。本章应改用同一夹具，把 `get_ppi_network + page_rank` 换成 `demo$network` 上可离线计算的 centrality 权重；若坚持用真实 STRING 网络，则必须像 `ppi.qmd:88-92` / `go-semantic-similarity.qmd:149-153` 那样显式做 ID 剥离与映射，并与那两章同一口径。
- 正文加一段（与 `universe` callout 同款）：`weight` 的 names 必须与 `gene`/`geneList` 同一命名空间；**ORA 错配时只警告并退回中位权重（结果等于不加权），GSEA 错配时直接报错**——这个不对称要写明；
- 该 callout 里顺带提醒：在 `warning=FALSE` 的会话/构建环境里这条警告不可见，交互使用时要显式检查 `any(names(weight) %in% universe)`。

**验收**：把示例真跑一遍（临时翻 `eval: true` 渲染该章），确认 `res_wora$pvalue` 与不加权版本**不同**，且 chunk 输出里能看到 `oddsRatio` 列生效。

---

# 第 2 批 — 断言失效与自相矛盾

## N3 `index.qmd` 的 DOI 写错年份，指向不存在的 DOI

**位置**：`index.qmd:120`（Citation 第 1 条）

```
[Background bias ...](https://doi.org/10.59717/j.xinn-life.2025.100181)
__*The Innovation Life*__. 2026, 4(1):100181.
```

**实测**：该 DOI 在 doi.org 返回 `Error: DOI Not Found`（404）；同一行正文年份写的是 **2026**；Crossref 按标题检索命中的注册 DOI 是
`10.59717/j.xinn-life.`**`2026`**`.100181`（resolve 后 HTTP 200）。即 DOI 串里的 `2025` 应为 `2026`，且与同行"2026, 4(1)"自相矛盾。

**改法**：`2025` → `2026`（一处）。
**为什么脚本没抓到**：`check_bibliography.py` 只解析 `references.bib`；正文内联 `https://doi.org/...` 10 条全部在任何检查的覆盖面外（见 N9）。

## N4 `choose-a-route.qmd:189` 教读者"重跑分析"，与全书的导入链自相矛盾

**位置**：`choose-a-route.qmd:189`

> If you only have a table exported by another program, **recreate the equivalent analysis in `clusterProfiler`** … before using the object-aware plots.

**矛盾对象**（逐条核实在位）：`04-visualization.qmd:12`（"Can an external result be shown in the same grammar? | Import and normalize the result, then plot it"）、`capability-map.qmd:141`、以及整整一章 `enrichplot-import.qmd`。`getNamespaceExports("enrichplot")` 实测确有 `import_enrichr / import_gprofiler2 / import_webgestalt / import_fgsea / as_enrichResult / as_gseaResult`——即"不用重跑也能拿到对象"正是这些函数的存在理由。全书只有这一处在教"重跑"。

**改法**：保留"缺 universe/ranking 时重跑是兜底"的语义，主句改为指向导入函数与 import 章。

## N5 三处"页面自述"失效

| 位置 | 原文 | 实际 |
|---|---|---|
| `04-visualization.qmd:14` | "The detailed [enrichplot chapter](…) **contains the plotting API**" | `enrichplot.qmd` 是 70 行兼容壳，其 `:69` 自己写着 "intentionally no longer duplicated here … Use the task pages"。指向的页面**没有任何 plotting API**，应路由到 6 个任务章。 |
| `data-contract.qmd:156` | "**The next chapter** applies these contracts to one offline, end-to-end example." | `_quarto.yml` Part 0 顺序 `first-workflow → data-contract → choose-a-route`：下一章是 `choose-a-route`（纯决策页）。端到端示例在**上一章**；同文件 `:163` 已写对（"use the [first complete workflow]"），156 与 163 自相矛盾。 |
| `capability-map.qmd:5-7` | "…so that this page can serve as a cross-reference **when it is added to the book navigation**" | 它就在导航里（`_quarto.yml:85`），`index.qmd:60` 等 4 处都在链它。合并前的遗留话术，向读者宣称本页是临时的。 |

**附带**（同文件，顺手改）：`capability-map.qmd` 的编号节实际按 **1,2,3,5,4,6** 出现（`:116` 的 "5." 排在 `:145` 的 "4." 前），把 116 与 145 的序号互换即可。

## N5b `capability-map.qmd:82` 把 `godata()` 列为 GSON 的消费者（实测：不成立）

> Supplies … gene sets to `enricher()`, `GSEA()`, `ora_gson()`, `gsea_gson()`, `nseKEGG()`, or **`godata()`**

`GOSemSim::godata` 实测 formals：`OrgDb, annoDb, keytype, ont, computeIC, processTCSS, cutoff`——**不接收任何 gene set / GSON**；它是从注释库构建 `GOSemSimDATA` 的构造函数，且由 GOSemSim 导出，不在 GSON 下游链路里。删掉这一项即可。

**订正（本条初稿曾同时质疑 `nseKEGG()`，经复核为误判，撤销）**：`.prepare_nse_kegg_data()`（clusterProfiler 内部）实测有显式分支：

```r
} else if (inherits(organism, "GSON")) {
    KEGG_DATA <- organism; species <- KEGG_DATA@species; keyType <- KEGG_DATA@keytype
} else { stop("organism should be a species name or a GSON object") }
```

即 `nseKEGG(organism = <GSON>)` **正是受支持的路径**，本书也确实在用它（`kegg-enrichment.qmd:330` 正文原话："pass a local KEGG-style `GSON` object through the `organism` argument"；`enrichment-network.qmd:143`、`kegg-enrichment.qmd:341,360`、`gson.qmd:491-492` 同）。所以 capability-map 列 `nseKEGG()` 是**正确的**。
**这条误判的价值**：它证明"函数 formals 里没有 `gson` 参数就判定不支持 GSON"是错的——该能力靠 `inherits()` 类型分支复用同一个 `organism` 参数，不体现在签名里。后续任何自动检查都不能只看 formals；本轮 N1 的参数名审计因此不能外推到"参数能力"。

---

# 第 3 批 — "结果必须由代码产生"的回归

上一轮 §1.7 刚把 ChIPseeker 章从"0 个可执行 chunk"改成 7 个，本章两个回归面说明这条规则**仍然没有验收工具**。

## N6 三个引擎章零输出；21 个代码块里 19 个不碰网络

**对象**：`enrichment-foundations.qmd`、`enrichment-network.qmd`、`enrichment-multiomics.qmd`（全书"分析引擎"叙事的正文）。
**渲染事实**（`docs/*.html`，对应 HEAD 内容）：

```
enrichment-foundations   source=6  output=0
enrichment-network       source=6  output=0
enrichment-multiomics    source=9  output=0
（对照：first-workflow 19/18，go-enrichment 15/8，gson 34/31）
```

三章共 21 个可见代码块、0 个计算输出。成因是双保险：每章 setup 里 `opts_chunk$set(... eval=FALSE)` + 每个 chunk 又单独 `#| eval: false`。

**可跑性实测**（离线、秒级）：

| 示例 | 结果 |
|---|---|
| foundations 的 Fisher/ORA 例 | `p-value = 7.879e-10`，毫秒级 |
| foundations 的 enrichit `gsea()` 合成例 | 2 行结果，ES/NES/p 齐全 |
| foundations 的 `scoreType` 例 | std 双路命中、pos 把底侧打回 ES=0/p=1、neg 反之（**与正文断言完全一致**，该断言由此从"存疑"转"已验证"） |
| multiomics 的 `aggregate_omics` fisher/brown | 均正常；注入信号基因确实进入头部（rank 3–39 / 1000） |
| network 章的 `demo` 块（`:117`） | 用 `_common.R` 的离线夹具，**同一段 `nseGO()` 调用在 `go-enrichment.qmd:188` 已经真跑并出表**（实测两处参数集逐条相同：`identical = TRUE`） |

**精确计数（本轮逐个 chunk 复核）**：21 个块里 **19 个不碰网络**（我此前一处把 `subnet` 里的 `net` 误判成网络调用，已纠正），仅 `:25` 与 `:203` 两处依赖 `get_ppi_network()`。也就是说这 19 个块本来就能进构建——**同一份 nseGO 代码在另一章已经在跑、并且渲染出了结果**，"不能跑"这个理由不成立。

这些恰恰是全书概念密度最高的章节：AGENTS.md §4 把"最小可运行示例"列为模板必选项，§5 禁止静态粘贴——而这里连静态粘贴都没有，只有代码没有结果。

**改法**（按上轮 §11.15 的做法分批）：
- 三章 setup 的 `eval=FALSE` 改为章级默认 true，仅对确需网络的两块保留 `#| eval: false`（`:25`、`:203` 的 `get_ppi_network`）；
- **注意连带**：翻正会激活 N2 的悬空对象（`:48` 的 `net`/`signed_stats`、`:203` 的 `de_genes/pathways/all_genes`，以及 foundations `:45` 的 `background_ids`）——**这两件事必须同批改，否则构建直接失败**。这大概也是它一直没人动的原因，建议 commit message 里写明；
- 翻正后逐章 `quarto render <章>`，把 gsea/aggregate/nseGO 输出纳入 knitr cache，再跑 `check_figure_sizes.py`。

## N7 19 个 ` ```r ` 纯围栏永不执行；其中两章的全部正文示例都在围栏里

**清点**：全书 `^```r$` 共 19 处 vs 可执行 ```` ```{r} ```` 351 处。分布与定性：

| 文件 | 处数 | 定性 |
|---|---|---|
| `recipes.qmd` | **4/4 全部** | **缺陷**。该章没有任何可执行 chunk（`recipes.html` source=4 output=0）。实测 recipe-1 整段可跑：`enrichGO` 245 terms / `gseGO` 124 terms，离线、`datasets/de_table.tsv` 现成。"Task recipes" 是全读者照抄密度最高的页面，却完全在构建校验之外。 |
| `reproducible-report.qmd` | **2/2 全部** | **缺陷**。同上：`saveRDS`/`sessionInfo` 段写向 `results/` 目录，章内无建目录语句，围栏身份使其永远不会以"失败"暴露。 |
| `interpretation.qmd` | 10 | 多数是 aisdk 用法示意（需 key，可辩护）；但 `cluster_mapping <- c(...)`、`context <- "…"` 等 3 处是纯 R，可执行。 |
| `go-enrichment.qmd:167` | 1 | **正确用法**——"the code therefore does roughly:" 的内核伪码，本就不该执行。 |
| `result-objects.qmd:108`、`troubleshooting.qmd:26` | 2 | 占位/示意（`read.csv(your_csv_file)`），可辩护。 |

**改法**：recipes 与 reproducible-report 的 6 处改为可执行 chunk（配 `eval: false` 仅给真正需要外部文件的部分，如 recipe-2/3 依赖 `term2gene` 的可以先补合成定义）；interpretation 的 3 处纯 R 翻正。
**验收**：`grep -c '^```r$' recipes.qmd reproducible-report.qmd` → 0；重渲染后两页 output>0。

---

# 第 4 批 — 工具盲区与卫生

## N8 chunk 选项两套语法混用，会骗过按语法写的任何工具

70 个 chunk 用旧式围栏内选项（` ```{r eval=FALSE} ` / `include=FALSE` / `warning=FALSE`），分布在 24 个文件；其余用 `#|` 行式。本轮我自己的两版检查器都因此**先后产出假阳性**（第一版把 13 个 `eval=FALSE` 围栏当成会执行、把 3 处"eval:false 对象泄漏"当真阳性报出来）。可复现的证据：

```bash
grep -rlc '^```{r [^}]*}' *.qmd | ...   # 24 files, 70 chunks
# 交叉验证：同一个 chunk 的禁用状态写两处、语法不同 → 只查 #| 的工具判"会执行"
```

`include=FALSE` 现存 6 处全部是 setup chunk 的正当用法（本轮逐个看过），但上轮教训 N-A 正是"`include: false` 连代码一起藏"——没有脚本盯这个数字。**改法**：全书统一为 `#|` 行式（机械替换即可，knitr 两者等价）；并在 `check_links.py` 旁加一个 `check_chunk_options.py`：同一 chunk 内围栏选项与 `#|` 选项不得并存声明同一键。

## N9 正文内联 DOI / 外部 API 完全在覆盖面外（N3 的成因）

`.qmd` 正文里有 **10 条内联 `https://doi.org/...`**，`check_bibliography.py` 只解析 `references.bib`，因此一条未注册 DOI（N3）带着"25 entries, 0 errors"的绿灯上线。**改法**：给 `check_bibliography.py` 加正文内联 DOI 提取（形态检查免费；resolve 检查可放 CI 的 `continue-on-error` 步）。
顺带：本轮 60 条外链全量探测的结果可入库作基线——`rapdb.dna.affrc.go.jp`（`kegg-enrichment.qmd:110`）DNS 可解析但连接失败（直连+代理双验），**处理标准沿用 N-2.12 的教训：替代地址未核实前宁可去链、如实记录**；biostars/OUP 等 403 为反爬，浏览器正常，不动。

## N10 卫生杂项

- **chunk label 跨章重复**：`load-packages` 在 7 章重复（`bayesian-term-selection / enrichment-overview / go-enrichment / go-semantic-similarity / interpretation / kegg-enrichment / result-objects`）。当前无人用 `@ref` 引用它，所以是**潜伏**缺陷——与上轮 §1.6 的跨章重复锚点同类；`check_links.py` 只管 `{#anchor}` 不管 `#| label:`，加一行即可。

---

# 第 5 批 — 知识连接器章（sources 评审 6 条，全部主代理复测）

评审子代理交付 6 条。逐条复测：**6 条方向都成立**，但主代理把其中 2 条的范围**收窄**了（N16 少误伤一章、N15 一度查错反而确认子代理），另有一处旁证补强（N14 的"为什么构建没抓到"）。

## N13 `enrichKEGG()` 水稻 keyType 案例：三个"Output:"全是手打的，教的结论是反的

**位置**：`kegg-enrichment.qmd:67-90`（chunk `find-keyType`，`eval=FALSE`）＋ `:90` 结论句

书里给三种探测写了"Output"，其中两条是 `Error in KEGG_convert(...) : uniprot is not supported for dosa` 与 `… ncbi-geneid is not supported for dosa`，并据此结论：*"for `dosa`, the supported `keyType` is `kegg`, and the expected gene ID format looks like `Os06t0664200-01`"*。

**实测**（本机直连 KEGG 挂起，走 `127.0.0.1:7897` 跑真实函数）：

| keyType | 实际行为 | 书里教的 |
|---|---|---|
| `kegg` | 正常，`--> Expected input gene ID: Os01g0190400,…` | 唯一支持 ✓（但 ID 形态错） |
| `uniprot` | **也正常**：`/conv/uniprot/dosa` → HTTP 200，返回 `up:P12192,P12186,…` | "not supported" ✗ |
| `ncbi-geneid` | `/conv/ncbi-geneid/dosa` → **HTTP 400**，报下载失败 | "not supported" ✗（错因） |

`curl https://rest.kegg.jp/list/dosa` 的真实 ID 是 `dosa:Os01g0100100` 这种 **g 型**（无 `t`、无 `-01`），`Os06t0664200-01` 在任何包/端点都不存在。

**为什么严重**：本节定位是"该方法适用于任何物种，照此探测即可"——**读者按它探测会得到反向结论**，把可用的 UniProt 命名空间整个排除。且这三段"Output:"是手打的、从未捕获，违反 AGENTS.md §5。
**改法**：重贴真实 message；结论改为"`dosa` 支持 `kegg`（g 型 ID）与 `uniprot`（`up:…`），`ncbi-geneid` 被 KEGG 以 400 拒绝"。

## N14 `gson_KEGG()` 被归给 CRAN 的 `gson` 包（实为 clusterProfiler 导出）

**位置**：`kegg-enrichment.qmd:141`（正文）＋ `:143-152`（`library(gson)` 后直接调 `gson_KEGG()`）

**实测**：`getNamespaceExports("gson")` 无 `gson_KEGG`（FALSE）；`clusterProfiler` 有（TRUE，`gson_WP`/`gson_GO`/`gson_KO` 同）。纯净会话只挂 gson 调用 → `could not find function "gson_KEGG"`。

**为什么构建没抓到（补强）**：该章 `:3-10` 的 setup chunk 是 `#| echo: false` 且里面 `library(clusterProfiler)`，所以**在本章语境里恰好能跑**——错误被不可见的搜索路径掩盖，读者只在没加载 clusterProfiler 时才撞上。正是 §7"每个新章节自己的 setup chunk 负责加载所需包"要防的"靠上文残留状态才成立"。`gson.qmd:104-108` 的对照章同时加载两包，故本章是其内不一致。
**改法**：正文改"`gson` 提供 `GSON` 容器，`gson_KEGG()` 这类知识获取器由 clusterProfiler 提供"；示例改 `clusterProfiler::gson_KEGG(...)` 或补 `library(clusterProfiler)`。

## N15 `category`/`subcategory` 只对 `enrichKEGG`/`gseMKEGG`/`nseKEGG` 成立，`gseKEGG` 没有

**位置**：`kegg-enrichment.qmd:381`（覆盖 ORA + GSEA 的"KEGG Pathway Classification"节）

**实测（这条主代理一度查错，反而确认子代理）**：四函数体直接 grep `append_kegg_category` → `enrichKEGG`/`gseMKEGG` TRUE、`gseKEGG`/`nseKEGG` FALSE。**但** `nseKEGG`/`mnseKEGG` 调 `.finalize_nse_kegg_result()`，该函数内含 `append_kegg_category`（全命名空间扫描命中 `.finalize_nse_kegg_result, enrichKEGG, gseMKEGG`）。所以 `nseKEGG` 经 finalize **确实带** category（子代理对），**只有 `gseKEGG` 不带**——其列为 `ID,…,core_enrichment,log2err`，无 `category`。
**改法**：限定为"`enrichKEGG()`（及 module/topology 变体）附 `category`/`subcategory`；`gseKEGG()` 目前不会"。

## N16 旗舰 callout"size filtering is overlap-based"对 **无 universe 的 ORA 不成立**

**位置**：`go-enrichment.qmd:164-175`（callout 本体，括号点明"the candidate vector for ORA"）、`:353`、`:358`；`disease-enrichment.qmd:65`（总结句）

**主代理实测（决定性判别，比子代理更干净）**：输入候选向量只有 **207** 个基因——按 callout 的规则，任何进入检验的集合"交集大小"最大不可能超过 207，故 `maxGSSize=500` **不可能淘汰任何集合**。同一输入、`pvalueCutoff=1`，看 `GO:0005737`(cytoplasm)：

| 项 | raw 注释大小 | 与 207 输入的交集 | `maxGSSize=500` 入选？ | `=Inf` |
|---|---|---|---|---|
| GO:0005737 cytoplasm | 11 946 | **132 < 500** | **否** | 是 |
| GO:0071944 cell periphery | 6 345 | **78 < 500** | **否** | 是 |

交集 <500 却被 `maxGSSize=500` 淘汰，只能是**上限作用在原始注释大小**。机制吻合 `enrichit:::ora_gson`：`extID <- intersect(注释基因, universe)`，无 universe 时 extID=全部注释基因。（注：两轮总 term 数 234/78 非嵌套、可能有其他分支差异，**不作证据**；上面单项成员判别无歧义。）GSEA 侧 `enrichit:::gsea` 确实 `intersect(gene_sets, names(geneList))`，正确。

**影响面（修正子代理两处）**：
- `first-workflow.qmd:152` 的同名 callout **没错**——它明确限定 GSEA（"after intersecting with … `names(geneList)`"）。**子代理列为重复错误项不成立，不入册。**
- `disease-enrichment.qmd:65` 是**自相矛盾**：括号写对了（"or with all annotated genes when no universe is set"），但紧跟的总结句"bounds refer to the effective size after intersection … **not** to the raw annotation size"在无 universe 时（`enrichDO` 默认）恰好反了。要改总结句，不是括号。
- `go-enrichment.qmd:358`"filtering now happens **after** intersecting with your measured genes"同错。

**改法**：callout 按引擎分写——GSEA 用 `names(geneList)`；ORA 用 `universe`，**不传 universe 则背景=全部注释基因、`maxGSSize` 回到按原始大小过滤**，想要 overlap 行为必须显式给 universe（或 `maxGSSize=Inf`）。这与本书"universe 必须是 character"的 callout 呼应。

## N17 `dropGO()`/`gofilter()` 不接受 `gseGO()` 结果；`subset(x, level …)` 示例照抄即报错

**位置**：`go-enrichment.qmd:289`（声明）、`:293-299`（chunk `go-add-level`，`eval: false`）

**实测**：`methods::is(new("gseaResult"),"enrichResult")` → FALSE；两函数都以 `is(x,"enrichResult")||is(x,"compareClusterResult")` 设闸，报 `x should be an instance of 'enrichResult' or 'compareClusterResult'`。故 `:289` 里 `gseGO()` **不成立**。逐字跑 `subset(x, level>=3 & level<=6)`（`x` 已 `add_go_level()`，`level` 列存在）→ **`Error: object 'level' not found`**；`enrichResult` 无 `subset` 方法，`subset.default` 对 S4 求值找不到 `level`。`subset(as.data.frame(x), …)` → **OK, 158 行**。子代理顺带验的 `OrgDb="org.Hs.eg.db"`（字符串）可用，非缺陷。
**改法**：`:289` 删 `gseGO()`；`:298` 改 `subset(as.data.frame(x), …)` 或 `x |> as.data.frame() |> dplyr::filter(…)`（与本书 dplyr 口径一致）。

## N18 ChIPseeker 章把 150→149 归因于"Distal Intergenic 峰无 geneId 被丢弃"，实际一个都没丢

**位置**：`chipseeker-enrichment.qmd:144-147`

**实测**（该章完全相同调用：`sample_peaks.txt` + `tssRegion=c(-3000,3000)` + hg19 knownGene）：
```
peaks: 150 | anno rows: 150
Distal Intergenic rows: 24 | their NA geneId: 0
   sample distal geneId: 220108, 27300, 2898, 57706
NA geneId across ALL rows: 0
distinct geneId: 149 | duplicated assignments: 1
```
24 个 distal intergenic 峰**全有 geneId**（`annotatePeak` 在 `flankDistance` 内指派了最近侧翼基因），全表零 NA；`^[0-9]+$` 一个没删。150→149 唯一原因是**一个基因被两峰共享**（duplicated=1）。教学点（报告有多少峰贡献基因）成立，但**因果写错**，读者会误以为自己的差异也来自 intergenic 丢失。旁侧 `seq2gene()` callout 正确（152 条里 12 条裸 Entrez；`sub(".*[._]","", "…_3")`→`"3"`）。
**改法**：改为"149 是去重后的基因数，可少于峰数（多峰可映射同一基因）；只有窗口内够不到任何基因的峰才让 `geneId` 为 NA 并被过滤——本例为 0 个。"

---

# 已排除项（全部实测翻案——照抄子代理或直觉会报错误的一条）

| 疑点 | 实测结论 |
|---|---|
| `compareCluster(geneCluster=)`（choose-a-route / recipes / comparecluster-*，7 处） | **不是缺陷**。formals 是 `geneClusters`，R 前缀部分匹配生效；实跑 `geneCluster=` 与 `geneClusters=` 返回完全相同的 `compareClusterResult`（361 行）。至多是风格问题。 |
| `cnetplot(categorySize="pvalue")`（first-workflow:140） | **不报错**：落入 `...`，实测 plot 数据不变（36 行 fortify 输出与不传一致）。真正的参数是 `categorySizeBy`，comparecluster-visualization 用法正确。此处静默无效参数 + N2 的命名教训同源，修复时顺手删。 |
| `enrichit::gsea` 的 null 分母 callout（foundations:90） | **完全正确**：`sample/permute` 下 `scoreType=pos/neg` 与 `std` 结果逐位相同（ES=-1, p=0.0018）；`multilevel` 下 pos 把底侧集打回 ES=0/p=1。与正文叙述一致。 |
| `scoreType` 三例注释（"pos 漏掉底侧、neg 漏掉顶侧"） | 正确（同上实测）。 |
| 数字 universe callout（foundations:41-43） | 正确：实测 message "`universe` is not in character and will be ignored…"，且回退到默认背景 18842 keys；`compareCluster` 体 `suppressMessages(fun(i, ...))` 亦与叙述一致。 |
| `barplot()` 未在 enrichplot 导出 | **不是缺陷**：`barplot.enrichResult` 是注册 S3 方法，`graphics::barplot` 为 internal generic，`barplot(ora)` 实测返回 ggplot；`check_api_names.R` 已 allowlist。 |
| multiomics fisher 例"注入信号没进头部" | 初判有误后复查：注入的 20 个基因占 rank 3–39（1000 取），top5 之外是随机噪声；聚合生效，示例成立。 |
| `get_ppi_network(9606)` 默认输出 | 与正文"Default output is data.frame (edge list)"一致：`formals$output = "data.frame"`。 |
| 富余 6 条外链（hrbmu/pathview 等） | 位于 HTML 注释内且正是"记录失效"的载体（上轮设计），非缺陷。 |
| **子代理报的**：`first-workflow.qmd:152` 也重复了 overlap-based 错话 | **不成立，不入册**。该 callout 明确限定 GSEA（"after intersecting with the genes present in your ranking (`names(geneList)`)"），实测 GSEA 侧确实 intersect——**写对了**。N16 的错只在 `go-enrichment` 把它扩张成"the candidate vector for ORA"。 |
| **主代理自查**：`gson_KEGG()` 示例在本章会报 could-not-find（子代理判为直接 hard-error） | 修正为**被掩盖的错误**：该章 setup chunk `echo:false` 已 `library(clusterProfiler)`，本章语境下能跑；错在归因与读者独立复现时。见 N14。 |
| **主代理自查**：`nseKEGG` 不带 category（直接 grep `gseKEGG`/`nseKEGG` 均 FALSE） | 我差点据此否定子代理——再查发现 `nseKEGG`/`mnseKEGG` 经 `.finalize_nse_kegg_result()` 附 category。**子代理对**，错的只有 `gseKEGG`。见 N15。 |
| **主代理自查**：`enrichGO` 在 `maxGSSize=Inf` 里查不到 `GO:0005737` 就断定"它本就被排除" | 我第一轮判据有缺陷（该 term 在 Inf 下未过 p 值筛选）；换成 207-候选向量判别后才干净。总 term 数 234/78 非嵌套，**不拿来当证据**。见 N16。 |

---

# 验收记录（本轮结束时）

```
check_navigation.py      PASS  50 QMD
check_links.py           PASS  72 pages
check_bibliography.py    PASS  25 entries, 0 errors (4 warnings)
check_package_macros.py  PASS  87 usages / 21 registry, 0 errors
check_api_names.R        PASS  224 mentions, 0 errors
check_versions.R         PASS  18 rows match
check_figure_sizes.py    PASS  0 oversized
git status: clean（本清单只建档，未改任何书稿文件）
```

**本轮方法记录**（为什么这些能被找到而脚本找不到）：
1. 参数名审计对**全部 351 个可执行 chunk + 内联 `` `foo(...)` `` 调用**与安装库 formals 做了逐调用比对（含 S3 方法并集豁免 base 内置函数后仍有 2 处 STRONG——`check_api_names.R` 只验函数名存在，不验参数名，这就是覆盖面差）。
2. 渲染产物 `docs/*.html` 的 `source vs cell-output` 计数把 N6/N7 变成一行 shell 就能复核的事实，而非阅读观感。
3. 关键防线依然是上轮 §6.10 那句：**任何"看起来像缺陷"的项先实测再入册**。本轮 9 条疑点实测后翻案 7 条，其中 2 条（geneCluster / categorySize）是子代理报告直接报错的。

# 变更记录

| 日期 | 内容 |
|---|---|
| 2026-10-17 | 建档（基线 `d59e5df`，七项自检全绿后开始）。机械扫描五套 + 分章深读 5 路（1 路交付 6 项发现、其中 4 项经复核入册为 N3/N4/N5/N5b；4 路在模型切换中中断，其 engines 线索由主代理实测闭环为 N2）。建档时 10 条：N1–N10；后续增至 19 条（N1–N18 + N5b），含"已排除项"9 条留档。未改任何书稿文件。 |
| 2026-10-17 | 订正两处**我自己的**误判并留档：(a) N5b 初稿曾判定 `nseKEGG()` 不接受 GSON——错，`.prepare_nse_kegg_data()` 有 `inherits(organism,"GSON")` 显式分支，能力不在签名里；据此记下"参数名审计不能外推到参数能力"。(b) N6 初稿"18/21 可离线"低估为……实为 19/21（我把 `subnet` 里的 `net` 误读成网络调用）。另补：`_common.R:317` 已有命名空间全程对齐的离线夹具 `clusterprofiler_enrichit_demo()`，且同一段 `nseGO()` 在 `go-enrichment.qmd` 已真跑出表——N6 的"跑不动"理由不成立。 |
| 2026-10-17 | viz 评审子代理报"正在写报告"即中断、未落盘；但其留在 `/tmp/audit/` 的 30+ 个验证脚本（O1–O4/P1/Q1/R2）暴露出两条未交付线索。主代理**自行复跑**并确认，新增 **N11**（emapplot 节点色在 colour 不在 fill；`:414/:419` 示例为空操作，边界：`pie=` 的 compareCluster 分支确实用 fill，故 comparecluster-visualization.qmd:219 正确）与 **N12**（`node_label="> 1"` 是带符号过滤，非绝对值；由 `"< -1"` 命中 −2.44 反证）。第 1 批由 2 条增至 4 条；第 5 批并入后共 19 项。 |
