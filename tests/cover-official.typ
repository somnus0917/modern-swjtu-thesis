#import "../lib.typ": documentclass
// 用相同内容比较两个封面的字形位置；en-space复现原Word题目中的半字空格。
#let cls = documentclass(doctype: "master", info: (
  title: "学\u{2002}位\u{2002}论\u{2002}文\u{2002}题\u{2002}目",
  title-en: ("Thesis Template for Master Degree of", "Engineering in", "Southwest Jiaotong University"),
  major: "", student-id: "", author: "", supervisor: (), department: "",
  major-en: "", author-en: "", supervisor-en: "", department-en: "",
  submit-date: datetime(year: 2024, month: 1, day: 8),
))
#show: cls.doc
#(cls.cover)(auto-field-width: false)
