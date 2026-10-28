#import "@preview/i-figured:0.2.4"
#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-numbering.typ": custom-numbering
#import "../utils/custom-heading.typ": heading-display, active-heading, current-heading
#import "../utils/unpairs.typ": unpairs

#let mainmatter(
  // documentclass 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  leading: 1.5 * 15.6pt - 0.7em,
  spacing: 1.5 * 15.6pt - 0.7em,
  justify: true,
  first-line-indent: (amount: 2em, all: true),
  numbering: custom-numbering.with(first-level: "第1章 ", depth: 4, "1.1 "),
  // 正文字体与字号参数
  text-args: auto,
  // 标题字体与字号
  heading-font: auto,
  heading-size: (字号.小二, 字号.小三, 字号.四号, 字号.小四),
  heading-weight: ("regular", "regular", "regular", "regular"),
  heading-above: (2 * 15.6pt - 0.7em, 2 * 15.6pt - 0.7em),
  heading-below: (2 * 15.6pt - 0.7em, 1.5 * 15.6pt - 0.7em),
  heading-pagebreak: (true, false),
  heading-align: (center, auto),
  // 一级标题距页面上边距的额外距离（Typst 会丢弃页首的块间距，故用显式 v 补足）
  heading-top-space: 0pt,
  // 页眉
  header-render: auto,
  header-vspace: 0em,
  display-header: false,
  skip-on-first-level: true,
  stroke-width: 0.8mm,
  // 是否在章标题处自动分页，并（双面模式下）确保章首页位于奇数页
  // 单页页眉文字，auto 时使用本科毕业设计（论文）的页眉
  header-text: auto,
  header-font: auto,
  header-size: auto,
  header-stroke: 0.8mm,
  // 页脚样式："prefix" 为「第 X 页」，"plain" 为纯页码
  footer-style: "prefix",
  footer-size: auto,
  // 页眉、页脚相对内容区的距离（none 表示使用 Typst 默认值）
  page-header-ascent: none,
  page-footer-descent: none,
  // 正文开始前若当前页为偶数页，是否插入空白页（双面打印用）
  blank-page-before: true,
  reset-footnote: true,
  // caption 的 separator
  separator: " ",
  // caption 样式
  caption-style: strong,
  caption-size: 字号.五号,
  // 图表整体段前段后距，以及图表与图题之间的间距（硕士用 12 / 12 / 6）
  figure-above: auto,
  figure-below: auto,
  figure-gap: 0.65em,
  // figure 计数
  show-figure: i-figured.show-figure.with(numbering: "1-1"),
  // equation 计数
  show-equation: i-figured.show-equation.with(
    numbering: (..nums) => text(font: ("Times New Roman", "Songti SC", "STSong"))[（#numbering("1-1", ..nums)）],
  ),
  ..args,
  it,
) = {
  // 0.  标志前言结束
  set page(numbering: "1")

  // 1.  默认参数
  fonts = 字体 + fonts
  if text-args == auto {
    text-args = (font: fonts.宋体, size: 字号.小四)
  }
  // 1.1 字体与字号
  if heading-font == auto {
    heading-font = (fonts.黑体,)
  }
  // 1.2 页眉页脚默认参数
  if header-text == auto {
    header-text = "西南交通大学本科毕业设计（论文）"
  }
  if header-font == auto {
    header-font = fonts.黑体
  }
  if header-size == auto {
    header-size = 字号.小四
  }
  if footer-size == auto {
    footer-size = 字号.小四
  }
  // 1.3 处理 heading- 开头的其他参数
  let heading-text-args-lists = args.named().pairs()
    .filter((pair) => pair.at(0).starts-with("heading-"))
    .map((pair) => (pair.at(0).slice("heading-".len()), pair.at(1)))

  // 2.  辅助函数
  let array-at(arr, pos) = {
    arr.at(calc.min(pos, arr.len()) - 1)
  }

  // 3.  设置基本样式
  // 3.1 文本和段落样式
  set text(..text-args)
  set par(
    leading: leading,
    justify: justify,
    first-line-indent: first-line-indent,
    spacing: spacing,
  )
  show raw: set text(font: fonts.等宽)
  // 3.2 脚注样式
  show footnote.entry: set text(font: fonts.宋体, size: 字号.五号)
  // 3.3 设置 figure 的编号
  show heading: i-figured.reset-counters
  show figure: show-figure
  // 3.4 设置 equation 的编号和假段落首行缩进
  show math.equation.where(block: true): show-equation
  // 3.5 表格表头置顶 + 不用冒号用空格分割 + 样式
  show figure.where(
    kind: table
  ): set figure.caption(position: top)
  set figure.caption(separator: separator)
  show figure.caption: caption-style
  show figure.caption: set text(font: fonts.宋体, size: 字号.五号)
  // 3.5.1 图表与图题的段间距：表题在表上方，图题在图下方
  set figure(gap: figure-gap)
  show figure: set block(above: figure-above, below: figure-below)
  // 3.6 优化列表显示
  //     术语列表 terms 不应该缩进
  show terms: set par(first-line-indent: 0pt)

  // 4.  处理标题
  // 4.1 设置标题的 Numbering
  set heading(numbering: numbering)
  // 4.2 设置字体字号并加入假段落模拟首行缩进
  show heading: it => {
    let weight = array-at(heading-weight, it.level)
    set text(
      font: array-at(heading-font, it.level),
      size: array-at(heading-size, it.level),
      weight: weight,
      // 中文字体没有真正的粗体字面，用描边模拟 Word 的合成加粗
      stroke: if weight == "bold" { 0.015em + 0.25pt } else { none },
      ..unpairs(heading-text-args-lists
        .map((pair) => (pair.at(0), array-at(pair.at(1), it.level))))
    )
    set block(
      above: array-at(heading-above, it.level),
      below: array-at(heading-below, it.level),
    )
    it
  }
  // 4.3 标题居中与自动换页
  show heading: it => {
    if array-at(heading-pagebreak, it.level) {
      // 如果打上了 no-auto-pagebreak 标签，则不自动换页
      if "label" not in it.fields() or str(it.label) != "no-auto-pagebreak" {
        pagebreak(weak: true)
      }
    }
    if it.level == 1 and heading-top-space != 0pt {
      v(heading-top-space)
    }
    if array-at(heading-align, it.level) != auto {
      set align(array-at(heading-align, it.level))
      it
    } else {
      it
    }
  }

  // 5.  处理页眉页脚
  set page(
    header: context {
      // 重置 footnote 计数器
      if reset-footnote {
        counter(footnote).update(0)
      }
      if display-header {
        let loc = here()
        // 5.1 获取当前页面的一级标题
        let cur-heading = current-heading(level: 1)
        // 5.2 如果当前页面没有一级标题，则渲染页眉
        if not skip-on-first-level or cur-heading == none {
          if header-render == auto {
            // 一级标题和二级标题
            let first-level-heading = if not twoside or calc.rem(loc.page(), 2) == 0 { heading-display(active-heading(level: 1)) } else { "" }
            let second-level-heading = if not twoside or calc.rem(loc.page(), 2) == 1 { heading-display(active-heading(level: 2, prev: false)) } else { "" }
            set text(font: fonts.楷体, size: 字号.五号)
            stack(
              first-level-heading + h(1fr) + second-level-heading,
              v(0.25em),
              if first-level-heading != "" or second-level-heading != "" { line(length: 100%, stroke: stroke-width + black) },
            )
          } else {
            header-render(loc)
          }
          v(header-vspace)
        }
      } else {
        stack(
          align(center, text(font: header-font, size: header-size, header-text)),
          v(0.25em),
          line(length: 100%, stroke: header-stroke + black),
        )
      }
    },
    footer: context {
      align(center, if footer-style == "plain" {
        text(font: fonts.宋体, size: footer-size, counter(page).display())
      } else {
        text(font: fonts.宋体, size: footer-size)[第#counter(page).display()页]
      })
    },
    ..(if page-header-ascent != none { (header-ascent: page-header-ascent) } else { (:) }),
    ..(if page-footer-descent != none { (footer-descent: page-footer-descent) } else { (:) }),
  )
  if blank-page-before {
    context {
      if calc.even(here().page()) {
        page(header: none, footer: none)[]
      }
    }
  }
  counter(page).update(1)

  it
}





