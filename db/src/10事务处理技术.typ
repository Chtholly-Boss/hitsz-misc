#import "../template.typ": *

= 事务处理技术
== Main
#qs(
  [
    #choice(
      [下列说法正确的是],
      dir: ttb,
      a: [一个调度如果是非冲突可串行化的，那么也一定不是可串行化的；],
      b: [正确的并行调度一定是具有可串行性的调度；],
      c: [两阶段封锁法是可串行化的并行调度算法；],
      d: [用于并发控制的两阶段封锁法不会产生死锁现象；],
      ans: [],
    )
  ],
  [
    C
    - A: 冲突可串行性是可串行性的子集，可串行化不一定是冲突可串行化的
    - B: 可串行性是并发调度正确性的子集，正确的并行调度不一定具有可串行性
    - C: 两阶段封锁法是冲突可串行化的，进而是可串行的
    - D: 两阶段封锁法可能导致死锁

    本题考察可串行化与两阶段封锁法，相关知识如下：
    - 并发调度正确性：在这个并发调度下所得到的新数据库结果与分别串行地运行这些事务所得的新数据库完全一致
    - 可串行性：不管数据库初始状态如何,一个调度对_数据库状态的影响_都和某个串行调度相同
    - 冲突: 调度中一对连续的动作:如果它们的顺序交换,那么涉及的事务中至少有一个事务的行为会改变。
      - 同一事务的任两个操作都是冲突的（必须按序操作）
      - 不同事务对同一元素的两个写操作是冲突的
      - 不同事务对同一元素的一读一写操作是冲突的
    - 冲突可串行性：通过交换相邻两个无冲突的操作能够转换到某一个串行的调度
    - _冲突可串行性 $subset$ 可串行性 $subset$ 并发调度的正确性_
    - 两段封锁协议(2 Phase Locking Protocal)：
      - 读写数据之前要获得锁。每个事务中所有封锁请求先于任何一个解锁请求
      - 两阶段:加锁段,解锁段。加锁段中不能有解锁操作,解锁段中不能有加锁操作
      - 能保证冲突可串行性
      - 可能导致死锁 (两个事务获得锁的顺序不同)
  ],
  rel: [
    + #choice(
        [下列说法正确的是],
        dir: ttb,
        a: [两阶段封锁法不会产生死锁现象。],
        b: [两阶段封锁法一定能够保证数据更新的一致性；],
        c: [并发控制只能依靠封锁的方法实现；],
        d: [只要对数据项加锁，就能保证数据更新的一致性；],
        ans: [B],
      )
  ],
)

#qs(
  [
    #choice(
      [若事务T对数据R已加S锁，则其它事务对R],
      dir: ttb,
      a: [不能加S锁可以加X锁；],
      b: [可以加S锁也可以加X锁；],
      c: [可以加S锁不能加X锁；],
      d: [不能加任何锁。],
      ans: [],
    )

  ],
  [
    C

    本题考察锁的类型及封锁协议，相关知识如下：
    - 锁的类型：
      - 排他锁/互斥锁（X 锁）：只有加锁事务能读、写,其他任何事务都不能对其加锁进行读、写
      - 共享锁（S 锁）：所有事务都可以读,但任何事务都不能写
      - 更新锁（U 锁）：初始读,以后可升级为写

    #figure(
      grid(
        rows: 2,
        row-gutter: 1em,
        table(
          columns: (1fr, 1fr, 1fr, 1fr),
          rows: 4,
          align: center + horizon,
          table.cell(colspan: 2, rowspan: 2)[读锁写锁协议],
          table.cell(colspan: 2)[事务 B 申请的锁],
          [S], [X],
          table.cell(rowspan: 2)[事务A持有的锁],
          [S], [是], [否],
          [X], [否], [否],
        ),
        table(
          columns: (1fr, 1fr, 1fr, 1fr, 1fr),
          rows: 4,
          align: center + horizon,
          table.cell(colspan: 2, rowspan: 2)[更新锁协议],
          table.cell(colspan: 3)[事务 B 申请的锁],
          [S], [X], [U],
          table.cell(rowspan: 3)[事务A持有的锁],
          [S], [是], [否], [是],
          [X], [否], [否], [否],
          [U], [否], [否], [否],
        )
      ),
      caption: [封锁协议, 对同一对象，事务A持有锁时若允许事务B申请锁，则对应的表格中为“是”],
    )
  ],
  rel: [
    + #choice(
        [若事务T对数据M已加S锁，在不改变S锁的情况下，则其它事务对数据M],
        dir: ttb,
        a: [不可以读，不可以写；],
        b: [不可以读，但可以写；],
        c: [可以读，可以写；],
        d: [可以读，但不可以写；],
        ans: [D],
      )

  ],
)

#qs(
  [
    基于时间戳的并发控制,需要冲突检测,当发生冲突的时候需要撤销事务、重启事务以解决冲突。现有三个事务 $T_1, T_2, T_3$, 他们的时间戳分别为 180, 140, 160。三个事务的操作按照下列次序进行:
    $
      r_1(B), r_2(A), r_3(C), w_1(A), w_2(C), w_3(A)
    $
    在忽略重启的情况下,请分析因为冲突而可能被撤销的事务。
  ],
  [
    #table(
      columns: range(0, 6).map(_ => 1fr),
      [T1], [T2], [T3], [A], [B], [C],
      [180], [140], [160], [RT=0; WT=0], [RT=0; WT=0], [RT=0; WT=0],
      [r1(B)], [], [], [], [RT=180; WT=0], [],
      [], [r2(A)], [], [RT=140; WT=0], [], [],
      [], [], [r3(C)], [], [], [RT=160; WT=0],
      [w1(A)], [], [], [RT=140; WT=180], [], [],
      [], [w2(C)], [], [], [], [ _TS(2) < RT !_],
      [], [], [w3(A)], [_TS(3) < WT !_], [], [],
    )
    可能被撤销的事务有事务 2 和 事务 3。

    本题考察基于时间戳的并发控制，相关知识如下：
    - 时间戳(TimeStamp) :一种基于时间的标志,将某一时刻转换成的一个数值
      - 具有唯一性和递增性
      - 事务的时间戳：事务 T 启动的时刻
    - 基于时间戳的并发控制：
      - 借助于时间戳,_强制_使一组并发事务的交叉执行等价于一个_特定顺序_的串行执行。
        - 顺序：时间戳由小到大
        - 强制：无冲突予以执行，有冲突则撤销并重启事务，赋予其更大的时间戳
      - 简单的调度规则：
        - 对每个数据元素 X，维护：
          - RT(x): 读过该数据事务中最大的时间戳,即最后读x的事务的时间。
          - WT(x): 写过该数据事务中最大的时间戳,即最后写x的事务的时间。
        - 设事务的时间戳为 TS
        - R-W: 若事务读x，TS>WT(x) 时允许读，并修改 RT(x) = max(TS, RT(x)), 否则撤销并重启 T
        - W-R: 若事务写x，TS>RT(x) 时允许写，并修改 WT(x) = max(TS, WT(x)), 否则撤销并重启 T
        - W-W: 若事务写x，TS>WT(x) 时允许写，并修改 WT(x) = TS, 否则撤销并重启 T
  ],
  rel: [
    + 基于时间戳的并发控制 _有_ (填“有”或“无” )冲突可串行性。
  ],
)

== Appendix
#board[
  - 事务：数据库管理系统提供的控制数据操作的一种手段,通过这一手段,应用程序员将一系列的数据库操作组合在一起作为一个整体进行操作和控制, 以便数据库管理系统能够提供一致性状态转换的保证。
    - 宏观性(应用程序员看到的事务): 一个存取或改变数据库内容的程序的一次执行
    - 微观性(DBMS看到的事务): 对数据库的一系列基本操作(读、写) 的一个整体性执行。
    - ACID 特性
      - 原子性：事务的一组更新操作是原子不可分的
      - 一致性：事务的操作状态是正确的
        - 三种不一致性：丢失修改、不能重复读、脏读
      - 隔离性：并发执行的多个事务之间互相不受影响
      - 持久性：已提交事务的影响是持久的,被撤销事务的影响是可恢复的。
  - 并行（并发）调度：多个事务从宏观上看是并行执行的,但其微观上的基本操作(读、写)则可以是交叉执行的。
]

#board[
  - $r_T(A)$: 事务 T 读 A
  - $w_T(A)$: 事务 T 写 A
  - $L_i(A)$ 事务 i 对 A 加锁
  - $U_i(A)$ 事务 i 对 A 解锁
]

#board[
  冲突可串行性的判定：
  - 以每一个事务 $T_i$ 为结点，构造一个前驱图(有向图)
  - 如果Ti的一个操作与Tj的一个操作发生冲突,且Ti在 Tj前执行,则绘制一条由Ti指向Tj的边
  - 如果此有向图没有环,则是冲突可串行化的
  #image("../assets/冲突可串行化判定.png")
]
