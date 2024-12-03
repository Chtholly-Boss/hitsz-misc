#import "../template.typ":*

#let dpfull = math.op($arrow.r^f$)
#let dppart = math.op($arrow.r^p$)
#let imply = math.op($tack.r.double$)

= 函数依赖、关系范式、模式分解理论

== 函数依赖
#board[
  - 函数依赖
    - 设 $R(U)$ 是属性集合 $U = {A_1, ..., A_n}$ 上的一个关系模式，$X$ 和 $Y$ 是 $U$ 的两个子集，若对 $R(U)$ 的任意一个可能的关系 $r$, $r$ 中不可能有两个元组在 $X$ 属性上的值相同，而在 $Y$ 属性上的值不同，则称 $X$ 函数决定 $Y$ 或 $Y$ 依赖于 $X$，记作 $X to Y$。
    - 非平凡函数依赖：$X to Y, Y subset.not X$。
    - 若 $X to Y, Y to X$，则记作 $X arrow.r.l Y$
    - 如⼀关系 $r$ 的某属性集 $X$, $r$ 中根本没有 $X$ 上相等的两个元组存在，则 $X to Y$ 恒成立
    - 完全函数依赖：$X to Y$ 但 $X$ 的任何真子集 $X'$ 都不决定 $Y$，记作 $X arrow.r^f Y$
    - 部分函数依赖：非完全函数依赖，记作 $X arrow.r^p Y$
    - 传递函数依赖：$X to Y, Y to Z$ 且 $Y subset.not X, Z subset.not Y, Z subset.not X, Y arrow.r.not X$，则称 Z 传递函数依赖于 X
]

利用函数依赖可以给出候选键的定义：
#board[
  设 K 为 $R(U)$ 的属性集，若 $K dpfull U $, 则称 K 为 $R(U)$ 上的候选键。
]
主键、超键等概念与之前相同，此处不再赘述。

#board[
设 F 是关系模式 $R(U)$ 的函数依赖集，X, Y 是 R 的属性子集
- 若从 F 中的函数依赖能推导出 $X to Y$，则称 F 逻辑蕴涵 $X to Y$，记作 $F imply X to Y $

阿姆斯特朗公理系统：
- (A1) 自反律
  - 若 $Y subset X subset U$, 则 $X to Y$
- (A2) 增广律
  - 若 $X to Y, Z subset U$, 则 $X Z to Y Z$
- (A3) 传递律
  - 若 $X to Y, Y to Z$, 则 $X to Z$

推论：
- (a) 合并律
  - 若 $X to Y, X to Z$, 则 $X to Y Z$
- (b) 伪传递律
  - 若 $X to Y, W Y to Z$, 则 $X W to Z$
- (c) 分解律
  - 若 $X to Y Z$, 则 $X to Y, X to Z$
]

#board[
- 属性闭包 (Attriute Closure): 
  - 对 $R(U, F), X subset U, U = {A_1, ..., A_n}$, $X$ 的闭包 $X^+_F = {A_i | X to A_i "using Armstrong Axioms"}$
  - 显然 $X subset X^+_F$
  - 若属性闭包 $X^+_F = U$, 则 X 为一个超键
    - 若其任何真子集 $X'$ 的闭包 $X'^+_F eq.not U$, 则为一个候选键
- 函数依赖闭包
  - 被F逻辑蕴涵的所有函数依赖集合，记为 $F^+$
  - 若 $F^+ = F$, 则称 F 为一个全函数依赖族（函数依赖完备集
]

#board[
- #fill_blank(choice(
[在关系模式 $R(U,F)$ 中，如果 $X to Y$, 存在 X 的真子集 $X_1$, $X_1 to Y$, 则称函数依赖 $X to Y$ 为],
a: [平凡函数依赖],
b: [部分函数依赖],
c: [完全函数依赖],
d: [传递函数依赖],
ans: [B]
))
]

#qs[
#fill_blank[R(A, B, C, D, E, F, G), 函数依赖集 F为 ${A to B, B to D, "AD" to "EF", "AG" to C}$, 求 A 关于 F 的属性闭包]
][

]
#qs[
#fill_blank(src: "PPT Example")[
  设 $U = (A, B, C), F = {A to B, B to C}, 求 F^+$
]
][
通过本题展示如何系统地求函数依赖闭包。

+ X 包含 A，而 Y 任意，则有：
  $
    A to A, A to B, A to C \
    "AB" to A, "AB" to B, "AB" to C \
    "AC" to A, "AC" to C \
    "ABC" to A \/ B \/ C
  $
+ X 包含 B 但不包含 A 且 Y 不含 A，则有：
  $
    B to B, B to C \
    "BC" to B, "BC" to C \
  $
+ X 包含 C 但不含 A、B且 Y 不含 A、B，则有：
  $
    C to C \
  $
]

#board[
- $F^+ = G^+$: $F$ 和 $G$ 是等价的函数依赖集
- $F^+ subset G^+$ 则称 G 覆盖 F
]

#qs[
#fill_blank[R(A, B, C, D, E, F, G), 函数依赖集 F为 ${"AB" to "CF", "AD" to "CE", "AG" to B, D to C, B to D}$, 求 F 的最小覆盖 ]
][

]

#board[
【引理】：每个函数依赖集 F 可被一个其右端至多有一个属性的函数依赖集 $G$ 覆盖

最小覆盖：满足以下条件的覆盖 $G$
- 右端均为单属性
- 不存在冗余函数依赖，即去掉任意函数依赖后，函数依赖闭包发生改变
- 任何函数依赖左部不存在冗余，即去掉任意一个依赖的任意左边属性，函数依赖闭包发生改变
]

== 关系范式

#board[
- 第一范式：R(U) 中的每个分量都是不可分的数据项，记为 $R(U) in 1 "NF"$
  - ⼀个表如果能够称为⼀个关系，则其至少为 1NF
- 第二范式：R(U) 是 1NF，且每个_⾮主属性完全函数依赖于候选键_，记为 $R(U) in 2 "NF"$
- 第三范式：R(U) 是 2NF，且每个_⾮主属性不传递函数依赖于候选键_，记为 $R(U) in 3 "NF"$
  - 非主属性必须直接依赖于候选键
- Boyce-Codd 范式(BCNF): 
  - 若 R(U, F) = 1NF, 且 F 中任意非平凡函数依赖 $X to Y$，X都是R的一个超键
  - 若 R(U, F) = 3NF，且任意主属性都只 _直接完全函数依赖_ 于候选键，而不存在对任何其他属性集的函数依赖
]

#board[
- #fill_blank[一个关系模式满足第三范式,那么它一定满足 _第二_ 范式]
- #fill_blank(choice(
  [在关系数据库中,任何二元关系模式最高范式必定是],
  a: [1NF],
  b: [2NF],
  c: [3NF],
  d: [BCNF],
  ans: []
))
]

== 模式分解
#board[
关系模式 R(U) 的分解是指用 R 的一组子集替代 R，即 $R(U) = R_1(U_1) union R_2(U_2) union dots union R_n (U_n); U = U_1 union dots U_k; U_i subset.not U_j (i eq.not j)$
- 无损连接性：分解后仍然可以通过自然连接操作获得与R完全等价的数据内容
- 保持依赖性：分解后仍然保持与R完全等价的数据依赖约束

无损连接判定定理：
- 设F是关系模式R上的⼀个函数依赖集合。$rho ={R_1,R_2}$ 是R的⼀个分解，则：当且仅当 $R_1 sect R_2 to R_1 - R_2 $ 或者 $R_1 sect R_2 to R_1 - R_2 in F^+$ 时，$rho$ 是关于 F 无损连接的 

保持依赖分解：
- 对于关系模式 $R(U, F)$ 的⼀个分解 $rho = {R_1(U_1), R_2(U_2), dots}$，如所有 $pi_(R_i)(F)$ 的并集逻辑蕴涵 $F$，则称 $rho$ 是关于 F 保持依赖的
  - $pi_(R_i)(F) = {X to Y | X to Y in F, X,Y subset R_i}$
]

#qs[
#fill_blank[
给定关系模式 R(U, F), 其中 $U = {A_1, dots, A_6}$, 给定函数依赖 $F = {A_1 to (A_2, A_3); A_3 to A_4; (A_2, A_3) to (A_5, A_6); A_5 to A_1}$, 则分解 $rho = {R_1(A_1, A_2, A_3, A_4), R_2(A_2, A_3, A_5, A_6)}$: 
- A. 既具有无损连接性,又保持函数依赖
- B. 不具有无损连接性,但保持函数依赖
- C. 具有无损连接性,但不保持函数依赖
- D. 既不具有无损连接性,又不保持函数依赖
]
][

]

#qs[
#fill_blank[
给定关系模式 $R(U,F)$,其中 $U={A,B,C,D,E}$,给定函数依赖集合 $F={A to C;C to D;B to C; "DE" to C;"CE" to A }$

+ 写出 R 的候选码
+ 将 R 无损连接分解使其满足 BCNF
+ 判断 $R_1 = {A, D}, R_2 = {A, B}, R_3 = {B, C}, R_4 = {C, D, E}, R_5 = {A, E}$ 是否无无损连接分解
]
][
// TODO: 无损依赖分解为 BCNF

]

// TODO: 保持依赖分解为 3NF 题目
