# 快速理解 Makefile

Makefile 是 GNU Make 这个工具所需的文件，可以看作是一个比较特殊的 Bash 脚本。而对比现代的编译辅助工具，Make 显得非常简陋，直接用这玩意如同在打火机一块钱一个的时代钻木取火，但好处就是这个工具并不是很难理解。

首先要明确的是，Make 这个工具是用来编译比较大型的工程的（就是管理一大堆源代码文件），所以它很多设计是围绕编译展开的，而且它是上世纪八十年代的产物，面向的是当时手无寸铁的程序员，至少比起啥工具都没有的情况，Make 还是有很大作用的。总的来说，Make 其实主要是在做这几件事：
- 判断是否可以跳过执行某些 Linux 命令（command）
- 确定 Linux 命令执行的顺序，并行执行不相关的命令

## 基本语法

我们先抛开编译不谈，来看 Make 的规则（Rule）的基本语法。

```makefile
target: prerequisites
    command
    command
```

Make 大概是个缝合怪，有很多东西坨在一起了。比如说目标target，就有：
- 真target：会对应一个具体的文件
- 假target（Phony Target）：和磁盘上的文件完全没关系

然后执行条件（prerequisites）是一个或者一组目标，这些目标会决定下面的命令（command）要不要被执行。

命令（command）就是 Linux 的命令，一般情况下这些命令写清楚了**如何产生一个真target**（如果 target 是真 target 的话）。

继续抛开编译不谈，来看`make/makefile1`里的简单例子，

```makefile
all: son.bak.txt
	@echo I am all # display I am all on screen
	
son.bak.txt: son.txt
	@echo I am son.bak.txt # display I am son.bak.txt on screen
	@cp son.txt son.bak.txt # copy son.txt to son.bak.txt
```

在 command 前加一个`@`，可以让 Make 不把原始命令显示出来。

这里`son.bak.txt`是一个真 target，因为真的会有`son.bak.txt`这么个文件（在执行了`cp`命令以后）。

`son.txt`也是一个真 target，并且一开始就有了。

习惯上`all`是一个假 target，类似于整个 Makefile 的入口（或者说总目标），并且会写成第一个 target（就像这里写在了第一行）。当我们执行`make`命令的时候（不手动指定 target），其实就是去产生（make）`all` target。

我们实际上并不用去特别区分真假 target，只需要知道有一些特殊的 target 就行。

什么叫 make 一个 target？其实就是：
- 如果存在一个执行条件里的 target 没有被 make 过，就先去 make 执行条件里还没 make 过的 target
- 在执行条件里所有的 target 都 make 了以后，**在某些时刻**，把它的 command 执行一遍

在这个例子里，Make 的故事是：
- 我们要 make `all` target
- Make 首先跑去 make `all`
    - 然后很快发现`son.bak.txt`没有 make 过，就跑去 make `son.bak.txt`
        - 接着一看`son.bak.txt`要求要 make `son.txt`
        - 但是
            - 没有一条关于`son.txt`的 rule
            - `son.txt`已经有这个文件了
        - 那我们就当`son.txt`已经 make 好了
        - 执行条件里所有的 target 都好了，再看发现我们没有`son.bak.txt`这个文件
            - 那就执行 command（`cp`和`echo`）
        - command 执行完了，就当`son.bak.txt` make 好了
- `all`执行条件里所有的 target 都好了，再看发现我们没有`all`这个文件
    - 那就执行 command（`echo`）（假 target 永远都要执行一次 command，毕竟对应的文件永远不存在）
- command 执行完了，就当`all` make 好了

程序输出如下：

```bash
# make
I am son.bak.txt
I am all
```

## 判断是否需要执行命令

Make 的一大作用是，当我们有一大堆代码文件的时候，我们并不希望改动一个文件就要重新编译所有的文件，当然是**拎出所有受到的影响的代码**来重新编译，这样就可以节约很多时间。所以 Make 会自动**选择性的执行** Makefile 里的 command。那什么时候 command 会被执行？

### 执行条件的 target 有更新

继续上一个例子，当我们在执行一次`make`命令以后，如果试着再`make`一次，程序的输出就只有

```bash
# make
I am all
```

很明显，只有`all` target 被执行了。在这个例子里，Make 的故事是：
- 我们要 make `all` target
- Make 首先跑去 make `all`
    - 然后很快发现`son.bak.txt`没有 make 过，就跑去 make `son.bak.txt`
        - 接着一看`son.bak.txt`要求要 make `son.txt`
        - 那我们当`son.txt`已经 make 好了
        - 执行条件里所有的 target 都好了，再看发现我们没有`son.bak.txt`这个文件
            - 我们有`son.bak.txt`，而且和`son.txt`一样新
            - 那就跳过执行 command
- `all`执行条件里所有的 target 都好了，再看发现我们没有`all`这个文件
    - 那就执行 command（`echo`）（假 target 永远都要执行一次 command，毕竟对应的文件永远不存在）
- command 执行完了，就当`all` make 好了

> 如果我们去掉 Makefile 里`all`的command，再执行`make`:
>
>```makefile
>all: son.bak.txt
>
>son.bak.txt: son.txt
>	echo I am son.bak.txt
>	cp son.txt son.bak.txt
>```
>
>输出就只剩下这些东西。这代表这次`make`啥事也没做。
>
>```bash
># make
>make: Nothing to be done for 'all'.
>```

也不难理解，我们没修改过`son.txt`，那也没有必要去重新复制一份`son.bak.txt`。Make 会根据 target 的执行条件里是否有依赖的 target 更新了（执行过 command，或者文件有新修改）来判断是否需要被重新 make 这个 target。

> 具体来说，Make 会比较`son.bak.txt`和`son.txt`的修改时间来判断两文件谁新谁旧。

我们可以编辑一下`son.txt`，随便写一些东西并保存，再执行`make`的时候，就会发现 Make 重新复制了一份`son.bak.txt`。

```bash
# echo 1 > son.txt # write 1 to file son.txt
# make
I am son.bak.txt
I am all
```

我们的`I am son.bak.txt`回来啦，意味着`son.bak.txt`被重新复制了一份。

再举一个复杂一点的例子，在`make/makefile2`里，Makefile 的内容如下：

```makefile
all: son.txt
	
son.txt: mom.txt dad.txt
	cat mom.txt > son.txt
	cat dad.txt >> son.txt # merge the content of mom.txt and dad.txt

mom.txt: grandma.txt
	cat grandma.txt > mom.txt # replace the content with grandma.txt

dad.txt: grandpa.txt
	cat grandma.txt > dad.txt

clean:
	@rm mom.txt dad.txt
```

同时我们新增一个`clean`假 target，用来清理 Makefile 产生的中间文件。输入命令`make clean`即可删掉`mom.txt`和`dad.txt`。

```bash
# make clean
# make
cat grandma.txt > mom.txt # replace the content with grandma.txt
cat grandma.txt > dad.txt
cat mom.txt > son.txt
cat dad.txt >> son.txt # merge the content of mom.txt and dad.txt
# make
make: 'all' is up to date.
# echo 1 > grandma.txt 
# make
cat grandma.txt > mom.txt # replace the content with grandma.txt
cat mom.txt > son.txt
cat dad.txt >> son.txt # merge the content of mom.txt and dad.txt
```

注意到第一次`make`之后，如果未对文件作出修改，所有的 target 除`all`以外会被跳过执行 command。当仅有`grandma.txt`被修改时，`dad.txt`这个 target 也会跳过执行 command。期间 Make 的故事是：
- make `all` target
    - make `son.txt`
        - make `mom.txt`
            - make `grandma.txt`
            - 检查`grandma.txt`文件是否有新修改
            - 有更新，执行`cat grandma.txt > mom.txt`
        - make `dad.txt`
            - make `grandpa.txt`
            - 检查`grandma.txt`文件是否有新修改
            - 没更新，啥也不做
        - 检查`mom.txt`和`dad.txt`是否执行过 command
        - `mom.txt`有执行过 command，执行`cat mom.txt > son.txt`和`cat dad.txt >> son.txt`
    - 检查`son.txt`是否执行过 command
    - `son.txt`有执行过 command，执行空指令

### 存在依赖关系

显而易见，下面的例子里，`aunt.txt`和`uncle.txt`因为和`all`屁关系没有，从未被依赖过，所以它们的 command 压根就不可能被执行。

```makefile
all: son.txt
	
son.txt: mom.txt dad.txt
	cat mom.txt > son.txt
	cat dad.txt >> son.txt

mom.txt: grandma.txt
	cat grandma.txt > mom.txt

dad.txt: grandpa.txt
	cat grandma.txt > dad.txt

aunt.txt: grandma.txt
	cat grandma.txt > aunt.txt

uncle.txt: grandpa.txt
	cat grandma.txt > uncle.txt
```

## 确定命令执行的顺序

Makefile 可以说是文件和命令的依赖关系的说明书，描述了通过什么文件以及什么命令可以产生什么文件。比如在上个例子里，`son.txt`文件的产生依赖`mom.txt`和`dad.txt`，`mom.txt`和`dad.txt`的产生分别依赖`grandma.txt`和`grandpa.txt`。在真实环境中，为了加速工程的编译速度，几个被依赖的，但它们之间没有依赖关系的 target 的 command 可以被同时执行。这也因此要求我们准确描述依赖关系。如果我们把上个例子的 Makefile 写成：

```makefile
all: son.txt mom.txt dad.txt
	
son.txt:
	cat mom.txt > son.txt
	cat dad.txt >> son.txt

mom.txt: grandma.txt
	cat grandma.txt > mom.txt

dad.txt: grandpa.txt
	cat grandma.txt > dad.txt
```

就有可能造成`son.txt`，`mom.txt`，`dad.txt`的 command 被同时执行，就存在`mom.txt`文件还没产生，`son.txt`的命令（需要`mom.txt`作为输入）就开始执行了的可能性。

| 时刻 | `son.txt`               | `mom.txt`       | `dad.txt`       |
| ---- | ----------------------- | --------------- | --------------- |
| 1    | `cat mom.txt > son.txt` |                 |                 |
| 2    | ？？我文件呢？          |                 | `cat > dad.txt` |
| 3    |                         | `cat > mom.txt` |                 |

所以我们需要确保执行的顺序像下面那个样子。

| 时刻 | `son.txt`               | `mom.txt`       | `dad.txt`       |
| ---- | ----------------------- | --------------- | --------------- |
| 1    |                         | `cat > mom.txt` | `cat > dad.txt` |
| 2    | `cat mom.txt > son.txt` |                 |                 |


使用`make -j`可以启动并行编译，在下面的例子中，我们可以看到`grandpa`和`grandma`同时开始执行，`son`在`mom`和`dad`都结束后才开始执行，总耗时为12s。

```makefile
all: son
	@echo "finish        @" "$(shell date)"

son: mom dad
	@echo "son     begin @" "$(shell date)"
	@sleep 2
	@echo "son     end"

mom: grandma
	@echo "mom     begin @" "$(shell date)"
	@sleep 3
	@echo "mom     end"

dad: grandpa
	@echo "dad     begin @" "$(shell date)"
	@sleep 5
	@echo "dad     end"

grandma:
	@echo "grandma begin @" "$(shell date)"
	@sleep 3
	@echo "grandma end"

grandpa:
	@echo "grandpa begin @" "$(shell date)"
	@sleep 5
	@echo "grandpa end"
```

```bash
# make -j
grandma begin @ Fri Dec 23 23:34:14 UTC 2022
grandpa begin @ Fri Dec 23 23:34:14 UTC 2022
grandma end
mom     begin @ Fri Dec 23 23:34:17 UTC 2022
grandpa end
dad     begin @ Fri Dec 23 23:34:19 UTC 2022
mom     end
dad     end
son     begin @ Fri Dec 23 23:34:24 UTC 2022
son     end
finish        @ Fri Dec 23 23:34:26 UTC 2022
```

可视化结果如下：

| 时刻 | `son` | `mom` | `dad` | `grandma` | `grandpa` |
| ---- | ----- | ----- | ----- | --------- | --------- |
| 14   |       |       |       | 执行      | 执行      |
| 15   |       |       |       | 执行      | 执行      |
| 16   |       |       |       | 结束      | 执行      |
| 17   |       | 执行  |       |           | 执行      |
| 18   |       | 执行  |       |           | 结束      |
| 19   |       | 结束  | 执行  |           |           |
| 20   |       |       | 执行  |           |           |
| 21   |       |       | 执行  |           |           |
| 22   |       |       | 执行  |           |           |
| 23   |       |       | 结束  |           |           |
| 24   | 执行  |       |       |           |           |
| 25   | 结束  |       |       |           |           |

将代码修改成如下形式，可以使所有 target 同时开始执行，总耗时为5s。

```makefile
all: son mom dad grandma grandpa
	@echo "finish        @" "$(shell date)"

son: 
	@echo "son     begin @" "$(shell date)"
	@sleep 2
	@echo "son     end"

mom: 
	@echo "mom     begin @" "$(shell date)"
	@sleep 3
	@echo "mom     end"

dad: 
	@echo "dad     begin @" "$(shell date)"
	@sleep 5
	@echo "dad     end"

grandma:
	@echo "grandma begin @" "$(shell date)"
	@sleep 3
	@echo "grandma end"

grandpa:
	@echo "grandpa begin @" "$(shell date)"
	@sleep 5
	@echo "grandpa end"
```

```bash
# make -j
son     begin @ Fri Dec 23 23:36:33 UTC 2022
mom     begin @ Fri Dec 23 23:36:33 UTC 2022
dad     begin @ Fri Dec 23 23:36:33 UTC 2022
grandma begin @ Fri Dec 23 23:36:33 UTC 2022
grandpa begin @ Fri Dec 23 23:36:33 UTC 2022
son     end
mom     end
grandma end
dad     end
grandpa end
finish        @ Fri Dec 23 23:36:38 UTC 2022
```

可视化结果如下：

| 时刻 | `son` | `mom` | `dad` | `grandma` | `grandpa` |
| ---- | ----- | ----- | ----- | --------- | --------- |
| 33   | 执行  | 执行  | 执行  | 执行      | 执行      |
| 34   | 结束  | 执行  | 执行  | 执行      | 执行      |
| 35   |       | 结束  | 执行  | 结束      | 执行      |
| 36   |       |       | 执行  |           | 执行      |
| 37   |       |       | 结束  |           | 结束      |

## One more thing



## References

- https://makefiletutorial.com/