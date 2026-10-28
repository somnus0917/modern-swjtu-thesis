// 显示中文日期（不补零，例如「2025 年 6 月」）
#let datetime-display(date) = {
  str(date.year()) + " 年 " + str(date.month()) + " 月"
}

// 显示英文日期（例如「Jun. 1, 2025」）
#let datetime-en-display(date) = {
  let months = (
    "Jan.", "Feb.", "Mar.", "Apr.", "May", "Jun.",
    "Jul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec.",
  )
  months.at(date.month() - 1) + " " + str(date.day()) + ", " + str(date.year())
}
// 显示中文日期（带日，例如「2025 年 6 月 1 日」），用于课程作业封面
#let datetime-display-day(date) = {
  str(date.year()) + " 年 " + str(date.month()) + " 月 " + str(date.day()) + " 日"
}
