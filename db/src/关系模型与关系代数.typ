#import "../template.typ":*

= 关系模型与关系代数

== 关系与关系模型


#board[
  - 关系模型的三个要素：
    - 基本结构: 关系/表
    - 操作集合
    - 完整性约束
  - 域(Domain): 域是一组具有相同数据类型的值的集合
    - 集合中元素的个数称为域的基数 (Cardinality)
  - 笛卡尔积：$D_1 times D_2 times dots D_n = {(d_1, d_2, dots, d_n) | d_i in D_i}$
  - 关系: 一组域 $D_1, D_2, dots$ 的笛卡儿积的子集
    - 由于关系的不同列可能来自同⼀个域，为区分，需要为每⼀列起⼀个名字，该名字即为_属性名_。不同列名的列值可以来自相同域。
    - 表示为 $R(A_1: D_1, A_2: D_2, dots, A_n: D_n)$，简记为 $R(A_1, A_2, dots, A_n)$，其中 $A_i$ 为属性名，$D_i$ 属性 $A_i$ 对应的域，$n$ 为关系的 _度_ 或 _目_，关系中的元组个数称为关系的 _基数_。
    - 一个关系的示例：Course(cno char(3), cname char(12), ...)
  - 关系模式是关系的结构, 关系是关系模式在某⼀时刻的数据 (instance)
    - 关系模式是稳定的；⽽关系是某⼀时刻的值，随时间变化
  - 关系的特性 (有印象即可，都很 trivial )
    - 关系是以内容(名字或值)来区分的，而不是属性在关系中的顺序 (调换行列顺序仍是同一个关系)
    - 任意两个元组不能相同 
      - 真实的 Table 可能有相同的元组，讨论关系时不考虑
    - 属性不可再分特性：又被称为 _关系第一范式_
]

#board[
  - 超码(superkey): 关系中能 _唯一标识_ 一个元组的一个 _属性组_
  - 候选码/候选键 (Candidate Key): 极小超码，即去掉任一属性后都不能唯一标识一个元组
  - 主码/主键 (Primary Key): 当有多个候选码时，选定其中 _一个_ 作为主码
  - 主属性：包含在任一 _候选码_ 中的属性。
  - 外码(Foreign Key)/外键: 关系 R 中的一个属性组，与另一个关系 S 的 _候选码_ 相对应
]

#board[
完整性约束：
- 实体完整性: 主码中的属性值不能为空
- 参照完整性: 外码的值必须为空值或另一个关系中某一元组相应的主码值
  - 如果关系R1的某个元组t1参照了关系R2的某个元组t2，则t2必须存在
- 用户自定义完整性： 用户针对具体的应用环境定义的完整性约束条件

DBMS 系统自动支持 _实体_ 完整性和 _参照_ 完整性。
]

#board[
- #fill_blank[关系是从 _表_ 抽象出来的。参与发生联系的实体的数目,称为联系的 _度_ 或 _目_。]
- #fill_blank(choice(
    [下列选项中,具有唯一性是],
    a: [超键], 
    b: [候选键],
    c: [主键],
    d: [外键],
    ans: [C]
  )
)
- #fill_blank(choice(
  [下列关于外键的说法中,正确的是],
  dir: ttb,
  a: [外键删除时必须级联删除],
  b: [外键值不允许为空],
  c: [外键可以包含多个属性],
  d: [钝角],
  ans: [C]
))
]

== 关系代数
#board[
- 关系代数操作以⼀个或多个关系为输⼊，结果是⼀个新的关系
- 基本运算：选择 $sigma$ 、投影 $Pi$ 、并 $union$ 、差 $minus$ 、笛卡尔积 $times$ 、更名 $rho$
- 扩展运算：交 $sect$ 、连接 $theta$ 、除 $div$
- 并相容性: 设 $R(A_1, A_2, dots, A_n)$ 和 $S(B_1, B_2, dots, B_m)$ 
  - $n = m$
  - $forall i, "Domain"(A_i) = "Domain"(B_i)$
  - 并、差、交均要求参与运算的两个关系具有并相容性
- 并：$R union S = {t | t in R or t in S}$
- 差：$R minus S = {t | t in R and t in.not S}$
- 交：$R sect S = {t | t in R and t in S}$
- 笛卡尔积：$R times S = {(t, s) | t in R and s in S}$
  - $R times S = S times R$
  - $R times S$ 的度数为 $R$ 的度数与 $S$ 的度数之和
  - $R times S$ 的基数是 $R$ 的基数与 $S$ 的基数的乘积
- 选择：$sigma_("condition")(R) = {t | t in R and "condition"(t) = "true"}$
  - 运算符优先次序：$() > theta > not > or = and$
- 投影：$Pi_("columns")(R)$ = { t[columns] | t in R}
- $theta$-连接：$R join_(A theta B) S$ 关系R和关系S的笛卡尔积中, 选取R中属性A与S中属性B间满⾜θ条件的元组。
  - 常用等值连接：$R join_(A = B) S$
- 自然连接：$R join S = sigma_(t[B] = s[B])$ 关系R和关系S的笛卡尔积中选取相同属性组B上值相等的元组所构成。
  - 必须有相同属性组 B
  - $R.B_1 = S.B_1, dots, R.B_n = S.B_n$ 才可连接
  - 结果中需要去除重复列
- 外连接：两个关系 R 与 S 进行连接时，如果 R 中的元组在 S 中没有与之匹配的元组，则将该元组与 S 中的空元组连接。
  - 左外连接：$R join.l_(A = B) S$，结果中保留 R 中的所有元组
  - 右外连接：$R join.r_(A = B) S$，结果中保留 S 中的所有元组
  - 全外连接：$R join.l.r_(A = B) S$，结果中保留 R 和 S 中的所有元组
  #image("../assets/out-join.png")

- 更名：$rho_("new_name")(R)$：将关系R的名称更改为new_name
- 除：$R div S = {t | t in Pi_(R-S)(R) and forall s in S, (t, s) in R}$
  - S 的属性必须为 R 的真子集
  - 即先对 R 做投影，再从结果中选出能与 S 中的所有元组组合得到 R 的元组的元组- 
]

#board[
- #fill_blank(choice(
  [在关系代数运算中,五种基本运算为],
  dir: ttb,
  a: [并、差、选择、投影、乘积],
  b: [并、交、选择、投影、连接],
  c: [并、差、交、选择、投影],
  d: [并、交、选择、投影、笛卡尔积],
  ans: [A]
))
- #fill_blank(src: [2018级期末])[
 关系 S(A, B,C) 有 300 条记录，关系 R(A, B, C) 有 200 条记录，R 与 S 共 50 条相同的记录，则 $S join R$ 的模式为 _?_, 其包含 _?_ 条记录
]
]

#qs[
#fill_blank([关系 R、S 分别有 M、N 个元组,则 $R join R,  R join S$ 的元组个数可能为]) 
- A. M*N, max(M, N)
- B. M, M*N
- C. M*N, M*N
- D. M*N, max(M, N)
][
B. 显然 R 与自身的连接不应与 N 有关。
]

#qs[
#fill_blank(src: [2018级期末])[
为查询选修了学号 98030201 学生所学全部课程的同学的姓名，有下列关系代数表达式：
$
  pi_("sname")(S join ("SC" div pi_("C#")(sigma_("S# = 98030201")("SC")))
$
该语句是否正确？请说明理由。
]
][

]