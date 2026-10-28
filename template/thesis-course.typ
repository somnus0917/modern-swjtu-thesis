// 仓库内开发：typst compile --input local=true …… 时用本地源码 ../lib.typ；
// 普通使用（含 typst init 生成的项目）：从已发布包 @preview/modern-swjtu-thesis 加载。
// 编辑器对条件导入的红色波浪线是 Tinymist 的静态检查误报，不影响编译。
// #import (if sys.inputs.at("local", default: "false") == "true" { "../lib.typ" } else { "@preview/modern-swjtu-thesis:0.2.0" }): documentclass

#import "../lib.typ": documentclass

// ============================================================
// 西南交通大学课程作业模板（示例入口）
//
// 与硕士论文模板共用同一套正文版式（3 cm 页边距、小四宋体、20 磅行距、
// 章-节-条标题、图表/公式/参考文献），但只保留课程作业封面：
// 没有摘要、目录、图目录、附录、成果页，页眉也关闭，只保留页脚页码。
//
// 使用方法：
//   1. 修改下方 info 中的课程名称、作业号与个人信息；
//   2. 按章节填写正文；
//   3. 执行 typst compile thesis-course.typ
// ============================================================

#let (
  doc,
  cover,
  mainmatter,
  bilingual-bibliography,
) = documentclass(
  doctype: "course",
  fonts: (
    宋体: ("Times New Roman", "SimSun", "Songti SC", "Noto Serif CJK SC", "STSong"),
    黑体: ("Arial", "SimHei", "Heiti SC", "Noto Sans CJK SC", "STHeiti"),
    楷体: ("Times New Roman", "KaiTi", "Kaiti SC", "Noto Serif CJK SC", "STKaiti"),
    仿宋: ("Times New Roman", "FangSong", "STFangsong"),
    等宽: ("Courier New", "Menlo", "IBM Plex Mono"),
  ),
  info: (
    // 课程名称 + 作业号，显示在封面「课程作业」下方
    title: "某课程　作业 1",
    major: "某专业",
    student-id: "2026000001",
    author: "张三",
    supervisor: ("李四",),
    department: "某学院",
    submit-date: datetime(year: 2026, month: 6, day: 1),
  ),
  bibliography: bibliography.with("ref.bib"),
)

#show: doc
#cover()

// 正文：章节编号、字体、行距与硕士论文一致；无页眉，页脚为页码
#show: mainmatter

= 作业要求与方案

== 题目要求

本作业要求分析 Buck 变换器在连续导通模式下的稳态特性，并给出仿真验证。设计要求如下：

- 输入电压 48 V，输出电压 24 V；
- 开关频率 100 kHz，电感电流纹波小于额定值的 20%；
- 负载电流 2 A，输出电压纹波小于 1%。

== 设计思路

采用状态空间平均法建立 Buck 变换器的稳态模型 @蒋有绪1998，占空比 $D$ 由输入输出电压比决定：

$ D = V_o / V_(i n) = 24 / 48 = 0.5 $ <duty>

电感取值按电流纹波要求计算，结果如 @tbl:param 所示。

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    align: center + horizon,
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header([参数], [符号], [取值]),
    table.hline(stroke: 1pt),
    [占空比], [$D$], [0.5],
    [电感], [$L$], [300 µH],
    [输出电容], [$C$], [220 µF],
    table.hline(stroke: 1.5pt),
  ),
  caption: [Buck 变换器主要参数],
) <param>

= 仿真与结果分析

== 仿真模型

在 Simulink 中搭建闭环仿真模型，主电路如 @fig:circuit 所示。

#figure(
  image("images/fig-sample.png", width: 70%),
  caption: [Buck 变换器仿真波形],
) <circuit>

== 结果分析

仿真得到的输出电压稳定在 24 V，纹波约 0.4%，满足设计要求。占空比计算结果与 @eqt:duty 一致，参数见 @tbl:param。

#bilingual-bibliography()




