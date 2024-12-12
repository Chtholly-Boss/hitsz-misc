#import "../template.typ": *

= Lab 4: 使用 C/CUDA 编写 GPU 代码

== 实验准备

下载实验包并解压：
```shell-unix-generic
wget http://10.249.10.96:3011/lab4-5.tar.gz
tar xzvf lab4-5.tar.gz
cd lab4-5
```

== 实验原理
本实验基于 CUDA 编程模型，使用 C/CUDA 编写 GPU 代码。

#figure(
  image("../assets/lab4-grid-block-thread.png"),
  caption: [
    Grid of Thread Blocks, from Nvidia CUDA Programming Guide
  ],
)

通过对每一个线程块（Thread Block）的并行计算，可以实现对大规模数据的高效处理。每一个线程块包含多个线程（Thread），线程之间可以通过共享内存（Shared Memory）进行通信。

在本次实验中，通过每个线程计算输出矩阵的一个元素，实现矩阵乘法的并行计算。

== 实验实现
由于模板代码中已将 CPU 与 GPU 之间的数据传输逻辑完成，本次实现只需关注矩阵乘法的核心逻辑。

```cpp
//! For square matrices only
__global__ void MatrixMulKernel(float *d_M, float *d_N, float *d_P, int width)
{
  // *** TODO: Compute the row index for the current thread ***
  int row = threadIdx.y + blockIdx.y * blockDim.y;

  // *** TO DO: Compute the column index for the current thread ***
  int col = threadIdx.x + blockIdx.x * blockDim.x;

  // Ensure the thread is within bounds
  if ((row < width) && (col < width))
  {
    float pValue = 0.0;

    // *** TO DO: Implement the matrix multiplication for a single element ***
    for (int k = 0; k < width; ++k)
    {
      pValue += d_M[row * width + k] * d_N[k * width + col];
    }

    // *** TO DO: Write the computed value to the correct position in d_P ***
    d_P[row * width + col] = pValue;
  }
}
```

实现较为直接，仅需注意边界检查，防止越界访问。

而后在主函数中取消注释该函数以进行调用即可
```cpp
int main(int argc, char **argv)
{
    ...
    for (int j = 0; j < nIter; j++)
    {
        // matrixMulCPU(reference, h_M, h_N, m, k, n);
        MatrixMulKernel<<<grid, block>>>(d_M, d_N, d_P, m);
        // MatrixMulSharedMemKernel<<<grid, block>>>(d_M, d_N, d_P, m, n);
        // cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, n, m, k, &alpha, d_N, n, d_M, k, &beta, d_P, n);
    }
    ...
}
```

编译程序得到可执行文件，由于模板代码中使用了 cublas 库，因此需要链接该库：
```shell-unix-generic
nvcc -o run matrix_mul.cu -lcublas
./run 1 1000 # 1 表示进行精度检查，1000 表示矩阵大小
./run 0 2000
./run 0 5000
./run 0 10000
```

运行结果如下
#figure(
  image("../assets/lab4-res.png"),
  caption: [
    不同参数下的运行结果
  ],
)
