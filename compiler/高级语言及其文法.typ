#import "utils.typ":*

#let all_production = $#sym.forall #sym.alpha #to #sym.beta #sym.in P$
= 高级语言及其文法
本部分主要对应教材 Chapter 2, 并涵盖了 Chapter 5 引入的相关文法概念。

由于大部分概念在 《形式语言与自动机》 课程中已有介绍，本部分仅包含往年题/作业题中考察频次较高的概念。

#def[
文法是一个四元组 $G = (V, T, P, S)$:
- V: Variable 变量/非终结符
- T: Terminal 终结符集合
- P: Production 产生式集合
- S: Start Symbol 开始符号
] 

== 文法的分类
本部分对应教材 Chapter 2.4

通过对产生式的约束，乔姆斯基将文法分为四种类型：0、1、2、3 型文法。

- 0 型文法：无限制文法，即任意产生式
- 1 型文法：上下文相关文法，即产生式右部的符号数量不小于左部，形式化定义为 
  - #all_production 均有 $|#sym.beta| #sym.gt.eq |#sym.alpha|$
- 2型文法：上下文无关文法，即在上下文相关文法的基础上，进一步约束产生式左部仅可为一个变量，形式化定义为
  - #all_production 均有 $#sym.alpha #sym.in V$
- 3型文法：正则文法，即在上下文无关文法的基础上，进一步约束产生式右部仅可包含一个非终结符，且所有产生式均为同一线性形式，形式化定义为
  - #all_production 均有 $A #to w | w B$ （右线性）
  - #all_production 均有 $A #to w | B w$ （左线性）

#ex([
  - (2023 深圳) 乔姆斯基把文法分为四种类型:0、1、2、3 型文法。其中 3 型文法是 #ans("正则文法")
])

== 文法的相关概念
本部分通过题目的方式进行概念整理。

#ex[
  - (2023 深圳）句子一定是句型,但句型不一定是句子。 #ans[(F)]

  句型即推导过程中出现的任意形式，可以含非终结符；句子只包含终结符。  

  - (2023 深圳) 规范规约是 #ans([最左归约])

  教材原文：对句型按照从左到右进行分析是比较自然的，而在推导和归约过程中优先考虑归约，因此，称 #ans[最左归约] 为规范规约，对应的最右推导为规范推导。
]


#synex([
  (2023 深圳) 给定文法如下：
  #align(center)[
    $$
      S #to S + T | T \
      T #to T \* P | P \
      P #to ( S ) | i 
    $$
  ]
  
  写出 P + T + i 所有的短语。
])

直白的说，短语就是句型中可归约成单个变量的部分。可一步归约的部分称为直接短语。
通过画语法树，可以直接地得到句型的所有短语。

#align(center)[
  #grid(
    columns: 2,
    column-gutter: 1em,
    align: left,
    
  tree("S", 
    tree("S", 
      tree("S", 
        tree("T", 
          tree("P"))
      ), 
      tree("+"), 
      tree("T"), 
      ), 
    tree("+"), 
    tree("T", 
      tree("P", 
        tree("i")), 
    ), 
    ), 

    [
      由语法树可以得到，句型 P + T + i 的所有短语为：
      - P: 可归约为 T
      - i: 可归约为 P
      - P + T: 可归约为 S
      - P + T + i: 可归约为 S
    ]
  )
]


#ex[
  - (2023 深圳)  一个句型的最左直接短语叫做 #ans([句柄])
]

素短语进一步要求短语中包含至少一个终结符，且不包含更小的素短语，即不可拆分。

#synex([
  (2023 深圳) 给定文法如下：
  #align(center)[
    $$
      E #to E + T | T \
      T #to T \* F | F \
      F #to (E) | id
    $$
  ]

  (1) 写出 (T \* F + id) 的最右推导(注意：括号也是终结符)

  (2) 写出(T \* F + id)的短语、直接短语、句柄、素短语、最左素短语
])

(1) 推导过程及对应的语法树如下：

#context {
  let production = [
    $ 
      E &to T \
        &to F \
        &to ( E ) \
        &to ( E + T ) \
        &to ( E + F ) \
        &to ( E + id ) \
        &to ( T + id ) \
        &to ( T * F + id ) \
    $
  ]

  let syntaxTree = tree("E", 
    tree("T", tree("F", 
      tree("("),  
      tree("E", 
          tree("E", tree("T",
            tree("T"),
            tree("*"),
            tree("F"),
          )),
          tree("+"),
          tree("T", tree("F", tree("id"))),
        ),  
      tree(")"),  
    )), 
  )

  align(center)[
    #grid(columns: 2, column-gutter: 4em, align: left,
      production, syntaxTree, 
    )
  ]  
}

(2) 由语法树可以得到，句型 (T \* F + id) 的所有短语为：
- id: 可归约为 F 
- T \* F: 可归约为 T
- T \* F + id: 可归约为 E
- (T \* F + id): 可归约为 F

其中，
- 直接短语： T \* F， id
- 句柄： T \* F
- 素短语： T \* F, id
- 最左素短语： T \* F

有关文法的更多内容，请参考教材，本资料仅对以上内容进行了整理。

