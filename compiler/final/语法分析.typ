#import "utils.typ": *

= 语法分析

== 自顶向下分析

#ex([
  - (2023 深圳) 递归下降分析法是 #ans[自顶向下分析] 的一种方法
  - (2023 深圳) 不是所有的文法都能改写成 LL(1) #ans([True])
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

(1) 本题中仅产生式 $T #to T , S | S$ 存在直接左递归，消除直接左递归的方式为引入一个新的非终结符 $A'$ 将 $A #to A #sym.alpha | #sym.beta$ 改写为 $A #to #sym.beta A'$ 与 $A' #to #sym.alpha A' | #sym.epsilon$

因此，消除左递归后的文法为：
#align(center)[
  $$
    S #to ( T ) | aP \
    P #to S | #sym.epsilon \
    T #to S T' \
    T' #to , S T' | #epsilon
  $$
]

(2) 
#def[
  $"FIRST"(#alpha) = {a | #alpha #dto^* a #beta, a #inset T, #beta #inset (V #sym.union T)^*}$， 即推导出的句型中的第一个终结符(如果存在)，如果 #alpha 可以推导出空串，则 $"FIRST"(#alpha) #sym.union {#epsilon}$。

  $"FOLLOW"(A) = {a | S #dto^* #alpha A a #beta, a #inset T, #beta #inset (V #sym.union T)^*}$， 即 A 后面可能跟的终结符(如果存在)。如果 A 是句型的起始符号，则 $"FOLLOW"(A) #sym.union {\#}$。
]

对每一条产生式提取出非终结符之间的FIRST集和FOLLOW集依赖关系，然后从容易求解的非终结符开始即可。

$
    S #to ( T ) | a P      ,& "FIRST"(S)     #union= {'(', 'a'} \
    P #to S | #sym.epsilon ,& "FIRST"(P)#union = "FIRST"(S) #union {#epsilon}\
    T #to S T'             ,& "FIRST"(T)              #union = "FIRST" (S) \
    T' #to , S T'          ,& "FIRST"(T')          #union = {',', #epsilon} \
$

$
  
    S #to ( T ) | a P ,       & "FOLLOW"(T) #union= ')', \ 
                              &"FOLLOW"(P) #union= "FOLLOW"(S) \
    P #to S | #sym.epsilon ,  & "FOLLOW"(S) #union= "FOLLOW"(P)  \
    T #to S T' ,              & "FOLLOW"(T') #union= "FOLLOW"(T) \
                              &"FOLLOW"(S) #union="FIRST"(T')+"FOLLOW"(T)\
    T' #to , S T' | #epsilon ,& "FOLLOW"(S) #union= "FOLLOW"(T')+"FIRST"(T')
$

不难得到答案为：
#table(
  columns: 3,
  align: center, 
  [], [FIRST], [FOLLOW],
  [S], ['(', a], [',', ')', \#],
  [P], ['(', a, #epsilon], [',', ')', \#],
  [T], ['(', a], [')'],
  [T'], [',', #epsilon], [')'],
)

#def[
  LL(1) 文法：对于任意产生式 $A #to #alpha | #beta$，若有以下条件成立：
  - 若 #alpha 和 #beta 均不能推导出空串，则需 $"FIRST"(#alpha) #sym.sect "FIRST"(#beta) = #sym.emptyset$
  - #alpha 和 #beta 至多有一个能推导出空串
  - 若 $#beta #dto^* #epsilon$， 则需 $"FIRST"(#alpha) #sect "FOLLOW"(#beta) = #empty$

  判断一个文法是否为 LL (1) 文法，只需对所有非终结符 $A$ 检查上述条件即可。
]

(3) 根据上述 FIRST 和 FOLLOW 集构造 LL(1) 分析表如下：
#figure(
  image("assets/lltable.png"), 
  caption: "LL(1) 分析表"
)

根据 LL (1) 分析表对输入串进行分析的过程较为直接，即根据符号栈栈顶及输入缓冲区的当前符号查表即可，格式类似下表：
#figure(
  grid(rows: 2, 
  image("assets/llanalyse1.png"),
  image("assets/llanalyse.png"),
  ), 
  caption: [
    LL(1) 分析过程格式示例，笔者太懒了，有时间再补上对本题的具体举例
  ]
)

#clues.tip[
  对每一个产生式$A arrow.r alpha $进行考察：
  - $forall a in "FIRST"(alpha)$，将 $A #to alpha$ 加入 $M[A,a]$ 中
  - 若 $epsilon in "FIRST"(alpha)$， 则 $forall a in "FOLLOW"(A)$，将 $A #to alpha$ 加入 $M[A,a]$ 中，包括 \#
]

== 自底向上分析

#ex([
  - (2023 深圳) LR 分析表中 s4 表示 #ans[从缓冲区中读取一个字符并跳转到状态 4]
  - (2023 深圳) a 是终结符,则 $A #to alpha #sym.dot a beta$ 是 #ans([移进]) 项目
  - (2023 深圳) #ans([算符优先文法]) 每次归约的都是句型的最左素短语。
  - (2023 深圳) 算符优先分析算法识别句柄. #ans[False]
  - (2023 深圳) 移进-归约分析是自顶向下翻译的动作. #ans([False])
  - (2020 深圳) SLR(1) 的归约要求 #ans[无归约-归约冲突]
  - (2023 深圳) SLR(1)中的 S 是简单的意思. #ans([True])
  - (2023 深圳)  LR(1)是自底向上分析的一种方法. #ans([True])
])



#synex([
  (2023 深圳改编) 有文法如下：
  #align(center)[
    $
      S' #to S \
      S #to a A d \
      S #to b A c \
      S #to a e c \
      S #to b e d \
      A #to epsilon "(原题为 A" #to "e)"
    $
  ]
  (1) 写出识别活前缀的 DFA
  
  (2) 写出 LR(1) 分析表
])

(1) 画出识别活前缀的 DFA 的关键在于如何从一个项目出发构造出整个项目集。

#clues.tip[
    教材 5.3.4： 对 [A #to #sym.alpha #sym.dot B #sym.beta, a] ，若存在规范推导 $S #dto^\* #delta A a x #dto #delta #alpha B #beta a x$，且有 $#beta a x #dto^* b y$，则任意项目 [B #to #sym.dot #sym.eta, b] 也位于同一项目集中。

    简单来说，某一个变量待约，则所有能约到它的项目都在同一项目集中，只需改变后继符即可。需要注意的是 $A #to #epsilon$ 仅有一个项目 $A #to #sym.dot$

    项目集之间的转移十分符合直觉，无需死记硬背。
]

首先计算 $I_0 = "CLOSURE" ({[S' #to #sym.dot S, \#]})$，根据 CLOSURE 的定义，对每个形如 [A #to #sym.alpha #sym.dot B #sym.beta, a] 的项目，将 [B #to #sym.dot #sym.eta, FISRT(#beta a)] 加入闭包中，此处 $A = S', B = S, "FIRST"(#beta a) = {\#} $

故加入如下项目：
- [S #to #dot a A d, \#]
- [S #to #dot b A c, \#]
- [S #to #dot a e c, \#]
- [S #to #dot b e d, \#]

对于新增的项目，重复上述步骤，直到项目集不再变化。

按以上步骤得到的项目集族如下图所示：

#figure(
  image("./assets/item-sets.png"), 
  caption: "项目集族"
)

(2) 根据项目集族构造 LR(1) 分析表如下：

#figure(
  image("assets/lrtable.png"), 
)
#clues.tip[
  每个项目集为一个状态，每个项目集的转移为状态转移，每个项目集的归约项目为归约动作（手动为产生式编号），每个项目集的移进项目为移进动作。
]

使用 LR(1) 分析表对输入串进行分析的过程较为直接，即根据符号栈栈顶及输入缓冲区的当前符号查Action表：
- 若为移进动作，则将当前符号压入符号栈，并将新状态压入状态栈
- 若为归约动作，则弹出相应数量的符号栈元素和状态栈元素，将产生式左部压入符号栈，根据当前状态栈顶和符号栈顶查GOTO表，将新状态压入状态栈

#figure(
  image("assets/lranalyse.png"), 
  caption: [
    LR(1) 分析过程格式示例，摘自作业答案，有时间再补上对本题的具体举例
  ]
)

=== Misc
#ex([
  - (2023 深圳) 语法分析一定要消除左递归. #ans([(False)])
  - (2023 深圳) YACC 是词法分析程序的自动生成工具. #ans([(False)])
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

此处附上算符优先文法的题型，防骗防偷袭。

#clues.tip[
  - $"FIRSTOP"(B) = {b | B #dto^+ b... or B #dto^+ C b ..., b in T, C in V}$

  - $"LASTOP"(B) = {b | B #dto^+ ...b or B #dto^+ ...b C, b in T, C in V}$
]

此题较为简单，由 $T #to S$ 容易知道 $b, \^, '(' in "FIRSTOP"(T)$，再由 $T #to T \* S$ 可知 $* in "FIRSTOP"(T)$，故 $"FIRSTOP"(T) = {b, \^, '(', *}$

知道定义便不难，此处不再赘述。
