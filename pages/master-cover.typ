#import "../utils/datetime-display.typ": datetime-display, datetime-en-display
#import "../utils/style.typ": 字号, 字体
#import "../utils/fill-field.typ": fill-field
#import "../layouts/master-preface.typ": master-pagebreak

// 硕士研究生封面（中文封面 + 英文扉页）
// 按 Word 原版 PDF 的文字基线和填写线锚点布局：
//   - 中文封面：分类号/密级/单位代码、校名、学位类别、加下划线的题目、五个栏目、日期；
//   - 英文扉页：提交说明、英文题目、Discipline 等栏目、日期。
// 坐标单位为 pt，原点为纸张左上角（封面页页边距为 0）。
#let master-cover(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  nl-cover: false,
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  underline-stroke: 0.6pt,
  title-size: 18pt,
  auto-field-width: true,
  major-label: "学科专业",
  anonymous-info-keys: ("student-id", "author", "supervisor", "supervisor-ii", "author-en", "supervisor-en"),
  datetime-display: date => str(date.year()) + " 年 " + str(date.month()) + " 月 " + str(date.day()) + " 日",
  datetime-en-display: datetime-en-display,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "西南交通大学硕士学位论文"),
    title-en: "A Thesis Template for Southwest Jiaotong University",
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    author-en: "Zhang San",
    department: "某学院",
    department-en: "School of XXX",
    major: "某专业",
    major-en: "XXX",
    supervisor: ("李四", "教授"),
    supervisor-en: "Professor Li Si",
    supervisor-ii: (),
    supervisor-ii-en: "",
    clc: "",
    udc: "",
    secret-level: "公开",
    school-code: "10613",
    submit-date: datetime.today(),
  ) + info

  // 2.  对参数进行处理
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }
  assert(type(info.submit-date) == datetime, message: "submit-date must be datetime.")
  if info.at("degree", default: auto) == auto {
    info.degree = if doctype == "doctor" { "工学博士" } else { "工学硕士" }
  }

  // 3.  内部辅助函数
  let hide(key) = anonymous and (key in anonymous-info-keys)
  let put(x, y, body) = place(top + left, dx: x * 1pt, dy: y * 1pt, body)
  let hline(x, y, width, stroke: underline-stroke) = put(x, y, line(length: width * 1pt, stroke: stroke))

  // 4.  中文封面
  master-pagebreak(twoside: twoside)
  set page(margin: 0pt, header: none, footer: none, numbering: none)
  set text(font: fonts.宋体, top-edge: 0.75em, bottom-edge: -0.25em)

  // 4.1 顶部分类号、密级、单位代码（12 pt 宋体）
  put(73.7, 79.11, text(size: 12pt, "中国图书分类号"))
  put(397.8, 79.11, text(size: 12pt, "密级"))
  put(73.7, 102.51, text(size: 12pt, "国际图书分类号"))
  put(397.8, 102.51, text(size: 12pt, "单位代码"))

  hline(157.7, 89.4, 90)
  hline(421.8, 89.4, 100)
  hline(157.7, 112.8, 90)
  hline(457.8, 112.8, 64)

  if info.clc != "" {
    put(157.7, 79.11, block(width: 90pt, align(center, text(size: 12pt, info.clc))))
  }
  if info.udc != "" {
    put(157.7, 102.51, block(width: 90pt, align(center, text(size: 12pt, info.udc))))
  }
  if info.secret-level != "" {
    put(421.8, 79.11, block(width: 100pt, align(center, text(size: 12pt, info.secret-level))))
  }
  put(457.8, 102.51, block(width: 64pt, align(center, text(size: 12pt, info.school-code))))

  // 4.2 校名与学位类别
  put(0, 210.04, block(width: 595.3pt, align(center, text(font: fonts.黑体, size: 26pt, weight: "bold", stroke: 0.015em + 0.25pt)[
    西#h(13pt)南#h(13pt)交#h(13pt)通#h(13pt)大#h(13pt)学
  ])))
  put(0, 250.71, block(width: 595.3pt, align(center, text(font: fonts.宋体, size: 22pt, weight: "bold", stroke: 0.015em + 0.25pt)[
    硕#h(11pt)士#h(11pt)学#h(11pt)位#h(11pt)论#h(11pt)文
  ])))

  // 4.3 题目使用原生断行和统一偏移的下划线，自动换行不再错配线条。
  put(73.7, 361.43, context {
    let title = block(width: 448pt, {
      set par(leading: 31pt - title-size, first-line-indent: 0pt, spacing: 0pt)
      set text(font: fonts.黑体, size: title-size)
      show regex("[A-Za-z0-9]+"): set text(font: "Times New Roman", weight: "bold")
      align(center, if info.title.join("").trim() == "" {
        fill-field("", size: title-size, font: fonts.黑体, stroke: underline-stroke)
      } else {
        underline(evade: false, offset: 2.64pt, stroke: 0.96pt, info.title.join("\n"))
      })
    })
    assert(measure(title).height <= 90pt,
      message: "中文封面题目超过三行，请精简题目或显式调整 title-size；不能覆盖个人信息栏。")
    title
  })

  // 4.4 固定标签栏、原生可换行内容栏。所有行（包括空栏）均保留填写线。
  let value(key, body) = if hide(key) { "" } else { body }
  let label-slot(label) = {
    set align(left)
    let chars = label.clusters()
    if chars.len() in (2, 4) {
      // 行内 box 中的 fr 空白没有拉开字距。使用原生 grid 的等分列，
      // 将末字右边缘固定在填写线起点，二字与四字标签保持同宽。
      grid(columns: range(chars.len() - 1).map(_ => 1fr) + (auto,), ..chars)
    } else { label }
  }
  put(0, 463.63, context {
    set text(size: 16pt)
    set par(first-line-indent: 0pt, leading: 15.2pt, spacing: 0pt)
    let values = (value("major", info.major), value("student-id", info.student-id),
      value("author", info.author), value("supervisor", info.supervisor.join(" ")),
      value("department", info.department))
    let natural-width = calc.max(..values.map(v => measure(
      box(text(font: fonts.宋体, size: 16pt, v)), width: 10000pt,
    ).width)) + 16pt
    let width = if auto-field-width {
      calc.min(calc.max(natural-width, 159.98pt), 425.2pt - 96.02pt)
    } else { 159.98pt }
    let fields = block(width: 96.02pt + width, grid(
      columns: (96.02pt, width), column-gutter: 0pt, row-gutter: 15.2pt,
      label-slot(major-label), fill-field(value("major", info.major), font: fonts.宋体),
      label-slot("学号"), fill-field(value("student-id", info.student-id), font: fonts.宋体),
      label-slot("作者姓名"), fill-field(value("author", info.author), font: fonts.宋体),
      label-slot("指导老师"), fill-field(value("supervisor", info.supervisor.join(" ")), font: fonts.宋体),
      label-slot("学院"), fill-field(value("department", info.department), font: fonts.宋体),
    ))
    assert(measure(fields).height <= 220pt,
      message: "中文封面填写栏总高度超过可用区域，请精简字段或使用规范简称。")
    if auto-field-width { block(width: 595.3pt, align(center, fields)) }
    else { block(width: 595.3pt, pad(left: 175.73pt, fields)) }
  })

  // 4.5 日期
  put(0, 713.26, block(width: 595.3pt, align(center, text(size: 16pt, datetime-display(info.submit-date)))))

  // 5.  英文扉页
  master-pagebreak(twoside: twoside)

  put(0, 105.56, block(width: 595.3pt, align(center, text(font: "Times New Roman", size: 14pt, weight: "bold", "A Thesis Submitted to"))))
  put(0, 136.76, block(width: 595.3pt, align(center, text(font: "Times New Roman", size: 14pt, weight: "bold", "Southwest Jiaotong University for Master Degree"))))

  put(85.1, 235.04, context {
    let title = block(width: 425.2pt, align(center, {
      set par(leading: 9.2pt)
      text(font: "Times New Roman", size: 22pt, weight: "bold", info.title-en.join("\n"))
    }))
    assert(measure(title).height <= 180pt, message: "英文扉页题目过长，不能覆盖个人信息栏。")
    title
  })

  // 英文扉页按 Word 批注要求：放不下时加行，显示每行下框线。
  put(0, 455.83, context {
    set text(font: "Times New Roman", size: 16pt)
    set par(first-line-indent: 0pt, leading: 15.2pt, spacing: 0pt)
    let make-fields(width) = grid(
      columns: (73.4pt, width), column-gutter: 8pt, row-gutter: 15.2pt,
      align(right, [Discipline]), fill-field(value("major-en", info.major-en), font: "Times New Roman"),
      align(right, [Student ID]), fill-field(value("student-id", info.student-id), font: "Times New Roman"),
      align(right, [Author]), fill-field(value("author-en", info.author-en), font: "Times New Roman"),
      align(right, [Supervisor]), fill-field(value("supervisor-en", info.supervisor-en + if info.supervisor-ii-en != "" { ", " + info.supervisor-ii-en } else { "" }), font: "Times New Roman"),
      align(right, [School]), fill-field(value("department-en", info.department-en), font: "Times New Roman"),
    )
    // 由实际填写内容测量统一栏宽。最少160pt，最长内容两侧各留8pt；
    // 整个标签/内容组合在页面居中，达到3cm页边距后才原生换行。
    let values = (
      value("major-en", info.major-en), value("student-id", info.student-id),
      value("author-en", info.author-en),
      value("supervisor-en", info.supervisor-en + if info.supervisor-ii-en != "" { ", " + info.supervisor-ii-en } else { "" }),
      value("department-en", info.department-en),
    )
    let natural-width = calc.max(..values.map(v => measure(
      box(text(font: "Times New Roman", size: 16pt, v)), width: 10000pt,
    ).width)) + 16pt
    let width = if auto-field-width {
      calc.min(calc.max(natural-width, 160pt), 425.2pt - 81.4pt)
    } else { 160pt }
    let fields = block(width: 81.4pt + width, make-fields(width))
    assert(measure(fields).height <= 235pt,
      message: "英文扉页填写栏总高度超过可用区域，请精简字段或使用规范简称。")
    if auto-field-width { block(width: 595.3pt, align(center, fields)) }
    else { block(width: 595.3pt, pad(left: 164.8pt, fields)) }
  })

  put(0, 728.86, block(width: 595.3pt, align(center, text(font: "Times New Roman", size: 16pt, datetime-en-display(info.submit-date)))))
}









