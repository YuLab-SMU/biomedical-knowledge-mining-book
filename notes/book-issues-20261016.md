# biomedical-knowledge-mining-book — 审核问题清单（2026-10-16 起）

> 审核对象：<https://github.com/YuLab-SMU/biomedical-knowledge-mining-book>（本地 `biomedical-knowledge-mining-book/`）
> 审核方式：全书 50 个 `.qmd` 静态扫描 + 与本地 R 环境 / CI workflow / 线上站点实况交叉核对
> 审核基线：`e9c4af3`，R 4.6.1 / Bioconductor 3.23，quarto 1.10.18
> 上一份问题记录：[`notes/book-issues.md`](book-issues.md)（2026-09-21，基于 GitHub issue 区）
> 本文件自身位置：`notes/book-issues-20261016.md`。第 1 批做于 2026-10-16，第 2–4 批及第 5、6 轮做于 2026-10-17（日期以提交时间为准）。

**一句话结论**：导航一致性、legacy redirect、`retry_download()` 防御、AGENTS.md 流程模板这几块做得扎实；但 **两个自检脚本（`check_navigation.py` / `check_links.py`）都通过的情况下，正文里仍有不存在的函数名、三个假 DOI、跨章重复锚点和失效的硬编码章节号**。根因是「脚本覆盖面 = 相对链接 + 导航完备性」，而本清单第一、二类问题全部落在覆盖面之外。

---

## 严重度与批次划分

| 批次 | 主题 | 条数 | 是否需要重跑构建 | 状态 |
|---|---|---|---|---|
| **第 1 批** | 内容硬错误（读者照抄会出错 / 违反 AGENTS.md 明文规则） | 10 | 需要 | ✅ 完成（2026-10-16） |
| **第 2 批** | 复现性与 CI（版本表、依赖、网络韧性） | 13 | 需要 | ✅ 完成（2026-10-17，2.12 改为「已核实并按实情处理」） |
| **第 3 批** | 结构、可访问性、仓库卫生 | 5 | 部分 | ✅ 完成（3.3 见下方说明） |
| **第 4 批** | 小问题 / 观感 | 4 | 否 | ✅ 完成 |

状态标记：✅ 已修 / 🟡 进行中 / ⬜ 未开始 / ➖ 记录但不改

> **本轮开始时的实际状态与本清单不符**：进入本轮时 `master` 已比清单记录的基线 `e9c4af3` 领先 4 个提交，其中 `5ecfdbe` 与 `b4d3666` 已经把 2.1–2.9、2.13 和 3.3 做掉了，只是清单没回写。因此本轮先**逐条核对**而非重做，确认已落地的直接回写状态，只处理真正剩下的部分。

---

# 第 1 批 — 内容硬错误

这一批的共同特征：**每一条都是「读者按书上写的做，会失败或得到错的东西」**，且每一条都可以用机械改动修掉，不涉及叙事重构。

## 1.1 API 索引里列了不存在的函数

**位置**：`glossary-api-index.qmd:33`

```
| Use network/weighted methods | `nseGO()`, `nseKEGG()`, `weighted_enrich()`, network helpers | ...
```

**问题**：`weighted_enrich()` 在 `enrichit`（本地 0.2.6）里不存在。`getNamespaceExports("enrichit")` 里没有该符号。加权富集的真实入口是把 `weight` 传给 `ora()` / `gsea()`，`enrichment-network.qmd:205` 自己的示例就是这么写的：

```r
res_wora <- ora(gene = de_genes, gene_sets = pathways, universe = all_genes, weight = pr_weights)
res_wgsea <- gsea(geneList = stats, gene_sets = pathways, weight = pr_weights)
```

`capability-map.qmd:81` 的写法是对的（`ora()`, `gsea()`, `nsea()`, `mnsea()`, weighted enrichment），两处口径不一致。

**改法**：把 `weighted_enrich()` 换成 `ora()` / `gsea()` 的 `weight` 参数表述，并与 `capability-map.qmd` 对齐。
**验收**：新增一个函数名存在性检查（见 2.x）后此条应自动报错。

状态：✅

## 1.2 `createKEGGdb::createKEGGdb()` 是错的函数名

**位置**：`troubleshooting.qmd:126`

```r
createKEGGdb::createKEGGdb("hsa")   # writes KEGG.db
```

**问题**：上游 `YuLab-SMU/createKEGGdb` 的 NAMESPACE 只导出 `create_kegg_db` 和 `create_kegg_db_microbiota`。同一个仓库里 `kegg-enrichment.qmd:190,196` 写的是正确的 `create_kegg_db(c("hsa", "ath"))`。FAQ 是读者最照抄的地方。

**改法**：统一为 `createKEGGdb::create_kegg_db("hsa")`。

状态：✅

## 1.3 `gson` / `enrichit` 的包链接指向 Bioconductor「Removed Packages」

**位置**：`gson.qmd:23`、`gson.qmd:40`、`kegg-enrichment.qmd:141` 用了 `r Biocpkg("gson")`。

**问题**：生成 `https://bioconductor.org/packages/gson`。该 URL **返回 HTTP 200**，所以 `check_links.py` 不报（它本来也不查 http 链接）；但页面标题是 `Bioconductor - Removed Packages`，正文是一长串被移除包名单。gson 实际在 CRAN（`CRAN: Package gson`，v0.2.2）。
实测 `https://bioconductor.org/packages/enrichit` 同样是「Removed Packages」页——`enrichit` 也在 CRAN。

`enrichit` 在书中出现 20+ 次（`capability-map.qmd`、`enrichment-foundations.qmd`、`bayesian-term-selection.qmd` 等）但**一次链接都没有**。

**改法**：
- `Biocpkg("gson")` → `CRANpkg("gson")`（3 处）。
- `enrichit` 首次出现处（`capability-map.qmd` 分层表 或 `enrichment-foundations.qmd:14`）补一个 `CRANpkg("enrichit")`。
- 注意 `_quarto.yml` 已关掉 `code-link`，理由写在 `REPRODUCIBILITY.md`（不依赖 CRAN index）。`CRANpkg()` 宏是纯字符串拼 URL、不查索引，因此不违背这条政策；需要在 2.x 的检查里确认 URL 形态而不是可达性。

状态：✅

## 1.4 references.bib：三个假 DOI + 五个重复 key

**位置**：`references.bib`

| 行 | key | 问题 | 正确值 |
|---|---|---|---|
| 143 | `wang_new_2007` | `doi = {btm087}` | `10.1093/bioinformatics/btm087` |
| 198 | `schlicker_new_2006` | `doi = {1471-2105-7-302}` | `10.1186/1471-2105-7-302` |
| 187 | `lin_information-theoretic_1998` | `doi = {10.1.1.55.1832}`（CiteSeerX 内部 id，非 DOI） | 删 `doi` 字段，保留 citeseerx `url` |

**影响已被渲染出来**：线上 `semantic-similarity.html`、`do-semantic-similarity.html`、`mesh-semantic-similarity.html` 三页的参考文献各含 2 处 `https://doi.org/btm087` / `doi.org/1471-2105-7-302` / `doi.org/10.1.1.55.1832` 死链（共 18 个坏链接）。

**重复 key**（BibTeX 行为未定义，pandoc 当前静默取其一，换渲染器即变）：

| key | 两处行号 | 是否一致 |
|---|---|---|
| `yu_dose_2015` | 55 / 257 | 一致 |
| `yu2012` | 76 / 278 | 类型 `@article` vs `@Article`、title 大小写保护不同 |
| `yu2011` | 94 / 294 | 类型不同 |
| `yu_new_2011` | 108 / 308 | title 花括号保护不同 |
| `yu2010` | 123 / 323 | 一致 |

**另有 7 个从未被正文引用的条目**：`Du15062009`、`lord_semantic_2003`、`huang_david_2007`、`fresno_rdavidwebservice_2013`、`paranjpe_genome_wide_2013`、`yu2011`、`yu_new_2011`。其中 `lord_semantic_2003`（疾病语义相似性奠基方法）与 `huang_david_2007` / `fresno_rdavidwebservice_2013`（DAVID 方法学与 Web 服务）本应被 `semantic-similarity.qmd` 和 `other-databases.qmd` 的 DAVID 小节引用——DAVID 节现在是**零引用**。

**改法**：修 3 个 DOI；5 组重复各保留一份（保留字段更完整的那份）；把 `lord_semantic_2003` 补进 `do-semantic-similarity.qmd` 的 IC 方法句、`huang_david_2007` + `fresno_rdavidwebservice_2013` 补进 `other-databases.qmd` 的 DAVID 节；`Du15062009` / `paranjpe_genome_wide_2013` / `yu2011` / `yu_new_2011` 若无自然归属则删除。

状态：✅

## 1.5 硬编码章节号全线失效

重构后 Quarto 自动编号已经变了，正文里还留着写死的数字。实测线上编号：

| 位置 | 书中写法 | 指向页实际章号 |
|---|---|---|
| `do-semantic-similarity.qmd:52` | `[Chapter 1](semantic-similarity.qmd#semantic-similarity-overview)` | **20** |
| `go-semantic-similarity.qmd:25` | `[Chapter 1](semantic-similarity.qmd#...)` | **20** |
| `mesh-semantic-similarity.qmd:110` | `[Chapter 1](semantic-similarity.qmd#...)` | **20** |
| `semantic-similarity.qmd:153` | `[Chapter 2](go-semantic-similarity.qmd#GOSemSim)` | **21** |
| `semantic-similarity.qmd:153` | `[Chapter 3](do-semantic-similarity.qmd#DOSE-semantic-similarity)` | **22** |
| `semantic-similarity.qmd:153` | `[Chapter 4](mesh-semantic-similarity.qmd#meshes-semantic-similarity)` | **23** |
| `identifier-utilities.qmd:145` | `[Chapter 12](universal-enrichment.qmd#universal-api)` | **15** |
| `troubleshooting.qmd:165` | `[Chapter 16](result-objects.qmd#clusterProfiler-dplyr)` | **19** |

所有目标锚点都存在（已逐个核对），所以链接是通的，只是**显示的文字在骗人**。书内已有大量正确写法（`@sec-xxx` 会自动渲染成 "Section 20.1"），这 8 处是漏改。

**改法**：一律改成 `[@anchor]` 交叉引用形式，让编号自维护；不要改成写死的新数字（下次重排还会坏）。

状态：✅

## 1.6 跨章重复锚点导致链接指错章节

| 锚点 | 定义处 A | 定义处 B | 实测后果 |
|---|---|---|---|
| `{#sec-setReadable}` | `identifier-utilities.qmd:79`（章 18） | `kegg-enrichment.qmd:294`（章 11.7） | `disease-enrichment.qmd:67`、`other-databases.qmd:107`、以及 **kegg 页自己的 `@sec-setReadable`** 全部解析到 Section 18.2；章 11.7 永远无法被链到 |
| `{#compare-dotplot}` | `comparecluster-visualization.qmd:49` | `enrichplot-comparison.qmd:68` | `enrichplot-summary.qmd:191` 链向 `enrichplot-comparison.qmd#compare-dotplot`，目标页存在该 id，但两页同名；侧栏与 `@` 引用行为取决于哪份先被索引 |

**为什么自检抓不到**：`check_links.py` 是按文件建 anchor 集合、然后做 `fragment in known[target]` 成员判断——跨文件重名在结构上不可见。

**改法**：把 `kegg-enrichment.qmd` 的 `{#sec-setReadable}` 改为 `{#kegg-setReadable}`；`comparecluster-visualization.qmd` 的 `{#compare-dotplot}` 改为 `{#cc-dotplot}`（chunk label 同名，一并改并同步 `@fig-` 引用），保留外部可能引用过的旧 anchor 作为 `<a id="...">` 别名放到其中一个页面（按 AGENTS.md §7 的 anchor 保留规则）。
**并**：在自检脚本里加「锚点全局唯一」检查（归到 2.x）。

状态：✅

## 1.7 ChIPseeker 章是空壳

**位置**：`chipseeker-enrichment.qmd`（33 行，**0 个可执行 chunk**）

**问题**：只有两段旧散文 + 一张 overview 表，正文承诺 `annotatePeak()` / `seq2gene()` 但**全书没有一个能跑的例子**。而：
- `README.md` 把 ChIPseeker 列为主要包之一；
- `index.qmd` 包角色表有「Genomic-coordinate entry point | `ChIPseeker`」；
- `capability-map.qmd:88`、`glossary-api-index.qmd` 的函数索引都有 `seq2gene()`；
- `_quarto.yml` 里它排在 Part 2 的第 9 章。

这直接违反 AGENTS.md §5「本书中的结果必须尽可能由代码产生」与 §4「最小可运行示例」。

**可行性已验证**：`ChIPseeker` 自带 `extdata/sample_peaks.txt`（9 列 BED：chr/start/end/length/summit/tags/X10.log10.pvalue/fold_enrichment/FDR）；本地已装 `TxDb.Hsapiens.UCSC.hg19.knownGene`，CI 已装 `ChIPseeker` + `org.Hs.eg.db`，所以可以离线跑通 `annotatePeak()` → `anno.pos` → 取 gene 列 → `enrichGO()` 的完整链。

**改法**：新增 3–4 个 chunk：
1. `annotatePeak()` 用 `sample_peaks.txt` + `TxDb.Hsapiens.UCSC.hg19.knownGene`，`asGviz=TRUE`，打印 annotation data frame 的 `head()` 与 `annotType` 计数；
2. `plotAnnot()`（或直接用 `table(anno$annotType)` 出条形图，避免额外依赖）呈现分布；
3. `seq2gene()` 构造 region→gene 多对多映射，喂给 `enricher()`，展示「区域也能进统一富集链」这本书的主线；
4. 保留现有 overview 表与限制说明。

CI 需确认 `Gviz`（`asGviz=TRUE` 才需要）；若不想加依赖就用 `asGviz=FALSE` + `head()` 表格。按 2.x 的依赖清单，`Gviz` 不在现有 CI 列表里 → **用 `asGviz = FALSE`**，并补 `TxDb.Hsapiens.UCSC.hg19.knownGene` 到 Bioconductor 安装段。

状态：✅

## 1.8 用 HTML 注释埋废弃正文（违反 AGENTS.md §5 明文）

AGENTS.md §5 已验证并写明：**「把一大段 Markdown headings、代码块和 callout 放进 HTML comment，并不能可靠阻止 Quarto/knitr 解析和渲染；废弃的静态示例应真正删除，必要的迁移信息只保留一两行说明。」** 但三处仍在：

| 位置 | 体量 | 内容 |
|---|---|---|
| `reactome-enrichment.qmd:84-138` | 2.2 KB | 整节 "Pathway analysis of NGS data"（与 ChIPseeker 章重复）+ 旧 "Visualize enrichment result" 正文，内含 `[@yu_clusterprofiler:_2012]` |
| `other-databases.qmd:38-76` | 1.5 KB | 旧 WikiPathways 手工下载 + `enricher()`/`GSEA()` 静态示例（新章节已有可跑版本） |
| `do-semantic-similarity.qmd:137-153` | 0.6 KB | 旧的 "GO semantic similarity calculation" / "MeSH semantic analysis" 两段，内容已由独立章节承载 |

额外风险：`reactome-enrichment.qmd` 注释块里的 `[@yu_clusterprofiler:_2012]` 这个 key **在 bib 里不存在**（真实 key 是 `yu2012`）。今天它被注释包着不渲染，一旦有人去掉外壳就漏出字面量。

**改法**：三处注释块整体删除。必要的迁移线索压成一行，例如在 `reactome-enrichment.qmd` 的 NGS 小节位置留一句「区域/峰输入请先走 [ChIPseeker 章](chipseeker-enrichment.qmd)，再回到统一富集链」。

状态：✅

## 1.9 未清理的重复段落（已渲染到线上）

**位置**：`do-semantic-similarity.qmd:38-45`

两段几乎同义的 Disease Ontology 介绍**都渲染进了线上页面**（实测 `do-semantic-similarity.html` 中各出现 1 次）：

> Disease Ontology (DO) [@schriml_disease_2011] **was developed to create a consistent description of gene products with disease perspectives** …
> Disease Ontology (DO) [@schriml_disease_2011] **aims to provide an open source ontology for the integration of biomedical data** …

两段之间夹 3 个空行。读起来是编辑做了一半。

**改法**：合并成一段，保留 `[@schriml_disease_2011]` 一次引用。

状态：✅

## 1.10 「结果由代码产生」的两处退让

在 1.7 之外，另有两处正文用静态图片/文字替代了可运行示例：

- `chipseeker-enrichment.qmd`（即 1.7）。
- `reactome-enrichment.qmd:84` 起的 NGS 段落（1.8 的注释块），它讲的正是 ChIPseeker 的 `seq2gene()` 工作流，却被注释掉了 —— 与 1.7 是同一个缺口的两个面。

**改法**：合并处理，1.7 建可跑例子、1.8 删注释。

状态：✅

---

# 第 2 批 — 复现性与 CI

## 2.1 REPRODUCIBILITY 版本表无法对应任何一次真实构建

| 组件 | 表里值 | CI 实装 | 本地 | 线上 badge |
|---|---|---|---|---|
| `enrichplot` | 1.99.6 | GitHub 主分支（workflow 注释自己写 ≥1.99.8） | 1.99.8 | **1.99.8** |
| `enrichit` | 0.2.5 | GitHub 主分支 | **0.2.6** | — |
| `meshes` | 1.39.3 | GitHub 主分支 | **1.39.1** | 1.39.3 |
| `DOSE` | 4.7.3 | GitHub 主分支 | 4.7.3 | **4.7.3.9000** |
| `GOSemSim` | 2.39.3 | GitHub 主分支 | 2.39.3 | **2.39.4** |

没有任何一次构建（本地 / CI / 线上）同时满足这一行行数字。表格自称「本验证轮次的 provenance」，但它既不是 CI 用的、也不是本地用的。

叠加风险：**本地 meshes 1.39.1 而 checked-in 的 MeSH cache 声称由 1.39.3 生成**，`REPRODUCIBILITY.md:36` 自己写了「包数据与三个 cache 文件要一起更新」，但没有任何校验。

**改法**：
1. 表格改成两列并置：`Tested locally` + `Deployed by CI`（或直接以 CI 的 `sessionInfo()` 产出为准，在 workflow 里自动写这个表）。
2. 加 `scripts/check_versions.R`：打印实际 `packageVersion()` 并与 `REPRODUCIBILITY.md` 表格比对，不一致即非零退出（挂进 validate workflow 与 publish workflow）。

状态：✅（由 `b4d3666` 完成）表格改为本地基线 + CI 另记 `docs/SESSION-INFO.txt`；新增 `scripts/check_versions.R` 并已通过。

## 2.2 Publish 工作流近 16 次运行 6 次失败

```
2026-10-11 schedule  success
2026-10-10 push      success
2026-10-09 push      failure   ← Install foundational YuLab packages
2026-10-09 push      failure
2026-10-09 push      failure
2026-10-09 push      failure
2026-10-06 push      success
...
2026-10-04 schedule  failure  → 2026-10-11 schedule success（靠下次定时撞运气）
```

失败集中在装包阶段。站点在线部分是靠每周日 02:00 重试维持的。

**改法**：装包步骤加 `retry`（`r-lib/actions/setup-r@v2` 之后用 `pak` 包一层重试）；把 `remotes` 装包从主链拆出；启用 `actions/cache` 缓存 R library（按 lockfile 哈希作 key）。

状态：✅（由 `b4d3666` 完成）全部安装步骤包 `retry()`。

## 2.3 CI 装了 15 个书里从不出现的包

`tidyverse`、`ggarchery`、`ggplotify`、`httr2`、`R.utils`、`europepmc`、`ggupset`、`ggridges`、`ExperimentHub`、`AnnotationHubData`、`DO.db`、`tidytree`、`treeio`、`ggfun`、`ggtreeExtra` —— 在所有 `.qmd` / `README.md` / `REPRODUCIBILITY.md` 中 0 次出现。

其中 `tidytree` / `treeio` / `ggfun` / `ggtreeExtra` 是 `ggtree` / `enrichplot` 的安装顺序依赖（GitHub 版必须显式装，可保留）；`ggarchery`、`ggplotify`、`ggupset`、`ggridges`、`europepmc`、`httr2`、`R.utils`、`ExperimentHub`、`AnnotationHubData`、`DO.db` 纯属历史遗留。全部源码编译 + `options(Ncpus = 1)` → 直接拉长 2.2 的失败面。

**改法**：删无引用的 CRAN 项；`tidyverse` 换成实际用到的 `dplyr` / `ggplot2` / `tidyr` / `stringr`（`tidyr` 目前只在 `eval: false` 里用到，按需）；被注释说明为什么保留哪些传递依赖。

状态：✅（由 `b4d3666` 完成）按**运行时可达性**而非文本搜索修剪：`ggupset`/`ggridges` 因 `upsetplot()`/`ridgeplot()` 的 `require_suggested()` 实际必需，保留；新增 `dotenv`。

## 2.4 `validate-book.yml` 名为 validate，实际不验证书的内容

只有 `check_navigation.py` + `check_links.py` + `git diff --check`。不装 R、不渲染、不检查代码块、不查 bib、不查版本、不查重复锚点。

另外最后一步 `git diff --check` 在 push 触发的干净 checkout 上是**恒真空操作**（工作区没有改动），只在本地有意义 —— 它给出虚假的安全感。

**改法**：把它升级为真正的 source gate（新增 2.5–2.8 的检查脚本），删掉或替换 `git diff --check`（改用 `git diff --check HEAD~1 HEAD` 或不放）。

状态：✅ 四个 Python 检查进 `validate-book.yml`；`check_api_names.R` 进 `publish-book.yml`；`git diff --check` 改为比对事件实际引入的提交。

## 2.5 需要新增的自检：锚点全局唯一

如 1.6 所述，`check_links.py` 的 anchor 检查是按文件独立集合做成员判断，跨文件重名不可见。

**改法**：在 `check_links.py` 里加一遍全局扫描，`{#...}` 与 `<a id="...">` 在全书范围内唯一（AGENTS.md §7 允许兼容别名，需要显式白名单文件，例如 `_anchor_compat.txt`）。

状态：✅（由 `5ecfdbe` 完成）`check_links.py` 增加全局 `{#anchor}` 唯一性扫描，`scripts/anchor_compat.txt` 允许显式别名。

## 2.6 需要新增的自检：bibliography 完整性

**改法**：`scripts/check_bibliography.py`，八项（1–4 为初版；5–8 由第 1 批自审补入，见「第 1 批自审 §B」）：
1. 重复 key → 报错；
2. `doi` 字段必须匹配 `^10\.\d{4,9}/` → 否则报错（这一条就能抓住 1.4 的三个假 DOI）；
3. 正文引用 key 集合 与 bib key 集合 双向差集 → 报告未引用条目与缺失条目（`@keytype` / `@result` / `@ontology` 这类 S4 slot 写法要排除，实测有 3 处假阳性）；
4. `[@key]` 形式出现在 HTML comment 内 → 警告（防止 1.8 那类"注释里埋引用"复活）；
5. **`author` 每一项须含逗号**，否则名姓解析歧义。`author = {Resnik Philip}` 无逗号时 BibTeX 取末词为姓，线上把 IC 方法归属给了一个叫 "Philip" 的作者（`Resnik ( Philip 1999 )`）。需放行 `{Hans-Anton}` 这类花括号保护段。
6. **mojibake 探针**：`author`/`title` 出现 `字母?字母`（`B?hm`、`K?lbl`）→ 报错。同文件其它条目是完好 UTF-8，故属单条导入损坏，可静态检出。
7. **空字段 `= {}`** → 警告。现存 3 处：`omer_ncg.urldate`、`janet_disgenet.number`、`janet_disgenet.urldate`（`philip_semantic_1999.url = {}` 已随 B4 一并清掉）。
8. **同一段落重复引用同一 key** → 警告（ChIPseeker 开篇段原有两次 `[@yu_chipseeker_2015]`，已删一处）。

> 关键教训：reference-checker 的 found/partial 是「条目 vs 真实出版物」的匹配，**不会告诉你 BibTeX 把作者串解析成了什么**。1.4 修完我用 checker 复核，25 条全过，但 5–8（尤其 B2/B3/B4 的名姓颠倒）只能在**渲染后的参考文献文本**上看出。建议实现两条腿：静态解析 bib 覆盖 5–8，另设可选的渲染后 `csl-entry` 文本比对覆盖解析类错误；前者进 `validate-book.yml`（无依赖、快）。

状态：✅（由 `5ecfdbe` 完成）`scripts/check_bibliography.py` 八项检查全部实现并通过。

## 2.7 需要新增的自检：包注册表宏与真实 registry 一致

如 1.3 所述，`Biocpkg("gson")` 生成的 URL 是 200 但落在「Removed Packages」页，任何可达性检查都抓不到。

**改法**：`scripts/check_package_macros.py` 抽取所有 `Biocpkg("X")` / `CRANpkg("X")`，对每个名字比对一份**手工维护但可离线核对的归属表**（`scripts/package_registry.yml`：`gson: cran`, `enrichit: cran`, `clusterProfiler: bioconductor`, …）。检查的是「宏与归属是否一致」，不发网络请求，因此不受 CRAN index 政策（`code-link: false`）影响。

状态：✅（由 `5ecfdbe` 完成）`scripts/check_package_macros.py` + `scripts/package_registry.yml`，21 条注册表、87 处宏、0 错误。

## 2.8 需要新增的自检：函数名存在性

**改法**：`scripts/check_api_names.R`，把正文 `` `foo()` `` 形式的函数名与 12 个主角包 + tidyverse/base 的导出集比对，未命中的输出为待人工确认清单。本次审核就是用这个思路抓出了 1.1（`weighted_enrich`）和 1.2（`createKEGGdb::createKEGGdb`）。注意需要白名单：`retry()`（`_common.R` 自定义）、`element_markdown()`（ggtext）、外部工具的 `FindAllMarkers()` / `page_rank()` 等。

状态：✅（由 `5ecfdbe` 完成）`scripts/check_api_names.R`，223 处函数名 × 31 个包，0 错误。

## 2.9 `dotenv` 未安装，README 的 `.env` 承诺在 CI 上不成立

`interpretation.qmd:17` 用 `requireNamespace("dotenv", quietly = TRUE)` 守住了，所以**不会报错**——正因如此它是静默降级：CI 永远没有 `dotenv`，`DEEPSEEK_API_KEY` 即便通过 secret 注入、`.env` 分支也永远不执行。`README.md:59` 写的 "It loads `.env` when available" 只在本地成立。

**改法**：`cran::dotenv` 加进 CI；或在 `interpretation.qmd` 的 `.env` 段落加一句说明 CI 走的是环境变量而不是 `.env`。二选一，倾向加包（成本一行）。

状态：✅（由 `b4d3666` 完成）CI 增加 `cran::dotenv`。

## 2.10 仍有 17 处已执行 chunk 直连网络、无 retry 包裹

`_common.R` 的注释宣称「those calls are wrapped in `retry()`」；实测（只算 eval 为真、且未被 `retry()` / `tryCatch()` 覆盖）：

| 文件 | 行 | 未包裹的远程调用 |
|---|---|---|
| `ppi.qmd` | 28 | `getPPI(genes, taxID="9606")` |
| `ppi.qmd` | 42 | `enrichKEGG(de)` |
| `ppi.qmd` | 45, 49, 52, 61 | `getPPI(y, 1)` / `getPPI(y, "hsa04110")` / `getPPI(y, 1:3)` / `getPPI(y, 1, add_nodes=10)` |
| `reactome-enrichment.qmd` | 49 | `enrichPathway(gene=de, ...)` |
| `reactome-enrichment.qmd` | 58 | `gsePathway(geneList, ...)` |
| `reactome-enrichment.qmd` | 79 | `viewPathway(...)` |
| `result-objects.qmd` | 150 | `gsePathway(geneList)` |
| `disease-enrichment.qmd` | 77 | `enrichNCG(gene2)` |
| `disease-enrichment.qmd` | 132 | `gseNCG(geneList, ...)` |
| `identifier-utilities.qmd` | 84 | `enrichKEGG(de)` |
| `kegg-enrichment.qmd` | 450 | `browseKEGG` 相关 |
| `troubleshooting.qmd` | 138 | `enrichKEGG(de)` |
| `troubleshooting.qmd` | 184 | `enrichPathway(de)` |
| `universal-enrichment.qmd` | 139 | `msigdbr_species()`（CRAN 本地，但 `msigdbr()` 下载） |
| `mesh-enrichment.qmd` | 53, 77 | `readRDS(cache)` —— 见 2.11 |

`book-issues.md` 自己记过「41 处网络调用未包 `retry()`」，逐章加过一轮，剩下的这批没加。一次 KEGG / Reactome / STRING 抖动就能让整本书构建失败，与 2.2 叠加。

**改法**：逐个包 `retry()`，并在就近正文按 `comparecluster-analysis.qmd:112` 的既有句式补一句为什么（那处已有一个写得很清楚的范例）。

状态：✅ 本轮完成，实际包裹 14 处（见下）。

## 2.11 MeSH 两章的「可运行示例」实际跑不通，且生成路径被注释藏起

`mesh-enrichment.qmd:52-53`、`76-77`、`mesh-semantic-similarity.qmd:102-103`：

```r
## saveRDS(x, file="cache/enrichMeSH.rds")
x <- readRDS("cache/enrichMeSH.rds")
```

生成 cache 的那行被 `##` 注释掉，只留 `readRDS()` 且 chunk 是 evaluated。读者 clone 仓库后：cache 缺失 → 报错且看不到生成方法；cache 版本与本地包版本不符（见 2.1 的 1.39.1 vs 1.39.3）→ 行为未知。

13.5 MB 的 `cache/hsamd.rds` 也是二进制 checked-in（实测可加载，是 `GOSemSimDATA`）。

**改法**：保留 `readRDS()` 快路径但改成「先尝试网络/本地生成，失败再 fallback 到 cache，并在正文说明这条 fallback」，或至少在紧邻正文写明这三份 cache 由哪个脚本、哪个包版本生成、缺失时如何重建。与 `REPRODUCIBILITY.md:36` 的「一起更新」要求对齐。

状态：✅ 本轮完成（见下）。

## 2.12 失效外链

实测不可达（本机对部分域有网络抖动，故分档）：

| 位置 | URL | 状态 | 处理 |
|---|---|---|---|
| `other-databases.qmd:148` | `http://david.abcc.ncifcrf.gov/content.jsp?file=WS.html` | 502 / 挂 | 旧域名 → `https://david.ncifcrf.gov/`（同页已用新域名，属遗留） |
| `identifier-utilities.qmd:142` | `http://ge-lab.org/#/data` | 502 / 挂 | → `https://jdr0887.github.io/GeLab2.0/` |
| `disease-enrichment.qmd:72` | `http://ncg.kcl.ac.uk/` | 直连超时 | NCG 网站状态需确认；至少补一句该库停更（release 5.0, 2015） |
| `enrichment-overview.qmd:55` | `http://disease-ontology.org/` | 502 | 现域名 `https://disease-ontology.org/`（http→https 升级） |

`check_links.py` 完全不查 `http(s)` 链接。

**改法**：改掉前两条与第四条（http→https）；第 3 条加停更说明。**不**把可达性检查放进 CI（外网抖动会让 gate 变噪声），改为本地可选脚本 + 结果缓存。

状态：✅ 本轮完成，但**两条的前提被核实推翻**（见下）。

## 2.13 PR 也会跑完整渲染但不部署

`Deploy` 步骤是 `if: github.event_name != 'pull_request'`，但 `Render Quarto Book` 没有同样条件。fork PR 还拿不到 `DEEPSEEK_API_KEY`（这点 workflow 注释里已写明并做了 skip 处理，做得对）。

**改法**：PR 触发时只跑 `validate-book.yml` 那一类 source gate，或给 publish workflow 的 render 步骤加 `--render str@file` 之类的抽样策略。

状态：✅（由 `b4d3666` 完成）PR 只跑 source gate，不再全量渲染。

---

# 第 3 批 — 结构、可访问性、仓库卫生

## 3.1 图缺 caption / alt 文本

> 更正：初版清单里「408 个重复 id」的统计是错的——那是把 Quarto 给 `<h2>` 自动补的
> `data-anchor-id` 以及 figure 的 `<div>`/`<img>` 双 id 当成了冲突。逐页重数后，真正的
> 内容级重复只有 `fig-*` 的 div/img 双 id（9 个，Quarto 自身行为，非缺陷）。锚点问题的
> 实害在 1.6（跨章重复 `{#sec-setReadable}` / `{#compare-dotplot}`），已修。

- 16 个 `fig-*` 命名 chunk 有 label 但**无 `fig-cap`**；线上渲染出 9 张 `quarto-uncaptioned` 的图（只有 "Figure 27.9" 这种编号、无题、无 alt）。
- 57 张带 caption 的图里 11 张没有 `fig-scap`（即无 alt 文本）。

集中在 `enrichplot-summary.qmd`（12 处）与 `enrichplot-networks.qmd`（4 处）。

对照：正文里已有 `[**Dot plot of …**+说明]` 这种好写法（`enrichplot-import.qmd` 全部齐备），说明是漏做，不是没标准。AGENTS.md §4 也要求 figure label 不得改名，所以这里是**补 caption 而不是改 label**。

**改法**：按 `enrichplot-import.qmd:135` 的既有格式补齐 `fig-cap` + `fig-scap`；不改任何 chunk label。

状态：✅ 本轮完成：9 张缺 `fig-cap` 的图补齐、11 张补 `fig-scap`；渲染后 `quarto-uncaptioned` 由 9 → 0。顺带修了两处图注错误（见「本轮新发现」）。

## 3.2 旧 URL 兼容仍有缺口

18 条 redirect 实测线上全部能跳（`FAQ.html`→`troubleshooting.html`、`utilities.html`→`identifier-utilities.html`、`dplyr.html`→`result-objects.html`、`misc.html`→`leading-edge-nonmodel.html`、`022-kegg.html`→`kegg-enrichment.html` …）。**这部分做得好。**

但 git 历史里存在过的四个页面现在 **404**、无跳转、无迁移说明，违反 AGENTS.md §3 归档规则第 3 条（公开锚点/旧 URL 要有兼容入口）：

```
020-enrichment-algorithms.html  → 404   （应指向 enrichment-foundations / -network / -multiomics）
029-compareCluster.html         → 404   （应指向 comparecluster-analysis）
023-wikipathways.html           → 404   （应指向 other-databases）
030-interpretation.html         → 404   （应指向 interpretation）
```

**改法**：在 `scripts/write_legacy_redirects.py` 的 `REDIRECTS` 补这四条。`020` 一拆三，指向 `enrichment-foundations.html` 并在页面里给一句分流说明。

状态：✅ 本轮完成：补 4 条 legacy redirect，`020` 按一拆三给出分流页；已核对 22 个目标页全部存在。

## 3.3 没有 LICENSE / CITATION

仓库无 `LICENSE`、无 `CITATION`，正文无许可声明。代码块大量可复制，书本身没有定许可；所涉 R 包是 GPL-2/GPL-3。技术书惯例是 CC-BY 系。

**改法**：加 `LICENSE`（建议 CC-BY-4.0 覆盖正文与图片，代码块沿用对应包的 GPL）+ 在 `_quarto.yml` / `index.qmd` 的 Contributing 段落一句话说明。需要作者决定，**不要代选**。

状态：✅ 作者已确认选 **CC BY-NC 4.0**（非商业）。`b4d3666` 先前的 Artistic-2.0 已替换为 CC BY-NC 4.0 全文，并在 README / `index.qmd` 各加一句边界说明。

## 3.4 仓库里混着私人/构建垃圾

| 项 | 问题 |
|---|---|
| `scripts/__pycache__/*.pyc` × 3 | 被 tracked |
| `020-enrichment-algorithms-check.R` | 硬编码 `pkg_dir <- "e:/YuNotebooks/01_Development/source/mycran/enrichit"`，私人绝对路径，且全书无人引用 |
| `todo.md` | 被 tracked，内容是一堆微信/BioStars/Support 链接的私人收藏，README 不说明其性质 |
| `book-issues.md` | 67 KB 工作笔记被 tracked（`.gitignore` 里 `book-issues.md` 是**注释掉的**？实测未忽略），对外部读者是噪声 |
| `COVID19_GeneSets.gmt` | 同时被 tracked 与（注释掉的）`.gitignore` 覆盖；它是 `identifier-utilities.qmd:129` 已执行 chunk 的**下载产物**，写到仓库根 → 工作树经常变脏 |
| `clusterProfiler-diagram.R` + `figures/clusterProfiler-diagram.png`（572 KB） | 两处都 0 引用，死资产 |
| `figures/cnetplot.png`(251 KB)、`figures/enrichMap.png`(309 KB) | 0 引用（同名图现由 chunk 现场生成） |

**改法**：
- `.gitignore` 加 `__pycache__/`，并从 index 移除 3 个 `.pyc`；
- `020-enrichment-algorithms-check.R` 删（历史在 git 里）或去掉私人路径改为环境变量；
- `todo.md` / `book-issues.md` / 本清单 移到 `notes/` 并在 README 说明；
- `COVID19_GeneSets.gmt` 改成写到 `knitr::current_output()` 或临时目录，或从 tracked 移除并让 chunk 自己下载（已带 `retry_download`）；
- 删三个死资产文件（`figures/clusterProfiler-diagram.png` 若原 R 脚本仍想留，把 `clusterProfiler-diagram.R` 一起挪进 `scripts/` 并在注释里说明它是手工出图脚本）。

状态：✅ 本轮完成（见下）。注意：`book-issues.md` 原本**未被 track**，本清单记录有误。

## 3.5 「每章末尾给出下一步链接」未全覆盖

16 个章节没有 `## Next steps`。其中 part 导言（7 个 `0X-*.qmd`）、`enrichplot.qmd`（兼容路由页）、`index.qmd`、`glossary-api-index.qmd`、`appendix.qmd`、`capability-map.qmd` 属合理豁免；但按 AGENTS.md §4 属于任务章节的这几个缺：

```
choose-a-route.qmd   data-contract.qmd   semantic-similarity.qmd   interpretation-reading.qmd   reproducible-report.qmd
```

**改法**：补 Next steps；`semantic-similarity.qmd` 应指向三个实现章节 + `simplify()`。

状态：✅ 本轮完成，但 `semantic-similarity.qmd` 实际**已有** `## Next steps`（提交 `fce5496`），本清单记录有误；只补了缺失的 `simplify()` 指针。

---

# 第 4 批 — 小问题 / 观感

## 4.1 书名两套
`README.md:3` 写 "**Biomedical Knowledge Mining using GOSemSim and clusterProfiler**"，`_quarto.yml:8` 与线上是 "**Biomedical Knowledge Mining Toolkit**"。README 第一句就与站点不一致。→ 统一。

## 4.2 出版日期硬编码
`_quarto.yml:10` `date: "11/18/2025"`，线上每页显示 "November 18, 2025"，而最后一次实质改动在 2026-10 → 整本书看起来过期一年。→ 改为 `last-modified: true` 或每次发布更新；或删掉 date 让 Quarto 用构建日期。

## 4.3 AGENTS.md 自己的数字过期
`AGENTS.md:64` 「当前所有 46 个 `.qmd`」，实际 50（`check_navigation.py` 也打印 50）。→ 删掉具体数字，改成「全部 `.qmd` 由 `check_navigation.py` 校验」。

## 4.4 Makefile 是坏的
- `nocache:` → `quarto render example.qmd --no-cache`，`example.qmd` **不存在**。
- `sync:` / `publish:` → 操作 `gh-pages/` 目录，本地**不存在**该目录；而且与 CI 的 `peaceiris/actions-gh-pages --force_orphan` 部署互相覆盖（手工 publish 的东西会被下次 CI 清掉）。
- `pdfbook:` → `quarto render --to pdf`，但 `_quarto.yml` 没配 pdf 格式，未验证。

README 首条构建指令是 `make book`（可用），其余目标等于陷阱。
**改法**：删 `nocache` / `sync` / `publish`（部署交给 CI），或改为明确的 `clean-cache` 目标；`pdfbook` 要么配好并实测，要么删。

状态：✅ 本轮完成：删 `nocache`/`sync`/`publish`/`pdfbook`，新增 `clean-cache` 与 `clean`。

---

---

# 第 1 批自审（commit `a6d5e31` → 修复提交 `851e78e`）

自审方式：逐文件读 `git diff` → 用 reference-checker 独立核对整份 bib → 用 Crossref 逐条验证新发现的作者表 → 检查渲染产物而不是只看源码。结论：**第一批本身方向正确，但我引入了 1 个真实缺陷，并漏掉 5 个问题**。

## A. 我自己引入的缺陷（必须记住的教训）

**`include: false` 用错了，把代码一起藏了。**
为了压掉 `annotatePeak()` / `seq2gene()` 输出里带构建时间戳的进度横幅，我最初给这两个 chunk 加了 `#| include: false`。但 `include: false` 同时隐藏 **code 和 output** —— 读者在页面上就看不到 `annotatePeak()` 这个本章最核心的调用了。对一个「教读者怎么用这个函数」的章节，这是比横幅噪声严重得多的回归。

- 正确做法：`#| output: false`（只丢输出、保留代码），再另起一个 `echo: false` 的 chunk 专门打印想要的结果。已改，源码与页面均已核对。
- 教训：**验证要打在渲染产物上，而不是只打在 exit code 上。** 两次渲染都是 exit 0、citeproc 0，这个缺陷完全不影响构建成功；是我用「code block 里是否出现 `annotatePeak(peaks`」去查才发现的。第一次查还被 HTML 实体转义骗过一次（`&lt;-`），要用去标签后的 `<pre><code>` 块判定。
- 顺带：`git commit --no-verify` 我用了，但本仓库只有 Qoder 的 `post-commit`/`post-checkout` 追踪钩子、**没有 `pre-commit`/`commit-msg`**，所以没有跳过任何实质校验。`post-commit` 不受 `--no-verify` 影响，仍照常执行。

## B. 自审新发现的 5 个问题（已修）

| # | 位置 | 问题 | 依据 |
|---|---|---|---|
| B1 | `references.bib` `schmidt2008` | 作者表 mojibake：`B?hm`、`von T?rne`、`K?lbl` —— 变音符被 `?` 替换。同文件其它条目是完好 UTF-8（`Rahnenführer`/`Jüri`/`Núria` 都在），说明是该条目早年单独导入时坏的，不是编码策略。 | Crossref 返回 `Böhm` / `von Törne` / `Kölbl`；已改为 `B\"ohm` 等 LaTeX 转义形式，`comparecluster-visualization.qmd` 引用它 |
| B2 | `omer_ncg` | **given/family 颠倒**：`{Omer A. and Giovanni M. D. and ...}` → 线上渲染成 `A., Omer, Giovanni M. D., ...`，姓被当成 "A." | Crossref: `An, Omer / Dall'Olio, Giovanni M. / Mourikis, Thanos P. / Cicarelli, Francesca D.`；首作者姓是 **An** |
| B3 | `janet_disgenet` | 同类颠倒：`{Janet, P. and Núria Q.R. and ...}` → 渲染成 `Janet, P., Núria Q. R., ...`，把名当姓 | Crossref: `Piñero, J. / Queralt-Rosinach, N. / Bravo, A. / Deu-Pons, J. / Bauer-Mehren, A. / Baron, M. / Sanz, F. / Furlong, L. I.`；首作者姓是 **Piñero** |
| B4 | `philip_semantic_1999` | `author = {Resnik Philip}` 名姓连写无逗号 → 按 BibTeX 规则解析成 given=Resnik、family=Philip，**正好反了**；且 `url = {}` 是空字段。Resnik 这篇是 IC 方法的开山引文，错了最显眼。 | Crossref `10.1613/jair.514` → `Resnik, P.`；改为 `Resnik, Philip` + 补 doi、删空 url |
| B5 | `chipseeker-enrichment.qmd` | 开篇同一句里 `[@yu_chipseeker_2015]` 出现两次（原文即如此，我重写时整句照搬保留了）。同段已给包名加链接，重复引用无意义。 | 删第二处，保留一处 |

B1–B4 属于同一类：**「条目存在且能被 citeproc 渲染」不等于「引用是对的」**。reference-checker 的 25 条 found/partial 判定全过，但它比对的是条目与真实出版物的匹配度，不会告诉我 BibTeX 把 `Resnik Philip` 解析成了「名 Resnik、姓 Philip」。这类只能在**渲染后的参考文献文本**上看出来——所以我在 `disease-enrichment.html` 里读到 `A., Omer` 才发现。

**这给第 2 批的检查脚本加了一条要求**（已并入 §2.6 的验收口径）：bibliography 检查除了 key 去重、DOI 形态、双向差集之外，还应检查

1. `author` 字段每一项是否含逗号（`X Y` 无逗号 = 名姓连写歧义）；
2. 字段里出现 `?` 且上下文疑似变音符（mojibake 探针）；
3. 空字段 `= {}`；
4. 同一段落内重复引用同一 key。

## C. 复核后仍然保留的判断

- `lord_semantic_2003` 的 DOI 我填 `10.1142/9789812776303_0056`：Crossref 收录标题为全大写、年份 2002（卷名 *Biocomputing 2003*），与 PubMed `12603061` 对应同一篇。reference-checker 判 found，DOI 与真实记录一致，保留。
- `lin_information-theoretic_1998` 无 DOI 是正确的（1998 ICML 论文，无 DOI 注册；OpenAlex 有记录），只留 citeseerx url。
- ChIPseeker 新章 `enrichGO` 返回 0 条：不是链路故障，默认 cutoff 下确实 0 条，放宽到 `pvalueCutoff = 1` 后最好 p.adjust ≈ 0.42，正文按此写。
- `<a id="sec-setReadable"></a>` 兼容锚保留：已核实**线上已发布页** `kegg-enrichment.html` 的 §11.7 带着 `id="sec-setReadable"`，外链深链确实可能存在；且实测 Quarto 不把原始 HTML 的 id 注册为 crossref 目标，`disease-enrichment` / `other-databases` 的裸 `@sec-setReadable` 仍解析到 Section 18.2，没有重新引入歧义。

## D. 自审后仍存疑（未处理，留给你决定）

- **书里 3 处 `pvalueCutoff = 1` 式的教学放宽**：只有 ChIPseeker 那处我加了显式理由。若不喜欢这种写法，可改为直接展示对象结构而不跑一次空的富集。
- `fig-*` chunk 的 id 在渲染 HTML 里出现两次（`<div id="fig-x">` + `<img id="fig-x">`），共 9 个：这是 Quarto 自身行为，不是本书缺陷，未处理（初版清单 §「重复 id」统计有误，已在下面更正）。

---

# 附：本次审核的复核命令

```bash
cd biomedical-knowledge-mining-book

# 现有自检（应全绿 —— 这正是问题所在：绿了但 1.x 全在）
python3 scripts/check_navigation.py
python3 scripts/check_links.py

# 导航数 vs AGENTS.md 声明数
ls *.qmd | wc -l                                   # 50；AGENTS.md 写 46

# 跨文件重复锚点（1.6）
grep -rhoE '\{#[A-Za-z0-9_.:-]+\}' *.qmd | sort | uniq -d

# DOI 形态（1.4）
grep -n 'doi *= *{' references.bib | grep -vE '10\.[0-9]{4,9}/'
# 重复 bib key
grep -oE '^@[a-zA-Z]+\{[^,]+' references.bib | sed 's/.*{//;s/,//' | sort | uniq -d

# 硬编码章节号（1.5）
grep -rn '\[Chapter [0-9]\+\]' *.qmd

# HTML 注释埋正文（1.8）
grep -c '<!--' *.qmd | grep -v ':0'

# 网络调用未包裹（2.10）—— 需按 chunk 解析，见本文件说明

# 死资产引用计数（3.4）
for f in figures/*; do echo "$(grep -rl "$(basename $f)" *.qmd | wc -l)  $f"; done
```

---

# 变更记录

| 日期 | 内容 |
|---|---|
| 2026-10-16 | 建档。审核基线 `e9c4af3`。第 1 批（10 条）开始处理。 |
| 2026-10-16 | **第 1 批完成**，含修复过程中新发现的 2 个问题（见 §1.11、§1.12）。全量 `quarto render` exit 0、citeproc warning 0。已提交 `a6d5e31`。 |
| 2026-10-16 | **第 1 批自审**（见 §「第 1 批自审」）：发现自己引入 1 个缺陷 + 查出 5 个新问题，已修并提交 `851e78e`。全量 render exit 0 / citeproc 0；§2.6 的验收口径据此扩充为 4 项新检查。 |
| 2026-10-17 | 发现 `master` 已领先本清单记录的基线：`5ecfdbe` 与 `b4d3666` 已完成 2.1–2.9、2.13、3.3，只是清单未回写。本轮改为先逐条核对再动手。 |
| 2026-10-17 | **第 2 批收尾**（2.10 / 2.11 / 2.12）。全量 `quarto render` exit 0、citeproc 0、6 项自检全绿。 |
| 2026-10-17 | **第 3 批完成**（3.1 / 3.2 / 3.4 / 3.5；3.3 的许可选择留待作者确认）。 |
| 2026-10-17 | **第 4 批完成**（4.1–4.4），另修 `_quarto.yml` 的 `repo-branch: main` → `master`。 |
| 2026-10-17 | 本清单移入 `notes/` 并订正日期：原文件名与文内变更记录写作 2026-10-26，与提交时间不符（第 1 批 `a6d5e31` 20:26、`851e78e` 20:50 均为 10-16）。 |

---

# 第 1 批变更记录（2026-10-16 完成）

改动文件：`glossary-api-index.qmd`、`troubleshooting.qmd`、`gson.qmd`、`kegg-enrichment.qmd`、
`enrichment-overview.qmd`、`references.bib`、`semantic-similarity.qmd`、`do-semantic-similarity.qmd`、
`go-semantic-similarity.qmd`、`mesh-semantic-similarity.qmd`、`identifier-utilities.qmd`、
`other-databases.qmd`、`enrichplot-summary.qmd`、`enrichplot-comparison.qmd`、`comparecluster-visualization.qmd`、
`chipseeker-enrichment.qmd`（重写）。净 `+197 / -351`。

## 逐条落地方式

- **1.1** 索引行的 `weighted_enrich()` 换成 `nseGO()`, `nseKEGG()`, `nsea()`, `mnsea()`, `ora()`/`gsea()` with `weight =`，与 `capability-map.qmd` 口径一致（已核对 `enrichit` 的 `ora()`/`gsea()` 形参确有 `weight`）。
- **1.2** `createKEGGdb::createKEGGdb("hsa")` → `createKEGGdb::create_kegg_db("hsa")`，注释改为「builds a local KEGG.db package」。
- **1.3** 三处 `Biocpkg("gson")` → `CRANpkg("gson")`；`enrichit` 在 `enrichment-overview.qmd` 首次出现处补 `CRANpkg("enrichit")`。渲染后已确认生成 `https://CRAN.R-project.org/package=gson` / `=enrichit`，`bioconductor.org/packages/gson` 归零。
- **1.4** 3 个假 DOI 已按 Crossref 核对回填（`10.1093/bioinformatics/btm087`、`10.1186/1471-2105-7-302`、`10.1142/9789812776303_0056`）；Lin 1998 的 `10.1.1.55.1832` 确认为 CiteSeerX 内部 id，**删除 doi 字段**保留 citeseerx url。5 组重复 key 去重（`yu_new_2011`/`yu2010` 保留字段更优的第二份，并把 `{microRNAs}}` 标题保护与 `number = {7}` 合并进保留副本）。顺带清掉 3 处 `*.eproxy*.lib.hku.hk` 代理 URL 和 6 条 `file = {...}` 私人 Zotero 路径。`lord_semantic_2003` 补进 `semantic-similarity.qmd` 的 IC 方法段；其余 6 条无自然归属的直接删除。**结果：25 条目，重复 0、未引用 0、被引用但缺失 0、非 `10.xxxx/` 形态 DOI 0。**
- **1.5** 8 处 `[Chapter N]` 全部改为显式 **文件名 + 锚点** 链接（`[Semantic Similarity Analysis](semantic-similarity.qmd#semantic-similarity-overview)` 等），链接文字用章名而不是数字。
  > ⚠ 修正本清单初稿的判断：原本打算改成裸 `@anchor`，实测**不行**——跨章裸 `@anchor` 会走 citeproc 并报 `citation ... not found`（章级 H1 锚点尤其如此），且 AGENTS.md §7 本来就要求「跨章节引用改成显式文件名加 anchor」。全量构建的 citeproc warning 从 8 降到 0 是这个改法的直接证据。
- **1.6** `kegg-enrichment.qmd` 的 `{#sec-setReadable}` → `{#kegg-setReadable}`，并按 AGENTS.md §7「保留旧 anchor」补 `<a id="sec-setReadable"></a>` 兼容锚 + 一句说明；`enrichplot-comparison.qmd` 的 `{#compare-dotplot}` → `{#dotplot2-compare}`。`enrichplot-summary.qmd:191` 那句「dotplot() also works with compareCluster() output」原本指向 Dotplot2，语义错位，改指 `comparecluster-visualization.qmd#compare-dotplot`。
  验收：`{#...}` 全局唯一；`disease-enrichment` / `other-databases` 里裸 `@sec-setReadable` 仍正确解析到 Section 18.2（原始 HTML 的 `<a id>` 不会被 Quarto 注册为 crossref 目标，所以不引入歧义）。
- **1.7 + 1.10** `chipseeker-enrichment.qmd` 由 33 行空壳重写为 167 行、**7 个可执行 chunk** 的真实链路：`read.delim` → `makeGRangesFromDataFrame` → `annotatePeak()` → `seq2gene()` → `enrichGO()` → 表格输出。全部离线、无新增 CI 依赖（`TxDb.Hsapiens.UCSC.hg19.knownGene` / `GenomicRanges` 已是 `ChIPseeker` 的 Imports 传递依赖；改用 base `read.delim` 以避免 `readr` 这个仅 *Suggests* 的依赖）。
- **1.8** 删除 `reactome-enrichment.qmd`(2.2 KB)、`other-databases.qmd`(1.5 KB)、`do-semantic-similarity.qmd`(0.6 KB) 三处注释块。全书 >200 字符的 HTML 注释块归零。
- **1.9** `do-semantic-similarity.qmd` 两段同义 DO 介绍合并为一段，`[@schriml_disease_2011]` 只出现一次。

## 修复过程中新发现（原清单未列）

### 1.11 `seq2gene()` 的返回值不满足其文档承诺

**位置**：`chipseeker-enrichment.qmd`（已写入正文 caution block）

`ChIPseeker::seq2gene()` 的 `Value:` 写的是 "gene vector"，示例直接把它当基因列表用。实测在当前 `TxDb.Hsapiens.UCSC.hg19.knownGene` 下，`r 152` 个元素里**只有 12 个是纯 Entrez ID**，其余是 `transcriptId.geneId` 复合串（`ENST00000692195.6877`）或 `A/B` 重复串（`ENST00000446298.1_3/ENST00000446298.1_3`）。

用看起来合理的 `sub(".*[._]", "", x)` 抽取会**静默出错**：对 `ENST00000446298.1_3` 返回 `"3"`，对 `ENST00000618962.4_10/...` 返回 `"10"`；这些假 ID 在 ID 映射阶段查不到，于是富集分析在一个被悄悄缩小且失真的基因集上运行，不报错、不警告。

本章现在明确：`seq2gene()` 用来看 region→gene **连通性**，标识符列表取 `annotatePeak()` 的 `geneId` 列（构造上即为数值 Entrez）。这条也解释了 1.7 初稿为什么跑不出结果——我自己就踩了这个坑。

### 1.12 `other-databases.qmd` 有一句被截断的话（预先存在）

**位置**：`other-databases.qmd:29`

原文 `Supported organisms can be listed by.` —— 句子缺宾语，`get_wp_organisms()` 不见了。与 1.8 无关（`git show HEAD` 已如此），属同类读者可见硬错误，已改为 `Supported organisms can be listed with \`get_wp_organisms()\`.`（已核对该函数确由 clusterProfiler 导出，对应 issue #14 记录的历史修复）。

## 验收记录

```bash
cd biomedical-knowledge-mining-book
timeout 7100 quarto render          # EXIT=0
grep -ci citeproc <log>             # 0（修改前 8）
python3 scripts/check_navigation.py # passed: 50 QMD files
python3 scripts/check_links.py      # source OK 50 + generated HTML OK 68 pages
git diff --check                    # clean
```

按 1.x 逐条的静态验收（全部为 0 / 空）：`weighted_enrich()`、`createKEGGdb::createKEGGdb`、
`Biocpkg("gson|enrichit")`、非 `10.xxxx/` 形态 DOI、`[Chapter N]`、重复 `{#anchor}`、
>200 字符 HTML 注释块、渲染后重复的 DO 介绍段；`chipseeker-enrichment.qmd` 可执行 chunk 由 0 → 7。

## 未随第 1 批处理（留待第 2 批，已确认）

- `troubleshooting.qmd` 的 `createKEGGdb` 示例与 `ppi.qmd` / `reactome-enrichment.qmd` 等 17 处未包裹 `retry()` 的网络调用（§2.10）——属复现性批次。
- ChIPseeker 新章不新增 CI 依赖，因此 §2.3 的依赖清单修剪不受影响；但新章用了 `TxDb.Hsapiens.UCSC.hg19.knownGene`，第 2 批若修剪 Bioconductor 段需**保留**它（当前经 `ChIPseeker` 的 Imports 传递覆盖，未显式列出）。
- `REPRODUCIBILITY.md` 版本表未更新：本次改动不引入包版本变化，但全量 render 已在新基线上跑通，表格仍需在 §2.1 与实际 CI/本地版本一并对齐。

---

# 第 2/3/4 批变更记录（2026-10-17）

## 本轮起点与实际状态

进入本轮时 `master` 已领先本清单记录的审核基线 `e9c4af3` **4 个提交**，其中两个尚未回写进本清单：

| 提交 | 实际已完成的条目 |
|---|---|
| `5ecfdbe` "tools: add source checks that catch what the link check cannot" | 2.5、2.6、2.7、2.8（新增 4 个检查脚本 + `anchor_compat.txt` + `package_registry.yml`） |
| `b4d3666` "ci: trim deps, retry installs, and publish real build provenance" | 2.1、2.2、2.3、2.9、2.13、3.3 |

因此本轮先跑一遍全部自检确认现状，再只处理真正剩下的 2.10 / 2.11 / 2.12 / 3.1 / 3.2 / 3.4 / 3.5 / 4.1–4.4。**没有重做已落地的部分。**

## 2.10 未包裹的网络调用

清点后实际包裹 **14 处**，而不是清单列的 17 处。两处差异有据可查：

- `mesh-enrichment.qmd` 的 2 处 `readRDS(cache)` 不是网络调用，属 2.11；
- `universal-enrichment.qmd` 的 `msigdbr()` 本就已包裹，只多包了 `msigdbr_species()`。

| 文件 | 调用 |
|---|---|
| `ppi.qmd` | `getPPI()` × 5、`enrichKEGG()` × 1 |
| `reactome-enrichment.qmd` | `enrichPathway()`、`gsePathway()`、`viewPathway()` |
| `result-objects.qmd` | `gsePathway()` |
| `disease-enrichment.qmd` | `enrichNCG()`、`gseNCG()` |
| `identifier-utilities.qmd` | `enrichKEGG()` |
| `universal-enrichment.qmd` | `msigdbr_species()` |

**只包裹真正会执行的 chunk。** 清点过程中发现清单列的 `kegg-enrichment.qmd` 的 `search_kegg_organism()`、`gseMKEGG()`、`browseKEGG()` 和 `gson.qmd` 的两个 `enrichKEGG()`/`gseKEGG()` 都在 `eval: false` 的 chunk 里——它们在构建期根本不运行，包裹它们等于教读者「这里脆弱」，而实际并不脆弱。这 6 处按设计未动。`troubleshooting.qmd:127` 的 `use_internal_data = TRUE` 走本地 KEGG 快照，不是远程调用，同样未包裹。

**顺带修掉一个会让构建直接失败的缺陷**：`ppi.qmd` 是 7 个文件里唯一没有 `source("_common.R")` 的，`retry()` 在那里根本未定义。加 `source()` 后该章开始继承 `_common.R` 的 knitr 缓存与 `dev = "svg"`，已单独重渲染该章确认正常。

## 2.11 MeSH cache 的生成路径

三份 cache 之前只有 `## saveRDS(...)` 注释掉的生成行和一句 evaluated 的 `readRDS()`：读者 clone 仓库后，cache 缺失即报错，且看不到怎么生成。

- 新增 `scripts/build_mesh_cache.R`：可运行的重建脚本，逐个解析 AnnotationHub 的 MeSHDb 记录并打印命中的 release；
- `_common.R` 新增 `load_mesh_cache()`：缺失时报错信息直接给出重建命令，而不是让 `readRDS()` 抛出裸错误；
- 新增 `cache/README.md`：记录每份文件是什么对象、由哪个调用生成、如何重建；
- 两个 MeSH 章各加一个 callout，写明「为什么用 cache 而不实时跑」和「怎么重建」；
- `REPRODUCIBILITY.md` 补上 cache 用 `meshes` 1.39.3 生成、而本地表是 1.39.1 这一**刻意存在的差异**，并说明这不是漂移。

provenance 不是照抄文档，而是从对象里读出来的：`hsamd.rds@metadata` 自带 `MESHVERSION = 2026`、`SOURCENAME = Gendoo / gene2pubmed`、`ORGANISM = Homo sapiens`、`DBSCHEMA = MeSH.Hsa.eg.db`。`cache/README.md` 因此让读者自己 `readRDS()` 去核对，而不是信一张会过期的表。

## 2.12 失效外链：两条的前提被核实推翻

**这是本轮最重要的一条教训。** 清单给的改法是「→ `https://david.ncifcrf.gov/`」「→ `https://jdr0887.github.io/GeLab2.0/`」。实际核实（直连 + 代理 + 多 resolver）：

| URL | 实测 |
|---|---|
| `david.abcc.ncifcrf.gov`（旧） | NXDOMAIN（三个 resolver 一致），最后 Wayback 快照 2013 年 |
| `david.ncifcrf.gov`（清单给的「替代」） | **同样 NXDOMAIN**；2026 年该域下零快照 |
| `ge-lab.org` | 连接失败，域名已被指向无关站点 |
| `jdr0887.github.io/GeLab2.0/`（清单给的「替代」） | **404**；该账号 141 个仓库里没有任何 GeLab |

也就是说，**建议的替代地址本身不存在**。照清单改只会把一条死链换成另一条死链。因此改为不链接、并如实记录观察结果：DAVID 段落加 `callout-warning` 说明 `david.ncifcrf.gov` 在 2026-10 无法解析、所有 `enrichDAVID()` 示例是 `eval: false`、以及改用 Bioconductor 侧的 `enrichGO()`/`enrichKEGG()`；GeLab 从资源列表移除并说明原因。

**通用教训：清单里的「改法」本身也可能基于未核实的假设。「已修」的标准应当是核实后的结果，而不是执行了清单写的动作。**

其余 6 条（KEGG catalog/module/dbget、Gene Ontology、Disease Ontology、MSigDb→`www.gsea-msigdb.org/gsea/msigdb`、WikiPathways data、NCG→`https://`）均逐一 curl 确认 https 目标独立返回 200 后才改。

## 3.1 图 caption / alt

范围是从**渲染产物**倒推出来的，不是从源码猜的：`docs/*.html` 里 `quarto-uncaptioned` 恰好 9 处，对应 9 个确定的 figure id；另 11 张有 caption 无 alt。

- 9 张补 `fig-cap` + `fig-scap`；
- 11 张补 `fig-scap`；
- 验收：`quarto-uncaptioned` 由 **9 → 0**。

`fig-dotplot-setup` 一个 chunk 出两张图。逐个比较过三种机制后选了**列表形式 `fig-cap`**：标量形式会把同一句图注同时贴到 ORA 图和 GSEA 图上（正是要避免的）；`fig-subcap` 需要 `layout-ncol`，会把两张图从上下排列改成并排，属于外观变更。列表形式在渲染结果里仍是两个独立 `<figure>`、各自 `data-fig-scap`，版式不变。

## 3.2 legacy redirect 缺口

补 4 条，并把 `020-enrichment-algorithms` 改成一拆三的分流页（主跳转 `enrichment-foundations.html`，另两个目标以列表给出）。跳转全部保留 `location.hash`，且**逐个核对旧章锚点在拆分后依然存在**：`ora-algorithm` / `gsea-algorithm` / `scoretype` 在 `enrichment-foundations.qmd`、`clusterprofiler-comparecluster` 在 `comparecluster-analysis.qmd`，所以 `…/020-enrichment-algorithms.html#ora-algorithm` 这类深链仍然落得到位。已核对 22 个跳转目标页全部存在。

## 3.4 仓库卫生

- `scripts/__pycache__/*.pyc` × 3 取消跟踪，`.gitignore` 加 `__pycache__/`；
- `020-enrichment-algorithms-check.R` 删除（硬编码 `e:/YuNotebooks/…` 私人绝对路径，0 引用）；
- `todo.md` → `notes/todo.md`；新增 `notes/README.md` 说明该目录性质；`book-issues.md` 一并移入；
- `COVID19_GeneSets.gmt` 取消跟踪，且**改写 chunk 让它下载到 `tempfile()`**（只加 gitignore 不改写法，工作树还是会脏）；
- `figures/cnetplot.png`、`figures/enrichMap.png`、`figures/clusterProfiler-diagram.png` 三个 0 引用图删除；`clusterProfiler-diagram.R` 移到 `scripts/` 并加注释说明它是手工出图脚本、不参与构建。

**更正**：本清单 §3.4 称 `book-issues.md` 被 track，实际它从未被 track（在 `.gitignore` 里）。已核实后按实际情况处理。

## 3.5 「下一步」未覆盖

`semantic-similarity.qmd` **本来就有** `## Next steps`（提交 `fce5496`，清单记录有误），所以只补了缺失的 `simplify()` 指针，没有造第二个同名标题。其余 4 章各补一节。

两处链接指向的目标**没有显式锚点**，只能用标题 slug（`go-enrichment.qmd#simplifying-enriched-go-terms`、`appendix.qmd#reproducibility-record`）。已到 `docs/*.html` 里确认 `id` 真实存在后才用。

## 第 4 批

4.1 README 旧书名删除；4.2 `date: last-modified`；4.3 删掉写死的「46 个」；4.4 删掉 4 个坏 target，新增 `clean-cache` / `clean`。

**额外修了一个清单没列的缺陷**：`_quarto.yml` 的 `repo-branch: main`，但远端默认分支是 `master`（`git remote show origin` 确认）。这会让站点上每个页面的「编辑此页」按钮指向不存在的分支。

`pdfbook` 的删除有依据：本机无 `pdflatex` / `xelatex` / `typst`，`_quarto.yml` 也未配置 PDF format，无法实测。清单要求「要么配好并实测，要么删」，故删。

## 本轮新发现（原清单未列）

| # | 位置 | 问题 | 处理 |
|---|---|---|---|
| N1 | `_quarto.yml:20` | `repo-branch: main`，实际默认分支是 `master` | 改为 `master` |
| N2 | `enrichplot-specialized.qmd` `fig-volplot` | 图注写「-log10(p-value) vs z-score」，与实现不符 | 查 `enrichplot:::volplot.enrichResult`：x=`log2(FoldEnrichment)`、y=`-log10(p.adjust)`、color=zScore，图注已改正 |
| N3 | `enrichplot-networks.qmd` `fig-cnetplot-custom-color` | 正文说「color specific genes」，但示例给的名字里只有 4 个落在绘制的 DO term 中，且**全部在 `+1` 组**，色标塌缩成单值，图上看不出任何着色 | 重选 4 个确实在图中的基因放进 `-1` 组（`AURKA`/`TOP2A`/`MMP1`/`BIRC5`），并同步修正下游两张图的 alt 文本 |
| N4 | `ppi.qmd` | 唯一没有 `source("_common.R")` 的章节；一旦按 2.10 包裹 `retry()` 就会因函数未定义而构建失败 | 补 `source("_common.R")`，已单独重渲染验证 |

> N3 的判断来自子代理，但它给的细节是错的（「只有 CXCL10 落在图内」）。**实测后是 4 个，且都是 `+1` 组**——结论（色标塌缩）成立，原因不同，修复方案也不同。照抄子代理的报告会把示例改成另一个仍然失效的版本。

## 验收记录

```bash
cd biomedical-knowledge-mining-book

timeout 10800 quarto render            # EXIT=0，全书 50 章 + 22 个跳转页 = 72 个 HTML
grep -ci citeproc /tmp/book_render.log # 0
python3 scripts/check_navigation.py    # PASS  50 QMD
python3 scripts/check_links.py         # PASS  50 QMD + 72 pages
python3 scripts/check_bibliography.py  # PASS  25 entries, 0 errors
python3 scripts/check_package_macros.py# PASS  87 macros / 21 registry
Rscript scripts/check_versions.R       # PASS  18 rows
Rscript scripts/check_api_names.R      # PASS  223 mentions / 31 packages
git diff --check                       # clean
```

渲染产物核对（而不是只看 exit code）：

- `quarto-uncaptioned` 计数 **9 → 0**；
- 4 个新 legacy redirect 页均生成，22 个跳转目标全部存在；
- 两个 MeSH 章的 callout 各出现 1 次，cache 对象正常打印（`enrichMeSH.rds` 1018 条、`gseMeSH.rds` 1306 条、`hsamd.rds` 正常载入为 `GOSemSimDATA`）；
- 全书不再出现硬编码的 `November 18, 2025`；
- `ppi.qmd` 渲染出 SVG 图且页面展示 `retry()` 代码。

## 待作者决定

1. ~~**3.3 许可**~~ —— 已确认：正文与图片用 **CC BY-NC 4.0**；章节里演示的各 R 包沿用其自身 GPL-2/GPL-3。`LICENSE` 写明了这个边界。
2. **`020-enrichment-algorithms-check.R` 与三个图文件已删**：均可 `git checkout` 恢复，若其中有想留的请说明。
3. **DAVID**：目前按「不可达、不链接」处理。若该服务恢复，应把链接与 `callout-warning` 一并加回。
4. **未推送**：本地 `master` 领先 `origin/master` 5 个提交。`index.qmd` 里指向 `LICENSE` 的 GitHub 链接要推送后才可达。

---

# 第 5 轮：超大图与体积自检（2026-10-17）

本轮不在原四批范围内，是排查第 4 批收尾时顺带发现的独立问题（对应仓库 issue #41 的复发）。

## 5.1 一张 13.2 MB 的图

`comparecluster-visualization.qmd` 的 `fig-mcnetplot` 是四联 `cnetplot()` 网络图，每张图元数量随基因数增长，渲染出的 SVG 达 **13.17 MB**，是全书唯一超过 5 MB 的图（次大只有 3.39 MB）。页面 HTML 本身只有 0.1 MB——重量全在这一个文件上。

这正是 `_common.R` 里 `svg2png()` 上方注释记录过的病因：**单张图就足以让页面渲染花掉几分钟、有时永远加载不完**。注释里连药方都写好了——「让 R 直接画 PNG，加 `#| fig-format: png`，小 60 倍」——但全章漏了没加（全书只有 3 个 chunk 用了这个选项）。

按仓库自己记录的方案修：

| | 体积 |
|---|---|
| 修改前 `fig-mcnetplot-1.svg` | 13.17 MB |
| 修改后 `fig-mcnetplot-1.png` | **2.92 MB**（4.5×） |

全书图件总量 39.2 MB → 29.0 MB。

## 5.2 新增 `scripts/check_figure_sizes.py`

**为什么读 HTML 而不是扫 `docs/` 目录**：Quarto 不清理上一次构建的图件，目录扫描会一直报一张**没有任何页面引用**的陈旧 SVG，把噪声变成常规，最终没人再看这个检查。实测修复后 `docs/` 里两份文件并存（新的 PNG 2.92 MB + 陈旧的 SVG 13.17 MB），而页面只引用前者——扫目录必然误报。

脚本行为：遍历 `docs/*.html`，抽出 `<img src>`，只量真正被引用的图；单张超过 **4 MiB** 即失败。阈值定在 3.4 MB（最大的合法矢量图）之上、13.2 MB（目标缺陷）之下——贴着缺陷设阈值会把 3.4 MB 那张也拖下水，反而教会所有人忽略它。

接入 `publish-book.yml`（依赖渲染产物，`validate-book.yml` 没有 render 步骤）。`scripts/figure_size_allowlist.txt` 提供豁免机制，目前为空。

## 5.3 验收：证明新检查抓得住缺陷

沿用 `5ecfdbe` 的做法——**光证明「现在能过」不算数**，第 1 批全部问题就是在既有检查全绿时发布的。四条路径都实测过：

| 场景 | 结果 |
|---|---|
| 当前产物（已修复） | exit 0 |
| **修复前产物**（把页面指回 13.17 MB SVG） | **exit 1**，指名 `fig-mcnetplot-1.svg` 并给出修法 |
| 豁免清单命中 | exit 0 |
| 页面引用了不存在的图 | exit 1，报 `missing image` |

## 5.4 顺带修掉一处过期指引

`_common.R` 的 `svg2png()` 注释让人「见 `enrichplot.qmd` 里的 gseaplot2 chunk」——但该章早已按 AGENTS.md §7 拆成 6 个任务章，`enrichplot.qmd` 现在只是兼容路由页。指向已不存在内容的指引，比没有指引更糟。改为指向 `check_figure_sizes.py`，不再依赖记忆。

AGENTS.md §8 新增「自检脚本」小节，列出六个检查各自抓什么，并写明**新增检查必须先在修复前的产物上验证其能 exit 1**。

---

# 第 6 轮：修好卡住发布的三层故障（2026-10-17）

第 5 轮推送后触发发布，三次连续失败，逐层剥洋葱。**这三层都是本仓库自己造成的，且都发生在任何人都没注意到的失败模式下。**

## 6.1 现象

线上站点停留在 10-11 的构建。三次推送、三次发布，**每次都死在同一个步骤**：`Prewarm ontology caches (DO/HDO)`。

## 6.2 第一层：过期签名

```
Error in yulab.utils::download_yulab_file("GOSemSim/HDO.sqlite"):
  argument "urls" is missing, with no default
```

签名其实是 `(destfile, urls, gzfile, appname)`，文件名落到了 `destfile` 上，`urls` 从未传值。

**为什么会漂移**：CI 从 `github::YuLab-SMU/*` 安装而非固定版本，上游一改签名就断。这正是 `REPRODUCIBILITY.md` 明文写的不可复现性——那个警告当时只是文档，这次变成了事故。

## 6.3 第二层：目录不存在

修好签名后再跑，4 秒就失败了。**3.7 MB 的下载不可能 4 秒完成，说明压根没发出网络请求。**

`download_yulab_file()` 经 httr2 写入，无法创建父目录；全新 runner 上 `~/.local/share/GOSemSim/` 不存在，于是写入失败，函数却**当作成功返回路径**。加 `dir.create()` 后本地从「0.1 秒静默失败」变成「25 秒下载成功」。

## 6.4 第三层：`R.utils` 被依赖裁剪误删（真凶）

目录修好后 CI 仍在 ~4 秒失败。`b4d3666`（第 2 批裁剪 CI 依赖）把 `R.utils` 当成「0 次出现的历史遗留」删掉了。

但 `download_yulab_file(..., gzfile=TRUE)` 需要它做 gunzip，而服务器上**只有压缩版** `HDO.sqlite.gz`（未压缩版 404），所以 `gzfile=TRUE` 无法回避。链条是：

1. `check_pkg("R.utils")` 抛 `missing_package_error`；
2. 该错误被 `download_yulab_file` 内部的 `tryCatch` 吞成 `FALSE`；
3. 换下一个 URL，重复失败；
4. 函数返回目标路径，**假装成功**；
5. 调用方 `file.exists()` 为假，判定「网络不可达」。

**这一层解释了前两层为什么都救不回来**：下载从来不是出问题的那一步，所以 6.3 加的 `retry()` 注定无效。

### 时间线对得上

| 日期 | 状态 |
|---|---|
| 10-11 | 最后一次成功发布，**装了 `R.utils`**，该步骤通过 |
| 10-17 | `b4d3666` 删除 `R.utils` → 此后每次发布都死在这一步 |

## 6.5 A/B 实证

把 workflow 里那段 R 代码**原样抠出来**，配一个全新的 `HOME` 跑两遍：

| 库内容 | 退出码 | 磁盘结果 |
|---|---|---|
| 无 `R.utils`（即 `b4d3666` 之后的状态） | **1** | 下载进度条到 100%，只留下 `HDO.sqlite.gz`，**没有** `HDO.sqlite` |
| 有 `R.utils`（修复后） | **0** | `HDO.sqlite` 10.95 MB |

## 6.6 方法论教训（本轮最重要的一条）

`b4d3666` 裁剪依赖的依据是**在 `.qmd` 里做文本搜索、统计出现次数**。这个方法有两类盲区：

- **依赖藏在别人包里**：`R.utils` 在正文里一次都不出现，却在 `yulab.utils` 的代码路径上被需要。文本搜索永远看不见。
- **运行时可达**：同一个提交里 `ggupset` / `ggridges` 同样 0 次出现，却因为 `upsetplot()` / `ridgeplot()` 内部 `require_suggested()` 而必须保留——当时靠人工经验补了回来，`R.utils` 没这么幸运。

**判据应当是「这条调用路径实际会不会执行到」，而不是「正文有没有提到它」。**

## 6.7 顺带修掉的两个 CI 缺陷

| 缺陷 | 说明 |
|---|---|
| 并发部署竞争 | 两次推送会排两个完整构建、都用 `force_orphan` 部署，谁最后完成谁赢——**新提交可能被它取代的旧构建覆盖**。已加 `concurrency: group: publish-book-${{ github.ref }}` + `cancel-in-progress`。注意它**无法取消改动之前已在跑的作业**（那次作业由旧版 workflow 定义创建），所以当时两个仍在竞速部署，靠「后启动的赢」侥幸正确。 |
| 我自己引入的 YAML 重复键 | 上一处修复的 `old_string` 匹配了 `run: |` 却没匹配上面的 `- name:`，留下**两个同名 step key**，GitHub 直接拒绝加载整个 workflow（run 秒失败，一个 step 都没执行）。 |

**值得单独记的教训**：`yaml.safe_load()` 对它**报 OK**。PyYAML 默认允许重复 mapping key 并保留最后一个，所以「语法有效但 key 重复」的文件能顺利解析。改 workflow 必须用**拒绝重复 key 的 loader** 校验：

```python
class Strict(yaml.SafeLoader): pass
def no_dupes(loader, node, deep=False):
    m = {}
    for k, v in node.value:
        key = loader.construct_object(k, deep=deep)
        if key in m:
            raise yaml.constructor.ConstructorError("mapping", node.start_mark, f"duplicate key: {key!r}", k.start_mark)
        m[key] = loader.construct_object(v, deep=deep)
    return m
Strict.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, no_dupes)
```

## 6.8 第四层：渲染期才发现的依赖（收尾）

prewarm 修好后，渲染走到 `enrichplot-specialized.qmd` 又死一次：

```
Error in require_suggested("ggarchery", "for `goplot()`.")
Quitting from enrichplot-specialized.qmd:207-214 [fig-goplot]
```

**与 6.4 同源**：`b4d3666` 按「正文出现次数」裁剪，把 `ggarchery` 和 `europepmc` 当成 0 提及的历史遗留删了，但它们被 `enrichplot` 的绘图方法在**运行时** `require_suggested()` 引用，而书中确实调用了这些函数。

这次没有再「一次修一个」，而是把整类问题一次枚举干净：扫 `enrichplot` / `enrichit` / `clusterProfiler` / `DOSE` / `GOSemSim` / `ReactomePA` / `meshes` / `gson` 全部 `require_suggested()` 调用点，再和 CI 安装清单对表。书中实际会走到的四个：

| 包 | 由哪个函数需要 | 书中调用处 |
|---|---|---|
| `ggarchery` | `goplot.enrichResult()` | `enrichplot-specialized.qmd` |
| `europepmc` | `pmcplot()` | `enrichplot-specialized.qmd` |
| `ggstar` | `dotplot.compareClusterResult()` | compareCluster 各章 |
| `ggrepel` | `.manhattanplot_internal()` | `enrichplot-summary.qmd` |

四个都在**会执行**的 chunk 里。同时扩了既有的 `Verify required packages are loadable` 步骤覆盖它们——这类缺失应该在一秒内报出名字，而不是在装完包、渲染二十分钟后以渲染中断的形式出现。

## 6.9 结果

`39001519862` 全绿，站点**自 10-11 以来首次真正更新**：

```
success  Prewarm ontology caches (DO/HDO)
success  Render Quarto Book
success  Record build provenance
success  Validate navigation and source/generated links
success  Validate function names against installed package exports   ← 首次在 CI 执行
success  Validate figure payload size                                 ← 首次在 CI 执行
success  Deploy to GitHub Pages
```

线上核对：

| 项 | 结果 |
|---|---|
| `fig-mcnetplot` | 页面引用 `.png`，**1.71 MB**（原 13.2 MB） |
| `index.html` 的 CC BY-NC 4.0 | ✅ |
| `data-contract.html` 的 Next steps | ✅ |
| MeSH 两章的 provenance callout | ✅ |
| 硬编码的 `November 18, 2025` | 已消失 |
| 新 legacy redirect `020-enrichment-algorithms.html` | 200 |
| `SESSION-INFO.txt` | 已部署 |

## 6.10 本轮总教训

四层故障里，**有三层源于同一个决定**：按「正文出现次数」裁剪 CI 依赖。这个方法在 `b4d3666` 里被明确写成依据并用它删掉了 `R.utils`、`ggarchery`、`europepmc`，代价是站点冻结六天、三次发布全灭、一次渲染中断。

正确判据是**运行时可达性**：沿着「这本书实际执行的 chunk → 调用的函数 → 该函数内部 require 的包」这条链走一遍，而不是在 `.qmd` 里 `grep`。同一个提交里 `ggupset` / `ggridges` 靠人工经验留了下来，`R.utils` 没这么幸运——这类问题不会自己浮出来，必须用方法去找。
