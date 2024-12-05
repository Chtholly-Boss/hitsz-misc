#import "../template.typ":*

= 查询优化技术
#qs([
#image("../assets/2023opt.png")
],[
首先将关系写的规整一些：
$
  "Student"("S#, Sname, Sage, Sclass") \
  "Course"("C#, Cname, Ccredit, Cteacher") \
  "SC"("S#, C#, Score")
$

由选择串接律，我们分解得到以下的选择操作：
+ $sigma_("Cname" = "Database System")$
+ $sigma_("Student.S#" = "SC.S#") $
+ $sigma_("Course.C#" = "SC.C#")$ 
+ $sigma_("Sname" = "张伟")$ 
#grid(
 columns: 2,
 rows: 2,
 column-gutter: 1em,
 row-gutter: 1em,
 figure(
    cetz.canvas({
      import cetz.draw: *
      import cetz.tree
      let data = (
        [$Pi_("Score")$], 
        ([$sigma_("Student.S#" = "SC.S#")$],
          ([$sigma_("Course.C#" = "SC.C#")$], 
          ([$times$], 
            ([$times$],
              ([$sigma_("Sname" = "张伟")$], [Student]),
              ([SC])
              ),
            ([$sigma_("Cname" = "Database System")$],[Course])
          ))
        )
      )
      tree.tree(
        data,
        direction: "down",
        spread: 2,
        draw-node: (node, ..) => {
        //   circle((), radius: .45, fill: rgb("#a9e34b"), stroke: none)
          content((), text(black, [#node.content]))
        },
        draw-edge: (from, to, ..) => {
          let (a, b) = (from + ".center", to + ".center")
          line((a, .3, b), (b, .3, a))
        }
      )
    }),
    numbering: none,
    caption: [Step 1:将 1, 4 直接发配到对应表上]
 ),
 figure(
    cetz.canvas({
      import cetz.draw: *
      import cetz.tree
      let data = (
        [$Pi_("Score")$], 
        ([$sigma_("Course.C#" = "SC.C#")$], 
        ([$times$], 
      ([$sigma_("Student.S#" = "SC.S#")$],
          ([$times$],
            ([$sigma_("Sname" = "张伟")$], [Student]),
            ([SC])
            )),
          ([$sigma_("Cname" = "Database System")$],[Course])
        ))
        // )
      )
      tree.tree(
        data,
        direction: "down",
        spread: 2.5,
        draw-node: (node, ..) => {
        //   circle((), radius: .45, fill: rgb("#a9e34b"), stroke: none)
          content((), text(black, [#node.content]))
        },
        draw-edge: (from, to, ..) => {
          let (a, b) = (from + ".center", to + ".center")
          line((a, .3, b), (b, .3, a))
        }
      )
    }),
    numbering: none,
    caption: [Step 2: 将 2 移动到相应的连接处]
 ),
 figure(
    cetz.canvas({
      import cetz.draw: *
      import cetz.tree
      let data = (
        [$Pi_("Score")$], 
        ([$sigma_("Course.C#" = "SC.C#")$], 
        ([$times$], 
        ([$Pi_("SC.C#, Score")$],
          ([$sigma_("Student.S#" = "SC.S#")$],
          ([$times$],
            ([$Pi_("Student.S#")$],
              ([$sigma_("Sname" = "张伟")$], [Student]),
            ),
            ([SC])
            )),
        ),
        ([$Pi_("Course.C#")$], 
          ([$sigma_("Cname" = "Database System")$],[Course])
        ),
        ))
      )
      tree.tree(
        data,
        direction: "down",
        spread: 2.5,
        draw-node: (node, ..) => {
        //   circle((), radius: .45, fill: rgb("#a9e34b"), stroke: none)
          content((), text(black, [#node.content]))
        },
        draw-edge: (from, to, ..) => {
          let (a, b) = (from + ".center", to + ".center")
          line((a, .3, b), (b, .3, a))
        }
      )
    }),
    numbering: none,
    caption: [Step 3: 在运算前投影出必要的属性] 
 ),
 figure(
    cetz.canvas({
      import cetz.draw: *
      import cetz.tree
      let data = (
        [$Pi_("Score")$], 
        ([$join$], 
        ([$Pi_("SC.C#, Score")$],
          ([$join$],
            ([$Pi_("Student.S#")$],
              ([$sigma_("Sname" = "张伟")$], [Student]),
            ),
            ([SC])
            ),
        ),
        ([$Pi_("Course.C#")$], 
          ([$sigma_("Cname" = "Database System")$],[Course])
        ),
        )
      )
      tree.tree(
        data,
        direction: "down",
        spread: 2.5,
        draw-node: (node, ..) => {
        //   circle((), radius: .45, fill: rgb("#a9e34b"), stroke: none)
          content((), text(black, [#node.content]))
        },
        draw-edge: (from, to, ..) => {
          let (a, b) = (from + ".center", to + ".center")
          line((a, .3, b), (b, .3, a))
        }
      )
    }),
    numbering: none,
    caption: [Step 4: 用连接代替笛卡儿积]
 ),
)
  
本题考察逻辑查询优化，相关知识如下：
- 关系代数表达式优化算法：
  + 依据选择串接律 $sigma_(F_1)(sigma_(F_2)E) = sigma_(F_1 and F_2)E$ 将$sigma_(F_1 and dots) (E)$ 改为串接形式
  + 对每个选择操作，尽可能的提前
    - 若涉及的属性属于单个表，可直接移到该表上方
    - 若涉及的属性属于多个表，则需要根据 _选择和积的交换律_，在沿途中遇到连接运算则进行属性分配
  + 对参与每个非投影运算的关系，投影出运算必要的属性(注意保留最后需要的属性)
- 按以上步骤进行后，若题目进一步要求分组，则按如下处理：
  - 寻找二元运算结点 P 
  - P 的一元运算直接祖先与其为同一组
  - P 的后代结点若是一串一元运算且以树叶为终点，则与其为一组
    - 若 P 是笛卡儿积，且其后代结点不能和它组合成等值连接，则不能归为一组
- 分组后产生一个程序，以每组结点为一步,但后代组先执行。
])

#board[
约定记号如下：
- $T_R \/ T(R)$: 关系 R 的元组数
- $B_R \/ B(R)$: 关系 R 的磁盘块数
- $I_R \/ I(R)$: 关系 R 一个元组的字节数
- $f_R \/ f(R)$: 关系 R 的块因子，即一个磁盘块能存储的元组数目
- $V(R,A)$: 关系 R 中属性 A 的不同取值个数
]

#qs([
估算以下关系代数表达式的运算结果大小, Student(\#sno, sname, cno), Course(\#cno, cname)：
$
sigma_("sname" = "Chtholly" and "cname" = "CS")("Student" join "Course")  
$
相关参数如下：
- $T("Student") = 10000$
- $T("Course") = 10$
- $V("Student","sname") = 100$
- $V("Course","cname") = 10$
],[
- 连接运算的结果元组数：$(10000 times 10)/ 100 = 1000$

- 选择运算的结果元组数：$1000 / (100 times 10) = 1$


本题考察代价估算:
- 投影运算 $Pi_L (R)$: 
  - $T(Pi_L (R)) = T(R)$
  - $B(Pi_L (R))$: 先计算元组数，再计算每块能放多少元组，最后算块数
- 选择运算：
  - $V(R,A)$ 未知时取 10

  - $T(sigma_(A = c) (R)) = T_R / V(R,A)$

  - $T(sigma_(A < c)(R)  = T_R / 2)$

  - 更准确的估计应根据各属性的频度，实际上可以用概率论中的知识进行计算
    - 选择运算即为随机抽样,不知道具体数量时假设均匀分布

    - $P(A = c) = n_c/n$
    
    - $P(A = c_1 or A = c_2) = 1 - (1 - n_(c_1)/n)(1 - n_(c_2)/n)$

    - 其余计算类似，最后用总数 n 乘以概率即可
- 连接运算 $R join S$：
  - 先笛卡儿积得到 $T_R * T_S$ 个元组
  - $P(R.A = c and S.A = C) = 1/(V(R,A) * V(S,A))$

  - c 最多有 $min(V(R,A), V(S,A))$ 种取值

  - $P(R.A = S.A) = (min(V(R,A), V(S,A)))/(V(R,A) * V(S,A)) = 1/(max(V(R,A), V(S,A)))$

  - 最终结果为 $(T_R * T_S)/(max(V(R,A), V(S,A)))$
])

== Appendix
#board[
- 关系操作次序交换的相关定理
  + 连接操作可交换：常取较小的关系放入内存
    - $E_1 join_(F) E_2 = E_2 join_(F) E_1$

    - $E_1 join E_2 = E_2 join E_1$

    - $E_1 times E_2 = E_2 times E_1$
  +  连接操作可结合：常取运算结果较小的先计算
    - $(E_1 join_(F_1) E_2) join_(F_2) E_3 = E_1 join_(F_1) (E_2 join_(F_2) E_3)$, 其余两个类似
  + 投影串接律
    - $Pi_(A_1 dots) (Pi_(B_1 dots) E) = Pi_(A_1 dots) E$
    - 可反向使用，扩展属性后移动投影操作
  + 选择串接律、
    - $sigma_(F_1)(sigma_(F_2)E) = sigma_(F_1 and F_2)E$
    - 分解复杂操作后移动选择操作
  + 选择和投影交换律
    - 设条件 F 只涉及属性 $A_1, dots$, 则有 $Pi_(A_1 dots) (sigma_(F)E) = sigma_(F) (Pi_(A_1 dots) E)$
    - 若 F 还涉及了其他属性，则 $Pi_(A_1 dots B_1 dots) (sigma_(F)E) = Pi_(A_1 dots) sigma_(F) (Pi_(A_1 dots B_1 dots) E)$, 即交换顺序计算完后还要投影
  + 选择和积交换律
    - 若条件F只涉及E1中的属性，则 $sigma_F (E_1 times E_2) = (sigma_F  E_1) times E_2$
    - 若 $F = F_1 and F_2$
      - 若 $F_1$ 只涉及 $E_1$ 中的属性， $F_2$ 只涉及 $E_2$ 中的属性，则 $sigma_F (E_1 times E_2) = (sigma_(F_1) E_1) times (sigma_(F_2) E_2)$
      - 若 $F_1$ 只涉及 $E_1$ 中的属性， $F_2$ 涉及了 $E_1, E_2$ 的属性，则$sigma_F (E_1 times E_2) = sigma_(F_2) (sigma_(F_1)(E_1) times E_2)$
  + 投影和积交换律
    - $Pi_(A_1 dots B_1 dots) (E_1 times E_2) = (Pi_(A_1 dots) E_1) times (Pi_(B_1 dots) E_2)$, 其中 $A_1 dots$ 和 $B_1 dots$ 分别是 $E_1, E_2$ 的属性
  + 选择和并的分配律：$sigma_F (E_1 union E_2) = sigma_F E_1 union sigma_F E_2$
  + 选择和差的分配律：$sigma_F (E_1 - E_2) = sigma_F E_1 - sigma_F E_2$
  + 投影和并的分配律：$Pi_(A_1 dots) (E_1 union E_2) = Pi_(A_1 dots) E_1 union Pi_(A_1 dots) E_2$
    - 投影和差并无此性质
]

