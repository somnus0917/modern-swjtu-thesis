# 西南交通大学硕士论文文献样式

`swjtu-numeric.csl` 改编自 citation-style-language/styles 的
[china-national-standard-gb-t-7714-2015-numeric.csl](https://github.com/citation-style-language/styles/blob/master/china-national-standard-gb-t-7714-2015-numeric.csl)。
原作者牛耕田，贡献者 Zeping Lee；原文件元数据日期 2024-01-22。
原作者、署名及 [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) 许可保留在 CSL 中。
该文件遵循 CC BY-SA 3.0，仓库其他自有代码的 MIT 许可不替换其许可。

本轮修改依据用户提供的学校范式 §2.9.2：将作者姓全大写改为首字母大写，
英文题名采用句首大小写，刊名和会议名采用标题大小写；保持原生引用、合并、链接及著录结构。
专有名词应在文献数据中用 BibLaTeX 的大小写保护标记（如 `{DC}`）保护。
数据中的姓名大小写、缺失字段及文献类型仍需作者核对。全大写输入姓名不会被可靠地自动改成仅首字母大写，请在文献数据中填写正确形式。

对 BibLaTeX 未识别的类型，CSL 的未知类型分支读取显式 genre 作为类型代码；标准文献可用 `@misc` + `type={S}`。其他类型仍遵循原 GB/T 分支，不按题名内容推断类型。
