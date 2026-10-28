#import "../utils/invisible-heading.typ": invisible-heading
﻿#import "../utils/style.typ": 字号, 字体
#import "../layouts/master-preface.typ": master-header, master-footer, master-pagebreak

// 硕士研究生注释表页（主要符号表 / 缩略词表）
// 依据《西南交通大学研究生学位论文撰写范式》：
//   若论文中符号、缩略词较多，应在目录之后编排主要符号表、缩略词表；
//   标题小三号黑体居中，表内文字五号宋体。
#let master-notation(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
  // 其他参数
  title: "主要符号表",
  header-title: auto,
  outlined: false,
  title-gap: (0pt, 25.17pt),
  body,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if header-title == auto {
    header-title = title
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

  // 3.  标题（距页面顶端 24 磅）
  v(28.94pt)
  block(
    width: 100%,
    above: title-gap.at(0),
    below: title-gap.at(1),
    align(center, text(font: fonts.黑体, size: 字号.小三, title)),
  )

  // 4.  内容（通常为三线表）
  set text(font: fonts.宋体, size: 字号.五号)
  body
  metadata("swjtu-section-end")
}


