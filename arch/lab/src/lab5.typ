#import "../template.typ": *

= Lab5: Shared Memory and Synchronization
== 实验准备
与实验四相同。

== 实验原理
在 CUDA 编程中，共享内存（Shared Memory）是一种高速缓存，用于存储线程块（Thread Block）中线程共享的数据。共享内存的读写速度远高于全局内存，因此可以通过共享内存提高程序的性能。

为正确使用共享内存，需要配合同步机制，保证线程之间的数据一致性。在本次实验中，我们为输出矩阵的每一个子块分配一个Block进行计算，通过共享内存存储输入矩阵的子块，提高对内存的访问效率。

== 实验实现

```cpp
const int TILE_WIDTH = 64; // 定义块block大小
/**
 * @brief C = A @ B
 * @param A Input matrix A
 * @param B Input matrix B
 * @param C Output matrix C
 * @param wA Width of matrix A
 * @param wB Width of matrix B
 */
const int BLOCK_SIZE = TILE_WIDTH;
__global__ void MatrixMulSharedMemKernel(float *A,
                                         float *B, float *C, int wA,
                                         int wB)
{
  // Block index
  int bx = blockIdx.x;
  int by = blockIdx.y;

  // Thread index
  int tx = threadIdx.x;
  int ty = threadIdx.y;

  float Csub = 0.0f;

  ... // Load the matrices from device memory to shared memory
  ... // And Compute the multiplication

  // Write the block sub-matrix to device memory; each thread writes one element
  int cCol = bx * BLOCK_SIZE + tx;
  int cRow = by * BLOCK_SIZE + ty;
  if (cCol < wB && cRow < wA)
  {
    C[cRow * wB + cCol] = Csub;
  }
}
```
如上面的代码所示，对每一个线程块（Thread Block）的并行计算，其对应输出矩阵的一个子块，块中的每一个线程对应输出子块内的一个元素。

需要注意的是，本实验中假定了输入矩阵为相同大小的方阵 `wA = wB = size`，查看主函数代码即可得知。这是由模板代码所决定的......

分块加载元素并进行计算的代码如下：

```cpp
for (int blk = 0; blk < wA; blk += BLOCK_SIZE)
  {
    // Shared memory for the sub-matrix A and B
    __shared__ float As[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ float Bs[BLOCK_SIZE][BLOCK_SIZE];

    // Load the matrices from device memory to shared memory
    // each thread loads one element of each matrix
    int aRow = by * BLOCK_SIZE + ty;
    int aCol = blk + tx;
    if (aRow < wA && aCol < wA)
    {
      As[ty][tx] = A[aRow * wA + aCol];
    }
    else
    {
      As[ty][tx] = 0.0;
    }

    int bRow = blk + ty;
    int bCol = bx * BLOCK_SIZE + tx;
    if (bRow < wB && bCol < wB)
    {
      Bs[ty][tx] = B[bRow * wB + bCol];
    }
    else
    {
      Bs[ty][tx] = 0.0;
    }
    // Synchronize to make sure the matrices are loaded
    __syncthreads();

    // Multiply the two matrices
    for (int k = 0; k < BLOCK_SIZE; ++k)
    {
      Csub += As[ty][k] * Bs[k][tx];
    }

    // Synchronize to make sure that the preceding computation is done before loading two new sub-matrices of A and B in the next iteration
    __syncthreads();
  }
```

需要注意边界检查，防止越界访问。同时需要注意：
- 必须等待块内的所有线程加载完毕后再进行计算
- 必须等待一个块的计算完毕后再加载下一个块的数据

上两个同步点的作用是保证线程之间的数据一致性，使用 `__syncthreads()` 函数实现。

而后在主函数中取消注释该函数以进行调用即可。

```cpp
int main(int argc, char **argv)
{
    ...
    for (int j = 0; j < nIter; j++)
    {
        // matrixMulCPU(reference, h_M, h_N, m, k, n);
        // MatrixMulKernel<<<grid, block>>>(d_M, d_N, d_P, m);
        MatrixMulSharedMemKernel<<<grid, block>>>(d_M, d_N, d_P, m, n);
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

运行结果如下：
#figure(
  image("../assets/lab5-res.png"),
  caption: [
    共享内存优化结果
  ],
)

相较于实验四的结果，共享内存优化后的程序性能有了明显提升。

== CUBLAS
为观察CUBLAS库的性能，取消注释 `cublasSgemm` 函数调用以及文件开头的`USE_CUBLAS` 宏定义，编译程序并运行结果如下：
#figure(
  image("../assets/lab5-res1.png"),
  caption: [
    CUBLAS库性能结果
  ],
)

可以看到，CUBLAS库的性能远高于我们自己实现的矩阵乘法函数。