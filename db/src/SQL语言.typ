#import "../template.typ":*
= SQL语言

由于在试卷中对 SQL 语句的使用可以只使用若干基本语句，因此此处不对 SQL 语句进行详细讲解，建议有时间自行参阅 PPT 第三讲。

#board[
- SQL语言是集 _DDL_、_DML_、_DCL_ 于一体的数据库语言。
  - DDL语句引导词： _CREATE_、_DROP_、_ALTER_。
  - DML语句引导词：_INSERT_、_UPDATE_、_DELETE_、_SELECT_。
  - DCL语句引导词：_GRANT_、_REVOKE_。
- SQL 中的_基本表_ 对应于三级模式两层映像结构中的 _概念模式_，而 _视图_ 对应于 _外模式_。
  - 基本表是实际存储于存储⽂件中的表，基本表中的数据是需要存储的
  - 视图在SQL中只存储其由基本表导出视图所需要的公式，即由基本表产⽣视图的映像信息，其数据并不存储，⽽是在运⾏过程中动态产⽣与维护的
  - *对视图数据的更改最终要反映在对基本表的更改上。*
]

#board[
- #fill_blank(src: [2018 级期末])[选择关系对应于 SQL 的 _DML_ 部分] 是否无无损连接分解
- #fill_blank(choice(
  [下列聚合函数中不忽略空值(null)的是],
  a: [sum(列名)],
  b: [count(\*)],
  c: [max(列名)],
  d: [avg(列名)],
  ans: [B]
))
- #fill_blank[SQL 语句 `select stu_id from Student where age>18 or age<22 and department=”计算机”` 的含义是 _列出计算机系中年龄大于18岁或小于22岁的学生的学号_]
]

#qs[
#set raw(lang: "sql")
#fill_blank[现有 `table Student = {#S, SName, Adress}` 以及视图 `create view mit_view as select SName,Address from Student`,若使用 `update mitview values ("张伟",“红花岭1栋”)`进行更新,这是 _?_ (填“合法”或“不合法”)的。\# 表示主键属性]
][
不合法。能否对视图进行更新取决于该操作是否能映射到基本表上，在本题中 mit_view 不包含 Student 表的主键，无法从视图中唯一确定要更新的记录，因此无法进行更新。

常见的不可更新的视图有：
- 视图的SELECT目标列包含_聚集函数_
- 视图的 SELECT 子句使用了_UNIQUE或 DISTINCT_
- 视图中包括了_GROUP BY_子句
- 视图中包括经算术表达式计算出来的列
- 视图是由单个表的列构成,但并_没有包括主键_
]

#qs[
现有需求 “选出那些选择了全部计算机部门的老师的开设的课程的学生”,数据库内的关系如下：
- `Student = {#S, SName}`
- `SC = {#S, #C}`
- `Teacher = {#T, #D},`
- `Teach = {#T, #C}`
- `Department = {#D, DName}`

(1) 请给出这个需求的关系代数表达式\
(2) 请将这个表达式转化为 SQL 语句\
(3) 请叙述这个 SQL 语句的执行过程
][

]

