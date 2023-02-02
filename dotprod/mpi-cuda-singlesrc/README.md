# Dot Product with MPI + CUDA

## Usage

启动两个MPI进程，并绑定到两GPU上

```bash
mpirun -n 2 ./dotprod.exe
```

## Notes

- 每一个MPI进程会绑定到一个GPU上
    - 但允许MPI进程数超过GPU数量，此时超出的MPI进程会与其他MPI进程共用一张显卡
- GPU版本的代码不比CPU版本快也是正常现象
    - 因为Host Memory与Device Memory之间搬运数据的开销非常大
    - 而Dot Product的计算不够复杂，计算时间对于总时间而言占比非常的小
- GPU版本的代码调用了NVIDIA Thrust库完成计算
    - 不嫌麻烦也可以自己手写CUDA代码
    - 其实也可以调cuBLAS或者CUTLASS库
