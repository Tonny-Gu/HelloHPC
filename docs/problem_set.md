# HelloHPC - 编译运行专题

```
Revision: Draft-3
```

## Welcome

欢迎诸位年轻人入坑高性能计算（HPC）。本题目的题型并非超算比赛的常规题型，出这题的目的在于让大家在（做其他题目的过程中）编译失败的时候，能够有那么一丢丢头绪去排查问题。想必各位在打超算比赛的过程中，领略到了超算环境的艰险：既没有root权限用不了apt，又有许多盘根错节交杂在一起的编译器和库，这使得超算环境成为了编译失败的事故高发地，也因此每年超算比赛都有无数选手倒在了编译这步上。另外，驾驭编译器也是超算比赛的重要的调优手段之一。

## Background

考虑到大家（以及出题人）的数学水平，我们不妨整点大家都能看得懂的东西作为背景：向量点乘（Dot Product）。计算方法如下，如果完全看不懂建议本升高进修一下。
$$
a = [a_1, a_2, \cdots, a_n]
$$

$$
b = [b_1, b_2, \cdots, b_n]
$$

$$
a \cdot b = \sum_{i=1}^n{a_i b_i}=a_1 b_1 + a_2 b_2 + \cdots + a_n b_n
$$

本题以向量点乘的代码为例，来引导各位运用（踩坑）超算环境上常用的编译技巧。

## Submission

- 本道赛题要求提交**每个小题**的**报告**和**脚本**

- 每个小题的报告合并成一个文件提交，报告的内容为每道小题指定的内容

  - 报告**不要水太长**，完成要求即可，评委会本着差不多就得了的原则进行给分
  - 如果实在做不出来，报告里可以写一写挣扎的过程，评委残存的少量同情心说不定会给分

- 每个小题的脚本是一个包含了所有完成这道小题所需的命令的**bash**脚本，以1.1小题为例，脚本的参考格式如下：

  ```bash
  #!/bin/bash
  
  module load ...
  module load ...
  
  export ENV1=...
  export ENV2=...
  
  cd /home/tonny/q1-1/native-singlesrc
  gcc -O0 main.c -o main.O0.gcc.out
  icc -O0 main.c -o main.O0.icc.out
  
  gcc ...
  icc ...
  
  ./main.O0.gcc.out
  ./main.O0.icc.out
  ./main.O3.gcc.out
  ./main.O3.icc.out
  ```

  - `export`命令配置的环境变量会在整个脚本内生效，若希望环境变量只作用于某条特定的命令，可以这么写：

    ```bash
    LIBRARY_PATH=./ CPATH=./ gcc ...
    ```

  - 在脚本开头处，执行其他命令之前，须使用`cd` + **绝对路径**（而不是相对路径）切换工作路径到指定的位置

- **请为每个小题创建一个目录**（文件夹），并把赛题提供的文件复制到该目录下

  - **不允许单独调整个别赛题文件（或文件夹）的路径**，比如将某个文件夹的内的头文件移出文件夹，以及将某个文件夹移动到另一个文件夹里
  - 可以自行指定生成文件（如动态链接库）的路径

- 在赛题没有要求的情况下，不可以修改赛题提供的文件

## Notes

- 本题对**使用的节点**， **程序运行的速度不做要求**。但**要求在报告中提及运行的节点信息**。
- 本题**不要求**运行在多节点上。
- 题目的难度**并不是**递增分布，做不出来可以先试着往后做，说不定能找到灵感。
- 请善用搜索引擎（指多Google少Baidu，多Stack Overflow少CSDN，最好不要瞎试来源不明，只有结论没有原因分析的野方法）。

## Part 1. 编译器的基础使用 (40pts)

在踩比较高级的坑（比如自动化编译工具带来的坑）之前，首先需要踩一点基础的坑。把编译过程自己的坑踩明白了，才（有可能）会踩明白更高级的坑。本部分不涉及到GNU Make（Makefile），CMake等自动化编译工具，要求使用原味的编译命令（不借助任何一种自动化编译工具）完成这一部分。

### 1.1 编译运行单个文件 (10pts)

使用任意**两种编译器**（如GCC和ICC）并启用`-O0`和`-O3`两种编译优化等级，编译`native-singlesrc/main.c`文件。

报告提交内容：

- 运行时间的对比，参考格式：

  |      | GCC  | ICC  |
  | ---- | ---- | ---- |
  | O0   | 1s   | 2s   |
  | O3   | 3s   | 4s   |

### 1.2 编译自制库 (10pts)

使用任意一种编译器，将`native-userlib-cmake`下的源文件编译成**动态链接库**。（注：本题不可使用CMake）

报告提交内容：

- 无

> 提示：
>
> - 可能用到的编译开关：`-shared`, `-fPIC`

### 1.3 链接自制库 (10pts)

使用任意一种编译器，编译`native-usermain-make`下的`main.c`，并链接到**1.2**编译产生的动态链接库，然后运行程序。（注：本题不可使用GNU Make）

报告提交内容：

- 程序运行成功的截图（含程序自动输出的运行时间）

> 提示：
>
> - 可能用到的环境变量：`LD_LIBRARY_PATH`
> - 可能用到的编译开关：`-L`, `-l`, `-I`
>   - `-L`的环境变量平替：`LIBRARY_PATH`
>   - `-I`的环境变量平替：`CPATH`
> - 可以通过让编译器输出所有include的路径来检查`-I`和`LIBRARY_PATH`是否正确配置
>   - https://stackoverflow.com/questions/17939930/finding-out-what-the-gcc-include-path-is

### 1.4 使用 BLAS 库加速计算 (10pts)

重写`native-singlesrc/main.c`的`dot_product`函数，使该函数调用BLAS库的`cblas_ddot`函数完成计算。使用任意一种编译器，编译运行修改后的`main.c`文件，并对比文件修改前的运行时间。

报告提交内容：

- 修改后的`dot_product`函数代码
- 文件修改前和修改后的运行时间（可直接使用1.1的结果，但要求使用相同优化等级和相同编译器）
- 程序运行成功的截图（含程序自动输出的运行时间）

> 提示：
>
> - BLAS库有很多变种，比如LAPACK，OpenBLAS和MKL。一般情况下我们会使用Intel的MKL库，因为其安装方便（下载解压即可），同时性能极佳。
> - 可以使用`module`加载超算预装的BLAS库。但是当`module`未能正确配置`LIBRARY_PATH`和`CPATH`两个环境变量时，仍可能需要手动配置`-L`和`-I`两个编译参数。使用`env`或者`printenv`命令可以显示当前配置的环境变量。
>   - 也可以自己用`spack`和`conda`装其他BLAS库，但有可能会遇到意想不到的问题。
> - 可能需要加`-l`指明需要链接的库文件（如.so文件）。
> - 扩展知识：`spack`以及一些超算的`module`上可能配置了`PKG_CONFIG_PATH`环境变量。这个时候可以用`pkg-config`生成编译器需要的`-I`和`-L`参数，但这个方法不是非常流行，因此本赛题并不会涉及`pkg-config`。

## Part 2. 自动化编译工具的基础使用 (30pts)

现代C/C++工程往往采用了自动化编译工具来管理大量的源代码。自动化编译工具一般提供了并行编译，增量编译，环境检查，管理编译连接参数，生成和打包库等等对大型工程非常实用的功能，然而这些工具在提供便利的同时，也使得编译的过程变得不那么透明，还可能需要用另一套语法来解决编译出现的问题。

### 2.1 编译自制库 (15pts)

分别使用GNU Make和CMake将`native-userlib-make`和`native-userlib-cmake`下的源码**通过ICC编译器并启用-O1优化**编译为动态链接库。

报告提交内容：

- 如有文件改动，提交修改后的文件内容

> 提示：
>
> - 对于GNU Make，往往通过修改`Makefile`来更换编译器和指定编译优化等级。
> - 对于CMake，可以指定环境变量来指定使用的编译器，可以修改`CMakeLists.txt`来指定编译优化等级。
>   - https://stackoverflow.com/questions/45933732/how-to-specify-a-compiler-in-cmake
>   - https://stackoverflow.com/questions/41361631/optimize-in-cmake-by-default
> - 有时候CMake默认会将编译生成的库安装到`/usr/lib64`和`/usr/include`目录中，这是所有编译器都会自动搜索的一个默认路径，也是使用`apt`安装库会安装到的地方，所以在自己的电脑上，我们很少需要手动指定`-I`和`-L`。但是很遗憾，给这个目录添加文件需要sudo权限。所以可以参考这个方法去修改安装路径：
>   - https://stackoverflow.com/questions/6003374/what-is-cmake-equivalent-of-configure-prefix-dir-make-all-install

### 2.2 链接自制库 (15pts)

分别使用GNU Make和CMake**通过ICC编译器并启用-O1优化**编译`native-usermain-make`和`native-usermain-cmake`下的源码，并链接到**2.1**的编译产生的库，然后运行程序。

注：共四种链接组合

- `native-usermain-make`与`native-userlib-make`
- `native-usermain-make`与`native-userlib-cmake`
- `native-usermain-cmake`与`native-userlib-make`
- `native-usermain-cmake`与`native-userlib-cmake`

报告提交内容：

- 如有文件改动，提交修改后的文件内容
- 程序运行成功的截图（含程序自动输出的运行时间）

> 提示：
>
> - 对于GNU Make，可能会用到编译开关：`-L`, `-l`, `-I`
> - 对于CMake，可能需要修改`CMakeLists.txt`
>   - https://stackoverflow.com/questions/28597351/how-do-i-add-a-library-path-in-cmake

## Part 3. 套壳编译器的基础使用 (30pts)

有一些“编译器”看起来像真的一样（说的就是你`mpicc`），实际上这些“编译器”只是一个空壳，背地里在悄悄调用别的编译器罢了，但是在超算环境中，往往存在多个编译器，当这些套壳编译器调用了不该调用的编译器的时候，或许它就会给你一点小小的编译器震撼。

MPI整套壳编译器的本意是帮助用户添加一部分`-L`,`-l`, `-I`参数。而NVCC在编译CPU代码的时候，也会调用别的编译器，它只有在编译GPU代码的时候才会真正起作用。（注：NVC和NVCC是两个完全不同的东西，前者的前身是PGI编译器，用于编译CPU代码，后者基于LLVM编译器，用于编译GPU代码）。

### 3.1 MPI (10pts)

通过**MPICC和ICC，并启用-O1优化**编译后运行`mpi-singlesrc/main.c`文件。需要补全`Makefile`文件后使用GNU Make编译。本题程序**不要求**运行在多节点上。

报告提交内容：

- 补全后的Makefile文件
- 程序运行成功的截图（含程序自动输出的运行时间）

>  提示：
>
> - MPI像BLAS一样，有很多种实现，如Intel MPI，OpenMPI，MVAPICH等等。超算比赛常用前两种，前者多用于纯CPU程序，后者因为有NVIDIA优化过的版本，多用于GPU程序。本题推荐使用OpenMPI。
> - 推荐使用`module`加载超算预装的MPI库。
>   - 也可以自己安装其他MPI库，常用的有：Intel OneAPI里的Intel MPI，NVIDIA HPC SDK里的OpenMPI。
> - 对于OpenMPI，可能用到的环境变量：`OMPI_CC`, `OMPI_CXX`
>   - https://www.open-mpi.org/faq/?category=mpi-apps
> - 对于OpenMPI，可以使用`mpicc --showme`查看真实使用的编译器

### 3.2 NVCC (10pts)

通过**NVCC和ICC，并启用-O1优化**编译后运行`cuda-singlesrc/main.cu`文件。需要补全`Makefile`文件后使用GNU Make编译。

报告提交内容：

- 补全后的Makefile文件
- 程序运行成功的截图（含程序自动输出的运行时间）

> 提示：
>
> - 可能用到的编译开关：`-ccbin`
> - NVCC包含在CUDA Toolkit里。可以使用`module`加载超算预装的CUDA Toolkit。但是在一些超算上，这个东西可能只有在GPU节点上才有。
> - `.cu`其实是C++的源文件的魔改。注意`CC`与`CXX`, `gcc`与`g++`的区别。

### 3.3 NVCC + MPI (10pts)

通过**NVCC、MPICC和ICC，并启用-O1优化**编译后运行`mpi-cuda-singlesrc/main.c`文件。需要补全`Makefile`文件后使用GNU Make编译。本题程序**不要求**运行在多节点上。

报告提交内容：

- 补全后的Makefile文件
- 程序运行成功的截图（含程序自动输出的运行时间）

> 提示：
>
> - 想清楚谁调用谁调用谁
> - 只有NVCC可以处理`.cu`文件
