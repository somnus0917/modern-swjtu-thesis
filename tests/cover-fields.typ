#import "../lib.typ": documentclass
#let overflow = sys.inputs.at("overflow", default: "false") == "true"
#let cls = documentclass(doctype: "master", info: (
  title: "", title-en: "", major: "", major-en: "", author: "", author-en: "",
  student-id: "", department: "", department-en: "", supervisor: (), supervisor-en: "",
))
#show: cls.doc
#(cls.cover)()
#(cls.cover)(info: (
  title: "面向轨道交通系统的双向直流变换器与多端口能量管理控制方法研究",
  title-en: "Bidirectional DC Converters and Multiport Energy Management for Railway Systems",
  major: "电气工程与轨道交通供电技术",
  department: if overflow { "超长学院名称" * 50 } else { "电气工程与轨道交通研究学院" },
  major-en: "Electrical Engineering and Railway Power Supply",
  department-en: "School of Electrical Engineering and Railway Power Systems",
))
