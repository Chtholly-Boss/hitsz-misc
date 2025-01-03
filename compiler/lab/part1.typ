= 实验目的与方法

#align(center)[
  #quote(block: true)[#text(fill: red)[
    实验目的为本次实验的实验目的，方法为所使用的语言，软件环境等。
  ]]
]

实验目的：

利用 Java 实现 TXTv2 语言编译器, 包括词法分析器、语法分析器、语义分析与中间代码成器以及目标代码生成器四个组成部分,每次实验均在上一次实验的基础上进行扩展和完善。目标平台为 RISC-V32 (指令集 RV32M)。

实验方法：
- 编程语言：Java，版本为 Java17
- 开发工具：IntelliJ IDEA
- 软件环境：RARS 及编译工作台

== 词法分析器

实验目的如下：

1. 加深对词法分析程序的功能及实现方法的理解;
2. 对类 C 语言的文法描述有更深的认识,理解有穷自动机、编码表和符号表在编译的整个过程中的应用;
3. 设计并编程实现一个词法分析程序,对类 C 语言源程序段进行词法分析,加深对高级语言的认识。

== 语法分析

实验目的如下：

1. 深入了解语法分析程序实现原理及方法。
2. 理解 LR(1)分析法是严格的从左向右扫描和自底向上的语法分析方法。

== 典型语句的语义分析及中间代码生成

实验目的如下：

1. 加深对自底向上语法制导翻译技术的理解,掌握声明语句、赋值语句和算术运算语句
的翻译方法。
2. 巩固语义分析的基本功能和原理的认识,理解中间代码生成的作用。

== 目标代码生成

实验目的如下：

1. 加深编译器总体结构的理解与掌握;
2. 掌握常见的 RISC-V 指令的使用方法;
3. 理解并掌握目标代码生成算法和寄存器选择算法

#pagebreak()