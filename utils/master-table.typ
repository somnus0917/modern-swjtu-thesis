#import "../utils/style.typ": 字体

// 原生 table 负责分页；零高度 figure 锚点放在首个数据单元格内，
// 防止表格移至下一页后，目录页码仍指向前一页。
#let master-table(columns: 2, header: (), caption: [], key: none,
                  fonts: (:), cell-align: center + horizon, continued: "续", ..cells) = {
  assert(type(key) == label, message: "thesis-table 必须提供唯一 key: <标签>，引用时用 @tbl:标签。")
  assert(cells.pos().len() > 0, message: "thesis-table 至少需要一个数据单元格。")
  let fonts = 字体 + fonts
  set text(font: fonts.宋体, size: 10.5pt, top-edge: 0.75em, bottom-edge: -0.25em)
  set par(first-line-indent: 0pt, leading: 0.3em, spacing: 0pt)
  let count = if type(columns) == array { columns.len() } else { columns }
  let reference = label("tbl:" + str(key))
  let anchor = {
    show figure.caption: caption => []
    show figure: set block(above: 0pt, below: 0pt)
    set figure(gap: 0pt)
    let element = figure([], kind: table, caption: caption)
    [#element #key]
  }
  let title = context {
    let matches = query(reference)
    if matches.len() > 0 {
      let parent = matches.first()
      let prefix = if here().page() > parent.location().page() { continued } else { "" }
      let content = [#prefix#parent.supplement#numbering(parent.numbering, ..parent.counter.at(parent.location()))#h(1em)#caption]
      block(below: 6pt, above: 0pt, layout(area => {
        if measure(content).width > area.width {
          pad(x: 4em, { set align(left); set par(justify: true); content })
        } else { align(center, content) }
      }))
    }
  }
  let data = cells.pos()
  let first = data.first()
  if type(first) == content and first.func() == table.cell {
    let fields = first.fields()
    let content = fields.remove("body")
    data.at(0) = table.cell([#place(top + left, anchor)#content], ..fields)
  } else {
    data.at(0) = [#place(top + left, anchor)#first]
  }
  block(above: 12pt, below: 6pt, breakable: true,
    table(
      columns: columns, align: cell-align, stroke: none, inset: (x: 5pt, y: 3pt),
      table.header(
        table.cell(colspan: count, title),
        table.hline(stroke: 1.5pt),
        ..header,
        table.hline(stroke: 1pt),
      ),
      ..data,
      table.footer(table.hline(stroke: 1.5pt)),
    ),
  )
}
