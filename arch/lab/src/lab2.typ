#import "../template.typ": *

= 预取与循环结构优化
本次实验由三部分组成：
- 性能瓶颈分析
- 利用预取技术优化性能
- 循环结构优化（选做）
== 准备工作
首先需要下载并解压实验包：
```sh
wget http://10.249.10.96:3011/lab2_new.tar.gz
tar -zxvf lab2_new.tar.gz
```
然后进行构建：
```sh   
# 项目根目录执行
mkdir -p build && cd build
cmake -B . -S ../ 
cmake --build ./ --target lab2_gemm_baseline
```

本次实验的测试方式如下:
```sh
# 项目根目录下执行
mkdir -p build && cd build

# 正确性测试
cmake -B . -S ../ && cmake --build ./ --target lab2_gemm_kernel_opt_prefetch.unittest
./dist/bins/lab2_gemm_kernel_opt_prefetch.unittest

# 性能测试
cmake -B . -S ../ && cmake --build ./ --target lab2_gemm_opt_prefetch
./dist/bins/lab2_gemm_opt_prefetch M K N
```

利用实验指导书中所给的参数 $(M, K, N) = (1024, 128, 4)$，在将原始程序 copy 到 `gemm_kernel_opt_prefetch.S` 后多次运行测试，得到如下几种结果：
#figure(
 grid(
  rows: 2, 
  row-gutter: 1em, 
  columns: 2, 
  column-gutter: 1em,
  image("../assets/lab2-t1r1.png"), 
  image("../assets/lab2-t1r2.png"), 
  image("../assets/lab2-t1r3.png"), 
  image("../assets/lab2-t1r4.png"), 
  ), 
  caption: [
    (M, K, N) = (1024, 128, 4) 测试结果
  ]
)

测试结果的方差较大，究其原因是因为该参数组合过小，绝大部分数据在预热后都能够驻留在缓存中。因此，在后续的测试中，我们选择 $(M, K, N) = (1024, 1024, 1024)$ 作为测试参数。

== 性能瓶颈分析
使用 `perf` 命令获取相应参数：
```sh
mkdir -p build && cd build
cmake -B . -S ../ && cmake --build ./ --target lab2_gemm_baseline
perf stat -e l2_rqsts.code_rd_hit,l2_rqsts.references,l2_rqsts.pf_hit,l2_rqsts.pf_miss,L1-dcache-loads,L1-dcache-load-misses ./dist/bins/lab2_gemm_baseline 1024 1024 1024
```
// TODO: 这里最好有图

== 利用预取技术优化性能
=== 预取指令概述

x86-64指令集架构包含SSE（Streaming SIMD Extension）扩展指令。查阅 #link("https://www.intel.cn/content/www/cn/zh/content-details/782158/intel-64-and-ia-32-architectures-software-developer-s-manual-combined-volumes-1-2a-2b-2c-2d-3a-3b-3c-3d-and-4.html", "软件开发人员手册Volume1:10.4.6.3") 可得到下表：

#grid(rows: 2, 
  image("../assets/lab2-prefetch-table1.png"), 
  image("../assets/lab2-prefetch-table2.png")
)

可以看到，对于不同的架构，预取指令的目标地址有所不同。其中值得我们注意的是临时性数据和非临时性数据的区别，该手册中给出了如下描述：

#quote(
  attribution: "Intel® 64 and IA-32 Architectures Software Developer’s Manual Volume 1: 10.4.6.2"
)[
  Data referenced by a program can be temporal (data will be used again) or non-temporal (data will be referenced once and not reused in the immediate future).

    To make efficient use of the processor’s caches, it is generally desirable to cache temporal data and not cache non-temporal data. Over-loading the processor’s caches with non-temporal data is sometimes referred to as “polluting the caches.”
]

由该描述可知，对于预取指令，`prefetchnta` 在一般情况下不需要使用。

=== 程序分析
我们首先对原始程序进行分析。

==== 冗余计算分析
在原始程序的最内层循环中有如下代码：
```yasm
    mov DIM_N, %rax
    mul loop_k
    mov %rax, mat_elem_idx
    add loop_n, mat_elem_idx          // 计算 k*N+n
    flds (MAT_B, mat_elem_idx, 4)     // 加载 B[k][n]
```
可以看到对于 $k * N$ 的计算是存在大量重复的，完全可以在最外层循环中计算一次，然后在最内层循环中直接使用。

假定我们用寄存器 R 存放 $k * N$ 的值，则我们可以将代码修改为：
```yasm
    mov R, mat_elem_idx 
    add loop_n, mat_elem_idx     
    flds (MAT_B, R, 4)     // 加载 B[k][n]
```

显然，修改之后极大程度地减少了运行时需要的指令数。
对于 $m * N$ 亦是如此，此处不再赘述

经过上述调整后，我们的测试结果如下：
#figure(
  image("../assets/lab2-t2-opt1.png"),
  caption: [
    去除冗余计算后的测试结果
  ]
)

==== 数据访问模式分析
在经过上述调整后，我们将注意力转向数据访问模式。原汇编代码的数据访问模式与下面的C代码相同。

```c
// A: M x K
// B: K x N
// C: M x N
for (int k = 0; k < K; k++) {
  for (int i = 0; i < M; i++) {
    for (int j = 0; j < N; j++) {
      C[i][j] += A[i][k] * B[k][j];
    }
  }
}
```

我们可以看到两种数据访问模式：
- Streaming Access: 最内层循环对矩阵 B 和 C 的一行进行连续访问
- Strided Access: 最外层循环对矩阵 A 的一列进行连续访问

这两种模式在现代处理器中都能够很好地通过硬件预取提高效率，不必要的软件预取反而会降低效率。因此，我们需要慎重的插入预取指令。

常用的预取方式有：
#grid(rows: 2, row-gutter: 2em,
  figure(
  [
    ```c 
    for (size_t i = 0; i < n; i++) {
      __builtin_prefetch(&a[index[i + 8]]);
      a[index[i]]++;
    }
    ```
  ], caption: [
    预取固定偏移处的数据
  ], numbering: none
  ),
  figure(
  [
  ```c 
  for (size_t ii = 0; ii < n; ii +=8) {
    size_t ii_end = std::min(ii + 8, n);
    for (size_t i = ii; i < ii_end; i++) {
        __builtin_prefetch(&a[index[i]]);
    }
    for (size_t i = ii; i < ii_end; i++) {
        a[index[i]]++;
    }
  }
  ```
  ],caption: [
    分块后先预取数据再计算 
  ], numbering: none
  )
)

我们选择使用第二种方式，即先预取数据再计算。这是因为在最密集的循环中，预取指令的插入可能会降低效率，因此我们选择在循环外插入预取指令。

我们选择对矩阵 B 的行进行预取，有如下考虑：
- 预取矩阵 A 同一列下一行在很长时间内不会被访问
- 矩阵 C 的数据属于 Load-Use-Write 模式，预取其数据意义不大
- 矩阵 B 的一行在很长时间内都会被多次访问

因此，我们在最外层循环插入下面的汇编代码：
```yasm
DO_LOOP_K:
    xor loop_m, loop_m

    mov DIM_N, r_kn
    imul loop_k, r_kn
// ---------------------
    mov r_kn, prefetch_idx
    xor %rax, %rax
PREFETCH_LOOP:
    add %rax, prefetch_idx
    prefetcht0 (MAT_B, prefetch_idx, 4)
    add $16, %rax
    cmp DIM_N, %rax
    jl PREFETCH_LOOP
// ---------------------
  ...
```
即将矩阵 B 的一行全部预取进 L1 Cache 中。`add $16 %rax` 中的常数 8 是实验性的，需要根据机器的 L1 Cache 行大小进行调整。

举例来说，在 Lab 1 中我们得到 L1 Cache 行大小为 64 字节，即 16 个 int 类型数据。因此我们每隔 16 个 int 插入一次预取指令。

测试结果如下：

#grid(
  rows: 2, row-gutter: 2em,
  figure(
    image("../assets/lab2-t2-opt2-1.png"),
    caption: [
      利用预取技术优化性能测试结果, (M, N, K) = (1024, 1024, 1024)
    ], numbering: none
  ),
  figure(
    image("../assets/lab2-t2-opt2-2.png"),
    caption: [
      利用预取技术优化性能测试结果, (M, N, K) = (1024, 1024, 2048)
    ], numbering: none
  )
)

可以看出 Gflops 值相较于原始程序有了显著提升，说明预取技术对程序性能的提升是有效的。
