// #import (if sys.inputs.at("local", default: "false") == "true" { "../lib.typ" } else { "@preview/modern-swjtu-thesis:0.2.0" }): documentclass
#import "../lib.typ": documentclass

// ============================================================
// 西南交通大学硕士学位论文模板（示例入口）
// 依据《西南交通大学研究生学位论文撰写范式》（研究生院，2024-07）
//
// 使用方法：
//   1. 修改下方 info 中的个人信息；
//   2. 按章节顺序填写正文；
//   3. 在 VS Code 中安装 Tinymist 插件后点击预览，或执行
//      typst compile --root . --input local=true template/thesis-master.typ（仓库根目录执行）
//
// 如需本科模板，请使用同目录下的 thesis.typ（doctype: "bachelor"）。
// ============================================================

// 字体说明：
// 本模板使用系统字体，请确保系统中安装了以下字体：
// - Times New Roman、Arial、Courier New（英文字体）
// - SimSun、SimHei、KaiTi、FangSong（Windows 中文字体）
// - Songti SC、Heiti SC、Kaiti SC（macOS 中文字体）
// - Noto Serif CJK SC、Noto Sans CJK SC（开源中文字体）

#let (
  // 布局函数
  twoside,
  doc,
  preface,
  mainmatter,
  appendix,
  // 页面函数
  fonts-display-page,
  cover,
  decl-page,
  abstract,
  abstract-en,
  outline-page,
  list-of-figures,
  list-of-tables,
  notation,
  acknowledgement,
  achievements,
  bilingual-bibliography,
) = documentclass(
  // 文档类型：本科生为 "bachelor"，硕士研究生为 "master"，博士为 "doctor"
  doctype: "master",
  // 学位类型："academic"（学术型）或 "professional"（专业型）
  degree: sys.inputs.at("degree", default: "academic"),
  twoside: sys.inputs.at("twoside", default: "false") == "true",
  // 盲审模式：将个人信息替换为黑色方块
  // anonymous: true,
  info: (
    // 论文题目：默认原生自动换行；仅确需指定断行时使用数组或 "\n"
    title: "基于 Typst 的西南交通大学硕士学位论文模板",
    title-en: "A Typst Template for Master Thesis of Southwest Jiaotong University",
    student-id: "2023201234",
    author: "张三",
    author-en: "Zhang San",
    department: "电气工程学院",
    department-en: "School of Electrical Engineering",
    major: "电气工程",
    major-en: "Electrical Engineering",
    supervisor: ("李四", "教授"),
    supervisor-en: "Professor Li Si",
    // 联合指导导师（可选）
    // supervisor-ii: ("王五", "副教授"),
    // supervisor-ii-en: "Professor Wang Wu",
    submit-date: datetime(year: 2025, month: 6, day: 1),
    // 封面顶部的分类号、密级等（可选，默认「公开」、单位代码 10613）
    // clc: "TP391",
    // udc: "004.9",
    // secret-level: "公开",
  ),
  // 参考文献源文件
  bibliography: bibliography.with("ref.bib"),
)

// 文稿设置（硕士模板自动使用 3 cm 页边距）
#show: doc

// 封面（中文封面 + 英文扉页）
#cover()

// 学位论文独创性声明 + 学位论文使用授权
#decl-page()

// 前置部分：页码使用大写罗马数字
#show: preface

// 中文摘要（关键词 3~8 个）
#abstract(keywords: ("学位论文", "Typst", "排版", "西南交通大学"))[
  本文研究了一种基于 Typst 的学位论文排版方法。通过对学校研究生学位论文撰写范式进行分析，设计并实现了一套符合规范的模板。实验结果表明，该模板能够稳定、高效地生成符合要求的学位论文 PDF 文件。
]

// 英文摘要
#abstract-en(keywords: ("Thesis", "Typst", "Typesetting", "Southwest Jiaotong University"))[
  This paper studies a thesis typesetting method based on Typst. By analyzing the university's thesis writing specification, a compliant template is designed and implemented. Experimental results show that the template can generate thesis PDF files that meet the requirements stably and efficiently.
]

// 目录（从第 1 章开始，列出章、节、条三级标题）
#outline-page()

// 图目录（自动收集图题、编号与页码）
#list-of-figures()

// 表目录（自动收集表题、编号与页码）
#list-of-tables()

// 主要符号表（可选，按论文实际需要启用）
#notation[
  #table(
    columns: (1fr, 3fr, 1fr),
    align: (center + horizon, left + horizon, center + horizon),
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header([符号], [意义], [单位]),
    table.hline(stroke: 1pt),
    [$S_v$], [空隙总面积], [$mu m^2$],
    [$rho$], [材料密度], [$g \/ "cm"^3$],
    [$T$], [绝对温度], [$K$],
    table.hline(stroke: 1.5pt),
  )
]

// 缩略词表（可选，按论文实际需要启用）
#notation(title: "缩略词表")[
  #table(
    columns: (1fr, 2fr, 2fr),
    align: (center + horizon, left + horizon, left + horizon),
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header([英文缩写], [英文全称], [中文全称]),
    table.hline(stroke: 1pt),
    [AUC], [Area Under the Curve], [曲线下面积],
    [PDF], [Portable Document Format], [便携式文档格式],
    table.hline(stroke: 1.5pt),
  )
]

// 正文部分：页码使用阿拉伯数字，页眉为「西南交通大学硕士学位论文」
#show: mainmatter

= 绪论

== 研究背景与意义

学位论文是研究生培养的重要成果，其排版质量直接影响论文的阅读体验与评审印象。近年来，Typst 作为一门新兴的排版语言，因其编译速度快、语法简洁而受到关注。

=== 国内外研究现状

国内外已有若干基于 Typst 的学位论文模板，为本模板的设计提供了重要参考。

== 本文主要工作

本文的主要工作包括：分析学校硕士学位论文格式规范；实现封面、声明、摘要、目录等页面；验证模板的排版效果。已有研究表明，规范的排版有助于提升论文质量 @蒋有绪1998。

// 表格示例：三线表，表题居中置于表上方。
// 标签不要带类型前缀：写成 <tab1>，引用时写 @tbl:tab1；
// 图片同理（标签 <fig1>，引用 @fig:fig1），公式同理（标签 <eq1>，引用 @eqt:eq1）。
#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    align: center + horizon,
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header([项目], [本科], [硕士]),
    table.hline(stroke: 1pt),
    [正文字号], [小四], [小四],
    [页边距], [2.6 cm], [3.0 cm],
    table.hline(stroke: 1.5pt),
  ),
  caption: [本科与硕士模板格式对比],
) <tab1>

如@tbl:tab1 所示，硕士模板在页边距等方面与本科模板存在差异。

#figure(
  box(width: 80%, grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    align: center + horizon,
    column-gutter: 6pt,
    rect(width: 100%, height: 30pt)[源文件],
    [→],
    rect(width: 100%, height: 30pt)[排版引擎],
    [→],
    rect(width: 100%, height: 30pt)[PDF],
  )),
  caption: [模板生成结果的示例图],
) <fig1>

如 @fig:fig1 所示，模板可以自动生成图表编号与目录条目。如 @eqt:eq1 所示：

$ phi.alt := (1 + sqrt(5)) / 2 $ <eq1>

= 模板功能验证

== 图表排版

本节用于验证图目录、表目录的自动收集功能。模板会为每个图表分配「章号-序号」形式的编号，并把图题、表题和页码写入对应的目录中。

#figure(
  box(width: 80%, grid(
    columns: (1fr, auto, 1fr),
    align: center + horizon,
    column-gutter: 8pt,
    rect(width: 100%, height: 30pt)[配置参数], [→], rect(width: 100%, height: 30pt)[学位论文样式],
  )),
  caption: [第二张示例图，用于验证图目录中的多条记录],
) <fig2>

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1.4fr),
    align: center + horizon,
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header([功能], [本科], [硕士], [说明]),
    table.hline(stroke: 1pt),
    [封面], [支持], [支持], [按学校 Word 范式排版],
    [图目录], [可选], [可选], [自动生成编号与页码],
    [符号表], [可选], [可选], [三线表形式],
    table.hline(stroke: 1.5pt),
  ),
  caption: [模板功能对照表],
) <tab2>

@tbl:tab2 列出了模板的主要功能，@fig:fig2 与 @tbl:tab1 均可正常交叉引用。

== 公式排版

多行公式同样会按章编号，公式主体居中、编号右对齐：

$
  a & = b + c + d \
    & = e + f + g
$ <eq2>

@eqt:eq2 展示了多行对齐的写法。

== 小结

本章验证了图表、公式、目录与交叉引用功能。

= 结论

本文实现并验证了西南交通大学硕士学位论文模板，各项格式的核验结果见项目审查报告。

// 致谢（按学校范式，致谢在参考文献之前）
#acknowledgement[
  感谢导师的悉心指导，感谢同学们的支持与帮助。
]

// 参考文献（GB/T 7714-2015 顺序编码制）
#bilingual-bibliography()

// 附录：自动编号为「附录 A」「附录 B」……
#show: appendix

= 补充材料

附录内容，包含表格 @tbl:tab-app。

#figure(
  table(
    columns: 2,
    align: center + horizon,
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header([项目], [取值]),
    table.hline(stroke: 1pt),
    [示例参数], [1.0],
    table.hline(stroke: 1.5pt),
  ),
  caption: [附录中的表格],
) <tab-app>

$ x = y + z $ <eq-app>

附录公式见 @eqt:eq-app。

// 攻读学位期间取得的研究成果
#achievements[
  一、攻读博士/硕士学位期间发表的论文及科研成果

  1\. 张三. 基于 Typst 的学位论文模板设计[J]. 某某学报, 2025.

  二、参与科研项目/科研获奖等

  1\. 参与国家自然科学基金项目“×××”（编号：×××）。
]




