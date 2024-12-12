#import "../template.typ": *

= x86 汇编语言
== 准备工作
首先需要下载并解压实验包：
```shell-unix-generic
wget http://10.249.10.96:3011/lab1.tar.gz
tar xzvf lab1.tar.gz
```

确保安装了 `cmake, gcc, perf` 等工具。

== 练习 1
本部分较为简单，下面直接给出结果：
第一小问只需在 TODO 处填入 `cmp $0, %rax` 即可。

第二小问解答如下：

#figure(
grid(
  columns: (1fr, 1fr),
  column-gutter: 1em, 
  [
    ```yasm
    // 系统调用号 (sys_write) // TODO: ...
    mov $1, %rax
    // 文件描述符 (stdout)
    mov $1, %rdi
    // 指向字符串的指针
    mov %rdi, %rsi
    // 要写入的字节数
    mov %rdx, %rdx
    // 执行系统调用
    syscall
    ```
  ], 
  [    
    ```yasm
    // 系统调用号 (sys_write) // TODO: ...
    mov $1, %rax
    // 指向字符串的指针
    mov %rdi, %rsi 
    // 文件描述符 (stdout)
    mov $1, %rdi
    // 要写入的字节数
    mov %rdx, %rdx
    // 执行系统调用
    syscall
    ```
  ]
),
caption: [
  修复系统调用，先将 rdi 寄存器的值转移到 rsi 后再写入
]
)

构建并运行测试：
```shell-unix-generic
mkdir -p build && cd build
cmake -B . -S ../ && cmake --build ./ --target lab1_print_integer
./dist/bins/lab1_print_integer
```

运行结果如下：

#figure(
  image("../assets/lab1-t1-res.png"),
  caption: [
    练习 1 运行结果
  ]
)

== 练习 2
本部分较为简单，下面直接给出结果：

```yasm
// TODO: 将矩阵B的地址存入MAT_B宏对应的寄存器
mov %rdx, MAT_B
...
// TODO： 加载A[m][k]
mov loop_m, mat_elem_idx
imul DIM_K, mat_elem_idx
add loop_k, mat_elem_idx
...
// TODO： 加载B[k][n]
mov loop_k, mat_elem_idx
imul DIM_N, mat_elem_idx
add loop_n, mat_elem_idx
...
// TODO: 加载C[m][n]
mov loop_m, mat_elem_idx
imul DIM_N, mat_elem_idx
add loop_n, mat_elem_idx
```

在 build 目录下执行以下命令：
```shell-unix-generic
cmake -B . -S ../ && cmake --build ./ --target lab1_test_gemm_kernel.unittest
./dist/bins/lab1_test_gemm_kernel.unittest --gtest_filter=gemm_kernel.test0
```

运行结果如下：

#figure(
  image("../assets/lab1-t2-res1.png"),
  caption: [
    练习 2 运行结果 1
  ]
)

进一步构建并运行测试：
```shell-unix-generic
cmake -B . -S ../ && cmake --build ./ --target lab1_gemm
./dist/bins/lab1_gemm 256 256 256
```

运行结果如下：

#figure(
  image("../assets/lab1-t2-res2.png"),
  caption: [
    练习 2 运行结果 2
  ]
)

== 练习 3
本部分仍较为简单，下面直接给出实现：
运行 `lscpu` 并截图如下：
#figure(
  image("../assets/lab1-t3-lscpu.png"),
  caption: [
    lscpu 运行结果
  ]
)

由上图可以得到缓存的参数：
- Caches (sum of all):
  - L1d:                    480 KiB (10 instances)
  - L1i:                    320 KiB (10 instances)
  - L2:                     12.5 MiB (10 instances)
  - L3:                     24 MiB (1 instance)

下面查看缓存的具体参数：
```shell-unix-generic
cd /sys/devices/system/cpu/cpu0/cache
(cd ./index0 && cat coherency_line_size number_of_sets ways_of_associativity)
(cd ./index1 && cat coherency_line_size number_of_sets ways_of_associativity)
(cd ./index2 && cat coherency_line_size number_of_sets ways_of_associativity)
(cd ./index3 && cat coherency_line_size number_of_sets ways_of_associativity)
```

运行结果如下：
#figure(
  image("../assets/lab1-t3-cache.png"),
  caption: [
    缓存参数
  ]
)

== 练习 4
// TODO: WSL 下无法运行，留待实验室截图
使用 perf 命令查看性能事件：
```shell-unix-generic
perf list
# 查看基本性能事件
perf stat ./dist/bins/lab1_gemm 256 256 256
# 查看指定的性能事件(-e)
perf stat -e L1-dcache-loads,L1-dcache-load-misses ./lab1_gemm 256 256 256
```

结果如下：
#stack(
  dir: ttb,
  spacing: 1em,
  figure(
    image("../assets/perf-list.jpg"),
    caption: [
      perf 基本性能事件
    ]
  ),
  figure(
    image("../assets/lab1-perf1.jpg"),
    caption: [
      perf 基本性能事件
    ]
  ),
  figure(
    image("../assets/lab1-perf2.jpg"),
    caption: [
      perf 指定性能事件
    ]
  )
)a