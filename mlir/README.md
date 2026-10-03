# VecAdd 实验及官方 AscendNPU 分析

## 实际可运行的通用 MLIR

`vecadd.mlir` 使用上游 MLIR 14。`make mlir` 保留每一阶段的真实产物：

| 阶段 | 可查看的变化 | 输出文件 |
| --- | --- | --- |
| 输入 | scf.for、memref、arith 及函数调用 | 01-input.mlir |
| --convert-scf-to-std | 循环成为基本块、条件分支及回边参数 | 02-control-flow.mlir |
| memref/arith/std 转换 | 内存描述符、算术和函数转换为 LLVM 方言 | 03-llvm-dialect.mlir |
| --mlir-to-llvmir | MLIR 导出为 LLVM IR | 04-llvm.ll |
| Clang 编译后执行 | 输出完整向量 1～16 和校验和 136 | stdout.txt、validation.json |

本例不包含 Ascend 专属方言，也不是 Ascend 逐层转换日志。

## 官方 AscendNPU VecAdd

`ascend_vecadd.mlir` 引用官方快速入门，访问日期 2026-10-03：
https://ascendnpu-ir.gitcode.com/en/sources/introduction/quick_start/examples.html

| 官方例子的操作或属性 | 可以直接观察的信息 |
| --- | --- |
| func.func @add 的三个参数 | 两个输入与一个输出，长度 16 的 i16 memref |
| #hivm.address_space<gm> | 外部输入输出使用全局内存空间 |
| memref.alloc 和 #hivm.address_space<ub> | 三个局部向量缓冲区位于 UB 空间 |
| hivm.hir.load | 两次把输入从 GM 读入 UB |
| hivm.hir.vadd | 在 UB 缓冲区上执行向量加法 |
| hivm.hir.store | 将计算结果写回输出 GM |
| hacc.entry、DEVICE | 标记设备函数入口及函数种类 |

这些向量和硬件内存空间信息在普通 LLVM IR 中通常需要进一步表达为低层指令及数据结构，因此本项目关注它们在转换中的保留和改变。

官方编译入口为 `bishengir-compile add.mlir -enable-hivm-compile -o kernel.o`。设备运行需要另按官方示例配置 CANN 并注册/启动 NPU kernel。

`make ascend` 检查当前工具实际支持的 IR dump 选项，再执行官方编译模式并保存 stderr 中的转换日志；没有工具时生成 `results/ascend/status.json` 并返回失败。当前没有实测的 Ascend 转换链和 NPU 运行结果，不预设未经验证的逐层方言顺序。

进一步查证入口：

- 官方例子源码：https://github.com/Ascend/AscendNPU-IR/blob/master/bishengir/test/Integration/HIVM/VecAdd/README.md
- 学习 MLIR conversion 的辅助资料：https://mlir.llvm.org/docs/DialectConversion/

课件允许环境困难时以官方文档/源码分析呈现探索过程。这里保留具体示例分析与可运行的通用降低实验，二者标明各自证据边界。
