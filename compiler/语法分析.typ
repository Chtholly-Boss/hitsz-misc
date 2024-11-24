#import "utils.typ": *

== 语法分析

=== 自顶向下分析

#ex([
  - (2023 深圳) 递归下降分析法是 #ans[自顶向下分析] 的一种方法
  - (2023 深圳) 不是所有的文法都能改写成 LL(1) #ans([True])
  - (2020 深圳) SLR(1) 的归约要求 #ans([?])
])

#synex([
  (2023 深圳) 有文法如下：
  #align(center)[
    $$
      S #to ( T ) aP \
      P #to S | #sym.epsilon \
      T #to T , S | S 
    $$
  ]
  (1) 消除左递归 

  (2) 写出所有非终结符的 First 集 和 Follow 集

  (3) 写出 LL(1) 分析表

])
=== 自底向上分析

#ex([
  - (2023 深圳) LR 分析表中 s4 表示 #ans[从缓冲区中读取一个字符并跳转到状态 4]
  - (2023 深圳) a 是终结符,则 $A #to alpha #sym.dot a beta$ 是 #ans([移进/待约？]) 项目
  - (2023 深圳) #ans([算符优先文法]) 每次归约的都是句型的最左素短语。
  - (2023 深圳) 算符优先分析算法识别句柄. #ans([T/F])
  - (2023 深圳) 移进-归约分析是自顶向下翻译的动作. #ans([False])
  - (2023 深圳) SLR(1)中的 S 是简单的意思. #ans([T/F])
  - (2023 深圳)  LR(1)是自底向上分析的一种方法. #ans([True])
])

#synex([
  (2020 深圳) 有文法如下：
  #align(center)[
    $$
    S #to b | ^ | ( T ) \
    T #to T \* S | S  
    $$
  ]
  求 FISRTOP(T)
])
#synex([
  (2023 深圳) 有文法如下：
  #align(center)[
    $$
      S' #to S \
      S #to aAd \
      S #to bAc \
      S #to aec \
      S #to bed \
      A #to e
    $$
  ]
  (1) 写出识别活前缀的 DFA
  
  (2) 写出 LR(1) 分析表
])

=== Misc
#ex([
  - (2023 深圳) 有限状态自动机有且仅有一个唯一的终态. #ans([False])
  - (2023 深圳) 语法分析一定要消除左递归. #ans([(False)])
  - (2023 深圳) YACC 是词法分析程序的自动生成工具. #ans([(False)])
])