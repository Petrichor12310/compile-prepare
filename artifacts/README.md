# 编译与运行产物

此目录保留本项目的关键阶段输出，便于直接对照源程序、IR、汇编及链接结果。

| 目录 | 内容 | 生成方式 |
| --- | --- | --- |
| `pipeline/` | 双文件 C 程序的预处理、Token、AST、LLVM IR、RV64 汇编、对象、符号表及反汇编 | `make inspect` |
| `optimization/` | 阶乘的 O0、O2 和 O2 禁用内联版本，包含 IR、汇编、对象及代码段大小 | `make inspect` |
| `llvm-rv64/` | 五组手写 LLVM IR 经 LLVM 14 后端生成的 RV64 汇编 | `make build` 后用 `llc-14 -filetype=asm` 导出 |
| `mlir/` | 通用 VecAdd 的四个降低阶段、主机程序与输出 | `make mlir` |
| `ascend/` | 官方 VecAdd 的关键 MLIR 阶段、设备 LLVM IR、ELF 及符号表 | `make ascend` |

`pipeline/linked.disassembly.txt` 节选静态链接后 `main` 与 `factorial_ref` 的反汇编，展示对象中的调用重定位如何变为确定的目标地址。`pipeline/stdout.txt` 对应输入 5，结果为 120。

`optimization/` 中 RV64 对象的 text 大小分别为 184、124 和 92 字节，描述代码体积。

`mlir/vecadd` 是 x86_64 Linux 主机程序，`mlir/stdout.txt` 包含向量 1～16 及总和 136。

`ascend/kernel.o` 为 Ascend 设备 ELF，共 2648 字节，其类型为 EXEC。它与 RV64 对象、主机程序面向不同平台，需要对应的设备运行环境。

源程序、手写 IR 与手写汇编分别位于 `src/`、`ir/`、`asm/`。重新执行生成的完整过程文件保存在本地 `results/`。
