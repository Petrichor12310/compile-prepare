# 了解我的编译器

编译系统原理预备工作项目，使用五组 SysY 程序观察源程序、LLVM IR 与 RISC-V 汇编之间的对应关系，并通过 VecAdd 探索通用 MLIR 和 AscendNPU IR 的逐级降低。

目标平台为 **RV64GC / LP64D**。SysY 整数按 32 位处理，地址和寄存器为 64 位，浮点数采用单精度。

## 项目内容

| 目录 | 内容 |
| --- | --- |
| `src/` | 五组 SysY 源程序，以及用于观察完整编译过程的双文件 C 程序 |
| `ir/` | 与 SysY 程序对应的手写 LLVM IR |
| `asm/` | 与 SysY 程序对应的手写 RISC-V 汇编 |
| `mlir/` | 通用 VecAdd、官方 Ascend VecAdd 输入及编译说明 |
| `runtime/` | 课程提供的 SysY 运行库及来源说明 |
| `scripts/` | 编译阶段产物采集、MLIR 降低和 Ascend 工具安装脚本 |
| `artifacts/` | 编译阶段输出、生成的汇编、对象文件和向量加法结果 |

`build/` 和 `results/` 用于本地构建及保存完整运行过程，不提交到仓库。实验报告和课程材料保留在本地。

## 样例

| 程序 | 主要内容 |
| --- | --- |
| `echo` | 整数输入输出、外部函数调用 |
| `arithmetic` | 整数算术、比较、有符号除法与取余 |
| `factorial` | 全局常量、范围判断、函数和循环 |
| `control_scope` | 作用域、变量遮蔽、短路求值、`break` 与 `continue` |
| `array_float` | 二维数组、行地址传参、单精度运算及类型转换 |

同名的 `.sy`、`.ll` 和 `.s` 文件对应同一个程序。LLVM IR 与汇编均为独立手写实现。参考程序采用与 C 兼容的 SysY 写法，以 `-x c -include runtime/sylib.h` 交给 C 编译器。

## 构建与运行

实测环境为 Ubuntu 22.04 / WSL Ubuntu，使用 GCC 11、LLVM/MLIR 14 和 QEMU 7。安装基础工具：

```bash
sudo apt-get update
sudo apt-get install -y build-essential python3 curl ca-certificates \
  clang-14 llvm-14 mlir-14-tools gcc-riscv64-linux-gnu \
  binutils-riscv64-linux-gnu qemu-user

git clone https://github.com/Petrichor12310/compile-prepare.git
cd compile-prepare
make -j2 build
```

构建结果分别保存在：

| 目录 | 程序来源 |
| --- | --- |
| `build/native/` | 源程序的主机版本 |
| `build/ir-native/` | 手写 LLVM IR 的主机版本 |
| `build/rv-reference/` | 源程序的 RV64 版本 |
| `build/rv-ir/` | 手写 LLVM IR 生成的 RV64 版本 |
| `build/rv-asm/` | 手写汇编生成的 RV64 版本 |

例如输入 5 计算阶乘：

```bash
printf '5\n' | build/native/factorial
printf '5\n' | qemu-riscv64 build/rv-ir/factorial
printf '5\n' | qemu-riscv64 build/rv-asm/factorial
# 输出均为 120
```

工具名和路径可在 `toolchain.local.mk` 中覆盖，该文件不提交。例如使用其他位置的 QEMU：

```make
QEMU := /opt/qemu/bin/qemu-riscv64
```

RV64 程序采用静态 Linux 链接。默认从课程 `sylib.c` 重建主机与 RV64 Linux 运行库；所附原始 RISC-V 库依赖 Newlib，与当前 Linux/glibc 环境不同，具体说明见 [runtime/PROVENANCE.md](runtime/PROVENANCE.md)。

## 编译过程与汇编结果

```bash
make inspect
```

该命令使用 `src/pipeline/` 中的 C 程序生成预处理文本、Token、AST、LLVM IR、RV64 汇编、对象文件、符号表、重定位和反汇编，并比较阶乘在 O0、O2 及关闭内联时的生成代码。

这里的主机 LLVM IR 由 Clang 生成，RV64 汇编由交叉 GCC 从同一份 C 源码生成。手写 IR 的 RV64 汇编保存在 `artifacts/llvm-rv64/`，可用以下命令重新生成阶乘版本：

```bash
llc-14 -mtriple=riscv64-unknown-linux-gnu \
  -mattr=+m,+a,+f,+d,+c -target-abi=lp64d -filetype=asm \
  build/rv-ir/factorial.bc -o build/rv-ir/factorial.s
```

仓库中保留的关键结果见 [artifacts/README.md](artifacts/README.md)，重新执行生成的完整文件位于 `results/inspection/`。

## MLIR 与 AscendNPU IR

```bash
make mlir
```

通用 MLIR 使用长度 16 的 i32 向量，依次经过结构化循环展开、LLVM 方言转换和 LLVM IR 翻译，再在主机执行。输出向量为 1～16，总和为 136。各阶段文件见 `artifacts/mlir/`。

Ascend 实验使用官方 HIVM VecAdd 示例，观察 UB 内存规划、流水同步、模板调用及设备 LLVM IR：

```bash
make install-ascend
make ascend
```

工具安装与转换过程见 [mlir/README.md](mlir/README.md)。关键阶段和设备文件 `kernel.o` 保存在 `artifacts/ascend/`。该文件面向 Ascend 设备，需要对应 NPU 及主机启动程序才能执行；本项目记录的是设备编译过程。

## 清理构建文件

```bash
make clean
```

该命令仅清理本地 `build/`，保留源代码与仓库中的实验产物。
