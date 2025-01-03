#import "../template.typ": *

= 数据库索引技术
== Main Content
#qs(
  [
    #choice(
      [关于索引的下列说法不正确的是],
      dir: ttb,
      a: [虽然索引文件增加了存储空间和维护负担，但是当主文件数据量越大时使用索引效率越高；],
      b: [索引文件比主文件存储小很多，通常先查索引再找主文件速度会快很多；],
      c: [虽然索引文件存在与否不改变主文件的物理存储，但更新主文件数据时要同步更新所有的索引；],
      d: [
        索引文件存在与否不改变主文件的物理存储，所以更新数据时可不用更新索引；],
      ans: [],
    )
  ],
  [
    D

    本题考察索引的基本概念
    - 索引：定义在存储表(Table)基础之上,无需检查所有记录,快速定位所需记录的一种_辅助存储结构_,由一系列存储在磁盘上的索引项(index entries)组成,每一索引项又由两部分构成:
      - 索引字段: 由Table中某些列(通常是一列)中的值串接而成。
      - 行指针: 指向Table中包含索引字段值的记录在磁盘上的存储位置。
  ],
)

#qs(
  [
    #choice(
      [关于索引的下列说法不正确的是],
      dir: ttb,
      a: [稠密索引，对于Table中索引字段的每一个不同值，总是有一个索引项；],
      b: [稠密索引，对于Table中的每一个记录，总是有一个索引项；],
      c: [稀疏索引是对于Table中索引字段的部分取值有索引项。],
      d: [主索引是对每一个存储块都有一个索引项；],
      ans: [],
    )
  ],
  [
    B 对于Table中_索引字段_的每一个不同值总是有一个索引项

    本题考察稠密索引和稀疏索引，相关知识如下：
    - 稠密索引：主文件中每一个记录(形成的每一个索引字段值),都有一个索引项和它对应,指明该记录所在位置。
      - 若索引字段为候选键，则可视为一一对应
      - 若索引字段为非候选键，则需要进行冲突处理
    - 稀疏索引：对于主文件中部分记录(形成的索引字段值),有索引项和它对应。
      - 要求主文件必须是按对应索引字段属性排序存储
  ],
  rel: [
    + 稠密索引主文件必须按主键排序 (False)
  ],
)

#qs(
  [
    #choice(
      [关于主索引，下列说法不正确的是],
      dir: ttb,
      a: [主索引是关于主码的稠密索引；],
      b: [主索引是对每一个存储块都有一个索引项；],
      c: [主索引通常建立在有序主文件的基于主码的排序字段上；],
      d: [主索引是按索引字段值进行排序的一个有序文件。],
      ans: [],
    )
  ],
  [
    A

    本题考察主索引的相关概念：
    - 主索引：索引项不指向记录指针,而是指向记录所在存储块的指针。
      - 存储表的每一存储块的第一条记录,又称为锚记录 (anchor record), 或简称为块锚(block anchor)
      - 主索引的索引字段值为块锚的索引字段值,而指针指向其所在的存储块。
      - 主索引是按索引字段值进行排序的一个_有序_文件
      - 主索引是_稀疏_索引。
  ],
)

#qs(
  [
    辅助索引 #b (可以/不可以) 建立在主键上。
  ],
  [
    可以

    本题考察辅助索引，相关知识如下：
    - 辅助索引: 定义在主文件的任一或多个_非排序字段_上的辅助存储结构。
      - 通常是对某一非排序字段上的每一个不同值有一个索引项
      - ,如字段值不唯一,则要采用一个类似链表的结构来保存包含该字段值的所有记录的位置。
      - 辅助索引是_稠密_索引
  ],
)

#qs(
  [

    B+和 B 树本质的区别是 #b.
  ],
  [
    指向主文件的指针是否仅存于叶子节点。

    本题考察 B+ 树与B树的区别，相关知识如下：
    #figure(
      table(
        columns: 3,
        [], [B+树], [B树],
        [索引字段值出现的位置], [重复出现于叶结点和非叶结点], [仅出现一次或者在叶结点或者在非叶结点;],
        [指向主文件的指针存储的位置], [仅叶节点], [叶子节点和非叶节点均有],
      ),
      caption: [B+树与B树的区别],
    )
  ],
)


#qs(
  [
    #choice(
      [关于B+树，下列说法正确的是],
      dir: ttb,
      a: [B+树中所有结点的索引项，才能覆盖主文件的完整索引；],
      b: [B+树的索引字段值或者出现在叶子结点，或者出现在非叶结点，只能出现一次。],
      c: [如果用B+树建立主索引，则B+树中所有结点的索引项都包含指向主文件存储块的指针；],
      d: [B+树索引的所有叶子结点构成主文件的一个排序索引；],
      ans: [],
    )
  ],
  [
    D

    本题考察B+树的存储约定，相关知识如下：
    - 索引字段值重复出现于叶结点和非叶结点
    - 指向主文件的指针仅出现于叶结点;
    - 所有叶结点即可覆盖所有键值的索引;
    - 索引字段值在叶结点中是按顺序排列的;
  ],
)

#qs(
  [

  ],
  [
    本题考察 B+ 树的创建、插入、删除，相关知识如下：
    #quote[非常抱歉，本部分未提供详细解答，请参考相关资料。]
  ],
)

#qs(
  [
    #image("../assets/2023hash.png", width: 80%)
  ],
  [
    此题中应为 "平均一个桶的容量不超过 80% "
    - 初始状态：r/N = 3/6 = 50%
    - 插入 1111, 键值为 11, 没有该桶，插入 (01) 桶, 此时 r/N = 4/6 = 66.67%
    - 插入 1110, 键值为 10, 有空位直接插入，此时 r/N = 5/6 = 83.33% 需要分裂
    - 新桶编号为 (10) + 1 = (11), 由 (01) 分裂而来

    图示过程如下：
    #image("../assets/hash-linear.png", width: 80%)

    本题考察线性散列索引，需要了解以下几点：
    - 键值从低位到高位开始使用，使用的位数需要维护
    - 若键值没有对应的桶，则将其插入到键值最高位为0(一定存在)的桶中
    - 若当前的索引数/桶数 $r/n$ 大于指定比例时，按二进制数大小顺序加一个桶
    - 假设要加的桶为 $1 a_2 a_3 dots$, 则该桶由 $0 a_2 a_3 dots$ 分裂而来
    - 桶数超过 $2^i$ 时，`i += 1`
  ],
)

== Appendix
#image("../assets/稠密索引定位.png")

#board[
  - 聚簇索引：索引中邻近的记录在主文件中也是临近存储的;
  - 非聚簇索引：索引中邻近的记录在主文件中不一定是邻近存储的。
]

#board[
  - 散列：
    - 有M个桶,每个桶是有相同容量的存储
    - 散列函数 h(k),可以将键值k映射到 { 0, 1, ..., M-1 }中的某一个值
    - 将具有键值k的记录Record(k) 存储在对应h(k)编号的桶中
      - 若桶无空间，则申请一个溢出桶进行插入(类似拉链法)，删除键值时需要注意合并溢出桶到主桶，溢出桶为空时删除。
  - 静态散列索引：桶的数目M是固定值
  - 动态散列索引：桶的数目随键值增多，动态增加
  - 可扩展散列索引：
    - 用一个指向块的指针数组来表示桶,而不是用数据块本身组成的数组来表示桶
    - 指针数组能增长,其长度总是2的幂。
    - 散列函数h为每个键计算出一个K位二进制序列，桶的数目总是使用从序列第一位或最后一位算起的若干位,此位数小于K
]

