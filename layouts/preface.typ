// 前言，重置页面计数器
#let preface(
  // documentclass 传入的参数
  twoside: false,
  ..args,
  it,
) = {
  // 分页
  if twoside {
    pagebreak() + " "
  }
  counter(page).update(0)
  set page(
    numbering: "I",
    header: context {
      stack(
        // 可以根据需要调整字体字号
        align(center, text(size: 10.5pt, "西南交通大学本科毕业设计(论文)")),
        v(0.25em),
        line(length: 100%, stroke: 0.5pt)
      )
    },
    footer: context {
      align(center)[
        #set text(size: 10.5pt)
        第 #counter(page).display() 页
      ]
    }
  )
  it
}