= 实验结果与分析
#align(center)[
  #quote(block: true)[#text(fill: red)[
    对实验的输入输出结果进行展示与分析。注意：要求给出编译器各阶段（词法分析、语法分析、中间代码生成、目标代码生成）的输入输出并进行分析说明。
  ]]
]

==	词法分析

输入文件如下：

#figure(grid(columns: 2, gutter: 1em, 
  figure(
    image(
      "./assets/coding_map.png",
      height: 30%
      ),
      numbering: none,
      caption: "coding map"
  ),
  figure(
    image("./assets/input_code.png", height: 30%),
    numbering: none,
    caption: "input code"
  )
), caption: "词法分析输入文件")

输出符号表与 token 流如下：

#let old_symbol_table = csv(delimiter: "\n","./output/old_symbol_table.csv").flatten()
#let tokens = csv(delimiter: "\n","./output/token.csv").flatten()

#figure(grid(columns: 2, gutter: 1em, align: bottom,
  figure(
    table(columns: 1, 
      // stroke: none,
      ..for value in old_symbol_table {
        (value, table.hline()).flatten()
      }, 
    ),
    caption: "符号表"
  ),
  figure(
    table(
      columns: 4, 
      stroke: none,
      table.hline(),
      table.vline(),
      ..for value in tokens {
        (value, table.hline()).flatten()
      },
      table.vline(),
  ),
    caption: "token 流(由左到右，由上到下)"
  )
  ) ,
  numbering: none,
  caption: "词法分析输出结果")

分析：

词法分析应对输入的程序进行词法分析，将输入的字符序列转化为 token 流，并生成符号表。由上表可知词法分析器能够正确识别出输入代码中的所有关键字、标识符、常量、运算符和分隔符，并生成对应的 token 流和。

== 语法分析

语法分析的输入文件在词法分析部分文件的基础之上附加了 `grammer.txt` 文件，内容如下：

#figure(
  image("./assets/grammer.png", width: 60%), 
  caption: "grammer.txt"
)

以及 LR1分析表:

#figure(
  image("./assets/lr1.png", width: 100%), 
  caption: "LR1分析表"
)

输出文件除了词法分析部分的输出文件之外，还包括了归约得到的产生式列表：

#let parser_list = csv(delimiter: "\n","./output/parser_list.csv").flatten()

#figure(
  table(columns: 4, 
    ..for value in parser_list {
      (value, table.hline()).flatten()
    },
  ),
  caption: "产生式列表"
)

分析：

本部分通过使用 LR1分析表 进行自底向上的语法分析，将输入的 token 流归约得到语法树。由上表可知，语法分析器能够正确识别出输入代码的语法结构，并生成对应的产生式列表。

== 语义分析和中间代码生成
本部分的输入文件为前两部分的所有输入文件，输出文件为前两部分的所有输出文件，以及如下文件：

#figure(
  grid(
    columns: 2, 
    rows: 2, 
    gutter: 1em,
    align: bottom,
    grid.cell(
      rowspan: 2,
      figure(
        image("./assets/ir_code.png"), 
        numbering: none,
        caption: "中间代码"
      )
    ), 
    figure(
      image("./assets/new_symbol_table.png"), 
      numbering: none,
      caption: "符号表"
    ), 
    figure(
      image("./assets/ir_result.png"), 
      numbering: none,
      caption: "中间代码执行结果"
    )
  ),
  caption: "语义分析输出文件",
)

观察符号表可知，本部分相较于旧符号表，更新了变量的类型，同时，对源代码模拟运行：

$8×5 - (3 + 5) * (3 - 8 - 8) = 144$ 得到的结果与中间代码执行的结果一致，说明本部分能够正确进行语义分析和中间代码生成。

== 目标代码生成
本部分无新增输入文件（未实现附加题），输出文件新增汇编代码如下：

#align(center)[
```asm  
.text
  li t0, 8	# (MOV, a, 8)
  li t1, 5	# (MOV, b, 5)
  li t2, 3	# (MOV, $6, 3)
  sub t3, t2, t0	# (SUB, $0, $6, a)
  mv t4, t3	# (MOV, c, $0)
  mul t5, t0, t1	# (MUL, $1, a, b)
  addi t6, t1, 3	# (ADD, $2, b, 3)
  sub t2, t4, t0	# (SUB, $3, c, a)
  mul t4, t6, t2	# (MUL, $4, $2, $3)
  sub t6, t5, t4	# (SUB, $5, $1, $4)
  mv t2, t6	# (MOV, result, $5)
  mv a0, t2	# (RET, , result)

```
]

目标代码生成部分将中间代码转化为汇编代码，包含：
- 指令选取：根据中间代码的语义，选择合适的汇编指令
- 寄存器分配：根据指令的依赖关系，选择合适的寄存器

由上面的代码可知，目标代码生成部分能够正确地将中间代码转化为汇编代码。

== 测试结果
运行脚本得到如下结果：

#figure(
  image("./assets/脚本测试截图.png"), 
  caption: "测试结果"
)

由脚本测试结果可知，本实验可通过所有测试用例，说明实验结果正确。