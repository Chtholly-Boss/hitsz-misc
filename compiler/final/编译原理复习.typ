#import "utils.typ": *

#set page(paper: "a4")

= 编译原理
// #set heading(numbering: "一.")
#show heading.where(level: 1): set heading(numbering: "一.")
#show heading.where(level: 2): set heading(numbering: "1.1")



#include "导论.typ"
#pagebreak()
#include "高级语言及其文法.typ"
#pagebreak()
#include "词法分析.typ"
#pagebreak()
#include "语法分析.typ"
#pagebreak()
#include "语义分析.typ"
#pagebreak()
#include "存储管理.typ"
#pagebreak()
#include "目标代码生成.typ"
#pagebreak()
#include "changelog.typ"
