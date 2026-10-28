#import "../utils/style.typ": 字号, 字体
#import "../utils/invisible-heading.typ": invisible-heading
#import "../layouts/master-preface.typ": master-header, master-footer, master-pagebreak

// 硕士研究生目录页
// 依据《西南交通大学研究生学位论文撰写范式》：
//   目录从「第 1 章」开始，列出章、节、条三级标题及起始页码；
//   目录标题小三号黑体居中，条目小四号宋体，页码用 Times New Roman。
#let master-outline-page(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
  // 其他参数
  depth: 3,
  title: "目　录",
  header-title: "目 录",
  outlined: false,
  title-gap: (0pt, 28.97pt),
  font: auto,
  size: 字号.小四,
  reference-size: 字号.小四,
  indent: (0pt, 20.4pt, 43.2pt, 43.2pt),
  above: (0pt, 0pt, 0pt),
  below: (8pt, 8pt, 8pt),
  gap: 0.3em,
  ..args,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if font == auto {
    font = fonts.宋体
  }

  // 2.  分页与页眉页脚
  master-pagebreak(twoside: twoside)
  set page(
    margin: 3cm,
    header-ascent: 7.4pt,
    footer-descent: 0pt,
    header: master-header(header-title, fonts: fonts),
    footer: master-footer(numbering: "I", fonts: fonts),
  )

  if outlined { invisible-heading(level: 1, title) }

  // 3.  目录标题（距页面顶端 24 磅，与 Word 原版对齐）
  v(28.94pt)
  block(
    width: 100%,
    above: title-gap.at(0),
    below: title-gap.at(1),
    align(center, text(font: fonts.黑体, size: 字号.小三, title)),
  )

  // 4.  目录条目样式（Word 原版行距 20 磅）
  set text(font: font, size: size, top-edge: 0.75em, bottom-edge: -0.25em, cjk-latin-spacing: none)
  set par(leading: 8pt, spacing: 0pt)
  show link: set text(fill: black)
  show outline.entry: entry => {
    let idx = calc.min(entry.level, indent.len()) - 1
    let level-indent = indent.at(idx)
    // 一级条目中文用黑体，其余用宋体；数字与英文用 Times New Roman
    let level-font = if entry.level == 1 {
      ("Times New Roman",) + fonts.黑体
    } else {
      ("Times New Roman",) + fonts.宋体
    }
    block(
      above: above.at(calc.min(entry.level, above.len()) - 1),
      below: below.at(calc.min(entry.level, below.len()) - 1),
      link(
        entry.element.location(),
        pad(left: level-indent, entry.indented(
          none,
          {
            set text(font: level-font, size: size)
            if entry.prefix() not in (none, []) {
              entry.prefix()
              h(gap)
            }
            entry.body()
            box(width: 1fr, inset: (x: .25em), repeat([·], gap: 0.05em))
            text(font: fonts.宋体, size: reference-size, entry.page())
          },
          gap: 0pt,
        )),
      ),
    )
  }

  // 5.  渲染目录
  outline(title: none, depth: depth, indent: 0pt)
  metadata("swjtu-section-end")
}





