#import "../pages/master-course-cover.typ": master-course-cover
#let mode = sys.inputs.at("mode", default: "normal")
#let info = if mode == "empty" { (
  title: "", major: "", student-id: "", author: "", supervisor: (), department: "",
) } else { (
  title: if mode == "long" { "轨道交通供电系统中的电力电子变换器建模分析与控制方法课程作业" } else { "电力电子技术课程作业" },
  major: if mode == "overflow" { "超长专业名称" * 30 } else if mode == "long" {
    "电气工程与轨道交通供电技术及电力电子系统控制"
  } else { "电气工程" },
  student-id: "202610752", author: "测试作者", supervisor: ("测试导师",),
  department: if mode == "long" { "电气工程与轨道交通研究学院" } else { "电气工程学院" },
) }
#master-course-cover(
  fonts: (宋体: ("Times New Roman", "SimSun"), 黑体: ("Times New Roman", "SimHei")),
  info: info + (submit-date: datetime(year: 2026, month: 6, day: 1)),
)
