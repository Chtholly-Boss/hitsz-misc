#import "../template.typ": *

= 循环展开、向量化与线程并行技术

== 准备工作

首先需要下载并解压实验包：
```shell-unix-generic
wget http://10.249.10.96:3011/lab3.tar.gz
tar xvzf lab3.tar.gz
```

== 循环展开

循环展开是一种常见的优化技术，通过增加循环内部的迭代次数来减少循环的次数，从而减少循环开销。

本部分练习主要内容为 FPU 编程模型，参考 #link("https://www.intel.cn/content/www/cn/zh/content-details/782158/intel-64-and-ia-32-architectures-software-developer-s-manual-combined-volumes-1-2a-2b-2c-2d-3a-3b-3c-3d-and-4.html", "软件开发人员手册Volume1:8.1/8.3.5") 

x87 FPU 指令将 FPU 的 8 个寄存器组织成栈，栈顶寄存器为 ST(0)，如下图所示：
#figure(
  image("../assets/lab3-fpu-stack.png", width: 80%), 
  caption: [
    FPU 栈结构，摘自 Volume 1: 8.1.2
  ]
)

一个典型的运算方式如下图所示：
#figure(
  image("../assets/lab3-fpu-arith.png", width: 80%),
  caption: [
    FPU 栈操作，摘自 Volume 1: 8.1.2
  ]
)

指令 `FADDP` 中的 P 表示 Pop，即运算完成后将栈顶元素弹出。手册中的解释如下：

#quote(
  attribution: "Intel 64 and IA-32 Architectures Software Developer’s Manual Volume 1: Chapter 8", 
)[
  a pop operation on the register stack. A pop operation causes the ST(0) register to be marked empty and the stack pointer (TOP) in the x87 FPU control work to be incremented by 1.

  The pop versions of the add, subtract, multiply, and divide instructions offer the option of popping the x87 FPU register stack following the arithmetic operation. These instructions operate on values in the ST(i) and ST(0) registers, store the result in the ST(i) register, and pop the ST(0) register.
]

由此我们不难完成练习中的循环展开：

```yasm
// TODO  练习1: 添加计算A[m][k] * B[k][n+1] --> st(0)的逻辑
add $1, mat_elem_idx
flds (MAT_B, mat_elem_idx, 4)     // 加载 B[k][n+1]
fmul %st(2), %st(0)                 // 计算A[m][k] * B[k][n+1]  --> st(0)

...
// TODO 练习1: 请添加加载C[m][n] --> st(1) 和 C[m][n+1] --> st(0)的逻辑
flds (MAT_C, mat_elem_idx, 4)     // 加载 C[m][n]
add  $1, mat_elem_idx
flds (MAT_C, mat_elem_idx, 4)     // 加载 C[m][n+1]

...
// TODO 练习1: 请添加部分和累加逻辑: 
// C[m][n+1] + A[m][k] * B[k][n+1] 和 C[m][n] + A[m][k] * B[k][n]
faddp  %st(2)
faddp  %st(2)

...
// TODO 练习1: 请添加保存C[m][n]的逻辑
sub     $1, mat_elem_idx
fstps (MAT_C, mat_elem_idx, 4)      // 保存C[m][n]
// TODO 练习1: 请添加N维度的循环更新逻辑
add $2, loop_n
```

构建并运行：
```shell-unix-generic
cd build/
cmake -B . -S ../ && cmake --build ./ --target lab3_gemm_opt_loop_unrolling.unittest
./dist/bins/lab3_gemm_opt_loop_unrolling.unittest
```

测试结果如下:
#figure(
  image("../assets/lab3-t1-res.png"),
  caption: [
    循环展开测试结果
  ]
)

进行性能测试：
```shell-unix-generic
cmake -B . -S ../ && cmake --build ./ --target lab3_gemm_opt_loop_unrolling
./dist/bins/lab3_gemm_opt_loop_unrolling 1024 1024 1024
```

结果如下：
#figure(
  image("../assets/lab3-t1-perf.png"),
  caption: [
    循环展开性能测试结果
  ]
)

Not so impressive... 本质上是因为内层循环过多的冗余计算，导致性能提升不明显。Anyway，我们完成了循环展开的练习。

== 向量化

向量化是一种常见的优化技术，通过将多个操作合并为一个操作来减少指令的执行次数，从而提高性能。

本实验中，我们使用 AVX2 指令集来实现向量化。AVX2 指令集提供了 256 位的寄存器，可以同时处理 8 个单精度浮点数或 4 个双精度浮点数。

However, 本实验着眼于基本的 AVX2 指令集使用, 主要内容为数据在向量寄存器与内存间的移动。

实现如下：
```yasm
.macro LOAD_MAT_A     // 每次装载矩阵A同一列的2个元素, 即A[m][k], A[m+1][k]
...
// TODO 练习3: 请添加加载并广播A[m+1][k]-->mat_a1_0_8的逻辑
add DIM_K, temp_reg
mov temp_reg, mat_elem_idx
shl $2, mat_elem_idx        // 左移，相当于乘4
// 将A[m+1][k]广播到AVX寄存器的8个单元
vbroadcastss (MAT_A, mat_elem_idx), mat_a1_0_8    
.endm

.macro LOAD_MAT_B    // 每次装载矩阵B一行32个元素, 即B[k][n:n+32]
// TODO 练习3: 请添加加载B[k][n:n+32]-->mat_b0_0_8, mat_b0_8_16, mat_b0_16_24, mat_b0_24_32的逻辑
mov loop_k, %rax
mul DIM_N
mov %rax, temp_reg
add loop_n, temp_reg
mov temp_reg, mat_elem_idx
shl $2, mat_elem_idx        // 左移，相当于乘4

vmovups (MAT_B, mat_elem_idx), mat_b0_0_8
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups (MAT_B, mat_elem_idx), mat_b0_8_16
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups (MAT_B, mat_elem_idx), mat_b0_16_24
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups (MAT_B, mat_elem_idx), mat_b0_24_32
.endm

.macro LOAD_MAT_C
...
// TODO 练习3: 请添加加载C[m][n:n+32]-->mat_c0_0_8, mat_c0_8_16, mat_c0_16_24, mat_c0_24_32的逻辑
vmovups (MAT_C, mat_elem_idx), mat_c0_0_8
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups (MAT_C, mat_elem_idx), mat_c0_8_16
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups (MAT_C, mat_elem_idx), mat_c0_16_24
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups (MAT_C, mat_elem_idx), mat_c0_24_32
// 装载矩阵C第二行的数据, 即C[m+1][n:n+32]
mov temp_reg, mat_elem_idx
add DIM_N, mat_elem_idx
shl $2, mat_elem_idx        // 左移，相当于乘4
// TODO 练习3: 请添加加载C[m+1][n:n+32]-->mat_c1_0_8, mat_c1_8_16, mat_c1_16_24, mat_c1_24_32的逻辑
vmovups (MAT_C, mat_elem_idx), mat_c1_0_8
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups (MAT_C, mat_elem_idx), mat_c1_8_16
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups (MAT_C, mat_elem_idx), mat_c1_16_24
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups (MAT_C, mat_elem_idx), mat_c1_24_32
.endm

.macro STORE_MAT_C
...
// TODO 练习3: 请添加保存mat_c0_0_8, mat_c0_8_16, mat_c0_16_24, mat_c0_24_32 --> C[m][n:n+32]的逻辑
vmovups mat_c0_0_8, (MAT_C, mat_elem_idx)
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups mat_c0_8_16, (MAT_C, mat_elem_idx)
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups mat_c0_16_24, (MAT_C, mat_elem_idx)
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups mat_c0_24_32, (MAT_C, mat_elem_idx)
// 保存矩阵C第二行的数据, 即C[m+1][n:n+32]
// TODO 练习3: 请添加保存mat_c1_0_8, mat_c1_8_16, mat_c1_16_24, mat_c1_24_32 --> C[m+1][n:n+32]的逻辑
mov temp_reg, mat_elem_idx
add DIM_N, mat_elem_idx
shl $2, mat_elem_idx        // 左移，相当于乘4
vmovups mat_c1_0_8, (MAT_C, mat_elem_idx)
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups mat_c1_8_16, (MAT_C, mat_elem_idx)
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
vmovups mat_c1_16_24, (MAT_C, mat_elem_idx)
add $AVX_REG_BYTE_WIDTH, mat_elem_idx
  vmovups mat_c1_24_32, (MAT_C, mat_elem_idx)
.endm

.macro DO_COMPUTE      // 计算 C[m:m+2][n:n+32] += A[m:m+2][k] * B[k:k+8][n:n+32]
// TODO 练习3: 请添加计算C[m:m+2][n:n+32] += A[m:m+2][k] * B[k:k+8][n:n+32]的逻辑
vfmadd231ps mat_a0_0_8, mat_b0_0_8, mat_c0_0_8
vfmadd231ps mat_a0_0_8, mat_b0_8_16, mat_c0_8_16
vfmadd231ps mat_a0_0_8, mat_b0_16_24, mat_c0_16_24
vfmadd231ps mat_a0_0_8, mat_b0_24_32, mat_c0_24_32

vfmadd231ps mat_a1_0_8, mat_b0_0_8, mat_c1_0_8
vfmadd231ps mat_a1_0_8, mat_b0_8_16, mat_c1_8_16
vfmadd231ps mat_a1_0_8, mat_b0_16_24, mat_c1_16_24
vfmadd231ps mat_a1_0_8, mat_b0_24_32, mat_c1_24_32
.endm
```

大部分为重复的逻辑，So tedious...

构建并运行：
```shell-unix-generic
cmake -B . -S ../ && cmake --build ./ --target lab3_gemm_opt_avx.unittest
./dist/bins/lab3_gemm_opt_avx.unittest
```

结果如下：
#figure(
  image("../assets/lab3-t2-test.png", width: 80%),
  caption: [
    AVX 向量化加速测试
  ]
)

运行性能测试：
```shell-unix-generic
cmake -B . -S ../ && cmake --build ./ --target lab3_gemm_opt_avx
./dist/bins/lab3_gemm_opt_avx 1024 1024 1024
```

结果如下：
#figure(
  image("../assets/lab3-t2-perf.png", width: 80%),
  caption: [
    AVX 向量化加速性能测试
  ]
)