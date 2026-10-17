# biomedical-knowledge-mining-book — GitHub Issues 整理

> 仓库：<https://github.com/YuLab-SMU/biomedical-knowledge-mining-book>
> 数据抓取时间：2026-09-21　|　抓取方式：`gh issue list --state all`
> 覆盖范围：全部 34 个 issue（含 20 open / 14 closed）+ 全部评论；另附 8 个 PR

---

## 1. 概览

| 指标 | 数值 |
|---|---|
| Issue 总数 | 34（#1–#42，缺号多为 PR 或已删除） |
| 开放中 | **20** |
| 已关闭 | 14 |
| 时间跨度 | 2021-02-03 → 2026-04-03（约 5 年） |
| 有评论的 issue | 12 |
| 作者亲自回复（GuangchuangYu） | 8 个 |
| 提 PR 的 issue | 1 个（#37 → PR #38，**已关闭未合并**） |
| 仓库 PR 总数 | 8（7 合并 / 1 关闭） |

**一句话结论**：这个 issue 区里真正属于"书的错"的只有约三分之一；其余是**上游 R 包的 bug、用户环境/网络问题、以及读者想让书多讲点什么**。而 open 的 20 个里，有相当一部分其实源码早就改了、只是没人关。

### 分类分布

| 分类 | 数量 | Issue |
|---|---|---|
| A. 文档错误 / 示例失效 | 12 | #14 #17 #18 #21 #25 #26 #31 #33 #35 #37 #39 #41 |
| B. 内容缺口 / 教学建议 | 9 | #7 #10 #13 #15 #29 #30 #32 #34 #36 |
| C. 用法问答（适合收进 FAQ） | 9 | #5 #11 #16 #19 #22 #23 #27 #40 #42 |
| D. 上游包 / 依赖问题（非书的锅） | 4 | #4 #12 #20 #28 |

---

## 2. 逐条索引

状态列含义：**✅ 源码已修** / **⚠️ 部分处理或修得不彻底** / **❌ 尚未处理** / **➖ 不属于本书问题**

| # | 状态 | 标题 | 提出 | 归属 | 说明 |
|---|---|---|---|---|---|
| 4 | ➖ | GSEA with ClusterProfiler-error | 2021-02 | D | `farver::decode_colour(na_value=)` 报 unused argument，是 **farver 包版本太旧**与新 ggplot2 不兼容，升级即可 |
| 5 | ➖ | please help me | 2021-08 | C | GSEA 报 `maxP > -minP` 缺值；维护者要可复现数据，用户没给，2025-12 关闭 |
| 7 | ❌ | How to use clusterProfiler with uniprot ids | 2021-11 | B | 建议补一节 **UniProt ID 做蛋白组学富集**的用法；作者回了"will do that"，**五年了还没做** |
| 10 | ➖ | How to compare two conditions ? | 2022-02 | B | 两个条件怎么对比，社区已答（先做差异分析 → 再富集） |
| 11 | ➖ | clusterprofiler can't analysis KEGG BRITE | 2022-03 | C | 希望支持 KEGG BRITE 而非只有 PATHWAY；功能请求 |
| 12 | ✅ | Problem with text position in treeplot | 2022-04 | D | treeplot 圆点遮字、cluster 名位置难调 → **直接促成 enrichplot PR #175**（label 置顶 + offset 支持 `rel()`） |
| 13 | ❌ | GSEA with phenotype permutation | 2022-05 | B | 请求 GSEA 支持**表型置换**（允许用户传入置换矩阵）。至今未实现 |
| 14 | ⚠️ | Multiple errors in pdf generation | 2022-06 | A | 用 Makefile 生成 PDF 失败、`get_wp_organisms()` 不存在。**现在该函数已在 clusterProfiler 导出**（`R/wikiPathways.R:80`、NAMESPACE:76），Makefile 也已改用 `quarto render`；但 **PDF 版仍无发布渠道** |
| 15 | ❌ | gseaplot2 color bar meaning unclear | 2022-06 | B | gseaplot2 红蓝条含义不清。2026-06 有人回帖指这是 bug（引 enrichplot#20、#221）。**书里至今没解释这个图元** |
| 16 | ➖ | pairwise_termsim() cannot be used | 2022-08 | C | 函数找不到 → 升级 enrichplot 即可 |
| 17 | ✅ | Cell Marker doc example is broken | 2022-08 | A | CellMarker 下载链接失效（返回中文 HTML"访问被禁止"） |
| 18 | ➖ | enrichplot barplot doc with mutate example is broken | 2022-08 | A | `mutate()` 对 enrichResult 报 no applicable method → 需**先 `library(clusterProfiler)`** 注册 S3 方法。示例代码应显式写出 |
| 19 | ➖ | enrichplot barplot doesn't work with GSEA result | 2022-08 | C | 设计如此：`barplot()` 只支持 `enrichResult` |
| 20 | ➖ | cannot load Inparanoid8Db database | 2022-09 | D | AnnotationHub 里 `Inparanoid8Db` 类未定义，上游数据问题 |
| 21 | ✅ | link expired | 2022-09 | A | 12.2 节 Cell Marker 链接失效，读者给了新链接，**已被采纳** |
| 22 | ➖ | Error No genes can be mapped while normal enriched on DAVID | 2023-03 | C | ⭐ **根因可诊断**：用户 ID 列表里出现 `1.01E+08`、`1E+08` —— Excel 把大数字转成了**科学计数法字符串**，Entrez ID 全废。这是数据导入问题，值得写进 FAQ |
| 23 | ➖ | KEGG enrichment analysis - supported organisms | 2023-06 | C | 非模式生物做 KEGG → 用 [createKEGGdb](https://github.com/YuLab-SMU/createKEGGdb) |
| 25 | ⚠️ | Example data in 12.2 not loadable | 2024-01 | A | 与 #17/#21 同一个坑：链接**第三次失效**。现源码改用 `http://yikedaxue.slwshop.cn/Cell_marker_Human.xlsx`（第三方非官方源，仍有失效风险） |
| 26 | ✅ | Treeplot() Links Broken | 2024-01 | A | chapter 15 treeplot 文档链接失效；已关（当前 qmd 里已无 rdrr.io 链接） |
| 27 | ➖ | enrichkegg 函数报错 | 2024-02 | C | `rest.kegg.jp` SSL connect error。用 `use_internal_data=TRUE` 能跑但 Description 只有编号、且多出 category/subcategory 列。**中文提问** |
| 28 | ➖ | treeplot not working | 2024-03 | D | `Invalid edge matrix for <phylo>` + `scale$guide` 比较错误，疑似 ape/tidytree 版本问题 |
| 29 | ❌ | chapter 14: CompareCluster question | 2024-04 | B | **已有两张富集结果表，怎么合成能喂给 compareCluster 的对象？p 值该取哪套？** 书里缺"从已有结果重建对象"的说明 |
| 30 | ❌ | Chapter 15 - Seurat option? | 2024-05 | B | enrichplot 的图能否用于 **Seurat / 单细胞**对象。高频需求，书里没有对应章节 |
| 31 | ✅ | overlap of 25 genes | 2024-10 | A | ORA 示例写 57 个 DE、28 个在基因集，下文却冒出"overlap of 25 genes"。**当前源码已删掉这个表述**，但 issue 没关 |
| 32 | ❌ | Consider increasing max.overlaps in cnetplot() | 2024-10 | B | cnetplot 标签重叠；问能否只标 category 不标 gene、或只显示 FC≥2 的基因。**源码里没有 `max.overlaps` 相关说明** |
| 33 | ✅ | Typo - DO instead of GO | 2024-11 | A | `DO`→`GO`、`knownledge`、`celluar` 三处 typo，**已修**（源码 grep 已无） |
| 34 | ❌ | No Advice for Overrepresentation versus Enrichment Analysis | 2024-12 | B | ⭐ **该讲清楚"什么时候用 ORA、什么时候用 GSEA"**：DE 基因多 → ORA；少甚至为 0 → GSEA。书里目前没有这段建议 |
| 35 | ✅ | Typo at Chap 14.2 | 2024-12 | A | `alternaitve` → `alternative`。**已修**，issue 没关 |
| 36 | ❌ | ScoreType | 2025-03 | B | `scoreType` 参数缺文档；问**非表达数据（正排序，分数越高越显著）**能否用于 `gsePathway`。源码里搜不到 `scoreType` |
| 37 | ⚠️ | Example in Section 5.2 - ORA | 2025-06 | A | ⭐⭐ **见第 3 节，修得不彻底、且现在算错了** |
| 39 | ❌ | enrichplot - treeplot() question | 2025-08 | A | rdrr.io 的 treeplot 文档页访问不了；另问 tip label 颜色怎么匹配 `group_color`、怎么 `str_wrap()`。**文档链接不该依赖 rdrr.io** |
| 40 | ✅ | package containing interpret | 2026-02 | C | `interpret()` 在哪个包 → **devel 分支 clusterProfiler ≥ 4.19.4** |
| 41 | ❌ | enrichplot: Multiple figures do not display | 2026-03 | A | `enrichplot.html` 打开后图要加载几十秒甚至几分钟，图 13.1/4/5/6/7… 干脆不出来。**站点侧问题，值得查** |
| 42 | ✅ | 4.3 GO classification groupGO 函数错误 | 2026-04 | C | groupGO 结果异常，改用 `DOSE:::TERMID2EXTID` 就正常。**已修**（enrichit commit `93923c0`）。中文提问 |

---

## 3. 重点发现：两处需要立刻动手

### 3.1 `#37` 修了，但**列序反了，示例现在是错的**（优先级最高）

读者 thegrebe 指出 §5.2 的 ORA 示例有两个问题：① 2×2 表的**列序**与 `alternative="greater"` 不匹配；② 文字里缺"2641 个基因被注释到目标基因集"这一信息，读者**根本推不出这张表**；③ 上文说 28 个 DE 基因，下文却写 "overlap of 25 genes"。

他提了 PR #38，但 PR 被**关闭未合并**。而当前源码 `020-enrichment-algorithms.qmd:26-39` 已经采纳了他的措辞，表却写成了：

```r
d <- data.frame(non_DE_gene=c(2613, 15310), DE_gene=c(28, 29))
row.names(d) <- c("In_category", "not_in_category")
fisher.test(d, alternative = "greater")
```

`alternative="greater"` 检验的是**左上角格子是否大于独立假设下的期望值**。现在左上角是 `2613`（非 DE ∩ 在基因集），方向恰好反了。实跑验证：

```
== 当前源码（non_DE 在前）==
                non_DE_gene DE_gene
In_category            2613      28
not_in_category       15310      29
p-value = 1          odds ratio = 0.1768      ← 不显著！

== 换成 DE 在前 ==
p-value = 7.879e-10  odds ratio = 5.65631     ← 这才是书中要的结论
```

**修法**：把两列对调即可 —— `data.frame(DE_gene=c(28, 29), non_DE_gene=c(2613, 15310))`。
（注意源码现在**不能**用 `alternative="less"` 糊过去，那样解释起来更绕；直接把列序摆正最干净。）

### 3.2 `#22` 的根因可以直接写进 FAQ

issue 说"DAVID 能富集，`enrichKEGG` 报 No gene can be mapped"。看用户贴的 ID 列表就明白了 —— 里面混着 `1.01E+08`、`1E+08`、`1.01E+08`：**Excel 把长数字自动转成了科学计数法**，Entrez ID 已经不是数字而是字符串，自然一个都映射不上。这不是 clusterProfiler 的问题，但**极易被误判成包 bug**，值得在 FAQ 里写一条"从 Excel 读 ID 一定要按文本读"。

---

## 4. 建议的处理清单

**P0 — 内容错误（会误导读者）**
1. 修 #37 的 2×2 表列序（上面已给改法），顺手关掉 #31 / #37。
2. 补 `library(clusterProfiler)` 到 barplot + mutate 示例（#18），避免读者撞 S3 方法未注册。

**P1 — 关掉已经修好但没人关的**
3. #31、#35 源码已改，直接关闭并留言说明。
4. #14：`get_wp_organisms()` 已导出，可关闭或转为"PDF 版发布渠道"的独立议题。
5. #26、#21、#33 已处理完，确认后关闭。

**P2 — 低成本高收益的内容补充**
6. #34：加一段"ORA vs GSEA 怎么选"（DE 基因多 → ORA；少/为 0 → GSEA）。这是**教学场景最容易被问到的问题**。
7. #7：补 UniProt ID 做蛋白组学富集的用法（作者 2021 年就答应了）。
8. #32 + #15：给 cnetplot 的标签控制、gseaplot2 红蓝条含义各写一段说明。
9. #36：补 `scoreType` 参数的说明。
10. #29：补"如何把已有的富集结果表重建为可分析对象"。

**P3 — 结构性缺口 / 基础设施**
11. #30：单细胞（Seurat）场景 —— 需要单独一节甚至一章，是长期高频需求。
12. #25 / #21 / #17：CellMarker 数据源**已经失效三次**，目前指向第三方站点 `yikedaxue.slwshop.cn`。建议把数据落到本仓库或 Figshare/Zenodo，别再依赖外部链接。
13. #39 / #26：文档链接不要再指向 rdrr.io，改用官方 pkgdown 站点（yulab-smu.top）。
14. #41：排查 `enrichplot.html` 图片加载慢/加载不出来的问题（图数量与体积、托管方式）。

---

## 5. 一个观察

这个 issue 区反映出的**最集中的读者痛点**，其实不是"书里有错"，而是三类：

1. **依赖/环境问题被误当成书的问题** —— farver 版本（#4）、ape/tidytree 版本（#28）、网络与 SSL（#27）、AnnotationHub 数据（#20）、Excel 科学计数法（#22）。这些占了近一半，且**答案都很短**，完全适合做一页 "Troubleshooting"。
2. **读者想从"教程"走到"自己的数据"** —— #10、#29、#30 都是同一个诉求：书上用的是示例数据，我自己手上已经有一堆结果表了，怎么接上去？
3. **链接与数据源腐烂** —— #17 / #21 / #25 是**同一个链接失效了三次**，#26 / #39 是文档链接失效。外部链接是这个仓库最大的长期技术债。

另外值得记一笔：#12 是个漂亮的例子 —— 读者报告 treeplot 标签遮挡，直接催生了 enrichplot PR #175。**书的 issue 区事实上在反哺上游包的开发**。

---

## 6. 本轮修复进展（2026-09-21）

### 已修复并提交（commit `e2cf0a4`，4 文件 +214 −3）

| issue | 处理 |
|---|---|
| **#37** | ✅ **修了真错**。`020-enrichment-algorithms.qmd` 的 2×2 表列序反了 → 改成 `data.frame(DE_gene=c(28,29), non_DE_gene=c(2613,15310))`，并补一段解释"为什么列序重要"。实跑验证：p = 7.879e-10、OR = 5.656（改前 p = 1、OR = 0.177） |
| **#18** | ✅ 示例中 `library(clusterProfiler)` 本已存在；新增 callout 说明**为什么必需**（`mutate.enrichResult` 是 clusterProfiler 加载时注册的 S3 方法），防止再犯 |
| **#34** | ✅ 新增 `### Choosing between ORA and GSEA`：按 DE 基因数量决定，含 5 行对照表 + 常见误用说明 |
| **#7** | ✅ `027-universal-enrichment.qmd` 新增 `## Proteomics data and UniProt identifiers`：模式生物走 `bitr()`；非模式生物走 EBI GOA/GAF（`read.delim` 解析 → `TERM2GENE`/`TERM2NAME` → `enricher()`）。**全流程已实跑验证**（下载番茄 `.goa` 切片，成功出富集结果） |
| **#36** | ✅ 新增 `### One-sided or two-sided: the scoreType argument`：`std`/`pos`/`neg` 三值语义对照表。**已实测**：全正分数用 `std` 会告警；混合符号数据下 `pos` 完全看不到底部富集集（ES=0、p=1） |
| **#15** | ✅ `enrichplot.qmd` 新增三面板说明 + callout 指出上游 bug。**注意**：描述按"应有行为"写，并显式标注当前版本分箱顺序是错的 |
| **#32** | ✅ 修书里参数名笔误 `node_label_gene` → `node_label`（该参数**不存在**）；新增 callout 讲标签重叠（`ggrepel.max.overlaps`、`node_label="category"`、`fc_threshold`） |
| **#22** | ✅ `FAQ.qmd` 的 "No gene can be mapped" 从两个链接扩写为完整条目：诊断 Excel 科学计数法（含可运行的检测代码）、说明 `1E+08` 是**有损**不可恢复、给出导出/读取的正确做法 |
| **#31** | ✅ 已确认源码中 "overlap of 25 genes" 表述早已删除 |
| **#35** | ✅ 已确认 `alternaitve` typo 早已修正 |

### 暂缓（见 `../enrichplot-pending/README.md`）

| 项 | 原因 |
|---|---|
| enrichplot #20 / #221（`gseaplot2` 分箱顺序反了） | 修复**已完成并验证**（补丁 + 回归测试 + 前后对比图已存档），但本工作区**另有会话正在修改 enrichplot 源码**，故暂不落地，避免互相覆盖 |

### 未处理（需决策或属外部问题）

`#30` 单细胞章节、`#29` 从已有结果重建对象、`#13`/`#11` 上游功能请求。

---

## 7. 第二轮（2026-09-21 下午）

### 7.0 最重要的发现：站点从 6 月 24 日起就没再发布过

查 CI 记录时发现的**根因，比任何单条 issue 都重要**：

```
gh api repos/.../actions/workflows
  → Publish Quarto Book   state = disabled_inactivity
```

GitHub 在仓库 60 天没有活动后**自动禁用**了 workflow。所以：

- 最后一次**成功**部署是 `2026-06-24`，`gh-pages` 停在那天；
- 之后每次构建都失败（6-29 起），跑到 8-30 后连 schedule 都不再触发；
- 我今天的 push **没有触发任何构建**——因为 workflow 是禁用的。

已 `gh workflow enable publish-book.yml` 恢复，并手动 dispatch 了一次。
**这一条要记住**：以后 push 完发现 CI 没动静，先查 workflow 是不是被 GitHub 自动禁用了。

### 7.1 构建失败的两个独立原因（都已修）

| 原因 | 修法 | commit |
|---|---|---|
| 缺 `libglpk-dev`，igraph/enrichplot/ChIPseeker 安装失败（`libglpk.so.40: cannot open shared object file`） | workflow 的 apt 列表加 `libglpk-dev` | `e1a4c0f` |
| GOSemSim `TCSSMethod.R` 在 `011-GOSemSim.qmd:103-115` 崩溃（`recursive indexing failed at level 2`） | 见 7.3 | GOSemSim `34c4ae3` |

**这两个都要修好，站点才能重新发布。**

### 7.2 `#41` 站点图片加载不出来 —— 真因找到了

不是"网络慢"，是**页面总共 100.8 MB 的 SVG**。enrichplot.html 有 42 张图，其中：

| 图 | 大小 |
|---|---|
| fig-gseaplot22 | 18.20 MB |
| fig-gseaplot23 | 17.62 MB |
| fig-gseaplot24 | 10.37 MB |
| fig-Enrichment2 | 8.69 MB |
| …另 11 张 > 1 MB | |

抓下 18 MB 那张 SVG 分析：**22,250 个 `<path>`、5,184 个 `<clipPath>`，单条 path 的 `d` 属性 290,576 字符**。
根因是 `gseaplot2()` 给排序列表里**每个基因**都画一个图元。

修法：让 R 直接画 PNG（`#| fig-format: png` + `#| fig-dpi: 150`），不做 SVG 转换。实测：

| 图 | SVG | PNG | |
|---|---|---|---|
| fig-gseaplot23 | 17.62 MB | 0.21 MB | 83× |
| fig-gseaplot22 | 18.20 MB | 0.27 MB | 66× |
| fig-gseaplot2 | 5.88 MB | 0.16 MB | 36× |
| fig-geom-gsea-gene | 5.89 MB | 0.18 MB | 33× |
| fig-gseaplot-pvalue | 5.89 MB | 0.18 MB | 32× |
| fig-gseaplot24 | 10.37 MB | 0.41 MB | 26× |
| fig-gseaplot-custom-color | 5.76 MB | 0.25 MB | 23× |
| fig-gseaplot | 5.67 MB | 0.38 MB | 15× |
| fig-simplify-go | 2.35 MB | 0.52 MB | 4.5× |
| **小计** | **77.6 MB** | **2.6 MB** | **30×** |

**刻意只改这 9 张。** 其余（emapplot 系列）改成 PNG 反而更大，实测
`fig-Enrichment` 1.01 → 1.15 MB、`fig-Networkplot` 1.99 → 2.36 MB，所以保留 SVG。
结论：**不能无脑全局栅格化**，要按图分别量。

### 7.3 `_common.R` 里那个 `svg2png()` 是个坑（重要）

`_common.R` 里早就写好了一个按 1.2 MB 阈值自动转 PNG 的 `svg2png()`，但 `fig.process` 那一行
**从引入它的那次 commit（`7f6ceaa`，2025-11-18）起就是注释掉的**，从来没在 Quarto 下生效过。

试过把它打开，结果发现**为什么不能用**：ImageMagick 6 的内置 SVG 渲染器解析不了这些文件——

```
convert-im6.q16: unbalanced graphic context push-pop `graphic-context'
convert-im6.q16: non-conforming drawing primitive definition `use'
```

退出码 1，且生成的 PNG **只剩坐标轴**：曲线、hit ticks、ranked list 面板全丢了。
也就是说，如果当初启用了它，会得到一堆"空白图"而不是"重图"。

已在 `_common.R` 就地写明**不要启用**及原因；同时把函数本身加固（`shQuote` 处理带空格的路径 +
转换失败时**保留 SVG 并告警**，而不是先 `file.remove()` 把图删掉）。

### 7.4 `#39` treeplot 的两个问题（已答，并修出两个文档错误）

提问者问：(1) 怎么让标签颜色对上 `group_color`；(2) 怎么用 `str_wrap()` 折行 tip 标签。
他给的是**旧版 API**（`cluster.params`/`offset.params`），现在都变成顶层参数了。

实测结论：

| 问题 | 答案 |
|---|---|
| 颜色对上 | `group_color = c(...)` 顶层参数，**clade 标签和 highlight 底色都用它**，天然一致 |
| tip 标签折行 | **`label_format` 折的是 clade 标签，不是 tip 标签**（源码 `add_clade_labels()` 里 `label_func` 只作用于 `df$labels`）。tip 标签取自 enrichment result 的 `Description`，所以要在 `pairwise_termsim()` **之前**改 `@result$Description` |

顺带修出**两个文档错误**：

1. 原文说"用 `leave_fontsize` 和 `clade_fontsize` 调字号"——**这两个参数都不存在**。
   实际是 `fontsize_tiplab` / `fontsize_cladelab`（同一节的示例代码用的就是对的，正文写错了）。
2. 由此新增 `### Colouring the clades and wrapping labels` 小节，把上面两条写清楚。

### 7.5 `#25` CellMarker 数据源（已修）

示例里的 URL 已经死了，而且是**死过第三次**：

| URL | 状态 |
|---|---|
| `bio-bigdata.hrbmu.edu.cn/CellMarker/download/Human_cell_markers.txt` | 403 |
| `yikedaxue.slwshop.cn/Cell_marker_Human.xlsx`（书里当时用的） | **DNS 都解析不了** |
| `www.bio-bigdata.center/CellMarker_download_files/file/Cell_marker_Human.xlsx` | ✅ 200，7.98 MB 有效 xlsx |

而且**列名改过**：书里写 `'Cell name'`，当前文件是 `cell_name`（正是提问者说的 "headers have names
with different formats"）。已实测跑通全流程（60,877 行 → `enricher()` 出正常结果）。
修法：换成可用 URL + 当前列名，并加 callout 说明**主机和列名都会漂移**，让读者先 `names()` 确认。

### 7.6 顺手修掉的 `interpretation.qmd` 两处笔误

该 chunk 是 `eval: false`，所以 CI 一直没发现：

- `libray(dplyr)` → `library(dplyr)`
- `top10` → `top20`（变量在上面两行才定义，`top10` 从未存在）

### 7.7 本轮提交

| 仓库 | commit | 内容 |
|---|---|---|
| book | `e1a4c0f` | CI 加 `libglpk-dev` |
| book | `5af13fa` | `#41` 九张图改 PNG、`_common.R` 记录 svg2png 为何不能用、`#39`、`#25`、`interpretation.qmd` 笔误 |
| GOSemSim | `34c4ae3` | TCSS 多簇崩溃修复（已推 `devel`） |

### 7.8 还没做

- `#30`（Seurat 结果怎么用 enrichplot 出图）、`#29`（从已有富集表重建对象）—— 都是内容缺口，需要写新小节
- `#13`（GSEA 表型置换）、`#11`（KEGG BRITE）—— 属上游功能请求，建议回复说明设计取舍后关闭
- `fig-Enrichment2`（8.69 MB）仍是页面最大的单张图；emapplot 转 PNG 更大，故保留 SVG
- `enrichplot-pending/` 里的 `gseaplot2` 分箱补丁，等并发的 enrichplot 会话结束后再落地

---

*本文档由 `gh` CLI 抓取全量 issue + 评论后整理，并逐条对照当前 `master` 分支源码验证。*

---

## 8. 第三轮：构建失败逐个击破（2026-09-21 傍晚）

### 8.1 第一次构建：安装全过了，渲染挂在别处

`e1a4c0f` + `5af13fa` 那次构建（run `35562467258`）结果：

| 步骤 | 结果 |
|---|---|
| 5–14 安装类步骤 | ✅ **全过**（`libglpk-dev` 那一修生效了；连"Prewarm ontology caches"都过了） |
| 15 Render Quarto Book | ❌ 失败 |
| 16 Deploy | ⏭ 跳过 |

**好消息**：日志显示章节 1–11 都渲染成功了，**说明 GOSemSim 的 TCSS 修复确实生效**。

**坏消息**：挂在一个我没想到的地方——

```
Error in `enrichDGN()`: could not find function "enrichDGN"
Quitting from 025-do-enrichment.qmd:76-87 [enrichdgn-example]
```

### 8.2 根因：DisGeNET 被上游删了（许可证变更）

DOSE 源码（devel 4.7.3）里根本没有 `enrichDGN`：

```
commit 1cfa7e3  "remove DisGeNET and update NCG"  (2026-06-29)
  - enrichDGN()、enrichDGNv()、gseDGN() 全删
  - DGN_*.rda / VDGN_*.rda 数据集全删
  - NAMESPACE 只剩 export(enrichNCG) / export(gseNCG)
```

NEWS 里写了原因：**DisGeNET 的许可证从 CC BY-NC-SA 改成专有（proprietary），
数据不能再随包分发**。替代方案是 `enrichDO(ont="HDO")`。

书的 CI 是用 `pak` 从 `github::YuLab-SMU/DOSE` 装 **devel**，所以书里只要还在用
`enrichDGN` 就必挂——而且挂在第 025 章，**根本走不到我改的那些图**。

### 8.3 ⚠️ 一个很重要的方法论教训

我本地装的 DOSE 是 **4.6.0（Bioconductor release）**，`enrichDGN` 还在；
CI 装的是 **devel 4.7.3**，已经删了。

所以**本地渲染通过 ≠ CI 通过**。以后改这个书，验证时要意识到：
CI 用的是各包的 **GitHub devel**，本地可能是 release。要复现 CI 得 `pkgload::load_all()`
加载工作区里的 devel 源码，而不是 `library()` 装好的 release。

（这次之所以没早点发现：前一版的失败都发生在**安装阶段**，根本没走到渲染，
所以这个 DisGeNET 问题一直藏着没暴露。）

### 8.4 修法

| 文件 | 改动 |
|---|---|
| `025-do-enrichment.qmd` | DisGeNET 的 ORA 小节 + `gseDGN` 小节 → 换成一段说明：函数已删、原因是许可证、替代走 `enrichDO(ont="HDO")` / `gseDO(ont="HDO")`。**并强调这是换了数据源不只是换了函数名**：DO 是"基因→疾病术语"注释，DisGeNET 是聚合的"基因-疾病关联"，结果不可互换 |
| `enrichplot.qmd` | 3 处 `enrichDGN(de)` → `enrichDO(de)`（这几处只是为了拿一个 enrichResult 来演示画图，且同章 line 200 本来就用 `enrichDO`）。顺带把没人引用的标签 `fig-enrichDGN` 改名 |
| `029-compareCluster.qmd` | 删掉指向 `#dose-dgn-ora` 的死链 |
| `02-Enrichment.qmd` | 基因集资源列表里不再暗示支持 DisGeNET |

**顺带做了一次预防性排查**：把 DOSE / enrichplot / clusterProfiler / enrichit / GOSemSim
的 NEWS 里所有 "remove" 条目拉出来，逐个对照书里的调用——
`mpoSim`/`hopSim`/`gseMPO`/`gseHPO`/`enrichMPO`/`enrichHPO`/`drag_network`/`aes_string` 都没用到；
`categorySize` 已删但书里用的是新的 `categorySizeBy`；`doSim` 仍在。
结论：**没有第二个同类问题**。

### 8.5 本轮 commit

| commit | 内容 |
|---|---|
| `e1a4c0f` | CI 加 `libglpk-dev` |
| `5af13fa` | `#41` 九张图改 PNG + `_common.R` 记录 svg2png 陷阱 + `#39` + `#25` + `interpretation.qmd` 笔误 |
| `d5bb274` | `#29` / `#30`：说明 `compareCluster()` 吃基因列表不吃富集表、enrichplot 需要结果对象 |
| `03815c8` | 删 DisGeNET 相关内容（本轮构建失败的直接原因） |
| GOSemSim `34c4ae3` | TCSS 多簇崩溃修复（已推 devel） |

### 8.6 待办

- 等这次构建结果；若还有失败，继续往下修（025 之后的章节还没验证过）
- `#30`/`#29` 的回复与关闭（内容已写进书，等构建确认）
- `enrichplot-pending/` 的 `gseaplot2` 分箱补丁，等并发的 enrichplot 会话结束
- GOSemSim TCSS 数值饱和（余老师指示：等 CI 通过再议）


## 9. 第四轮：让构建对"第三方服务抽风"有韧性（2026-09-21 晚）

### 9.1 第二次构建失败：Europe PMC 返回 503

`03815c8` 那次构建（run `35565037086`）走得更远了——**渲染到 `enrichplot.qmd` 第 110/121 个 chunk**，
也就是说 DisGeNET 那一修生效了，9 张 `fig-format: png` 的 gseaplot 图**全部渲染成功**。

然后挂在最后几张图之一：

```
Error in `map()`: ℹ In index: 1. Caused by error in `rebi_GET()`:
! Service Unavailable (HTTP 503).
  1. ├─enrichplot::pmcplot(terms, 2010:2020)
  9. │         └─europepmc::epmc_hits_trend(query = x, period = period)
Quitting from enrichplot.qmd:1113-1126 [fig-pmcplot]
```

**这不是代码 bug，是 Europe PMC 挂了。** 一个第三方服务抽风不该让整本书发不出去。

### 9.2 设计决策：重试逻辑放 `_common.R`，不塞进章节

一开始我把重试写成章节里的一个局部 `pmc_trend()`，但那样：

1. 教学章节里多出 15 行防御代码，读者要读的重点（`pmcplot` 怎么用）被淹没；
2. 同一类问题在别处还会再犯。

所以改成在 `_common.R` 里加通用助手。这不是新花样——`_common.R` 里的
`build_demo_network()` / `clusterprofiler_enrichit_demo()` 早就在 3 个**会渲染的** chunk 里被调用了
（`020`/`021`/`022` 章），是这个书既有的约定。

```r
retry <- function(expr, times = 3, wait = 5) {
  expr <- substitute(expr)
  env <- parent.frame()
  for (attempt in seq_len(times)) {
    res <- tryCatch(eval(expr, env), error = function(e) e)
    if (!inherits(res, "error")) return(res)
    if (attempt < times) Sys.sleep(wait)
  }
  warning(conditionMessage(res), call. = FALSE)
  NULL
}
```

**为什么要 `substitute` + `eval`**：直接把 `expr` 交给 `tryCatch()` 的话，promise 只会被求值一次，
R 会在每次重试时打一句 `restarting interrupted promise evaluation`。实测确认：
朴素写法能重试（计数器到 3）但会刷 2 条这个警告；`substitute` 版本干净无警告，且能正确解析调用方
作用域里的变量（已用嵌套函数 + `edo$Description[1:5]` 这种真实表达式验证）。

### 9.3 顺手挖出一个**静默错误**：Enrichr 的 HTTP 200 + HTML

`utilities.qmd` 里那个 Enrichr GMT 下载是同一类脆弱点，一并处理。做的时候发现一个更麻烦的事：

**Enrichr 对不存在的 library name，返回的不是 404，而是 HTTP 200 + 一个 HTML 错误页。**

```
$ curl -o bad.gmt "...libraryName=NoSuchLibraryXYZ"
HTTP=200  SIZE=683  TYPE=text/html;charset=UTF-8
```

于是 `download.file()` 认为**下载成功**（exit status 0），而 `read.gmt()` 对那个 HTML 页
**不报错**，返回一个 **0 行的 data.frame**：

```
> read.gmt("bad.gmt")
class: data.frame | dim: 0 x 2
```

也就是说：**哪天 Enrichr 把库改个名，这本书会安静地发布一张空表**，构建照样绿。
这比构建失败更糟。所以助手不能只看 exit status，还得看内容：

```r
is_html_response <- function(path) {
  bytes <- readBin(path, "raw", n = 512L)
  bytes <- bytes[!bytes %in% charToRaw(" \t\r\n")]
  length(bytes) > 0 && bytes[1] == charToRaw("<")
}
```

比原始字节而不是字符串，这样对任何编码都安全（xlsx 这种二进制也不会误判）。

`retry_download()` 把两种情况都归一到 error 交给 `retry()`：
①`download.file()` 在不同后端行为不一致——`wget`/`curl` 方法**只警告 + 返回非 0 status**，
内部/libcurl 方法**抛错**；②HTTP 200 但内容是 HTML。

### 9.4 一个重要的本地/CI 差异（又一次）

我本想本地把 `pmcplot` 的成功路径也跑通，结果单次 `pmcplot()` 调用 **240 秒都没返回**。
一度以为是 httr2 重试堆叠的问题，查下来是**我的机器根本连不上 EBI**：

```
$ curl -m 10 "https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=cell%20cycle"
curl: (28) Operation timed out after 10000 milliseconds with 0 bytes received
HTTP=000 time=10.000425s
```

而 Enrichr（maayanlab.cloud）本地是通的。所以：

- **本地那次"240 秒还没完"是我的网络，不是书的代码**，CI 里拿到的是**快速返回的 503**；
- `retry(times = 3)` 在 CI 的失败场景下代价就是 3 次快速失败 + 2×5 秒 sleep，**是有界的**，
  不需要为它调参；
- **`pmcplot` 的成功路径只能等 CI 验证**（本地无法复现）。

### 9.5 改了什么

| 文件 | 改动 |
|---|---|
| `_common.R` | 新增 `retry()`（重试并优雅降级）、`is_html_response()`、`retry_download()` |
| `enrichplot.qmd` | `fig-pmcplot`：`pmcplot(...)` → `retry(pmcplot(...))`，两者都拿到才画；拿不到就跳过这张图 |
| `utilities.qmd` | Enrichr GMT：`download.file()` + `read.gmt()` → `retry_download()` + `if (!is.null(gmt))` |

**确认过 `@fig-pmcplot` 没有任何地方引用**，所以跳过这张图不会留下断掉的交叉引用
（Quarto 遇到无法解析的 `@fig-` 引用会直接报错，那就白改了）。

### 9.6 有意识**没做**的事

- **没给 `enrichKEGG` / `enrichPathway` 加 retry**。KEGG REST 和 Reactome 一直很稳，
  而且书里十几处都依赖它们——真挂了包一层也救不回来。只处理**已经实际挂过**的和**同类的
  非 KEGG 第三方服务**。
- **没加 `setTimeLimit()` 兜底**。理论上能给 `pmcplot` 加超时，但它只在中断检查点生效，
  对 C 层的 socket 等待不可靠，容易给出"以为有保护其实没有"的错觉。
- **没改 `interpretation.qmd` 的执行状态**。确认过它的 **6 个 chunk 全是 `eval: false`**
  （LLM 调用不进 CI），不需要动。

### 9.7 验证做了什么

`retry()` / `retry_download()` 都是先跑过再写的：

| 测试 | 结果 |
|---|---|
| 真实 URL 下载 | ✅ 399,553 字节 → `read.gmt()` 得 60,289 行 / 205 个基因集 |
| 用 `wget` 方法（和 CI 一致）跑 `utilities.qmd` chunk 原文 | ✅ 下载 + 解析 + `head()` 正常输出 |
| 错误 library name | ✅ 重试 3 次后返回 `NULL` + 警告，不抛错 |
| 不可达主机 | ✅ 返回 `NULL` |
| `is_html_response()` 单元测试 | ✅ HTML / 带前导空白的 HTML / 真 GMT / 二进制 xlsx 四种都对 |
| `retry()` 重试语义 | ✅ 第 3 次成功、计数为 3、**无** promise-restart 警告 |
| `fig-pmcplot` chunk 原文（本地无 `europepmc`） | ✅ 报错被吃掉 → 返回 `NULL` → chunk 正常结束，**没有中断渲染** |
| `fig-pmcplot` chunk 成功路径 | ⏳ 本地连不上 EBI，只能等 CI |

### 9.8 待办

- 提交并重跑 CI，确认能过 `enrichplot.qmd` 第 110 个 chunk 之后的部分
- **`enrichplot.qmd` 之后的章节（`PPI`/`bayesian-term-selection`/`interpretation`/`dplyr`/
  `utilities`/`FAQ`）这一轮 CI 从没走到过**，是本轮最大的未知数。
  已初步排查：`interpretation.qmd` 全 `eval: false`；其余章节自 2026-06-24 那次成功发布后基本没动过
- 站点发布恢复后：回复并关闭 `#30` / `#29` / `#25` / `#39` / `#41`
- 两个遗留小问题（都不影响构建）：~~`#| fig-scap:` 是 `fig-alt` 的拼写错误，书里出现 30+ 次~~
  （**此结论已在第五轮推翻，见 §11.1**）；
  `022-kegg.qmd` 等处有 `#| eval: false` 写在**普通 ```r 代码块**里，会被当正文显示给读者


## 10. 第四轮结果：构建全绿，站点恢复发布（2026-09-21 夜）

### 10.1 17 个步骤全过，站点自 6 月 24 日以来第一次发布

run `35570067004`（commit `1a16653`）：

| 步骤 | 结果 |
|---|---|
| 5–14 全部安装步骤 | ✅ |
| 15 Render Quarto Book | ✅ |
| 16 Deploy to GitHub Pages | ✅ |

`gh-pages` 产生新提交 `7ece004 deploy: 1a16653`。
**也就是说：站点从 2026-06-24 停更至今，终于恢复了。** 之前那三个坑
（workflow 被 GitHub 自动禁用、`libglpk-dev` 缺失、DisGeNET 被上游删、Europe PMC 503）
全部清掉。

### 10.2 用真浏览器验证，而不是只看构建绿

构建绿不等于"图能看"。这次用 playwright + chromium 真跑了一遍线上页面
（这是 #41 的直接验收标准）：

```
URL: .../enrichplot.html
load event          :   64.3 s
all images decoded  :   64.5 s   (all_loaded=True)
images              : 42/42 rendered
transferred         : 5.75 MB
       2.57 MB  image/png
       2.21 MB  image/svg+xml
```

**42/42 张图全部渲染出来**，传输 5.75 MB。

那 64.3 秒**主要是我的网络慢**（5.75 MB ÷ 64.3 s ≈ 90 KB/s，到 GitHub Pages 的国际链路），
不是浏览器渲染慢——证据是 `load` 到"所有图解码完"只差 **0.2 秒**。

### 10.3 把"传输"和"渲染"分开量（方法值得复用）

网络上量不准，所以改成**起个本地 HTTP 服务 + playwright 逐张 `img.decode()` 计时**，
彻底去掉网络变量：

| 图 | 解码 | 原始 | `<use>` |
|---|---|---|---|
| `fig-Enrichment2-1.svg` | **2145 ms** | 8.09 MB | **100,092** |
| `fig-mcnetplot-1.svg` | 996 ms | 10.52 MB | 24,189 |
| `fig-simplify-emapplot-1.svg` | 900 ms | 2.34 MB | — |
| `fig-Networkplot-1.svg` | 322 ms | 1.10 MB | 14,306 |
| `fig-goplot-1.svg` | 312 ms | 0.95 MB | 14,728 |
| `fig-Enrichment-1.svg` | 247 ms | 1.02 MB | 10,489 |
| `fig-gseaplot22-1.png`（已转 PNG） | 65 ms | — | 0 |

**新发现：`<use>` 字形爆炸，和之前修的 `<path>` 爆炸是两回事。**

`fig-Enrichment2` 里 **0 个 `<text>` 元素、100,092 个 `<use>`**，每个字符都是
`<use xlink:href="#glyph-N-M">` 引用 `<defs>` 里的字形轮廓——这是 **cairo 的 SVG 输出特性**
（把文字转成路径轮廓）。浏览器要把这 10 万个 `<use>` 逐个实例化，这才是它慢的原因。

**关键结论：解码时间和 `<use>` 数量相关，和字节数无关。**
`fig-mcnetplot` 10.52 MB 却只要 1.0 秒（24k 个 use）；`fig-Enrichment2` 只有 8.09 MB 却要 2.1 秒（100k 个 use）。
`fig-Enrichment2` 之所以是 7 倍离群值，是因为它是一张 16×18 英寸的图里塞了**四个 emapplot 面板**（2×2）。

### 10.4 决定：这两张图**不改**

`fig-Enrichment2`（2.1 s 解码）和 `fig-mcnetplot`（1.0 s）都**保持 SVG**。理由：

- 它们**能正常显示**，2.1 秒是"偏慢"不是"显示不出来"，#41 的症状（图不出来）已经解决；
- 这两个 SVG **gzip 压缩率约 10×**（`fig-Enrichment2` 8.09 MB → **0.80 MB**），
  而 PNG 不能 gzip——转成 PNG 会让**实际传输量变大**；
- emapplot 这一族之前实测过 PNG 反而更大（`fig-Enrichment` 1.01 → 1.15 MB、
  `fig-Networkplot` 1.99 → 2.36 MB）。

整站页面体重（本轮实测）：

| 页面 | 图的体积 |
|---|---|
| `enrichplot` | 22.11 MB（原 ~100.8 MB）→ gzip **4.58 MB** |
| `029-compareCluster` | 11.84 MB（其中 `fig-mcnetplot` 一张占 10.52 MB） |
| `021-go` | 2.34 MB |
| 其余 | 全部 < 0.5 MB |

### 10.5 一次差点误报（记下来）

第一次逐张量解码时，`fig-goplot-1.svg` 返回 `-1`（解码失败），看着像"有个图显示不出来"。
实际是**我把路径写错了**（写成了 `021-go_files/`，而它其实在 `enrichplot_files/`），
`-1` 是 404 不是解码失败。

**教训：报"解码失败"之前先确认路径真的存在**（`git cat-file -e` / `-f` 检查一遍），
否则会把 404 当成浏览器 bug。

### 10.6 Issue 收尾

全部回复并关闭（`--reason completed`）：

| issue | 处理 |
|---|---|
| `#41` | 回复实测数据（100.8 MB → 22 MB raw / 4.6 MB gzip，42/42 张图渲染正常）并关闭 |
| `#39` | 回复 `group_color` 用法 + `label_format` 只管 clade 标签、tip 标签要改 `@result$Description`；关闭 |
| `#30` | 回复 enrichplot 需要结果对象、`compareCluster()` 吃基因列表；关闭 |
| `#29` | 回复同上 + 解释为什么只有一套 p 值；关闭 |
| `#25` | 回复新 URL（实测 HTTP 200 / 7.98 MB / 60,877 行）与列名变更；关闭 |
| `#15` | **保持开启**——这是 enrichplot 上游 bug，余老师指示先别修；已在今天回复说明 |

**open issue 从 20 → 6 → 1**（只剩 `#15`）。

### 10.7 本轮验证清单（都是实测，不是推断）

- ✅ 线上 42/42 张图渲染（playwright + chromium）
- ✅ `fig-pmcplot-1.svg` **存在于部署产物里** → Europe PMC 成功路径在 CI 里跑通了
  （本地连不上 EBI，本来无法验证，只能靠这次 CI）
- ✅ `utilities.html` 里 Enrichr 的 6 行表正常输出 → `retry_download()` 在 CI 里生效
- ✅ `#39` 的 `treeplot-labels` 锚点、`fontsize_tiplab`/`fontsize_cladelab` 都在；
  **旧错参数 `leave_fontsize`/`clade_fontsize` 已 0 次出现**
- ✅ `#30`/`#29` 的 callout 已上线
- ✅ `#25` 新 URL 与 `cell_name` 已上线（残留的 2 处 `hrbmu.edu.cn` 是**故意保留**的
  "旧地址已失效"说明，已核对上下文）
- ✅ 本轮之前从没渲染过的章节（`PPI`/`bayesian-term-selection`/`interpretation`/`dplyr`/
  `utilities`/`FAQ`）全部部署成功、无错误文本

### 10.8 剩下的（都不阻塞）

- `#15` 的根因修复在 **enrichplot 上游**（`YuLab-SMU/enrichplot#20`、`#221`）。
  `enrichplot-pending/gseaplot2-hit-bins.patch` 已备好，等并发的 enrichplot 会话结束再合
- ~~`#| fig-scap:` 拼写（应为 `fig-alt`，书里 30+ 处，图因此没有 alt 文本，影响无障碍）~~
  → **误判，撤销，理由见 §11.1**
- ~~`022-kegg.qmd` 等处 `#| eval: false` 写在普通 ```r 代码块里，会当正文显示给读者~~
  → `022-kegg.qmd` 等已清干净；**仅 `interpretation.qmd` 剩 4 处**（第五轮已处理，见 §11.2）
- ~~GOSemSim TCSS 数值饱和~~ → **devel 里已修**（`GOSemSim-tcss-notes.md` §2）；
  本地看到饱和是因为**本地装的是 release 2.38.3**，而 CI 装的是
  `github::YuLab-SMU/GOSemSim` devel。第五轮已把本地库对齐到 devel（见 §11.3）
- `enrichplot.qmd` 末尾未提交的 "Importing results from other tools" 一节里，
  `dev_dir <- "/home/wang/data/source/..."` 是**机器专属硬编码路径**，且若干 chunk
  未做开关。本地靠 `pkgload::load_all()` 能跑，**CI 上 `import_*()` 不存在会导致构建失败**。
  第五轮已修（见 §11.4）


---

## 11. 第五轮：本地整书构建 + interpretation 真跑（2026-09-22 下午）

### 11.1 `fig-scap` 不是拼写错误 —— 上一轮的结论**推翻**

上一轮（§9.8 / §10.8）把 `#| fig-scap:` 判成 `fig-alt` 的笔误，理由"图因此没有 alt 文本"。
本轮的实测证据表明这个判断是错的：

| 证据 | 结果 |
|---|---|
| `grep -c fig-scap *.qmd` | 44 处，分布在 9 个文件（`enrichplot.qmd` 30 处） |
| **是否每处都与 `fig-cap` 同 chunk 共存？** | **44/44 全部共存**（`fig-cap` 数目恰好也是同一批 chunk） |
| 两者的文字关系 | 同义：`fig-cap: "**Bar plot of enriched terms.**"` / `fig-scap: "Bar plot of enriched terms."`；FAQ 里 `fig-cap` 是长句、`fig-scap` 是它的小标题短句 |
| 书里有没有任何 `fig-alt` | **0 处** |
| knitr 语义 | `fig.scap` 是**合法**选项（LaTeX / 图表目录用的**短标题**），HTML 输出下无效但不报错 |

**结论**：这是 bookdown 时代"长标题 + 短标题"的成对写法，不是笔误。把它改名成 `fig-alt`：

1. **会丢信息** —— 将来做 PDF 版（issue #14 正想要 PDF 渠道）短标题就没了；
2. **收益也有限** —— 生成的 alt 文本与可见 caption 逐字重复，屏幕阅读器会把 caption 和 alt 读两遍，无障碍规范反而不建议这么做。

真正想要无障碍支持，正确做法是**另写** 44 条描述性 `fig-alt`（保留 `fig-scap`），而不是改名。
余老师决定：**保持不动**，只把本条结论改正（本节即为此）。若将来要做，按 §4 的清单单独立项。

### 11.2 `interpretation.qmd`：从"全 `eval: false`"到"有 key 真跑"

原状：10 个 chunk 里 6 个是"能执行但被关掉"，4 个是**普通 ```r 代码块**（Quarto 从不执行，
里面的 `#| eval: false` 纯属摆设，还会当正文显示给读者）。另有 4 处与 issue 无关的笔误。

本轮改动（commit `e149c35`）：

1. 新增 setup chunk：`source("_common.R")`、`has_ai <- nzchar(Sys.getenv("DEEPSEEK_API_KEY"))`、
   `interpret_failed()`。
2. 两个单次调用 chunk 改为 `#| eval: !expr has_ai`：**有 key 就真跑，没 key 就跳过**。
   fork PR 拿不到 secret（GitHub 不注入），因此 PR 构建不会红。
3. **示例自给自足**：原示例 `interpret(edo)` 里的 `edo` 定义在 `enrichplot.qmd`
   （第 37/365/851 行），而 Quarto **每章一个独立 R session**，所以即使有 key 也会
   `object not found`。改为本章离线自造：`data(geneList, package="DOSE")` →
   `enrichDO(names(geneList)[abs(geneList) > 1.5])`（513 基因，不依赖网络）。
4. **防静默失败**：`interpret()` 调用失败时**不报错**，只 warning 并返回占位结果
   （`confidence == "None"`、`overview` 以 `LLM call failed` 开头），而 `_common.R` 里
   `warning = FALSE` 会把 warning 吞掉。因此在 chunk 里显式判定并 `stop()`，
   否则**坏 key 会静默出一本空报告的书、CI 还是绿的**。
   实测（假 key）：`quarto render interpretation.qmd` 失败并打印
   `interpret() returned no report -- check the API key and quota: ... 401 ...`，
   停在 `interpret-basic` chunk。
5. 默认模型改为 `deepseek:deepseek-v4-flash`；`.env` 走
   `if (file.exists(".env") && requireNamespace("dotenv", quietly=TRUE))`，不再硬依赖 dotenv。
6. 其余 4 处普通 ```r 块里的无用 `#| eval: false` 已清（§10.8 那条只剩本章，本章已处理）。

**aisdk 的环境变量名**（实测确认，别写错）：`DEEPSEEK_API_KEY`。依据是 aisdk 的 provider
spec（`api_key_env = "DEEPSEEK_API_KEY"`，默认 `https://api.deepseek.com`，默认模型
`deepseek-v4`）；用假 key 打真实端点会得到
`401 ... URL: https://api.deepseek.com/chat/completions`。
两个坑：
- `aisdk::has_api_key("deepseek")` **恒为 FALSE**（该函数是硬编码 if-else，只认
  openai/anthropic/stepfun/moonshot/kimi），**不能用它做开关**；
- RStudio 插件那套用 `AISDK_DEEPSEEK_API_KEY`，与脚本/render 用的不是同一个变量。

**CI 侧配套**（同一 commit）：workflow 的 render 步骤单独注入
`DEEPSEEK_API_KEY: ${{ secrets.DEEPSEEK_API_KEY }}`；依赖步骤补上
`github::YuLab-SMU/aisdk`（原先根本没装，`interpret()` 在 CI 里跑不起来）。
`.gitignore` 补 `.env`（原先没有，key 有被 commit 的风险）。

### 11.3 TCSS 数值饱和：devel 已修，本地看到饱和是**装错了版本**

本地 `goSim(..., measure="TCSS")` 实测仍是 `0.282 / 1 / 1`、`geneSim` = 1，看着像没修。
真因：**本地装的是 Bioconductor release `GOSemSim 2.38.3`**，而
`GOSemSim-tcss-notes.md` §2 的修复在 **devel 2.39.3**；CI 装的是
`github::YuLab-SMU/GOSemSim`（devel）。release 里连崩溃 bug 都还在。

本轮做法：把 devel 装进**独立库** `/home/wang/R/book-devel-lib`，构建时用
`R_LIBS_USER` 前置该库（`R CMD INSTALL --library=...`），
**不动 `/home/wang/R/.../4.6` 主库**，避免影响其它会话。

> 可复用的一条经验：**本地构建失败先核对包版本**（`packageVersion()` + 安装路径），
> 否则会把"本地装的是 release"误报成"书/devel 有 bug"。本轮 §11.8 的失败清单里
> 有好几条都是这个原因。

### 11.4 `enrichplot.qmd` 未提交那节的 CI 地雷（已修）

`enrichplot.qmd` 末尾那 267 行未提交的 "Importing results from other tools"：

```r
dev_dir <- "/home/wang/data/source/clusterProfiler_family/enrichplot-converters"
if (dir.exists(dev_dir)) pkgload::load_all(dev_dir, quiet = TRUE)
```

- **机器专属绝对路径** + 10 个 chunk（4 个 `*-import` + 4 个 `fig-*` + 2 个 custom）**没有开关**。
  本地靠 `load_all()` 能跑；**CI 上 `import_enrichr()` / `import_gprofiler2()` /
  `import_webgestalt()` / `import_fgsea()` 都不存在**（它们只在
  `YuLab-SMU/enrichplot` 的 `feature/converters` 分支，commit `96ba656`，
  主 devel 分支 `1.99.3` 的 NAMESPACE 里没有），一旦提交 CI 必红。

本轮改法（沿用 `has_ai` 那套模式）：

1. 路径不再硬编码：`dev_dir <- Sys.getenv("ENRICHPLOT_DEV_DIR", "../enrichplot-converters")`，
   只有目录真的存在才 `load_all()`；
2. setup chunk 里 `has_importers <- exists("import_enrichr")`；
3. 10 个 chunk 全部加 `#| eval: !expr has_importers`；
4. `.callout-note` 补一句"没有该开发版时，本节的代码仍会展示、但不会执行"。

效果：本地（converters 分支在场）照常真跑；CI 安全跳过；将来 converters 合进 enrichplot 后
**自动开始执行**，无需再改书。

### 11.5 `#15` 的上游修复**早就在 devel 里了**

`enrichplot-pending/README.md` 说"暂缓、等并发会话结束再合"，本轮核对后发现**已经合了**：

```
$ git -C enrichplot log --oneline -S "rev(9 - inv)" --all
6b153df chore: relax aplot requirement for cowplot support
$ git -C enrichplot show origin/devel:R/gseaplot.R | grep -c "rev(9 - inv)"
1
```

即 `R/gseaplot.R:584` 的 `inv <- rev(9 - inv)` 已在 `origin/devel`
（commit `6b153df`，混在另一个提交里），**但不在 `origin/master`**。
所以：

- 上游代码侧**不用再修**（本轮为此开的 worktree 是多余的，且已被并发会话清理掉）；
- **书侧仍未做**：issue #15 的原始诉求是"`gseaplot2` 红蓝矩形含义不清"，
  书里至今没有解释这个图元 —— 这才是本条真正剩下的工作（见 §11.8 待办）。

### 11.6 顺手修掉：重复的 chunk label（4 处）

`index.qmd:3,43`（`initial` / `summaryDiagram`）与 `023-other-dbs.qmd:73,84`
（`enrichwp` / `gsewp`）同时写了 ` ```{r label} ` 和 `#| label: ...`，knitr 每次构建都警告：

```
Duplicated chunk option(s) 'label' in both chunk header and pipe comments of the chunk 'pipelabel'.
```

实测（`knitr::opts_current$get("label")`）：**pipe 注释里的 label 生效，header 里的被忽略**，
警告信息点名的也是 pipe 那个。8 个候选名字在全书**没有任何交叉引用**（`@fig-*` 等均为 0），
所以直接删掉 header 里的冗余 label 最干净，且**不改变生效 label**（缓存键不变）。
已修，全书复扫 0 处。

> 注意：改 label 会影响 knitr 缓存键；这里删的是**本来就被忽略**的那一个，所以缓存不失效。

### 11.7 本地整书构建的方法（可复用）

这一步是本次能快速定位问题的基础，记下来：

1. **逐章渲染，而不是一口 `quarto render`**：`
   while read f; do quarto render "$f"; done < 章节清单`（清单从 `_quarto.yml`
   的 `chapters:` 段解析）。一次跑完拿到**完整的失败清单**，不会像整书构建那样
   在第一个错误处停住、后面章节永远没被验证过。
2. **devel 包装进独立库**：`R CMD INSTALL --library=/home/wang/R/book-devel-lib <pkg>`，
   渲染时 `R_LIBS_USER="/home/wang/R/book-devel-lib:/home/wang/R/x86_64-pc-linux-gnu-library/4.6"`。
   主库保持 release，不动其它会话。
3. **key 只在需要时注入**：`.env` 存在但 R 不会自己读；需要真跑时
   `set -a; . ./.env; set +a`，不需要时什么都不做 —— 这正好也验证了"无 key 跳过"分支。
4. **网络走代理**：本机直连 CRAN 可以（200），但 `bioconductor.org` / `zenodo.org`
   会挂住 —— `pak::pkg_install()` 曾**空转 21 分钟、CPU 只用了 1 秒**就是被它卡住的。
   按 AGENTS.md 用 `http(s)_proxy=http://127.0.0.1:7897` 重试。

### 11.8 第五轮：本地整书渲染的完整清单（25 章）

方法见 §11.7：逐章渲染 + `R_LIBS_USER` 前置 devel 库 + 按需注入 key + **选择性代理**。

**代理必须分开设（本轮最重要的环境教训）**：本机

| 目标 | 直连 | 经 127.0.0.1:7897 |
|---|---|---|
| `cloud.r-project.org` | ✅ 200（8s） | — |
| `bioconductor.org` | ❌ 挂住 | ✅ |
| `rest.kegg.jp`（KEGG） | ❌ 挂住 | ✅ 200（2s） |
| `string-db.org`（STRING/`getPPI`） | ✅ 200（1s） | ❌ 失败 |
| `zenodo.org`（msigdbr 数据） | ❌ 000 | ✅ 200 |

所以必须 `http_proxy=... no_proxy="string-db.org,localhost,127.0.0.1"`：
- 全开代理 → `PPI.qmd`/`utilities.qmd` 的 KEGG 过了，但 **STRING 挂**；
- 全不开代理 → KEGG 挂。
另外 `pak::pkg_install()` 在 bioconductor 那步**空转 21 分钟（CPU 仅 1 秒）**就是被这个卡的，
换成 `install.packages` + `BiocManager::install` 并显式走代理后正常。

**失败清单与定性（全部已解决，无一是书的逻辑错误）**：

| 章节 | 首次失败原因 | 定性 | 解决 |
|---|---|---|---|
| `index.qmd` | `library(emojifont)` 缺包 | 本地环境 | 装 `emojifont` |
| `013-meshes-semantic-similarity.qmd` | 缺 `meshes` | 本地环境 | 装 `meshes` |
| `025-do-enrichment.qmd` | `enrichNCG` → `gsid2name should have at least 2 columns` | **本地 DOSE 是 release** | 侧库装 DOSE devel |
| `027-universal-enrichment.qmd` | ① zenodo 连不上 ② 修掉后 `could not find function "msigdbr"` ③ `curl_download` 传输截断 | ①网络 ②**书的真问题** ③网络 | 见下 |
| `PPI.qmd` | `enrichKEGG` 连不上 KEGG | 本地网络 | 选择性代理 |
| `utilities.qmd` | 同上（KEGG） | 本地网络 | 选择性代理 |
| `FAQ.qmd` | 网络（Enrichr/Europe PMC 类） | 本地网络 | 代理后通过 |
| `interpretation.qmd` | 不在失败列（循环里 SKIP，单独验证） | — | 见 §11.2 |

**`027` 的第 ② 条是本轮唯一由"书"引起、且 CI 上也会咬人的问题**（值得单独记）：

```r
```{r}
#| label: msigdbr-species      <-- 没有 cache: false
library(msigdbr)
msigdbr_species()
```
... 后面三个 chunk 都写了 `#| cache: false`，但里面是**裸调用** `msigdbr(...)`
```

全局 `execute: cache: true` 下，**缓存命中时这个 chunk 的副作用（attach 包）不会发生**，
于是新会话里后面那些"不缓存"的 chunk 找不到 `msigdbr()`：
`Error: could not find function "msigdbr"`。
CI 每次都是冷缓存所以看不出来；**读者本地重跑第二次就会撞上**。
修法：给这个只负责 attach 的 chunk 加 `#| cache: false`（已在源码里写明原因）。
更一般的判据：**只做 `library()` 的 chunk 必须不缓存，或者后续 chunk 一律用 `pkg::fun()` 限定名**。

**第 ③ 条**：`msigdbr` 首次要下 44 MB 的 `msigdb.2026.1.zip`（zenodo，`timeout = 600`），
走代理时被截断（`transfer closed with 43315758 bytes remaining`）。
用 `curl -x` 手动下完整包（38s，44,335,790 bytes，**md5 与 msigdbr 期望的
`512ba99c6827141a9d471972b812d4ac` 一致**），解到 `~/.cache/R/msigdbr/` 后即通过。
纯网络问题，与书无关。

**`#15` 的收尾**（承接 §11.5）：上游已修，书里那段 callout 原本写着
"until this is fixed upstream, do not read the red/blue split as a faithful picture"，
对本书（CI 装 devel）已经是**过时且错误**的描述。已改写，并给出本轮实测：

```
40 hits / 1000-gene list：
  修复后 9 个矩形全部非空，最大一个占 15%（修复前：10 个里 1 个非空、独占 100%）
```

同时把中间色带那段的"are *meant* to divide / would then encode"（因 bug 而加的虚拟语气）
改成陈述句。并注明 **`master` 分支仍是旧序**，老版本读者不要据此读图。

### 11.9 CI 实测：`aisdk.providers` 没装 → `Provider not found: deepseek`（本轮唯一一次 CI 红）

push `e149c35` 后 run [`35692638143`](https://github.com/YuLab-SMU/biomedical-knowledge-mining-book/actions/runs/35692638143)
在 render 阶段失败（`interpretation.qmd:56-78 [interpret-basic]`）：

```
Error:
! interpret() returned no report -- check the API key and quota:
LLM call failed: Provider not found: deepseek
ℹ Available providers: openai, anthropic, gemini, custom
ℹ The 'deepseek' provider is supplied by the 'aisdk.providers' package.
  Install it with install.packages("aisdk.providers").
```

**根因**：DeepSeek 适配器**不在 `aisdk` 里**，而在独立包 **`aisdk.providers`**
（YuLab-SMU，0.1.0，CRAN 也有）。workflow 只装了 `github::YuLab-SMU/aisdk`，
于是 `set_model("deepseek:…")` 在 CI 上找不到 provider。
修法：依赖步骤补 `"github::YuLab-SMU/aisdk.providers"`。

**三条值得记住的教训**：

1. **§11.2 的 `interpret_failed()` 守卫起作用了** —— 否则这次会"渲染成功"，
   把一份写着 `LLM call failed: Provider not found: deepseek` 的报告**当正文发布上线**，
   而且 CI 是绿的。CI 日志里那一行 `Error: interpret() returned no report` 就是它抛的。
2. **本地跑通 ≠ CI 跑通**：本地 `aisdk.providers` 早就装着（`RemoteType: github`），
   所以本地两次渲染（无 key / 有 key）都过；CI 的包里没有它。
   **本地依赖集和 workflow 的安装清单必须逐项对齐**，否则这类"缺一个包"只在 CI 上现形。
3. `AISDK_DEEPSEEK_API_KEY` / `DEEPSEEK_API_KEY` 之外，还要记住 provider **适配器是独立包**这件事
   —— 文档和报错都指向同一句 `install.packages("aisdk.providers")`。

> CI 侧另外确认：`Install foundational YuLab packages`（含 aisdk）本身**是成功的**，
> 所以"aisdk 能不能在 CI 装上"这个最初的疑问已排除。

### 11.10 待决策（没擅自做）：41 处网络调用没有 `retry()`

本轮整书渲染时，`023-other-dbs.qmd:73-79 [enrichwp-example]` 撞上一次**瞬时**失败：

```
Error in `file()`: cannot open the connection to 'https://data.wikipathways.org/current/gmt/'
```

紧接着手工验证同一个调用（`yulab.utils::yread(url)`、`enrichWP(gene, "Homo sapiens")`）
**都正常**（7 个通路），确认是瞬时网络抖动，不是代码问题。

但这暴露一件事：全书目前有 **41 处**未包 `retry()` 的网络型富集调用
（`enrichWP` / `gseWP` / `enrichKEGG` / `gseKEGG` / `enrichDO` / `gseDO` …）。

- 第四轮已经确立了原则与工具：`retry()` 放在 `_common.R`，**调用点**在章节里包
  （例如 `enrichplot.qmd:1127` 的 `p <- retry(pmcplot(terms, 2010:2020))`），
  理由是"一次第三方 5xx 不该让整本书发不出去"（commit `1a16653`）。
- 但 §9.6 也明确记了"有意识**没做**的事"——所以这 41 处**要不要全包是维护者的决定**，
  本轮不擅自改（改动面大、且会改变"示例真的按原样调用"的教学语义）。

**建议**：至少把 WP / KEGG 这几处包上（它们最容易抖动，且 CI 上是真执行）。
若要保守，可以只在 `retry()` 里包、失败时 `NULL` + 页面留一句说明，保持构建能过。

### 11.11 最终结果：整书渲染通过 + 两处断链

**整书 `quarto render`（不是逐章）已通过：`EXIT=0`，806 秒**（缓存已热）。
全部 25 章都出产物，`docs/interpretation.html` 里是**真实 LLM 报告**
（例如 "Enrichment is dominated by two major themes: (1) cell cycle/DNA replication …"），
没有 `LLM call failed` 占位文本。

渲染日志里只剩两条警告，都是**真的断链**，已修：

| 文件 | 原文 | 锚点实际是 | 改为 | 复验 |
|---|---|---|---|---|
| `011-GOSemSim.qmd:14` | `[see @sec-tcss]` | `{#tcss}` | `[see @tcss]` | 重渲染 0 警告 |
| `022-kegg.qmd:278` | `(see also @sec-kegg-id-conversion)` | `{#kegg-id-conversion}` | `@kegg-id-conversion` | 重渲染 0 警告 |

Quarto 只对自动生成的 id 加 `sec-` 前缀；作者手写了 `{#tcss}` / `{#kegg-id-conversion}`，
所以引用里不该有 `sec-`。这两条在 CI 日志里也存在（源码级问题），只是没人注意。

**本轮提交**：`0ae28e5`（7 文件，+291 −15）
—— `interpretation.qmd`、`publish-book.yml`、`027-universal-enrichment.qmd`、
`index.qmd`、`023-other-dbs.qmd`、`011-GOSemSim.qmd`、`022-kegg.qmd`。

**没有提交**（避免把别人的工作混进来）：
- `enrichplot.qmd` —— 里面是**未提交的 WIP**（+267 行 "Importing results from other tools"）
  加上本轮我对其做的两处改动：(a) WIP 那节的 `ENRICHPLOT_DEV_DIR` + `has_importers` 开关（§11.4），
  (b) `gseaplot2` 那段 callout 的改写（§11.8）。
  **同一文件、不同区域**，所以整体留给维护者一起提交；`git add` 部分提交做不到干净切分。
- `.gitignore` —— 只有 `+book-issues.md` 一行，是维护者自己加的。

**复现整本书本地构建的最小命令**（devel 包在侧库、选择性代理、key 可选）：

```bash
cd biomedical-knowledge-mining-book
set -a; . ./.env; set +a                      # 想真跑 LLM 示例才需要
export R_LIBS_USER="/home/wang/R/book-devel-lib:/home/wang/R/x86_64-pc-linux-gnu-library/4.6"
export http_proxy=http://127.0.0.1:7897 https_proxy=http://127.0.0.1:7897
export no_proxy="string-db.org,localhost,127.0.0.1"   # STRING 必须直连
quarto render
```

### 11.12 第二次 CI 红：**enrichplot devel 的回归**（不是本书的问题，已定位并修好）

run [`35700834223`](https://github.com/YuLab-SMU/biomedical-knowledge-mining-book/actions/runs/35700834223)
（`aisdk.providers` 修好之后那次）又在 render 阶段失败，但**换了一个地方**：

```
24/27 [fig-mcnetplot]
Error in `-log10(p.adjust)`:
! could not find function "-"
Backtrace:
 1. ├─ggtangle::cnetplot(ck, showCategory = 3, categorySizeBy = ~-log10(p.adjust))
 2. └─enrichplot:::cnetplot.compareClusterResult(...)
 3.   └─enrichplot:::compute_comparecluster_category_size(d, category_size_quo)
 4.     └─rlang::eval_tidy(...)
Quitting from 029-compareCluster.qmd:329-351 [fig-mcnetplot]
```

**不是本书的问题，也不是我这次提交引入的**——`029-compareCluster.qmd` 我一行没动，
而且**本地用 release enrichplot 渲染它是过的**。CI 装的是
`github::YuLab-SMU/enrichplot`（默认分支 `devel`），所以这是 **devel 上的回归**：

- 元凶是当天 **`9c33a73` "fix: restore legacy cnetplot compatibility args"**
  （2026-09-22 14:15，**晚于**上一次绿的 CI run 2026-09-21 09:00）；
- 该提交为了兼容旧参数，在 `cnetplot.compareClusterResult()` 里**先重赋值再捕获**：

  ```r
  categorySizeBy <- normalize_legacy_category_size_arg(...)
  category_size_quo <- rlang::enquo(categorySizeBy)   # 此时实参已被 force
  ```

  `enquo()` 对**已被 force 的变量**返回 value-quosure，其环境是**空环境**；
  于是 `~-log10(p.adjust)` 的 RHS 在「数据掩码 + 空环境」里求值，
  **连 `-` 和 `log10` 都找不到** —— 任何公式都必挂，不只是书里这一处。

**本地复现**（`pkgload::load_all()` devel 树 + `mock_comparecluster_result()`）：

```
ggtangle::cnetplot(ck, categorySizeBy = ~-log10(p.adjust))  ERR: could not find function "-"
enrichplot::cnetplot(ck, categorySizeBy = ~-log10(p.adjust)) ERR: could not find function "-"
formula via variable f                                      ERR: could not find function "-"
inline ~log10(p.adjust)                                     ERR: could not find function "log10"
```

**修复**（按余老师要求，enrichplot 的问题**新开 worktree 独立修**）：

- worktree：`worktrees/enrichplot-cnetplot-categorysizeby`，分支 `fix/cnetplot-categorysizeby-env`，
  基于 `origin/devel`（`1182d73`）；
- 提交 **`cb93b2a`**（3 文件 +41）：`compute_comparecluster_category_size()` 里，
  当表达式是公式时**优先用公式自带的环境**（`environment(formula)`），
  而不是被 force 后已经变空的 quosure 环境；未 force 的 promise 不受影响
  （未求值的 `~...` 是 call，`environment()` 为 NULL，仍走原路径）。
- 回归测试覆盖三种情形：内联公式、在**另一个 frame 里构造**的公式（闭包变量仍要能找到）、
  以及旧参数 `categorySize`。
- **全套测试：`FAIL 0 | WARN 2 | SKIP 0 | PASS 449`**
  （2 个 WARN 是 `test-converters.R` 里本来就有的 qvalue 警告）。

**对书的验证**：把修好的 devel enrichplot 装进侧库后再渲染失败章节 ——
`029-compareCluster.qmd` **EXIT=0**，用的是 `enrichplot 1.99.13`（侧库）且确认含修复。

> `cb93b2a` **只在本地分支**，没有 push：该仓库 `make push` 会同时推 Bioconductor 上游与 GitHub，
> AGENTS.md 明确要求"没有明确指示不要推"，而且 devel 上还有别的会话在并发提交。
> **书的 CI 要变绿，得先把这个修复合进 `origin/devel`。**

### 11.13 更正 §11.11 的断链修法（我第一版修错了）

§11.11 里写的是"把引用改成 `@tcss` / `@kegg-id-conversion`"——**这是错的**，
而且那一版已经 push 出去了（`0ae28e5`）。重新渲染后发现它把
"Unable to resolve crossref" 换成了另一条警告：

```
[WARNING] Citeproc: citation tcss not found
[WARNING] Citeproc: citation kegg-id-conversion not found
```

即 Pandoc 把 `@tcss` 当成了**文献引用键**。

用最小样例实测 Quarto 的规则（`/tmp/qtest/t.qmd`）：

| 锚点写法 | 引用写法 | 结果 |
|---|---|---|
| `{#plainsection}` | `@sec-plainsection` | ⚠ Unable to resolve crossref |
| `{#sec-prefixed}` | `@sec-prefixed` | ✅ 解析为 "Section 2"（`class="quarto-xref"`） |
| 任意 | `[text](#anchor)` | ✅ 纯 markdown 链接，按**字面 id** 走 |

**结论：`sec-` 前缀要加在锚点 id 上，不是加在引用上。** 正确改法（已提交 `cfc5ed7`）：

- `{#tcss}` → `{#sec-tcss}`，引用保持 `@sec-tcss`
- `{#kegg-id-conversion}` → `{#sec-kegg-id-conversion}`，引用保持 `@sec-kegg-id-conversion`
- `utilities.qmd` 那处**纯链接** `[KEGG ID Conversion](#kegg-id-conversion)`
  跟着字面 id 改成 `(#sec-kegg-id-conversion)`

三个章节重渲染：`011-GOSemSim` / `022-kegg` / `utilities` **0 条 crossref/citation 警告**。

> 记录这条是因为"改引用还是改锚点"很容易搞反，而两种错的症状完全不同
> （一个是 unresolved crossref，一个是 citeproc citation）。

### 11.14 并发会话提醒

本轮期间 `029-compareCluster.qmd` 被**另一个会话**改了（+15 行，关于
`scale_fill_manual()` 固定配色 / `size_category` 等），`book-issues.md` 也被加了进
`.gitignore`。这些都是**别人的未提交改动**，本轮提交一律避开，没有混进来。

### 11.15 余论（同一轮稍后补）：真·冷缓存整书验证 + 一处新提交里的错

**（a）为什么之前"整书通过"还不够严谨**：前两次 `EXIT=0` 的整书渲染都是**热缓存**
（本地 `*_cache/` 从早先的会话留下来），也就是**大量 chunk 其实没真执行**。
CI 每次是**冷缓存**，所以本地热缓存通过 ≠ CI 会过。
为此新建 `worktrees/book-ci-sim`（干净检出 `cfc5ed7`，拷入 `.env`），**逐章**渲染、每章最多重试 3 次：

```
25 章：OK 25 / FAIL 0（只有 023-other-dbs 重试 1 次，WikiPathways 瞬时失败）
```

即**在干净检出 + 冷缓存 + devel 包（含修好的 enrichplot）+ 真 key 下，整本书逐章都能渲染**，
`docs/` 里 25 个页面齐全，`interpretation.html` 里是真实 LLM 报告
（"Enrichment analysis of 279 genes reveals a dual program of cell cycle/mitotic
progression and inflammatory/ECM remodeling…"），无占位文本。
其中 **`029-compareCluster.qmd` 冷缓存下 OK** —— 正是 CI 挂掉的那一章。

> 逐章渲染里会看到一些 `Unable to resolve crossref @sec-…`，那是**跨章引用**在单章渲染
> 范围外无法解析，**整书渲染时为 0**，不是问题（`@sec-bayes-enrich`、`@sec-enrichplot`、
> `@sec-id-convert`、`@sec-mutate` 等都属于这一类）。

**（b）冷缓存下唯一的失败点仍是第三方网络**：`enrichplot.qmd:688-708 [fig-Enrichment2]`
的 `compareCluster(..., enrichKEGG)` 两次全量渲染都断在 `rest.kegg.jp`
（`cannot read from connection`）。本机 KEGG 单次可达但很慢（直连 21s / 代理 8s），
而该 chunk 要发多次请求。这正对应 §11.10 记的"41 处网络调用未包 `retry()`"
——**逐章循环加上重试后同一章就过了**。CI（GitHub runner）访问 KEGG 正常。

**（c）顺手修掉一处新提交里的硬错误**：并发会话把 WIP 提交成了 `1329096 update docs`，
其中 `fig-cnet-node-edge-color` 这个新 chunk 在**冷缓存下必然报错**（我本地实测
`quarto render enrichplot.qmd` 退出码 1）：

```
Error in `scale_color_manual()`:
! Continuous value supplied to a discrete scale.
ℹ Example values: -2.54556628193772, -2.63598395197002, 3.21343469687452, ...
```

根因：`foldChange = geneList` 把**连续**的 fold change 映射到 colour 上，
再叠加**离散**的 `scale_color_manual()` 必然冲突。改为连续标度
`scale_color_gradient(low = "blue", high = "red")`，并把"该用连续标度、
离散标度会报什么错"写进正文，避免读者重犯。修后该章 `exit=0`。
提交 `e915cb3`。
