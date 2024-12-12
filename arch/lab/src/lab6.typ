#import "../template.typ": *

#show: apply-template.with(author: "马奕斌")
#set heading(numbering: "1.1")
#show heading.where(level: 1): set heading(numbering: (.., num) => {
  sym.circle
})

= Lab 6:
== 实验准备
下载并解压实验包
```bash
wget http://10.249.10.96:3011/lab6/stories15M.bin
wget http://10.249.10.96:3011/lab6/stories42M.bin
wget http://10.249.10.96:3011/lab6/stories110M.bin

wget http://10.249.10.96:3011/lab6/llama2.c.tar.gz
tar xvzf llama2.c.tar.gz
```

本次实验可采取多种方式进行优化，我采用了 AVX 和 CUBLAS 两种方式进行实现。

测试过程中需要反复进行编译运行，为此，我们在 Makefile 中添加了多个目标，以便于快速编译运行。
```make
.PHONY: run rungpu runavx

run: run.c
	$(CC) -O3 -o run run.c -lm
runavx:
	$(CC) -mavx -O3 -o run run.c -lm
rungpu: run.c
	nvcc -O3 -o run run.c -lm -L/usr/local/lib64 -lcublas
```

为了便于切换不同的实现方式，我们提取出 `run.c` 中的 `matmul` 函数并将其置于文件开头，利用宏定义 `USE_CPU` 包裹它。

```cpp
#ifdef USE_CPU
void matmul(float *xout, float *x, float *w, int n, int d)
{
    // W (d,n) @ x (n,) -> xout (d,)
    // by far the most amount of time is spent inside this little function
    int i;
#pragma omp parallel for private(i)
    for (i = 0; i < d; i++)
    {
        float val = 0.0f;
        for (int j = 0; j < n; j++)
        {
            val += w[i * n + j] * x[j];
        }
        xout[i] = val;
    }
}
#endif
```

对于 AVX 和 CUBLAS 两种实现方式，我们分别定义了 `USE_AVX` 和 `USE_GPU` 宏，并在 `run.c` 中使用 `#ifdef` 进行选择。

```cpp
#define USE_CPU
// #define USE_GPU
// #define USE_AVX

#ifdef USE_CPU
void matmul(float *xout, float *x, float *w, int n, int d)
{
    ...
}
#endif

#ifdef USE_AVX
#include <immintrin.h>
void matmul(float *xout, float *x, float *w, int n, int d)
{
  ...
}
#endif

#ifdef USE_GPU
#include <cuda_runtime.h>
#include <cublas_v2.h>
#include <device_launch_parameters.h>

void matmul(float *xout, float *x, float *w, int n, int d)
{
  ...
}
#endif
```

以 AVX 为例，测试过程如下：
- 取消注释 `#define USE_AVX`, 注释其他两个宏
- 运行 `make runavx`
- 运行 `./run stories15M.bin`, 或使用其他数据集

== 数据规模
通过在 `matmul` 函数起始位置插入 `printf` 语句。
```cpp
void matmul(float *xout, float *x, float *w, int n, int d)
{
  printf("param: d: %d, n: %d\n", d, n);
  ...
}
```

编译运行测试数据集 `stories15M.bin`，并筛选出 `param` 行，排序并对连续重复的行进行去重。
```bash
make run
./run stories15M.bin | grep "^param" | sort | uniq
```
结果如下
#figure(
  image("../assets/lab6-param.png"),
)

可以看到，模型中涉及的矩阵规模有限，后续优化中可考虑使用足够大的空间存储。

== 实验实现与测试结果
=== OpenMP 实现
从模板代码可以看到其中使用了 `#pragma omp parallel for private(i)` 指示编译器使用 OpenMP 进行并行化。测试结果如下：

#figure(
  image("../assets/lab6-cpu.png"),
  caption: [
    OpenMP 实现性能测试
  ],
)

=== AVX 实现
```cpp
#include <immintrin.h>
void matmul(float *xout, float *x, float *w, int n, int d)
{
    // W(d, n) @x(n, )->xout(d, )
    // by far the most amount of time is spent inside this little function
    for (int i = 0; i < d; i++)
    {
        float val = 0.0f;
        for (int j = 0; j < n - 8; j += 8)
        {
            __m256 w_vec = _mm256_loadu_ps(w + i * n + j);
            __m256 x_vec = _mm256_loadu_ps(x + j);
            __m256 mul = _mm256_mul_ps(w_vec, x_vec);
            val += mul[0] + mul[1] + mul[2] + mul[3] + mul[4] + mul[5] + mul[6] + mul[7];
        }
        for (int j = n - n % 8; j < n; j++)
        {
            val += w[i * n + j] * x[j];
        }
        xout[i] = val;
    }
}
```
为使用 AVX 指令集，我们引入了 `immintrin.h` 头文件，并使用 `_mm256_loadu_ps` 和 `_mm256_mul_ps` 等函数进行向量化计算。

需要注意的是矩阵的列数 `n` 不一定是 8 的倍数，因此我们需要对最后一部分数据进行特殊处理。

测试结果如下：
#figure(
  image("../assets/lab6-avx.png"),
  caption: [
    AVX 实现性能测试
  ],
)

可以看到，相较于 OpenMP 实现，AVX 实现的性能在三个测试中均有显著提升。

=== CUBLAS 实现
利用 CUBLAS 库，我们可以直接调用 GPU 进行矩阵乘法运算。
```cpp
#include <cuda_runtime.h>
#include <cublas_v2.h>
#include <device_launch_parameters.h>

void matmul(float *xout, float *x, float *w, int n, int d)
{
    // W (d,n) @ x (n,) -> xout (d,)
    // by far the most amount of time is spent inside this little function
    float *h_M, *h_N, *d_M, *d_N;
    float *h_P, *d_P;

    size_t sizeM = d * n * sizeof(float);
    size_t sizeN = n * 1 * sizeof(float);
    size_t sizeP = d * 1 * sizeof(float);

    h_M = w;
    h_N = x;
    h_P = xout;

    // Allocate device memory
    cudaMalloc(&d_M, sizeM);
    cudaMalloc(&d_N, sizeN);
    cudaMalloc(&d_P, sizeP);

    // Copy data from CPU to GPU
    cudaMemcpy(d_M, h_M, sizeM, cudaMemcpyHostToDevice);
    cudaMemcpy(d_N, h_N, sizeN, cudaMemcpyHostToDevice);

    cublasHandle_t handle;
    cublasCreate(&handle);

    const float alpha = 1.0f;
    const float beta = 0.0f;

    cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, 1, d, n, &alpha, d_N, 1, d_M, n, &beta, d_P, 1);

    // Copy data from GPU to CPU
    cudaMemcpy(h_P, d_P, sizeP, cudaMemcpyDeviceToHost);

    cudaFree(d_P);
    cudaFree(d_M);
    cudaFree(d_N);
    cublasDestroy(handle);
}
```

测试结果如下：
#figure(
  image("../assets/lab6-cuda.png"),
  caption: [
    CUBLAS 实现性能测试
  ],
)

可以看到，相较于 OpenMP 实现，CUBLAS 实现的性能有所下降，观察代码可以推断出性能瓶颈在于
- GPU 上内存的分配与释放
- CPU 与 GPU 之间的数据传输
- 重复的创建销毁 cublasHandle_t 对象。

由数据规模可知，权重的最大参数为 (32000, 768), 输入的最大参数为 (2048,)，因此我们可以考虑直接在 GPU 上分配足够大的空间，减少数据分配与释放的开销。同时，我们将句柄的创建与销毁放在主函数中，避免重复创建销毁。
```cpp
#ifdef USE_GPU
#include <cuda_runtime.h>
#include <cublas_v2.h>
#include <device_launch_parameters.h>
float *d_M, *d_N, *d_P;
cublasHandle_t handle;
void matmul(float *xout, float *x, float *w, int n, int d)
{
    // W (d,n) @ x (n,) -> xout (d,)
    // by far the most amount of time is spent inside this little function
    float *h_M, *h_N, *h_P;

    size_t sizeM = d * n * sizeof(float);
    size_t sizeN = n * 1 * sizeof(float);
    size_t sizeP = d * 1 * sizeof(float);

    h_M = w;
    h_N = x;
    h_P = xout;

    // Copy data from CPU to GPU
    cudaMemcpy(d_M, h_M, sizeM, cudaMemcpyHostToDevice);
    cudaMemcpy(d_N, h_N, sizeN, cudaMemcpyHostToDevice);

    const float alpha = 1.0f;
    const float beta = 0.0f;

    cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, 1, d, n, &alpha, d_N, 1, d_M, n, &beta, d_P, 1);

    // Copy data from GPU to CPU
    cudaMemcpy(h_P, d_P, sizeP, cudaMemcpyDeviceToHost);
}
#endif

int main(int argc, char *argv[])
{
  ...
// * LAB6 : Alloc Device Memory
#ifdef USE_GPU
    cublasCreate(&handle);
    cudaMalloc(&d_M, 32000 * 2048 * sizeof(float));
    cudaMalloc(&d_N, 2048 * sizeof(float));
    cudaMalloc(&d_P, 32000 * sizeof(float));
#endif

  // run!
  ...
// * LAB6 : free Device Memory
#ifdef USE_GPU
    cudaFree(d_P);
    cudaFree(d_M);
    cudaFree(d_N);
    cublasDestroy(handle);
#endif
  ...
  return 0;
}
```

再次测试 CUBLAS 实现，结果如下：
#figure(
  image("../assets/lab6-cuda-beta.png"),
  caption: [
    优化后的 CUBLAS 实现性能测试
  ],
)

可以看到，优化后的 CUBLAS 实现性能有所提升，但仍然不如 AVX 实现或 OpenMP 实现。初步推断瓶颈在于数据传输的开销。由于推理过程中不断地在 CPU 和 GPU 之间切换计算，导致性能下降。

一个合理的思路是将计算部分进行 Fusing 后，一次性传输数据到 GPU 上进行计算，再将结果传回 CPU。这样可以减少数据传输的次数，提高性能。