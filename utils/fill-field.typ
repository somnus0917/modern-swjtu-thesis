// 原生段落负责中英文断行；按实测行盒高度为每一行画完整填写线。
// 空值保留一行。不缩小字号，不依赖空格或特定示例的字符数。
#let fill-field(value, size: 16pt, font: "SimSun", stroke: 0.7pt, line-height: 31.2pt,
                offset: 2pt, alignment: center) = layout(area => {
  set text(font: font, size: size, top-edge: 0.75em, bottom-edge: -0.25em)
  set par(leading: line-height - size, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set align(alignment)
  let body = block(width: area.width, value)
  let height = calc.max(size, measure(body).height)
  let lines = int(calc.max(1, calc.round((height - size) / line-height) + 1))
  block(width: area.width, height: height, breakable: false, {
    for i in range(lines) {
      place(top + left, dy: 0.75 * size + offset + i * line-height,
            line(length: area.width, stroke: stroke))
    }
    body
  })
})
