# Biomedical Knowledge Mining 知识库重组建议

> 这是一份信息架构与内容迁移方案，不直接修改现有章节内容。目标是把本书从“多个 R 包的章节集合”重组为一套围绕生物医学知识挖掘任务组织的工具系统。

## 1. 核心判断

当前内容并不是缺少功能，而是**导航逻辑仍然接近项目历史和包的演化顺序**：

- Part 1 以语义相似性开始，Part 2 以富集分析为主体，Part 3 是 Miscellaneous，整体上更像能力清单；
- 文件名同时使用 `01`、`011`、`020`、`029` 等历史编号，读者很难从文件名判断分析流程；
- 算法、知识库、可视化、结果操作、网络分析和 AI 解读混在同一层级；
- `enrichplot.qmd` 过长，既承担基础作图，又承担比较、GSEA、外部工具结果导入和多个高级图形任务；
- `utilities.qmd`、`dplyr.qmd`、`FAQ.qmd` 放在后面，但其中的 ID 准备、结果对象操作和排错其实是新手最早会遇到的问题；
- `misc.qmd` 中的 leading-edge 和非模式物种分析并不“杂”，分别属于“结果解释”和“自定义注释工作流”；
- `interpretation.qmd` 是一个完整的“从统计结果到生物学叙事”的能力层，不应只作为一个孤立的 AI 包装页；
- 首页目前有 `hello` 占位内容，书的结构说明主要按包名罗列，没有给读者一个“我有一份组学结果，接下来怎样走”的主线。

因此，建议把组织原则从：

> **我有哪些包？每个包能做什么？**

改为：

> **我手里有什么证据，想回答什么生物学问题？工具系统如何把这些证据逐步变成可解释、可复现的结论？**

## 2. 建议确立的产品叙事

建议把整套工具定义为一个分层系统，而不是若干包的拼盘：

```text
输入数据与研究问题
        ↓
数据契约：ID、排序、背景集、注释、分组
        ↓
分析引擎：ORA / GSEA / 网络 / 加权 / 多组学
        ↓
知识连接器与知识封装：GO / KEGG / Reactome / DO / MeSH / GSON / 自定义基因集
        ↓
证据整合：多组比较、语义相似性、冗余消解、PPI、贡献追踪
        ↓
结果呈现：统计图、网络图、通路图、比较图、可导出的表格
        ↓
生物学解释：人工检查、证据合成、可选的 AI 辅助报告
        ↓
可复现交付：报告、图表、参数、版本和引用
```

这套叙事允许继续保留所有包名，但包名变成实现层信息：

| 系统层 | 读者关心的问题 | 主要实现模块 | 典型输出 |
|---|---|---|---|
| 数据与输入 | 我的基因列表、排序列表和背景集是否准备正确？ | `clusterProfiler` utilities、`dplyr` | 可分析的 gene vector / ranked list |
| 分析引擎 | 应该用 ORA、GSEA 还是网络/加权方法？ | `enrichit`、`clusterProfiler` | `enrichResult`、`gseaResult` 等结果对象 |
| 知识连接与封装 | 选择哪个知识库，或如何把多个知识库统一起来？ | `clusterProfiler`、`gson`、`DOSE`、`ReactomePA`、`meshes` | GO、KEGG、Reactome、疾病、MeSH、GSON 或自定义富集结果 |
| 证据整合 | 多组结果如何比较？相似 term 如何合并？ | `clusterProfiler`、`GOSemSim`、`DOSE`、PPI 工具 | 比较表、语义距离、网络和贡献表 |
| 结果呈现 | 如何把结果画成可读、可发表的图？ | `enrichplot` | bar/dot/cnet/tree/emap/GSEA 等图 |
| 解释与交付 | 如何从显著 term 走到生物学结论？ | `enrichplot`、`clusterProfiler::interpret()`、可选 LLM | 解释框架、报告、图表和审计信息 |

其中：

- `clusterProfiler` 是高层入口和工作流编排层；
- `enrichit` 是富集算法引擎，承载 ORA、GSEA、网络、加权和部分多组学能力；
- `gson` 是知识库的标准封装与交换层，负责把不同来源的 gene set、term、名称、物种和元数据组织成统一对象，支持组合多个知识库后再交给同一套富集接口；
- `DOSE`、`ReactomePA`、`meshes` 等是面向特定知识体系的连接器/扩展；
- `GOSemSim` 提供语义相似性能力，可服务于 term 去冗余、基因/基因簇相似性和跨物种分析；
- `enrichplot` 是跨结果对象的呈现层；
- `ChIPseeker` 是基因组协调/峰注释场景的领域入口；
- AI 辅助解释是证据链的可选最后一步，而不是所有分析的默认起点。

## 3. 面向读者的新版目录

下面的目录不是按包划分，而是按一次真实分析的决策顺序划分。建议先采用这个导航结构，再逐步迁移内容；不必一开始就重写所有章节。

### Part 0 — Start here：先把问题和数据说清楚

目标：让读者在最短路径内完成第一次成功分析，并知道后面每一步的选择依据。

1. **Welcome to the Biomedical Knowledge Mining Toolkit**（重写 `index.qmd`）
   - 这套工具解决什么问题；
   - 从输入到解释的总流程图；
   - 按任务选择入口，而不是按包选择入口；
   - 一个最小可运行的 GO/KEGG 示例；
   - 版本、引用、可复现性说明。
2. **A complete first workflow**（新建）
   - 从差异表达结果开始；
   - 准备 gene vector、ranked list 和 universe；
   - 选择 ORA 或 GSEA；
   - 使用 GO/KEGG 完成一次分析；
   - 用 `enrichplot` 画图；
   - 得到一个可解释的结果对象。
3. **The data contract**（从 `FAQ.qmd`、`utilities.qmd` 抽取并重写）
   - ID 类型与映射损失；
   - gene vector 与 named ranked vector 的区别；
   - 背景集 `universe`；
   - `TERM2GENE` / `TERM2NAME`；
   - `enrichResult`、`gseaResult` 和 `compareClusterResult` 的共同结构。
4. **Choose a route**（新建决策页）
   - 我有阈值后的基因列表 → ORA；
   - 我有完整排序 → GSEA；
   - 我有多个 cluster/条件 → compareCluster；
   - 我有网络或检测偏差 → NSEA / weighted enrichment；
   - 我有多组学证据 → multi-omics aggregation；
   - 我没有标准注释 → universal/custom enrichment。

### Part 1 — Choose the analysis engine：先决定“怎样检验”

目标：先讲统计问题和输入要求，再进入具体数据库。这样读者不会把“GO 富集”“KEGG 富集”误解为不同的统计方法。

1. **Enrichment questions and statistical foundations**
   - 从“过度代表”与“整体偏移”开始；
   - ORA、GSEA 的问题定义、输入和限制；
   - 多重检验、背景集和结果解释。
2. **ORA and GSEA in practice**
   - 从 `020-enrichment-algorithms.qmd` 拆出基础算法和选择指南；
   - 明确 score direction、`scoreType`、leading edge；
   - 用同一组示例对比 ORA 和 GSEA。
3. **Network-aware and weighted enrichment**
   - NSEA、MNSEA、weighted ORA/GSEA；
   - 网络传播、检测偏差、权重和解释性；
   - 将 `020-enrichment-algorithms.qmd` 中的高级算法集中到这里。
4. **Multi-omics evidence integration**
   - `aggregate_omics()`、ID harmonization、方向冲突、late fusion；
   - 结果如何回到已有的 ORA/GSEA/网络后端。
5. **Comparing conditions, clusters, and cell populations**
   - 从 `029-compareCluster.qmd` 迁入；
   - 多基因列表、单细胞 marker、Seurat/COSG 结果；
   - 先讲比较问题，再讲比较图。

### Part 2 — Connect biological knowledge：再决定“用什么知识”

目标：每个知识库页面使用相同模板，强调它们是同一个分析引擎上的不同知识连接器，而不是不同产品。

1. **Knowledge bases and annotation models**（从 `02-Enrichment.qmd` 扩展）
   - gene set、pathway、ontology、disease network 的差异；
   - 注释覆盖率、更新频率、物种支持和 ID 要求；
   - 如何选择知识库，以及为什么需要统一的知识封装层。
2. **GSON: the knowledge-base interchange layer**（建议从 `023-other-dbs.qmd` 抽出为新章节）
   - `gson` 包和 GSON 对象解决什么问题；
   - 如何把 GO、KEGG、WikiPathways、自定义 gene set 等知识组织成统一对象；
   - `gsonList` 如何组合多个知识库，再交给统一的 `enricher()` / `GSEA()` 接口；
   - 知识库版本、物种、来源和元数据如何随分析一起保存；
   - 明确区分：GSON 是知识表示/交换层，不是另一种富集统计方法。
3. **GO**（`021-go.qmd`）
   - `groupGO()`、ORA、GSEA、topology-aware GO；
   - 直接/间接注释和 `buildGOmap()`；
   - GO 特有的冗余问题只在这里引入，解决方案放到 Part 3。
4. **KEGG and pathway resources**（`022-kegg.qmd`）
   - 物种、`keyType`、ID 转换、数据本地化；
   - pathway、module、compound 和拓扑感知分析；
   - 说明何时使用 KEGG 原生入口，何时将其封装进 GSON 工作流。
5. **Reactome, Disease, and MeSH**（由 `024-reactome.qmd`、`025-do-enrichment.qmd`、`026-meshes-enrichment.qmd` 合并为同一组模板）
   - 每个知识库都按“适用问题 → 输入 → ORA/GSEA → 结果对象 → 可视化 → 限制”展开；
   - 不把每个包作为一个独立 Part；
   - 对可以进入 GSON 的知识集合，补充统一封装示例。
6. **Custom and universal enrichment**（`027-universal-enrichment.qmd`）
   - 自定义 `TERM2GENE` / `TERM2NAME`；
   - MSigDB、CellMarker、WikiPathways、GSON；
   - 非模式物种和自建注释，重点说明何时应把临时表升级为可复用的 GSON 对象。
7. **Other databases and external results**（`023-other-dbs.qmd`）
   - 外部服务的适用边界、数据更新和结果导入；
   - 与 GSON、universal/custom enrichment 的关系要明确区分。
8. **Genomic coordination enrichment**（`028-chipseeker.qmd`）
   - 作为“另一种输入场景”单独保留；
   - 说明它最终仍然进入相同的富集、比较和可视化系统。

### Part 3 — Connect and reduce evidence：把“显著结果”变成“可组织的证据”

目标：把原来散落在语义相似性、PPI、Bayesian term selection 和结果操作中的能力，组织成证据整合层。

1. **Working with enrichment result objects**（从 `utilities.qmd`、`dplyr.qmd` 抽取）
   - 子集、过滤、排序、提取 term 对应基因；
   - `setReadable()`、ID 可读化；
   - 保持结果对象类别，避免过早转成普通 data frame。
2. **Semantic similarity across terms, genes, and clusters**
   - 先讲共同概念和方法选择；
   - 再讲 GO、DO、MeSH 的知识结构差异；
   - 将 `01-semantic-similarity.qmd`、`011-GOSemSim.qmd`、`012-DOSE-semantic-similarity.qmd`、`013-meshes-semantic-similarity.qmd` 作为一个能力组重排。
3. **Term redundancy and representative selection**
   - `simplify()`、语义相似性、Bayesian term selection；
   - 重点回答“为什么显著 term 很多但信息重复，以及如何保留代表性主题”。
4. **PPI and evidence networks**（`PPI.qmd`）
   - 从富集结果回到基因和相互作用网络；
   - 邻居扩展、hub gene、fold change 映射和网络图；
   - 与 NSEA 的输入网络、与 `cnetplot()` 的概念边界要说明清楚。
5. **From gene sets to biological themes**
   - 把 compareCluster、语义相似性、网络和 term selection 串成一条“主题提炼”路线；
   - 为下一 Part 的图形输出提供干净的结果对象。

### Part 4 — Visualize and communicate：让结果可读、可比较、可复用

目标：不再把所有图都堆在一个 `enrichplot.qmd` 中，而是按读者想回答的问题拆分。

1. **A visual grammar for enrichment results**（新建短导言）
   - x/y、颜色、点大小、显著性、gene ratio 的含义；
   - 选择图形前先明确要比较什么。
2. **Common summary plots**
   - bar plot、dot plot、manhattan plot；
   - 常见筛选、分面和颜色设置。
3. **Gene–term and term–term networks**
   - `cnetplot()`、`emapplot()`、`treeplot()`、`upsetplot()`；
   - 网络图何时有帮助，何时会造成视觉过载。
4. **GSEA and distribution views**
   - `gseaplot2()`、ridge plot、running score、rank plot、leading-edge 展示。
5. **Compare functional profiles**
   - compareCluster 的 dot plot、cnetplot 和跨条件比较；
   - 只保留比较相关图形，避免和 Part 1 的统计问题重复。
6. **Pathway and external-result views**
   - KEGG/Reactome/pathway 图；
   - Enrichr、g:Profiler、WebGestalt、fgsea 和自定义结果的导入与绘制。
7. **Publication-ready figures**（新建）
   - 统一颜色、标签、排序、图例、导出和复现参数；
   - 说明“好看”不等于“证据更强”。

### Part 5 — Interpret and report：从结果到生物学叙事

目标：把人工解释、领域知识和可选 AI 辅助放到证据链末端，明确其边界。

1. **How to read an enrichment result**（新建）
   - 统计显著性、效应方向、背景和注释覆盖率；
   - 不把 term 名称直接当成机制结论；
   - 用 leading edge、核心基因、网络和外部证据交叉检查。
2. **Evidence-guided biological interpretation**
   - 从 `interpretation.qmd` 中抽出 context、reference-guided interpretation、PPI/表达趋势等内容；
   - 先建立人工可审计的解释框架。
3. **AI-assisted interpretation**（保留 `interpretation.qmd` 的 API 示例，但重新定位）
   - `interpret()` 的输入、任务类型和输出结构；
   - API key、模型、失败处理、置信度和成本；
   - LLM 只能合成和表达已有证据，不能替代统计检验或文献核验；
   - 将 multi-agent、annotation、phenotyping 作为高级专题或附录，避免阻塞主线。
4. **From analysis to a reproducible report**（新建）
   - 保存输入、背景集、数据库版本、参数、图表和解释文本；
   - 给出适合论文方法和结果部分的报告清单。

### Part 6 — Recipes and reference：按场景查找，按问题排错

1. **Recipes**（新建或由现有章节抽取）
   - RNA-seq 差异基因；
   - 无显著 DEG 时的 GSEA；
   - 单细胞 marker 与 cell-type annotation；
   - 蛋白组/UniProt ID；
   - ChIP-seq/peak 注释；
   - 非模式物种；
   - 多组学整合。
2. **Troubleshooting**（将 `FAQ.qmd` 从 Appendix 移出）
   - 没有 gene 能映射；
   - 下载失败与映射失败的区分；
   - KEGG 注释覆盖率低；
   - 没有显著结果；
   - 图标签、term 重复和结果对象类型问题。
3. **Package and capability map**（新建）
   - 包名、能力层、主要函数、输入、输出、依赖关系；
   - 用于满足熟悉包名的老用户，但不作为新手主导航。
4. **Glossary, citations, and API index**
   - 术语表、核心论文、函数索引、版本信息和数据来源。

## 4. 现有文件的迁移表

| 现有文件 | 建议去向 | 处理方式 |
|---|---|---|
| `index.qmd` | Part 0 | 重写为产品入口和完整工作流，不再主要罗列包名 |
| `02-Enrichment.qmd` | Part 1 / Part 2 导言 | 拆成“富集问题概览”和“知识库选择” |
| `020-enrichment-algorithms.qmd` | Part 1 | ✅ 已拆为 ORA/GSEA 基础、网络/加权、多组学三个任务章节；旧编号兼容页已删除 |
| `021-go.qmd` | Part 2 | 保留为 GO 连接器章节，补齐统一章节模板 |
| `022-kegg.qmd` | Part 2 | 保留为 KEGG 连接器章节，压缩历史性数据下载说明到附录 |
| `023-other-dbs.qmd` | Part 2 | 将 GSON 小节抽出为知识封装层；其余内容保留为外部数据库与结果导入 |
| GSON 相关内容（现位于 `023-other-dbs.qmd`） | Part 2 | 新建 `gson.qmd` 或 `knowledge-packaging.qmd`，作为 GO/KEGG 等知识库之前的共同抽象层 |
| `024-reactome.qmd` | Part 2 | 与 DO、MeSH 使用同一章节结构，并补充 GSON 互操作说明 |
| `025-do-enrichment.qmd` | Part 2 | 与 Reactome、MeSH 合并为知识库家族导航下的独立章节 |
| `026-meshes-enrichment.qmd` | Part 2 | 与 MeSH semantic similarity 交叉链接 |
| `027-universal-enrichment.qmd` | Part 2 | 前置，作为自定义注释和非模式物种的主入口 |
| `028-chipseeker.qmd` | Part 2 / Recipes | 作为基因组坐标输入场景，而不是孤立的包页 |
| `029-compareCluster.qmd` | Part 1、Part 4 | ✅ 已拆为 Part 1 的 `comparecluster-analysis.qmd` 与 Part 4 的 `comparecluster-visualization.qmd`；旧编号文件已删除 |
| `01-semantic-similarity.qmd` | Part 3 | 作为方法总览，不再作为全书第一能力 |
| `011-GOSemSim.qmd` | Part 3 | 与 term 去冗余、基因/基因簇相似性关联 |
| `012-DOSE-semantic-similarity.qmd` | Part 3 | 与 DO enrichment 交叉链接 |
| `013-meshes-semantic-similarity.qmd` | Part 3 | 与 MeSH enrichment 交叉链接 |
| `enrichplot.qmd` | Part 4 | ✅ 已拆成 6 个按任务组织的章节，原文件保留为兼容页 |
| `PPI.qmd` | Part 3 | 放入证据网络，并与 NSEA、cnetplot 互链 |
| `bayesian-term-selection.qmd` | Part 3 | 与语义相似性和 `simplify()` 合并成 term 选择专题 |
| `utilities.qmd` | Part 0、Part 3、Part 6 | ID 准备前置，结果对象操作放 Part 3，零散内容移入参考 |
| `dplyr.qmd` | Part 3 | 改名为 enrichment result manipulation，不以 dplyr 包为主角 |
| `misc.qmd` | Part 3、Part 6 | leading edge 放算法/解释链；非模式物种放 custom enrichment recipe |
| `interpretation.qmd` | Part 5 | 从“AI 页面”改为“证据到解释”，AI 为可选子章节 |
| `FAQ.qmd` | Part 0、Part 6 | 常见数据准备问题前置，其余成为 Troubleshooting |
| `appendix.qmd` | Part 6 | 只保留术语、函数、引用、版本和兼容性等参考材料 |

迁移期间可以暂时保留原文件名，先通过 `_quarto.yml` 改变导航顺序；等内容稳定后再统一重命名。所有现有锚点、外部链接和旧 URL 应保留跳转或兼容页，避免破坏已有引用。

## 5. 每个章节采用统一模板

为了持续强化“工具系统”感，建议所有实践章节都使用同一套开头和结尾：

```text
本章要回答什么问题？
你需要什么输入？
本章使用哪个分析引擎和知识连接器？
最小可运行示例
结果对象是什么？
如何检查结果是否可信？
下一步可以做什么？
常见失败与排错
相关章节：算法 / 数据契约 / 可视化 / 解释
```

每个知识库章节可以使用同一个小表格：

| 项目 | 内容 |
|---|---|
| 适合回答的问题 | 该知识库的生物学范围 |
| 输入 | gene vector、ranked list、ID 类型、背景集 |
| 可用方法 | ORA、GSEA、比较或拓扑方法 |
| 主要函数 | 入口函数及其所在模块 |
| 主要限制 | 注释覆盖率、物种支持、数据更新、ID 映射 |
| 输出 | 结果对象、可视化和后续解释路径 |

这样即使读者跳到某一个 GO、KEGG 或 Reactome 页面，也能感受到它们是同一个系统的不同连接器。

## 6. 示例和交叉链接策略

### 6.1 用一套贯穿示例，而不是每页重新造数据

建议选择一套离线、稳定、可复现的示例数据，贯穿以下路径：

```text
差异表达/排序结果
  → 数据契约和 ID 检查
  → ORA 与 GSEA 对比
  → GO/KEGG/Reactome
  → term 去冗余和 leading edge
  → dotplot/cnetplot/emapplot
  → 多组比较或 PPI
  → 人工解释与可选 AI 报告
```

现有 `DOSE::geneList` 可以作为算法演示的基础，但建议再提供一个明确的、从输入表格开始的示例文件，让读者看到真实用户通常拥有的输入格式，而不是只看到已经准备好的 R 对象。

### 6.2 每章末尾给出“下一步”

例如：

- GO ORA 之后：跳到 `simplify()` 和 dot plot；
- GSEA 之后：跳到 leading edge、ridge plot 和 `gseaplot2()`；
- 无标准 OrgDb：跳到 `enricher()` / `GSEA()` 的自定义注释；
- 多个 cluster：跳到 compareCluster 和 profile comparison；
- term 过多：跳到语义相似性和 Bayesian term selection；
- 想生成叙事：跳到 evidence-guided interpretation，而不是直接跳到 LLM API。

### 6.3 增加三种入口

书的顶部导航和首页可以同时提供：

1. **按流程读**：Start here → Engine → Knowledge → Evidence → Visualize → Interpret；
2. **按任务查**：RNA-seq、单细胞、ChIP-seq、蛋白组、多组学、非模式物种；
3. **按函数查**：函数索引、包/能力地图和 FAQ。

主导航采用第一种，后两种通过首页卡片、侧栏链接和搜索实现。这样既不牺牲系统性，也照顾熟悉具体函数的老用户。

## 7. 建议的实施顺序

### 阶段 0：只改导航，不大规模改正文

- 重写 `index.qmd`；
- 在 `_quarto.yml` 中按照 Part 0–6 排序；
- 暂时复用现有文件，先通过章节标题和导言建立新叙事；
- 删除或替换首页的 `hello` 占位内容；
- 加入一张工具系统总图。

### 阶段 1：建立最小主线

- 新建 `first-workflow.qmd`；
- 新建 `data-contract.qmd` 和 `choose-a-route.qmd`；
- 从 `FAQ.qmd`、`utilities.qmd` 抽取最常用的 ID、geneList、universe 说明；
- 确保新读者不读完整本书也能跑通一次 ORA/GSEA。

### 阶段 2：拆分过长章节、合并零散能力

- 拆分 `enrichplot.qmd`；
- 拆分 `020-enrichment-algorithms.qmd`；
- 合并 semantic similarity 的导航和交叉链接；
- 把 GSON 从 `023-other-dbs.qmd` 中抽出，建立独立的知识封装/交换章节，并在 GO、KEGG、WikiPathways 和自定义注释中各放一个互操作示例；
- 把 `misc.qmd` 的内容放回正确能力层；
- 把 `bayesian-term-selection.qmd`、`simplify()`、semantic similarity 放在同一个 term 组织专题下。

### 阶段 3：补齐任务式 recipes

- 为 RNA-seq、单细胞、ChIP-seq、蛋白组、多组学、非模式物种各提供一个短 recipe；
- 每个 recipe 只负责“从输入到下一步”，深入原理通过链接回主线章节；
- 统一示例数据、对象命名和图形风格。

### 阶段 4：清理和稳定化

- 统一文件名和标题，去掉历史编号依赖；
- 给旧锚点保留兼容链接；
- 把不稳定的外部下载、服务限制和版本差异移入 troubleshooting/reference；
- 建立链接检查、代码构建和示例数据可复现检查；
- 在首页维护包/能力矩阵，而不是再恢复包式目录。

## 8. 判断重组是否成功的标准

重组完成后，建议用以下标准验收：

- 新读者从首页开始，在不阅读包论文的情况下，能在 3 个章节内完成第一次富集分析；
- 读者面对一份 gene list 或 ranked list 时，可以明确知道下一步选择 ORA、GSEA、比较、网络或自定义注释；
- 每个知识库章节都能回答“适合什么问题、需要什么输入、会输出什么、限制是什么”；
- 任何一个结果对象都能沿着“整理 → 去冗余/整合 → 可视化 → 解释”找到下一步；
- `enrichplot`、`GOSemSim`、`DOSE`、`ReactomePA`、`meshes` 等包都能在能力地图中找到位置，但主导航不再以包名为中心；
- AI 章节明确依赖、失败模式和证据边界，不会让读者误以为 LLM 替代富集检验；
- 章节中的示例对象、输入文件、数据库版本和图形输出可以复现；
- 旧链接和已有引用不会因重组而失效。

## 9. 一句话总结

建议把这本书重组为：

> **一套从组学输入出发，经由统计富集、知识库连接、证据整合和可视化，最终形成可审计生物学解释的工具系统。**

包名仍然重要，但应该作为系统内部的模块和能力来源出现；读者首先看到的应当是问题、数据、决策和结果流，而不是包的清单。

## 10. Implementation status

The proposal has been implemented in the current source tree as follows:

| Proposal item | Status | Implementation |
|---|---|---|
| Task-oriented Part 0–6 navigation | Complete | `_quarto.yml`, `index.qmd`, and the seven part introductions. |
| First workflow within three chapters | Complete | `first-workflow.qmd` now starts from `datasets/de_table.tsv`, derived from Bioconductor `airway` with DESeq2, and runs through ORA, GSEA, plots, and object export. |
| Data contract and route selection | Complete | `data-contract.qmd` and `choose-a-route.qmd`. |
| Analysis-engine and knowledge-source separation | Complete | Enrichment foundations, network/multi-omics chapters, GSON, GO, KEGG, Reactome, DO, MeSH, custom, and ChIPseeker routes. |
| Evidence integration and result flow | Complete | Result objects, semantic similarity, Bayesian term selection, PPI, and explicit next-step links. |
| Evidence-bounded optional AI interpretation | Complete | `interpretation-reading.qmd`, `interpretation.qmd`, and `reproducible-report.qmd`; static pasted AI output is not retained. |
| Part 6 recipes and troubleshooting | Complete | `recipes.qmd`, `leading-edge-nonmodel.qmd`, and `troubleshooting.qmd`. |
| Capability map and reference index | Complete | `capability-map.qmd`, `glossary-api-index.qmd`, and `appendix.qmd`. |
| Unified semantic-similarity chapter template | Complete | Overview tables and limitation/next-step routes added to the shared, GO, DO, and MeSH similarity chapters. |
| Reproducible input and report record | Complete | `datasets/de_table.tsv`, `scripts/make_airway_de_table.R`, dataset metadata, and `reproducible-report.qmd`. |
| Historical filenames, anchors, and old HTML URLs | Complete with build-time compatibility | Source files use task-oriented names; `scripts/write_legacy_redirects.py` recreates redirects after Quarto rendering, and `scripts/check_links.py` checks source and generated links. |
| Raw-table example as a single cross-book dataset | Partial by design | The first workflow and RNA-seq recipe now use the committed airway-derived table; specialized chapters retain package-local examples when their method requires a distinct object. |
| Full chapter-template uniformity | Mostly complete | Bayesian selection, result objects, identifier utilities, summary/network/GSEA/comparison/specialized/import visualization chapters now have explicit question/input/function/output/limitation overviews; older executable examples still retain some historical exposition. |
| External-service isolation | Improved, still partial | `troubleshooting.qmd#external-services` now centralizes service failure classes, provenance, and offline alternatives, with links from KEGG, GO, Reactome, universal, external-database, and import chapters. The most unstable WikiPathways discovery/ORA/GSEA chunks are now opt-in; other real APIs remain in context. |
| Code-link and build-network stability | Complete | Quarto `code-link` is disabled to avoid CRAN index lookups during builds; function lookup is maintained through the capability map and glossary/API index. |
| Canonical recipe schema | Complete | The RNA-seq and no-DEG recipes use `de_table`’s actual `log2FoldChange`, `stat`, and `padj` fields and make Ensembl/OrgDb coverage explicit. |
| Reproducible build and regression checks | Complete | `REPRODUCIBILITY.md` records the tested R/Bioconductor snapshot and validation commands; `validate-book.yml` runs fast source checks, while `publish-book.yml` performs the full render and post-render link/navigation checks. |

The remaining partial items are editorial follow-ups rather than missing analysis capabilities. Any future changes should preserve the committed airway table, its regeneration script, the explicit source/version metadata, and the legacy redirect step in the Quarto build.
