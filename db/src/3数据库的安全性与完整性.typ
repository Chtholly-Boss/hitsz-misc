#import "../template.typ": *

= 数据库的安全性与完整性
== Main
#qs(
  [
    #choice(
      [`Create Table` 有三种功能,以下不是其中一项功能的是],
      dir: ttb,
      a: [定义安全性约束],
      b: [定义关系模式],
      c: [定义完整性约束],
      d: [定义物理存储特性],
      ans: [],
    )
  ],
  [
    A

    本题考察 `CREATE TABLE` 的功能，相关知识如下：
    - `CREATE TABLE` 有三种功能：
      - 定义关系模式
      - 定义完整性约束
      - 定义物理存储特性
  ],
)

== Appendix

#board[
  - 数据库完整性(DB Integrity)是指 DBMS应保证 DB 在任何情况下的 _正确性_ 、 _有效性_ 和 _一致性_ 。
  - 完整性约束条件 Integrity Constraint 定义为四元组 (O, P, A, R)
    - O: 数据集合/约束的对象
    - P: 谓词条件
    - A: 触发动作，即什么时候检查
    - R: 响应动作，即满足/不满足条件时对应的操作
  - SQL 语言支持的约束：
    - 静态约束：
      - 列完整性---域完整性约束
      - 表完整性---关系完整性约束
    - 动态约束---触发器(Trigger)

  - 数据库安全性是指DBMS能够保证_使DB免受非法、非授权用户的使用、泄漏、更改或破坏的机制和手段_
]
