# compile-prepare

编译系统原理预备工作项目，目标为 **RV64GC / LP64D**。包含 SysY 样例、独立手写 LLVM IR 和 RISC-V 汇编、运行时库、行为对照测试、编译阶段产物采集及 MLIR 降低实验。

## 快速运行

在 Ubuntu 22.04 / WSL Ubuntu 中安装依赖：

```bash
sudo apt-get update
sudo apt-get install -y build-essential clang-14 llvm-14     gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu qemu-user mlir-14-tools

git clone https://github.com/Petrichor12310/compile-prepare.git
cd compile-prepare
make doctor
make -j2 build
make test
make inspect
make mlir
make probe-course-runtime
```

工具名可在 `toolchain.local.mk` 中覆盖，例如 `QEMU := /opt/qemu/bin/qemu-riscv64`。该文件不提交。

项目固定使用 LLVM/MLIR 14 的语法及 pass 名；Ubuntu 的 `clang` 默认版本可能不同，默认配置使用带版本的工具名。所有 RV64 可执行文件采用静态 Linux 链接，不需要为 QEMU 额外指定动态库目录。

## 样例与执行链路

| 样例 | 验证内容 |
| --- | --- |
| `echo` | SysY 库调用、换行、32 位有符号整数边界 |
| `factorial` | 常量、短路范围检查、函数调用、循环、整数运算 |
| `control_scope` | 嵌套作用域、遮蔽、break/continue、&&/|| 副作用、! |
| `array_float` | 二维数组、数组行传参、float 运算及向零截断 |

`make test` 使用独立的 Python 预期模型，检查 **33 个用例 × 5 条链路 = 165 次运行**：主机 C、主机手写 IR、RV64 C、RV64 由手写 IR 自动生成的对象、RV64 手写汇编。每次运行有超时，比较完整 stdout 和退出状态，stderr 单独保存。

```bash
printf '5\n' | build/native/factorial
printf '5\n' | qemu-riscv64 build/rv-asm/factorial
# 两者均输出 120
```

`.sy` 作为参考 C 编译输入时，使用 `-x c -include runtime/sylib.h` 补充库声明。这只用于语义兼容的样例；项目未把 C 编译器当作完整 SysY 前端。

## 编译流程观察

`make inspect` 在 `results/inspection/` 保存宏展开结果、Token、AST、主机 Clang IR、RV64 GCC 汇编、对象符号和重定位、可执行文件反汇编，以及 O0/O2 的代码段大小。

双文件辅助实验 `src/pipeline/` 展示从未解析函数符号到链接完成的变化；该辅助实验是 C 程序。每条处理链标明所用编译器，采集命令保存在 `commands.json`。O0/O2 都用正常及边界输入验证输出，不以单次短程序耗时推断性能。

## 运行时库

课程源码见 `runtime/sylib.c`、`runtime/sylib.h`，默认分别重建主机库及 RV64 Linux 库，来源和修改见 [运行时来源](runtime/PROVENANCE.md)。

所附原始 `course-libsysy_riscv.a` 在当前 Linux/glibc 组合中引用无法解析的 Newlib `_impure_ptr`。`make probe-course-runtime` 保存真实兼容性诊断，探测命令成功不表示原始库成功运行；`make test-course-runtime` 是严格验证入口，在不兼容环境下返回失败。正常项目测试使用从相同课程源码重建的 Linux 库。

## MLIR 与 AscendNPU

`make mlir` 实际执行通用 MLIR 14 的 VecAdd：SCF → 分支控制流 → LLVM 方言 → LLVM IR → 主机执行。验证全部 16 个向量元素为 1～16，校验和为 136，各阶段 IR 保存在 `results/mlir/`。

AscendNPU 工具及实测过程见 [MLIR 说明](mlir/README.md)。在 x86_64 Ubuntu 中运行：

```bash
make install-ascend
make ascend
```

已实测官方 AscendNPU IR 1.1.0 的 VecAdd 转换：142 份 pass IR、hivmc 后端 LLVM IR，以及 2648 字节的 Ascend 设备 ELF。安装入口补齐 hivmc / 毕昇路径，关键阶段 IR 和导出符号自动验证，证据保存在 `results/ascend/` 及 [验收快照](evidence/ascend/README.md)。本次没有 NPU 硬件执行。

## 文件与验证证据

- `src/`、`ir/`、`asm/`：源程序及两套手写实现。
- `scripts/`：环境检测、构建辅助、对照测试、产物采集与 MLIR 验证。
- `runtime/`：课程资源及链接修正。
- `results/`：每次运行生成的完整日志，不提交。
- `evidence/`：实际验收的摘要和小型产物快照，提交到仓库。
- `docs/`：指令映射、测试范围和资源引用等技术说明。

GitHub Actions 在 Ubuntu 22.04 上执行构建、对照测试、编译观察和通用 MLIR 验证，上传 `results/`。本地验收记录与远程 CI 状态分别核实。

`make clean` 仅移除本仓库的 `build/`。重新采集会覆盖对应实验文件，但保留原始课程资料。

GitHub 上传仅需本仓库的 Contents / Workflows 读写权限，PR 协作权限按需添加，详见 [权限说明](docs/github-permissions.md)。
