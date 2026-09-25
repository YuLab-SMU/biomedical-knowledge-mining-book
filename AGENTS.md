# Biomedical Knowledge Mining Toolkit — Agent Instructions

本文件适用于 `biomedical-knowledge-mining-book/` 及其子目录。它记录本书的产品叙事、R 包分层、内容维护规则和本项目中已经验证过的工作流经验。

## 1. 本书要呈现的不是“包的拼盘”

本书的主线是：

```text
研究问题与输入证据
  → 数据契约：ID、排序、背景集、注释
  → 分析引擎：ORA / GSEA / compareCluster / NSEA / weighted / multi-omics
  → 知识连接与封装：GO / KEGG / Reactome / DO / MeSH / GSON / 自定义 gene sets
  → 证据整合：结果对象、语义相似性、term 选择、PPI、leading edge
  → 结果呈现：统计图、网络图、通路图、比较图
  → 生物学解释：人工核验、证据合成、可选 AI 辅助
  → 可复现交付：输入、参数、数据库版本、图表、报告和引用
```

编辑、增写或移动章节时，优先回答：

1. 读者要解决什么生物学问题？
2. 输入是什么，数据契约是什么？
3. 使用哪个分析引擎，检验的零问题是什么？
4. 使用哪个知识源，覆盖率、版本和 ID 限制是什么？
5. 输出什么标准结果对象？
6. 下一步是结果整理、可视化还是解释？

不要把“某个包有哪些函数”作为章节主线。包名应作为系统中的实现模块出现。

## 2. 包与工具系统的关系

| 系统层 | 主要模块 | 责任边界 |
|---|---|---|
| 高层入口与工作流编排 | `clusterProfiler` | 提供知识感知的分析入口、统一结果对象和跨场景工作流 |
| 统计分析引擎 | `enrichit` | ORA、GSEA、网络感知、加权和部分多组学算法 |
| 知识表示与交换 | `gson` | 将 gene set、term、物种、ID、来源和版本封装为可复用的 GSON 对象；不是新的统计检验 |
| 专用知识连接器 | `DOSE`、`ReactomePA`、`meshes` | 分别覆盖疾病/疾病语义、Reactome 和 MeSH 等知识体系 |
| 语义相似性 | `GOSemSim`、`DOSE`、`meshes` | term、gene、gene cluster 的语义相似度，以及 term 去冗余和主题组织 |
| 结果处理 | `clusterProfiler` utilities、`dplyr` | ID 转换、结果对象操作、过滤、排序、可读化；不要过早丢失 S4 结果对象 |
| 结果呈现 | `enrichplot` | ORA、GSEA、比较结果、gene–term 和 term–term 网络的可视化 |
| 基因组区域入口 | `ChIPseeker` | peak/region 注释和 region-to-gene 适配；下游仍回到统一的富集/可视化链 |
| 可选解释层 | `interpret()`、`interpret_agent()`、`interpret_hierarchical()` + `aisdk` | 消费已经验证的结果对象，生成证据条件化的叙事、annotation 或 phenotype 草稿；不能替代统计检验 |

### GSON 的定位

GSON 是知识层的共同抽象：

```text
GO / KEGG / WikiPathways / CellMarker / 自定义注释
                         ↓
              GSON / gsonList
                         ↓
             enricher() / GSEA()
                         ↓
                enrichplot / interpretation
```

新增知识库时，优先考虑是否应该提供 GSON 表示、来源和版本信息，而不是再创建一个孤立的“某包章节”。

## 3. 当前导航与源文件规则

- `_quarto.yml` 是书籍导航的权威来源。
- 当前所有 46 个 `.qmd` 都在 `_quarto.yml` 中使用；没有确认无用的 `.qmd` 时，不要为了“看起来整齐”随意移动文件。
- `docs/`、`*_cache/`、`*_files/` 是构建生成物，已经由 `.gitignore` 忽略；不要手工修改生成的 HTML 代替修改 `.qmd`。
- 稳定源数据放在 `datasets/`，图片放在 `figures/`，共享 R 工具放在项目根目录的 `_common.R` 等文件中；由于章节大量使用相对路径，不要无计划地移动这些目录。
- 新的 part 导言使用 `00-start-here.qmd`、`01-analysis-engines.qmd` 等明确的能力名称；旧的数字文件名原则上暂时保留，用导航和交叉链接完成渐进迁移。已完成迁移并经项目明确决定删除的 `020`、`029` 兼容源文件不再恢复。

### `_archive/` 归档规则

只有在以下条件同时满足时，才把 `.qmd` 移入 `_archive/`：

1. 它已经从 `_quarto.yml` 导航中移除；
2. 没有其他章节或 README 依赖其相对路径；
3. 公开锚点、旧 URL 和外部引用有兼容入口或迁移说明；
4. 在归档目录中补充原因和替代章节。

归档动作应在变更说明中列出原路径、新路径和替代入口。不要把仍然承担 part 导言、术语、兼容链接或 API 示例的章节误判为废弃文件。

## 4. 新章节的统一模板

实践型章节建议按照以下顺序写：

```text
本章要回答的问题
需要什么输入和 identifier namespace
使用的分析引擎与知识连接器
最小可运行示例
结果对象和关键字段
可信度检查与已知限制
可视化或解释的下一步
常见失败与排错
相关章节链接
```

知识库章节还应明确：

| 项目 | 必须说明 |
|---|---|
| 生物学范围 | ontology、pathway、disease、literature term 或自定义 gene set |
| 输入 | gene vector、ranked list、universe、ID 类型 |
| 方法 | ORA、GSEA、compareCluster、topology-aware 等 |
| 数据状态 | 物种、来源、release、更新时间和网络依赖 |
| 输出 | `enrichResult`、`gseaResult`、`compareClusterResult`、GSON 或图形 |
| 限制 | 注释覆盖率、ID 映射损失、背景集、更新频率和解释边界 |

每章末尾至少给出一个“下一步”链接。例如：

- gene list → ORA；
- ranked list → GSEA；
- term 过多 → semantic similarity / `simplify()` / Bayesian selection；
- 多个 cluster → `compareCluster()`；
- 无标准注释 → `enricher()` / `GSEA()` + custom `TERM2GENE` 或 GSON；
- 想形成叙事 → evidence-guided interpretation，而不是直接把统计表交给 LLM。

## 5. 动态示例优先于静态粘贴结果

本书中的结果必须尽可能由代码产生。不要把一次 LLM、网络服务或手工分析的结果复制进正文，作为永久的“示例输出”。

### LLM 示例的最低要求

1. 从项目 `.env` 加载凭据，但绝不打印或提交 key；
2. 在判断 `has_ai` 之前加载 `.env`，否则本地 key 存在但 chunk 会被错误跳过；
3. 明确设置并记录模型，例如：

   ```r
   aisdk::set_model("deepseek:deepseek-v4-flash")
   ```

4. 使用 `#| eval: !expr has_ai`，没有 key 时跳过 LLM 块但允许全书继续构建；
5. 对返回对象做结构化检查：annotation 检查 `cell_type`、`confidence`、`reasoning`；interpretation 检查 `overview`、`narrative` 等字段；
6. 结果从返回对象直接打印到页面；不要把结果另行手写进 Markdown；
7. 使用 Quarto/knitr cache 控制重复调用，并在文中说明清理哪个 cache 才会触发新调用；
8. 明确 LLM 的证据边界：它合成输入证据，不替代富集统计、背景集选择、数据库核验或文献审查。

当前 `interpretation.qmd` 的 cell type annotation 示例使用本地 CellMarker 表、`compareCluster()`、`enricher()` 和 DeepSeek；修改它时应保持这条真实运行链，不要退回到静态报告。

### 不要用 HTML 注释“隐藏”旧的 Markdown 输出

本项目已经验证：把一大段 Markdown headings、代码块和 callout 放进 HTML comment，并不能可靠阻止 Quarto/knitr 解析和渲染；还可能造成重复 chunk label。废弃的静态示例应真正删除，必要的迁移信息只保留一两行说明。

### 格式化输出不要返回 Markdown headings

`print.interpretation_list()` 会输出 `##`、`###` 等 Markdown headings。若在 `results: asis` 的 chunk 中直接 `print()`，Quarto 会把这些 heading 当成书的章节，进入目录并改变章节编号。需要同时提供“预览”和“原始输出”时：

- 用 `results: asis` 输出 HTML，而不是 Markdown heading；
- 用 `<details><summary>...</summary>...</details>` 或带边框的 `<div>` 做结果 block；
- 预览使用 `<p>`、`<strong>`、`<ul>` 等 HTML 元素；
- 原始 `print()` 结果放进 `<pre><code>`，先做 HTML escaping，避免其中的 `##` 被再次解析；
- HTML 生成函数必须转义 `&`、`<`、`>` 和引号；
- 最后检查 HTML 的 TOC：结果 block 内只能有 `<summary>`，不能新增 `h1`–`h6`。

## 6. 代码和结果对象的正确性

- ORA 使用 thresholded gene vector；GSEA 使用带名称的完整 numeric ranking；二者不要互相替换。
- `universe` 必须是字符型，并代表真正有机会进入 selected list 的背景群体。
- 自定义注释使用明确的 `TERM2GENE` / `TERM2NAME`，并记录 ID namespace。
- 尽量保留 `enrichResult`、`gseaResult`、`compareClusterResult`，不要只保存打印出来的 data frame。
- `setReadable()` 主要改变展示，不应被误解为改变了统计检验。
- GSON 文件应记录 source、species、key type、release/version 和访问日期。
- PPI、外部数据库和 AI 都属于额外证据层，必须说明网络依赖、版本和失败模式。

## 7. 重构与交叉链接经验

- 先改变导航和入口，再逐步移动正文；不要一次性重命名全部历史文件。
- 章节重排时保留旧 anchor，尤其是已经被外部页面引用的 anchor；可以添加兼容 `<a id="...">` 或保留短的兼容小节。
- 大章节拆分前先盘点 heading、figure label、缓存和外部链接。`enrichplot.qmd` 已按此流程拆分为“兼容页 + 6 个任务章节”；原 `020` 算法内容已拆为基础 ORA/GSEA、网络/加权、多组学三个任务章节，原 `029` 比较内容已拆为分析与可视化两个任务章节，可作为后续大章节拆分模板。
- 拆分大章节的标准做法（`enrichplot.qmd` 已验证）：
  1. 原文件保留为**兼容页**，只留标题、原 anchor（如 `#sec-enrichplot`）、任务路由表和 `<a id="...">` 旧 anchor 索引，不复制任何可执行示例；
  2. 正文按“读者要回答的问题”切分到新章节，`##` 级标题尽量原样搬运，chunk label 与 figure label **不得改名**（外部引用和图号依赖它们）；
  3. 每个新章节自己的 setup chunk 负责 `source("_common.R")`、加载所需包、重建该章用到的全部对象；
  4. 跨章节引用改成显式文件名加 anchor，例如 `[cnetplot](enrichplot-networks.qmd#cnetplot)`，不要依赖同页 `#anchor`；
  5. 兼容页上为旧 figure fragment 补 `<a id="fig-...">` 别名并指向新页面，保证 `/old.html#fig-x` 仍能落到有意义的页面；
  6. 拆分后删除原文件的 `*_cache` / `*_files`（可能上百 MB），否则会留下永不使用的死缓存。
- 同一概念只保留一个权威说明：GSON 详解放 `gson.qmd`，`other-databases.qmd` 只保留指向它的兼容入口。
- README 应说明从哪里开始、如何构建、哪些文件是生成物、如何使用 live examples，而不是只列软件包名称。
- 外部工具导入示例不要只用两行手写表格来画图：如果重点是验证导入与可视化链，应先跑一个完整、可复现的本地 canonical enrichment，再将完整结果按 enrichR/g:Profiler/WebGestalt/fgsea 等 schema 转换；真正在线的服务调用可以保留为显式 `eval: false` 的可选验证。
- 大章节拆分后，每个 QMD 必须独立加载 `_common.R`、包和对象；不能把前一个 QMD 的 R session 或 cache 当作后一个 QMD 的输入。

## 8. 必做验证

修改后至少执行：

```bash
# 只检查某一章
quarto render interpretation.qmd

# 完整构建
quarto render

# 检查空白和冲突标记
git diff --check
```

还应检查导航覆盖率。下面的 Python 检查可以确认根目录 `.qmd` 是否全部出现在 `_quarto.yml`：

```bash
python3 - <<'PY'
from pathlib import Path
import re
root = Path('.')
config = (root / '_quarto.yml').read_text()
nav = set(re.findall(r'^\s*-\s+(?:part:\s+)?([^\s#]+\.qmd)\s*$', config, re.M))
qmd = {p.name for p in root.glob('*.qmd')}
assert nav == qmd, (sorted(nav - qmd), sorted(qmd - nav))
print(f'QMD navigation coverage OK: {len(qmd)} files')
PY
```

如果修改了 live LLM 示例，必须额外确认：

- 实际 render 走到了目标 chunk，而不是只复用了旧 cache；
- 生成的 HTML 中出现的是本次对象打印的结果，而不是旧的粘贴文本；
- 没有重复 chunk label；
- 删除旧静态结果后，页面目录和 heading 数量符合预期。

构建 warning 要区分“已有文件的非致命格式 warning”和“本次修改导致的错误”，不能因为 exit code 为 0 就忽略新的代码或链接问题。
