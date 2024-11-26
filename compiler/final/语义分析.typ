#import "utils.typ":*

== 语义分析及中间代码生成
本部分主要对应教材 Chapter 6/7

语义分析的题型需要引起重视，因为其在往年题中均有出现，但作业题中缺少相关练习，复习时应从教材中寻找相关习题。

=== 属性的定义

本部分需要掌握若干概念：
- 综合属性(syn): #ans[节点的属性值是通过分析树中该节点或其子节点的属性值计算出来的]
- 继承属性(inh): #ans[节点的属性值是由该节点、该节点的兄弟节点或父节点的属性值计算出来的]
- 固有属性: #ans[通过词法分析直接得到的属性]，通常归类于综合属性

#synex([
  (2023 深圳) 有翻译过程如下：
  #align(center)[
    $B #to B_1 "and" B_2$
    ```java
    {
      backpatch(B1.truelist, M.quad);
      B.truelist := B2.truelist;
      B.falselist:= merge(B1.falselist, B2.falselist);}
    }
    ```
  ]
  其中，`B.truelist` 是 #ans[综合] 属性， `B.falselist` 是 #ans([综合]) 属性。
])


#synex([
  填写下面的空白：
  #align(center)[
    $B #to B_1 "or" B_2$

    {
      backpatch(B1.truelist, M.quad); \
      B.truelist := #ans([?]); \
      B.falselist:= #ans([?]);}
    }
  ]
])

=== 翻译模式

翻译模式是语法制导定义的一种便于实现的书写形式。其中属性与文法符号相关联，语义规则或语义动作用花括号 {} 括起来，并可被插入到产生式右部的任何合适的位置上。

在实际解题中，把语义动作看成终结符号，按深度优先遍历语法分析树即可。

#synex([
  (2023 深圳) 有文法及其语法制导翻译如下所示:
  #align(center)[
    $$
      A #to aB {print(0)} \
      A #to c {print(1)}  \
      B #to Ab {print(2)}
    $$
  ]
  若输入序列为 aacbb, 则输出结果为 #ans([?])

  Sol: 简记 print 为 p, 绘制语法分析树如下：
  #set align(center)
  #tree("A",
    tree("a"),
    tree("B",
      tree("A", 
        tree("a"), 
        tree("B", 
          tree("A", 
            tree("c"), 
            tree("print(1)")), 
          tree("b"), 
          tree("print(2)")), 
        tree("print(0)")),
      tree("b"), 
      tree("print(2)")), 
    tree("print(0)"))
  #set align(left)
  按深度优先遍历得到的输出为：12020
]
)

=== 语法制导翻译
对于翻译的另一种考查方式为设计翻译模式/语法制导定义，通常需要引入若干属性，并给出语义规则。

本部分需要掌握若干概念：
- S-属性定义是指 #ans[只含综合属性的语法制导定义]
- L-属性定义是指 #ans([语法制导定义中的每个属性或者是综合属性，或者是满足如下条件的继承属性：设产生式为 $A #to X_1 ... X_n, X_i$ 仅依赖于：
      - A 的继承属性
      - $X_i$ 左边符号 $X_1 ... X_(i-1)$ 的综合属性或继承属性
      - $X_i$ 本身的综合或继承属性，但前提是其属性不能在依赖图中形成回路])

L-属性定义的概念已作为名词解释考察过，S-属性定义则常在语法制导定义后进行判断考察。

#clues.tip[由定义可以看出，S-属性定义更适用于自底向上的翻译，L-属性定义更适用于自顶向下的翻译。]

#synex([
  (2023 深圳) 有二进制转十进制的文法如下所示:
  #align(center)[
    $$
      S #to L \
      L #to LB | B \
      B #to 0 | 1   
    $$
  ]
  (1) 补全下面的翻译表
  #align(center)[
    #table(columns : 2, 
      [S #to L ], [ print(L.val)],
      [L #to $L_1$ B], [#ans[L.val = L1.val \* 2 + B.val]],
      [L #to B], [#ans[L.val = B.val]],
      [B #to 0], [#ans[B.val=0]],
      [B #to 1], [B.val = 1],
    )
  ]

  (2) 判断是否为 S 属性并说明理由 #ans([是，检查每个属性的定义即可])

  该题显然可以进行自底向上分析，解题较为直接。
])

#synex([
  (2020 深圳) 有拓展文法如下：
  #align(center)[
    $$
      S' #to S \
      S #to ( T ) | a \
      T #to T, S | S \
    $$
  ]
  (1) 设计一个语法制导定义，引入属性 num，输出 S 所生成的串中的配对括号的的个数
  
  (2) 判定是否为 S 属性并说明理由

  Sol: 产生式 $S #to ( T )$ 即有一对配对的括号，解题较为直接。
  仿照上一道题画表如下：
  #align(center)[
    #table(columns : 2, 
      [S' #to S ], [print(S.num)],
      [S #to ( T ) ], [S.num = T.num + 1],
      [S #to a ], [S.num = 0],
      [T #to T1, S ], [T.num = T1.num + S.num],
      [T #to S ], [T.num = S.num],
    )
  ]
  显然为 S 属性。
])

=== 概念解释

#ex([
  - (2023 深圳) 中间代码生成依据 #ans([语义规则])
  - (2023 深圳) 语法制导翻译是指 #ans([将静态检查和中间代码生成结合到语法分析中进行的技术])
  - (2023 深圳) S 属性用于自顶向下传递信息 #ans[(False)]
])

// 可能考察的概念解释：
// - 语义属性是指 #ans[一个文法符号所携带的语义信息]
// - 依赖图是指 #ans[描述属性之间依赖关系的图]
// - 注释分析树是指 #ans[节点带有属性值的分析树]
// - 属性文法是指 #ans[没有副作用的语法制导定义]
