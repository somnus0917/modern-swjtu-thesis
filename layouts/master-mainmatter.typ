#import "@preview/i-figured:0.2.4"
#import "../utils/style.typ": 字体, 字号
#import "master-preface.typ": master-pagebreak, master-header, master-footer
#import "../utils/custom-numbering.typ": custom-numbering
#let format-number = numbering

// 独立于本科正文规则。表 2-2 的明确要求优先于 Word 的预置样式。
#let master-mainmatter(
  twoside: false,
  fonts: (:),
  header-text: "西南交通大学硕士学位论文",
  header-size: 字号.五号,
  show-header: true,
  numbering: custom-numbering.with(first-level: "第1章", depth: 4, "1.1"),
  heading-size: (16pt, 14pt, 14pt, 12pt),
  heading-above: (24pt, 18pt, 12pt, 12pt),
  heading-below: (18pt, 6pt, 6pt, 6pt),
  math-font: "Cambria Math",
  it,
) = {
  fonts = 字体 + fonts
  master-pagebreak(twoside: twoside, count-blank: true)
  counter(page).update(1)
  set page(
    margin: 3cm, numbering: none,
    header: if show-header { master-header(header-text, fonts: fonts, size: header-size) } else { none },
    footer: master-footer(fonts: fonts),
    header-ascent: 7.4pt, footer-descent: 0pt,
  )
  set text(font: fonts.宋体, size: 12pt, top-edge: 15.6pt, bottom-edge: -4.4pt,
           cjk-latin-spacing: none, overhang: false)
  set par(leading: 0pt, spacing: 0pt, justify: true,
          first-line-indent: (amount: 2em, all: true))
  show raw: set text(font: fonts.等宽)
  show terms: set par(first-line-indent: 0pt)
  show strong: emphasis => {
    set text(weight: "bold")
    show regex("\\p{sc=Hani}+"): set text(stroke: 0.015em + 0.25pt)
    emphasis.body
  }
  show par: paragraph => [#metadata("swjtu-body-par")#paragraph]
  set heading(numbering: numbering)
  show heading: node => context {
    let index = calc.min(node.level, 4) - 1
    let previous = query(selector(heading).before(node.location(), inclusive: false))
    let consecutive = previous.len() > 0 and query(
      selector(metadata.where(value: "swjtu-body-par")).after(previous.last().location()).before(node.location())
    ).len() == 0
    if node.level == 1 {
      master-pagebreak(twoside: twoside, count-blank: true)
      i-figured.reset-counters(node, return-orig-heading: false)
      v(24pt)
    }
    set text(font: fonts.黑体, size: heading-size.at(index), weight: "regular", stroke: none,
             top-edge: 16pt, bottom-edge: -4pt)
    // 黑体标题中的拉丁字母及编号使用真正的 Times New Roman Bold。
    show regex("[A-Za-z0-9]+(?:[.-][A-Za-z0-9]+)*"): set text(font: "Times New Roman", weight: "bold")
    set par(first-line-indent: 0pt, leading: 0pt, spacing: 0pt,
            justify: false)
    show par: paragraph => paragraph
    set block(above: if node.level == 1 or consecutive { 0pt } else { heading-above.at(index) },
              below: heading-below.at(index), sticky: true)
    set align(if node.level == 1 { center } else { left })
    let prefix = if node.numbering == none { none } else {
      format-number(node.numbering, ..counter(heading).at(node.location()))
    }
    block(if prefix == none { node.body } else if node.level == 1 {
      [#prefix#h(1em)#node.body]
    } else {
      grid(columns: (auto, 1fr), column-gutter: 1em, prefix, node.body)
    })
  }

  show figure: i-figured.show-figure.with(numbering: "1-1")
  show figure.where(kind: table): set figure.caption(position: top)
  set figure(gap: 6pt)
  show figure: set block(above: 12pt, below: 6pt)
  show figure: set text(font: fonts.宋体, size: 10.5pt, top-edge: 0.75em, bottom-edge: -0.25em)
  show figure: set par(first-line-indent: 0pt, leading: 0.3em, spacing: 0pt)
  show figure.caption: caption => context {
    set text(font: fonts.宋体, size: 10.5pt, top-edge: 0.75em, bottom-edge: -0.25em)
    set par(first-line-indent: 0pt, leading: 0.3em, spacing: 0pt)
    let content = [#caption.supplement#caption.counter.display(caption.numbering)#h(1em)#caption.body]
    layout(size => {
      if measure(content).width > size.width {
        pad(x: 4em, { set align(left); set par(justify: true); content })
      } else { align(center, content) }
    })
  }
  show math.equation: set text(font: math-font)
  show math.equation.where(block: true): set block(above: 6pt, below: 6pt)
  show math.equation.where(block: true): i-figured.show-equation.with(
    numbering: (..nums) => text(font: "Times New Roman")[(#format-number("1-1", ..nums))],
  )

  // 脚注编号在同一物理页内从①开始，避免在页眉中修改全局计数器。
  set footnote(numbering: n => context {
    let previous = query(footnote).filter(note => note.location().page() < here().page()).len()
    format-number("①", n - previous)
  })
  show footnote.entry: entry => context {
    let note = entry.note
    let notes = query(footnote).filter(n => n.location().page() == note.location().page())
    let index = notes.position(n => n.location() == note.location())
    set text(font: fonts.宋体, size: 9pt, top-edge: 0.75em, bottom-edge: -0.25em)
    set par(first-line-indent: 0pt, hanging-indent: 1.5em, leading: 0.3em, justify: true)
    [#format-number("①", index + 1)#h(0.5em)#note.body]
  }
  it
}
