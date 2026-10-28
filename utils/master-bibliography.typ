#import "../utils/style.typ": 字体
#let bibliography-element = bibliography

#let content-text(node) = {
  if type(node) == str { node }
  else if type(node) != content { "" }
  else if node.has("text") { node.text }
  else if node.has("children") { node.children.map(content-text).join("") }
  else if node.has("body") { content-text(node.body) }
  else if node.has("child") { content-text(node.child) }
  else { "" }
}

// 保留原生 CSL 输出中的链接、强调和字符格式，不把文献转为纯字符串。
#let master-bibliography(bibliography: none, fonts: (:), title: "参考文献", full: false,
                         style: "../styles/swjtu-numeric.csl") = {
  assert(bibliography != none, message: "请传入带 source 的 bibliography 函数。")
  let fonts = 字体 + fonts
  show bibliography-element: set text(font: fonts.宋体, size: 10.5pt,
                             top-edge: 0.75em, bottom-edge: -0.25em)
  show bibliography-element: set par(leading: 9.5pt, spacing: 9.5pt, justify: true,
                            first-line-indent: 0pt)
  show bibliography-element: body => {
    // Typst 0.15.1 在底层直接布局文献 grid，跳过 show grid。
    // 编号栏宽 1.85em + 原生栏间距 0.65em = 2.5em 悬挂缩进。
    show grid.cell: set grid.cell(breakable: false)
    show grid.cell.where(x: 0): cell => box(width: 1.85em, cell.body)
    show grid.cell.where(x: 1): cell => {
      // CSL-M 多布局不被 Typst 支持。只检查责任者段，不用题名推断语言，
      // 且只替换 et-al 术语，不把正文、链接或强调转成纯字符串。
      let root = if cell.body.has("body") { cell.body.body } else { cell.body }
      let authors = content-text(if root.has("children") { root.children.at(0, default: []) } else { root })
      let western = authors.contains(regex("[A-Za-z]")) and not authors.replace("等", "").contains(regex("\\p{sc=Hani}"))
      let content = if western {
        show ", 等": ", et al"
        cell.body
      } else { cell.body }
      block(breakable: false, content)
    }
    show grid.cell: set par(leading: 9.5pt, spacing: 0pt, first-line-indent: 0pt)
    body
  }
  bibliography(title: title, full: full, style: style)
}
