#import "../utils/style.typ": 字号, 字体

// 原生奇偶分页插入的页面不显示页眉页脚。
#let master-is-blank() = {
  let physical = here().page()
  query(metadata.where(value: "swjtu-break-after")).any(next => {
    let previous = query(selector(metadata.where(value: "swjtu-boundary")).before(next.location()))
    (previous.len() > 0 and physical > previous.last().location().page()
      and physical < next.location().page())
  })
}

// ============================================================
// 硕士研究生学位论文的页面基础设置
// 依据《西南交通大学研究生学位论文撰写范式》（2024-07 版）
//   - A4 纸，上、下、左、右边距均为 3.0 cm，页眉、页脚距边界 2.0 cm
//   - 页眉：五号宋体居中，单横线 0.75 磅
//   - 页码：小五号 Times New Roman 居中，数字两侧不加修饰线
//   - 从中文摘要开始行距固定值 20 磅
// ============================================================

// 页眉：按规范说明采用五号宋体与 0.75 磅线，不沿用示例的 9pt/0.8pt。
#let master-header(
  title,
  fonts: (:),
  size: 字号.五号,
  stroke-width: 0.75pt,
  gap: 2.625pt,
) = context {
  let fonts = 字体 + fonts
  set align(center)
  if not master-is-blank() { stack(
    text(font: fonts.宋体, size: size, top-edge: 0.75em, bottom-edge: -0.25em, title),
    v(gap),
    line(length: 100%, stroke: stroke-width + black),
  ) }
}

// 页脚：小五号 Times New Roman 居中，仅显示页码
#let master-footer(numbering: "1", fonts: (:)) = context {
  let fonts = 字体 + fonts
  if not master-is-blank() {
    align(center, text(font: "Times New Roman", size: 字号.小五,
      top-edge: 0.75em, bottom-edge: -0.25em, counter(page).display(numbering)))
  }
}

// 分页到下一部分。
// 前置部分的空白背页不计入罗马页码；正文空白页计入连续页序。
#let master-pagebreak(twoside: false, count-blank: false) = {
  metadata("swjtu-boundary")
  pagebreak(weak: true, to: if twoside { "odd" } else { none })
  metadata("swjtu-break-after")
  if twoside and not count-blank {
    context {
      let ends = query(selector(metadata.where(value: "swjtu-section-end")).before(here()))
      let boundary = if ends.len() > 0 { ends.last() } else {
        query(selector(metadata.where(value: "swjtu-boundary")).before(here())).last()
      }
      let skipped = calc.max(0, here().page() - boundary.location().page() - 1)
      counter(page).update(n => n - skipped)
    }
  }
}

// 前置部分：页码使用大写罗马数字，页眉由各页自行设置
#let master-preface(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
  ..args,
  it,
) = {
  // 0.  默认参数
  fonts = 字体 + fonts

  // 1.  分页到前置部分第一页（双面模式下从奇数页开始）
  master-pagebreak(twoside: twoside)

  // 2.  将当前页设为第 I 页
  counter(page).update(1)

  // 3.  各部分自行设置页眉与罗马页脚，作用域间的空白背页不打印页码。
  set page(
    numbering: none,
    header: none,
    footer: none,
    margin: 3cm,
  )
  it
}
