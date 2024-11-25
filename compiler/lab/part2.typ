= 实验内容及要求

#align(center)[
  #quote(block: true)[#text(fill: red)[
    每次实验的实验内容和要求描述清楚。
  ]]
]
== 词法分析器
1. 实验内容:

编写一个词法分析程序,读取文件,对文件内自定义的类 C 语言程序段进行词法分析。

2. 实验要求:

  - 输入:以文件形式存放自定义的类 C 语言程序段;
  - 输出:以文件形式存放的 TOKEN 串和简单符号表;
  - 要求:输入的 C 语言程序段包含常见的关键字,标识符,常数,运算符和分界符等
  
== 语法分析


1. 实验内容:

利用 LR(1)分析法,设计语法分析程序,对输入单词符号串进行语法分析;

2. 实验要求:

  - 输出推导过程中所用产生式序列并保存在输出文件中;
  - 较低完成要求:实验模板代码中支持变量申明、变量赋值、基本算术运算的文法;
  - 较优完成要求:自行设计文法并完成实验。
  - 要求:实验一的输出作为实验二的输入。

== 典型语句的语义分析及中间代码生成

1. 实验内容:

  - 采用实验二中的文法,为语法正确的单词串设计翻译方案,完成语法制导翻译。
  - 利用该翻译方案,对所给程序段进行分析,输出生成的中间代码序列和更新后的符号表,并保存在相应文件中。
  - 实现声明语句、简单赋值语句、算术表达式的语义分析与中间代码生成。

2. 实验要求:
  - 使用框架中的模拟器 IREmulator 验证生成的中间代码的正确性

== 目标代码生成

1. 实验内容:
  - 将实验三生成的中间代码转换为目标代码(汇编指令);
  - 运行生成的目标代码,验证结果的正确性。

2. 实验要求:

使用 RARS 运行由编译程序生成的目标代码,验证结果的正确性。

#pagebreak()