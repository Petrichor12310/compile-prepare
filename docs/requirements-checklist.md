# 预备工作要求验收清单

核对日期：2026-10-03。依据课程《预备工作 - 了解你的编译器》课件第 2、3 页及《上机大作业总体要求》。材料哈希和本轮实测摘要见 [prepush-audit.json](../evidence/prepush-audit.json)。

本仓库完成当前预备工作的代码和实验。总体要求中的词法分析器、语法分析器、类型检查、完整 SSA/优化及目标代码生成属于后续模块，不能据此仓库宣称整个学期大作业已经完成。

| 课程要求 | 本次验收 | 对应实现与证据 |
| --- | --- | --- |
| Linux 环境，选定 RISC-V 后端 | 通过 | WSL Ubuntu 22.04，LLVM 14，RV64GC/LP64D，Linux 交叉工具链及 QEMU；`make doctor` |
| 观察预处理及编译器细分阶段 | 通过 | `src/pipeline/` 双文件程序的宏展开、Token、AST、LLVM IR、RISC-V 汇编；`make inspect` |
| 观察汇编器和链接器 | 通过 | 两个对象文件的符号、重定位和反汇编，静态链接后执行输出 120；汇编、链接、执行命令均已记录 |
| SysY 样例涵盖数值运算、赋值、条件、循环、函数及进阶特性 | 通过 | 五组程序，覆盖整数算术与全部比较、短路副作用、作用域、break/continue、二维数组、float 和转换 |
| 手写等价 LLVM IR | 通过 | `ir/` 的五组独立实现；llvm-as/opt 验证，并在主机和 RV64 上执行 |
| 手写等价 RISC-V 汇编 | 通过 | `asm/` 的五组独立实现，word 指令保持 int32 语义，按 LP64D 保存寄存器和对齐栈 |
| 链接 SysY 运行时并验证结果 | 通过，采用源码重建库 | 从课程 sylib.c 构建主机和 RV64 Linux 库；42 个输入 × 5 条链路，210/210 通过 |
| 命令行生成各阶段产物并关联源码 | 通过 | `results/inspection/` 保存完整可再生产物；[commands.json](../evidence/inspection/commands.json) 保存本次全部 47 条处理和执行命令 |
| 探索优化差异（课件鼓励项） | 通过 | factorial 的 O0、O2、O2 加 `-fno-inline`；三组各测 0、5、12、13，输出一致 |
| AscendNPU 官方 VecAdd 多层 IR 转换（进阶 1 分） | 通过转换验收 | 官方 AscendNPU IR 1.1.0 实测 142 份 pass IR、四个关键 MLIR 阶段、hivmc 后端 LLVM IR及 Ascend 设备 ELF；`make ascend` |
| 实验及参考来源说明 | 已记录 | README、运行时来源、MLIR 说明和 `evidence/`；原始课程资料保留在本地 |

`factorial` 对象的 text 大小实测为 O0 184 字节、O2 124 字节、O2 禁用内联 92 字节。禁用内联保留函数调用并减少该小程序的重复代码；这些数据描述对象代码大小，不能推断运行速度。

课程原始 `libsysy_riscv.a` 依赖 Newlib 的 `_impure_ptr`，当前 Linux/glibc 链接失败。真实失败诊断已保留，默认使用相同课程源码重建库；不把 `make probe-course-runtime` 退出成功当作原始库运行通过。

本次没有 NPU 硬件执行，验收范围是实际编译转换和产物验证。课件要求的 PDF 调研报告仍未编写，这是用户明确排除的工作，不能标记为已完成。两人组队备案、真实分工和两人分别向小雅提交同一 PDF 也需要组员自行完成或确认，仓库推送不能替代课程提交。
