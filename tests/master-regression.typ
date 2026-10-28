#import "../lib.typ": documentclass
#let twoside = sys.inputs.at("twoside", default: "false") == "true"
#let degree = sys.inputs.at("degree", default: "academic")
#let optional = sys.inputs.at("optional", default: "all")
#let empty = sys.inputs.at("empty", default: "false") == "true"
#let long = sys.inputs.at("long", default: "false") == "true"
#let many = int(sys.inputs.at("many", default: "0"))
#let anonymous = sys.inputs.at("anonymous", default: "false") == "true"
#let cls = documentclass(doctype: "master", degree: degree, twoside: twoside,
  anonymous: anonymous,
  bibliography: bibliography.with("../template/ref.bib"),
  info: (
    title: if long { "面向轨道交通牵引供电系统的多端口双向直流变换器控制策略及其稳定性分析" }
      else { "双向直流变换器控制策略研究" },
    title-en: "Control Strategies for Bidirectional DC Converters in Railway Power Systems",
    author: "测试作者", author-en: "Test Author", student-id: "2026000001",
    major: if degree == "professional" { "某专业（某方向）" } else { "某专业" },
    major-en: "Electrical Engineering",
    department: if long { "某学科与某技术研究及工程应用学院" } else { "某学院" },
    department-en: "School of Electrical Engineering and Railway Power Systems",
    submit-date: datetime(year: 2026, month: 6, day: 1),
  ))
#show: cls.doc
#(cls.cover)()
#(cls.decl-page)()
#show: cls.preface
#(cls.abstract)(keywords: ("双向变换器", "稳定性", "轨道交通"))[
  第一段用于测量正文基线。测试模板在不同配置下的分页、编号及字体。

  第二段用于测量段落间距。正文与独立段落之间应保持二十磅基线间距。
]
#(cls.abstract-en)(keywords: ("Bidirectional Converter", "Stability", "Railway"))[
  This regression fixture checks pagination, numbering and fonts.

  A second paragraph checks the distance between paragraph baselines.
]
#(cls.outline-page)()
#(cls.list-of-figures)(enabled: optional == "all")
#(cls.list-of-tables)(enabled: optional != "none")
#if optional == "all" {
  (cls.notation)[#table(columns: 2, [符号], [含义], [$V$], [电压])]
  (cls.notation)(title: "缩略词表")[#table(columns: 2, [缩写], [含义], [DAB], [双有源桥])]
}
#show: cls.mainmatter
= #if long { [面向轨道交通牵引供电系统的多端口双向直流变换器控制策略与稳定性分析方法及实验研究] } else { [控制原理] }
== 连续标题
=== 第三级标题
==== 第四级标题
正文首段用于验证连续标题不会孤立在页面底部。这是第一条脚注#footnote[本页第一条脚注，应从圈码一开始。]。

第二段含有 Mixed English 123、斜体 #emph[Italic ABC] 与加粗 #strong[加粗测试 Bold 456]。
再增加脚注#footnote[本页第二条脚注，应使用圈码二。]。

文献引用为 @蒋有绪1998，另见文献 #(cls.cite-inline)(<蒋有绪1998>)。

多文献合并引用：@蒋有绪1998 @中国力学学会1990 @WHO1970 @张志祥1998。

#if not empty {
  [图示见 @fig:control，表格见 @tbl:values，公式见 @eqt:power。]
  [#figure(rect(width: 60%, height: 60pt, [控制系统示意]), caption: [控制原理图，用于验证较长图题自动换行并在左右各缩进四个汉字后两端对齐的排版效果，包含 English 123]) <control>]
  [#figure(table(columns: 2, [参数], [取值], [$V$], [100 V]), caption: [参数取值表，用于验证较长表题自动换行且始终位于表格上方并与表格保持在同一页面的排版效果]) <values>]
}
$ P &= V I \
    &= U^2 / R $ <power>

== 固定行距测量
第一行文本用于检查二十磅基线距离。
第二行文本用于检查二十磅基线距离。
第三行文本用于检查二十磅基线距离。
第四行文本用于检查二十磅基线距离。

独立段落也应保持二十磅基线距离。

#if not empty {
  [长表见 @tbl:long。]
  [#(cls.thesis-table)(columns: (1fr, 3fr, 2fr), key: <long>,
    header: ([序号], [参数或工况], [取值]),
    caption: [用于验证跨页自动续表重复表头和连续编号的较长表格标题，包含中文与 English 123],
    ..range(80).map(i => (str(i+1), [工况 #i：稳态与动态控制], [#(i*10) V])).flatten(),
  )]
}

= 编号重置
正文应从新纸正面开始。下一页脚注重新从圈码一开始#footnote[新页脚注编号重置。]。
#if not empty {
  [#figure(rect(width: 50%, height: 40pt), caption: [第二章图]) <second>]
  [回引 @fig:control；本章图为 @fig:second；长表仍为 @tbl:long。]
}
$ x = y + z $ <second-eq>
本章公式见 @eqt:second-eq。

#for i in range(many) {
  figure(rect(width: 20%, height: 8pt), caption: [批量图序号 #i])
}

#(cls.acknowledgement)[感谢为本测试提供帮助的人员。]
#(cls.bilingual-bibliography)(full: true)
#show: cls.appendix
= 附录内容
附录的图表与公式按字母编号。
#if not empty {
  [#figure(table(columns: 2, [参数], [数值], [a], [1]), caption: [附录表]) <appendix-table>]
}
$ a = b + c $ <appendix-eq>
附录公式见 @eqt:appendix-eq。

= 第二份补充材料
第二个附录应重新开始图表及公式计数。
#if not empty {
  [#figure(table(columns: 2, [参数], [数值], [b], [2]), caption: [第二附录表]) <appendix-b>]
  [附录表见 @tbl:appendix-b。]
}
$ d = e + f $ <appendix-b-eq>
第二附录公式见 @eqt:appendix-b-eq。
#(cls.achievements)[
  第一条成果，测试五号字和十六磅行距。

  第二条成果，测试独立段落间距。
]
