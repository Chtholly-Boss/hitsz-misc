#import "../template.typ":*
= SQL语言
#qs([
选择关系对应于 SQL 的 #b 部分
],[
DML 

本题考察 SQL 数据库语言，相关知识如下：
- SQL语言是集 _DDL_、_DML_、_DCL_ 于一体的数据库语言。
  - DDL语句引导词： _CREATE_、_DROP_、_ALTER_。
  - DML语句引导词：_INSERT_、_UPDATE_、_DELETE_、_SELECT_。
  - DCL语句引导词：_GRANT_、_REVOKE_。
- SQL 中的_基本表_ 对应于三级模式两层映像结构中的 _概念模式_，而 _视图_ 对应于 _外模式_。
  - 基本表：实际存储于存储⽂件中的表
  - 视图：只存储其由基本表导出视图所需要的公式，即由基本表产⽣视图的映像信息，其数据并不存储，⽽是在运⾏过程中动态产⽣与维护的
])

#qs([
SQL 语句 `select stu_id from Student where age>18 or age<22 and department=”计算机”` 的含义是 #b
],[
列出计算机系中年龄大于18岁或小于22岁的学生的学号

本题考察 SQL 语句，SQL 的语法较为简单，此处不再赘述，可直接翻看 Lec3 PPT
])

#qs([
‍在SQL中，与"NOT IN"等价的操作符是 #b
],[
<> ALL
])
#qs([
现有 `table Student = {#S, SName, Adress}` 以及视图 `create view mit_view as select SName,Address from Student`,若使用 `update mitview values ("张伟",“红花岭1栋”)`进行更新,这是 #b (填“合法”或“不合法”)的。
],[
不合法。

本题考察视图的创建与更新，相关知识如下：
- 视图的创建：`create view foo_view as (查询语句)`
- 对视图的更新最终要反映到对基本表的更新上，如果视图定义的映射不是可逆则不可更新。
  - 常见的不可更新类型：
    - 视图的SELECT目标列包含_聚集函数_
    - 视图的 SELECT 子句使用了_UNIQUE或 DISTINCT_
    - 视图中包括了_GROUP BY_子句
    - 视图中包括经算术表达式计算出来的列
    - 视图是由单个表的列构成,但并_没有包括主键_
  - 一般的可更新类型：
    - 视图是从单个基本表使用选择、投影操作导出的,并且包含了基本表的主键
])

#qs([
现有需求 “选出那些选择了全部计算机部门的老师开设的课程的学生”,数据库内的关系如下：
- `Student = {#S, SName}`
- `SC = {#S, #C}`
- `Teacher = {#T, #D},`
- `Teach = {#T, #C}`
- `Department = {#D, DName}`
+ 请给出这个需求的关系代数表达式
+ 请将这个表达式转化为 SQL 语句
+ 请叙述这个 SQL 语句的执行过程
],[
1. $
    "Student" join ("SC" div Pi_(\#C)("Teach" join Pi_(\#T)(sigma_("DName" = "计算机") ("Teacher" join "Department")))))
  $
2. 转换后的 SQL 语句为：
```sql 
select distinct SC1.S
from SC SC1
where not exists (
  select *
  from (
    select Teach.C 
    from Teach 
    join (
      select Teacher.T
      from Teacher
      join Department on Teacher.D = Department.D
      where Department.DName = "计算机"
    ) on Teach.T = Teacher.T
  ) courses 
  where not exists (
    select *
    from SC SC2
    where SC2.S = SC1.S and SC2.C = courses.C
  )
)
```
3. 该语句的执行过程如下：
- 将 Teacher 表和 Department 表连接，选择所有DName（部门名称）为"计算机"的记录。
- 筛选上述结果的教师编号列，与Teach表连接，筛选得到所有计算机系教师开设的课程编号表 courses。
- 对于SC表中的每个学生（SC1），检查是否存在至少一门由计算机系老师开设的课程，该学生没有选修。这是通过检查第二个NOT EXISTS子查询的结果来完成的。如果对于某个学生，所有的计算机系课程都至少有一个对应的SC记录，那么这个学生就满足条件。
- 选择所有满足第一个NOT EXISTS子查询条件的学生编号（S），并且使用DISTINCT关键字确保每个学生只被列出一次。

本题的核心考点在于除法的SQL实现，其在 PPT 中也占据了较大的篇幅。

假设我们想要计算 $A div B$, 模板如下：
```sql
-- X = A.attributes - B.attributes
-- Y = B.attributes
-- `NOT EXISTS` 用于检查子查询是否返回空元组，若是则返回真。
select distinct A1.X
from A A1
where not exists (
  select *
  from B
  where not exists (
    select *
    from A A2
    where A2.X = A1.X
    and A2.Y = B.Y
  )
```
该语句的执行过程如下：
- 取 `A1.X` 的一行
- 将其与 B 的每一行连接，检查是否在 A 中
- 如果存在，则第二层 `NOT EXISTS` 返回假，该行 B 的记录被排除
- 若 B 的所有记录都被排除，则第一层 `NOT EXISTS` 返回真，该行 A1 的记录被保留
- 若有记录被保留，则排除该行 A1 的记录
- 取 `A1.X` 的下一行，重复上述过程

上述过程显然实现了除法，即若 `A1.X` 的某一条记录不能和 B 的每一条记录连接，则其将被排除
])
