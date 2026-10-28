#import "../utils/datetime-display.typ": datetime-display-day
#import "../utils/style.typ": 字体
#import "../utils/fill-field.typ": fill-field

// 课程作业封面（只有一页，无摘要/目录）
// 版式依据学校课程作业封面（Word 导出）逐项量取：
//   校名 26 pt 黑体、课程作业 22 pt 宋体、课程名称 18 pt 黑体（下划线）、
//   五个栏目 16 pt（标签不加线，填写内容加线）、日期 16 pt 居中、
//   作者签名 16 pt。
// 除课程名称与栏目填写内容外，其余文字不加下划线。
#let master-course-cover(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  title-size: 18pt,
  body-size: 16pt,
) = {
  // 0.  默认参数
  fonts = 字体 + fonts
  info = (
    (
      title: "某课程　作业 1",
      major: "某专业",
      student-id: "1234567890",
      author: "张三",
      supervisor: ("李四", "教授"),
      department: "某学院",
      submit-date: datetime.today(),
    )
      + info
  )

  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  assert(type(info.submit-date) == datetime, message: "submit-date must be datetime.")

  // 1.  辅助函数
  // 中文字形墨迹相对 block 顶端的偏移（与硕士封面同一套实测值）
  let cjk-dy(y, size) = y * 1pt + 0.109 * size
  let put(x, y, body) = place(top + left, dx: x * 1pt, dy: y, body)

  // 2.  封面
  pagebreak(weak: true)
  set page(margin: 0pt, header: none, footer: none, numbering: none)
  set text(font: fonts.宋体, top-edge: 0.75em, bottom-edge: -0.25em)

  // 2.1 校名（Word：x=186.8，y=160.4，26 pt SimHei，无下划线）
  put(0, cjk-dy(160.4, 26pt), block(width: 595.3pt, align(center,
    text(font: fonts.黑体, size: 26pt, weight: "bold", stroke: 0.015em + 0.25pt)[
      西#h(13pt)南#h(13pt)交#h(13pt)通#h(13pt)大#h(13pt)学
    ])))

  // 2.2 课程作业（Word：x=236.9，y=201.5，22 pt SimSun，无下划线）
  put(0, cjk-dy(201.5, 22pt), block(width: 595.3pt, align(center,
    text(font: fonts.宋体, size: 22pt, weight: "bold", stroke: 0.015em + 0.25pt)[
      课#h(11pt)程#h(11pt)作#h(11pt)业
    ])))

  // 2.3 课程名称 + 作业号（Word：y=312.7，18 pt SimHei，下划线 191.9–403.5）
  put(73.7, cjk-dy(312.7, title-size), context {
    let title = block(width: 448pt, {
      set text(font: fonts.黑体, size: title-size)
      set par(leading: 31pt - title-size, spacing: 0pt, first-line-indent: 0pt)
      align(center, if info.title.join("").trim() == "" {
        fill-field("", size: title-size, font: fonts.黑体)
      } else {
        underline(evade: false, offset: 2.64pt, stroke: 0.96pt, info.title.join("\n"))
      })
    })
    assert(measure(title).height <= 90pt, message: "课程名称超过三行，不能覆盖填写栏。")
    title
  })

  // 2.4 五个栏目（Word：标签 x=175.7、值 x=319.6、下划线 271.8–431.7）
  let label-slot(label) = {
    set align(left)
    let chars = label.clusters()
    grid(columns: range(chars.len() - 1).map(_ => 1fr) + (auto,), ..chars)
  }
  put(0, cjk-dy(415.1, body-size), context {
    set text(size: body-size)
    set par(first-line-indent: 0pt, leading: 31.2pt - body-size, spacing: 0pt)
    let labels = ("学科专业", "学号", "作者姓名", "指导老师", "学院")
    let values = (info.major, info.student-id, info.author, info.supervisor.join("、"), info.department)
    let natural-width = calc.max(..values.map(v => measure(
      box(text(font: fonts.宋体, size: body-size, v)), width: 10000pt,
    ).width)) + 16pt
    let width = calc.min(calc.max(natural-width, 159.98pt), 425.2pt - 96.02pt)
    let cells = labels.zip(values).map(((label, value)) => (
      label-slot(label), fill-field(value, size: body-size, font: fonts.宋体),
    )).flatten()
    let fields = block(width: 96.02pt + width, grid(
      columns: (96.02pt, width), column-gutter: 0pt,
      row-gutter: 31.2pt - body-size, ..cells,
    ))
    assert(measure(fields).height <= 180pt,
      message: "课程封面填写栏总高度超过可用区域，请精简字段或使用规范简称。")
    block(width: 595.3pt, align(center, fields))
  })

  // 2.5 日期（Word：y=617.4，16 pt，居中，无下划线）
  put(0, cjk-dy(617.4, body-size), block(width: 595.3pt, align(center,
    text(size: body-size, datetime-display-day(info.submit-date)),
  )))

  // 2.6 作者签名（Word：x=345.8，y=680.4，16 pt，无下划线）
  put(345.8, cjk-dy(680.4, 16pt), text(size: 16pt, [作者签名：]))
}
