#import "../lib.typ": documentclass
#let cls = documentclass(doctype: "master", bibliography: bibliography.with("reference-format.bib"))
#show: cls.doc
#show: cls.mainmatter
= 引用格式测试
普通上标引用 @english；作为句子成分的平排引用 #(cls.cite-inline)(<english>)。

重复及多篇合并引用 @english @chinese @standard。
#(cls.bilingual-bibliography)()
