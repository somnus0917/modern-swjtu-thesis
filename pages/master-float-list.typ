#import "../utils/style.typ": 字体
#import "../layouts/master-preface.typ": master-header, master-footer, master-pagebreak

// i-figured 转换后的真实 figure 元素仍由 Typst 自动收集、定位和链接。
#let master-float-list(kind, title: "图目录", twoside: false, fonts: (:), enabled: true,
                       show-empty: false) = context {
  let target = figure.where(kind: "i-figured-" + repr(kind))
  if enabled and (show-empty or query(target).filter(f => f.outlined).len() > 0) {
    let fonts = 字体 + fonts
    master-pagebreak(twoside: twoside)
    set page(margin: 3cm, header-ascent: 7.4pt, footer-descent: 0pt,
             header: master-header(title, fonts: fonts),
             footer: master-footer(numbering: "I", fonts: fonts))
    set text(font: fonts.宋体, size: 12pt, top-edge: 0.75em, bottom-edge: -0.25em)
    set par(first-line-indent: 0pt, leading: 8pt, spacing: 8pt)
    v(24pt)
    block(width: 100%, below: 18pt, align(center, text(font: fonts.黑体, size: 15pt, title)))
    show outline.entry: set block(above: 0pt, below: 8pt)
    outline(title: none, target: target)
    metadata("swjtu-section-end")
  }
}
