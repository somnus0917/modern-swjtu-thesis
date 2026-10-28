#import "../utils/invisible-heading.typ": invisible-heading
﻿#import "../utils/style.typ": 字号, 字体
#import "../layouts/master-preface.typ": master-header, master-footer, master-pagebreak

// 硕士研究生英文摘要页（ABSTRACT）
// 依据《西南交通大学研究生学位论文撰写范式》：
//   标题 ABSTRACT 小三号 Times New Roman 加粗居中，段前 24 磅、段后 18 磅；
//   正文小四号 Times New Roman，固定行距 20 磅，首行缩进 2 字符，两端对齐；
//   关键词与摘要正文之间空一行，顶格书写，用逗号隔开。
#let master-abstract-en(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  title: "ABSTRACT",
  header-title: "ABSTRACT",
  outlined: false,
  keyword-gap: 20pt,
  body,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title-en: "A Thesis Template for Southwest Jiaotong University",
    author-en: "Zhang San",
    major-en: "XXX",
    supervisor-en: "Professor Li Si",
  ) + info

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

  // 3.  正文样式
  // 英文标点也必须使用西文字体，不能被 CJK 标点覆盖范围送入宋体。
  let en-font = ("Times New Roman",) + if type(fonts.宋体) == array { fonts.宋体 } else { (fonts.宋体,) }
  set text(font: en-font, size: 字号.小四, top-edge: 0.75em, bottom-edge: -0.25em)
  set par(leading: 8pt, spacing: 8pt, justify: true, first-line-indent: (amount: 2em, all: true))

  // 4.  标题（与 Word 原版墨迹位置对齐）
  v(26.44pt)
  block(
    width: 100%,
    above: 0pt,
    below: 25.67pt,
    align(center, text(font: "Times New Roman", size: 字号.小三, weight: "bold", title)),
  )

  // 5.  摘要正文
  body

  // 标签列按实际字宽测量，续行与第一行关键词内容对齐。
  if keywords.len() > 0 {
    v(keyword-gap)
    block(width: 100%, above: 0pt, below: 0pt, {
      set par(first-line-indent: 0pt, leading: 8pt, spacing: 0pt, justify: true)
      grid(columns: (auto, 1fr), column-gutter: 0.4em,
        text(weight: "bold", [Keywords:]), keywords.join(", "))
    })
  }
  metadata("swjtu-section-end")
}




