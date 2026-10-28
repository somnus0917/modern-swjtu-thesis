#import "../utils/style.typ": 字号, 字体
#import "../layouts/master-preface.typ": master-pagebreak

// 硕士研究生声明页：学位论文独创性声明 + 学位论文使用授权
// 逐项按 Word 原版 PDF 的墨迹坐标复刻（A4，页边距 3 cm）。
#let master-decl-page(
  anonymous: false,
  twoside: false,
  fonts: (:),
  // 其他参数
  title-size: 字号.三号,
  body-size: 字号.小四,
  innovation-points: none,
  // 正式电子版可传两张已签字扫描页（独创性声明、授权书），原样排为 A4。
  scans: (),
) = {
  // 0.  默认参数
  fonts = 字体 + fonts
  if scans.len() > 0 {
    assert(scans.len() == 2, message: "scans 必须按独创性声明、使用授权顺序提供两张图片。")
    for scan in scans {
      master-pagebreak(twoside: twoside)
      page(margin: 0pt, header: none, footer: none, numbering: none, {
        set image(width: 100%, height: 100%, fit: "contain")
        if type(scan) == content { scan } else { image(scan) }
      })
    }
    return
  }

  // 复选框：强制用中文字体渲染，避免拉丁字体（Times New Roman）里的窄方框
  let cjk-font = if type(fonts.宋体) == array { fonts.宋体.slice(1) } else { (fonts.宋体,) }
  let checkbox = text(font: cjk-font, "□")

  // 正文墨迹顶端到 block 顶端的补偿（12 pt 宋体实测 1.31 pt）
  let body-dy = 1.31pt
  let body-top(ink-y) = (ink-y - 85) * 1pt + body-dy
  let title-top(ink-y) = (ink-y - 85) * 1pt + 1.73pt
  let at(x, y, body) = place(top + left, dx: (x - 85.1) * 1pt, dy: y, body)

  let decl-title(ink-y, content) = place(
    center + top,
    dy: title-top(ink-y),
    text(font: fonts.黑体, size: title-size, weight: "bold", stroke: 0.015em + 0.25pt, content),
  )

  let body-text(ink-y, content) = at(85.1, body-top(ink-y), {
    block(width: 15cm, {
      set par(first-line-indent: 0pt)
      h(2em)
      content
    })
  })

  // 1.  学位论文独创性声明
  master-pagebreak(twoside: twoside)
  set page(margin: 3cm, header: none, footer: none, numbering: none)
  set text(font: fonts.宋体, size: body-size, top-edge: 0.75em, bottom-edge: -0.25em)
  // Word 原版声明页正文使用 1.5 倍行距（行距约 23.3 磅）
  set par(leading: 11.3pt, spacing: 0pt, justify: true, first-line-indent: 0pt)

  decl-title(87.5, "西南交通大学")
  decl-title(111.4, "学位论文独创性声明")

  body-text(161.8)[
    本人郑重声明：所呈交的学位论文是本人在导师指导下进行的研究工作及取得的研究成果。据我所知，除了文中特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写过的研究成果，也不包含为获得西南交通大学或其它教育机构的学位或证书而使用过的材料。其他人员对本研究所做的任何贡献均已在论文中作了明确的说明并表示谢意。
  ]

  body-text(284.5)[本学位论文的主要创新点如下：]
  if innovation-points != none {
    at(85.1, body-top(308), context {
      let content = block(width: 15cm, innovation-points)
      assert(measure(content).height <= 180pt, message: "创新点内容超出声明页预留区域。")
      content
    })
  }

  place(top + left, dx: 240.1pt, dy: body-top(519.3), text(size: 12pt, [作者签名：]))
  // 签名下划线（与 Word 原版 385.2–481.2 pt 一致）
  place(top + left, dx: 300.1pt, dy: 446pt, line(length: 96pt, stroke: 0.5pt))
  place(top + left, dx: 246.1pt, dy: body-top(560.6), text(size: 12pt, [日期：#h(3em)年#h(2em)月#h(1.5em)日]))

  // 2.  学位论文使用授权
  master-pagebreak(twoside: twoside)

  decl-title(87.5, "西南交通大学")
  decl-title(111.4, "学位论文使用授权")

  body-text(155.8)[
    本学位论文作者完全了解西南交通大学有关保留、使用学位论文的规定，同意学校有权保留并向国家有关部门或机构送交论文的复印件和电子版，允许论文被查阅。本人授权西南交通大学可以将学位论文的全部或部分内容编入有关数据库进行检索及下载，可以采用影印、缩印、扫描等复制手段保存、汇编本学位论文。
  ]

  body-text(267.2)[本学位论文属于]
  // 「保密□，在 ___ 年解密」：Word 中这里只有 3 个半角空格（18 pt），没有下划线
  body-text(290.1)[1．保密#checkbox，在#h(1.5em)年解密后适用本授权书；]
  body-text(313.5)[2．不保密#checkbox，使用本授权书。]
  body-text(337.1)[（请在以上方框内打“√”）]

  place(top + left, dx: 24.1pt, dy: body-top(378.5), text(size: 12pt, [作者签名：]))
  place(top + left, dx: 233.9pt, dy: body-top(378.5), text(size: 12pt, [导师签名：]))
  // 两处签名下划线（Word 原版：169.1–300.4、379.1–510.4 pt）
  place(top + left, dx: 84pt, dy: 305.2pt, line(length: 131.3pt, stroke: 0.5pt))
  place(top + left, dx: 294pt, dy: 305.2pt, line(length: 131.3pt, stroke: 0.5pt))

  // 日期：Word 为「日期：」+ 5 个空格 + 年 + 3 个空格 + 月 + 3 个空格 + 日（无下划线）
  place(top + left, dx: 239.2pt, dy: body-top(413.8), text(size: 12pt, [日期：#h(2.5em)年#h(1.5em)月#h(1.5em)日]))
}






