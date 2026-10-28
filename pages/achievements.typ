#import "../utils/style.typ": 字号, 字体

// 攻读学位期间取得的研究成果页（硕士、博士通用）
// 依据《西南交通大学研究生学位论文撰写范式》：
//   标题按一级标题排版；内容采用五号宋体，段前段后均为 0 磅。
// 说明：Word 范式中该页正文实际按 Normal 样式（行距 20 磅、首行缩进 2 字符）排版，
//   与页内说明文字「行距 16 磅」不一致，这里按实际渲染效果取 20 磅。
#let achievements(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
  // 其他参数
  title: "攻读博士/硕士学位期间取得的研究成果",
  body-size: auto,
  // 可选的填写说明（范式中的说明文字，正式论文可删除）
  note: none,
  body,
) = {
  pagebreak(weak: true)
  [
    #heading(level: 1, numbering: none, outlined: true, title) <no-auto-pagebreak>

    #{
      // 注意：set 规则不能放在 if 内（作用域只限 if 块），这里先算好字号再无条件设置
      let size = if body-size == auto { 字号.小四 } else { body-size }
      set text(font: fonts.宋体, size: size)
      set par(
        leading: 20pt - size,
        spacing: if body-size == auto { 0pt } else { 20pt - size },
        first-line-indent: (amount: 2em, all: true),
      )
      v(8pt)
      if note != none {
        note
        parbreak()
      }
      body
    }
  ]
}


