#import "../lib.typ": documentclass
#let cls = documentclass(doctype: "master")
#show: cls.doc
#show: cls.mainmatter
= 章标题
== 连续二级
正文甲。

== 非连续二级
正文乙。

=== 非连续三级
正文丙。

== 连续组二级
=== 连续组三级
==== 连续组四级
正文丁。

独立段落甲。

独立段落乙。
