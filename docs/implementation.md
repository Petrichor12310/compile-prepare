# 实现与阅读指南

## 三种表示的对应关系

| SysY | 手写 IR | 手写 RV64 |
| --- | --- | --- |
| a / b、a % b | sdiv、srem | divw、remw，商向零截断 |
| factorial 范围检查 | 两个条件块，negative 为真时跳过 upper | bltz、bgt |
| while 循环 | loop 的 phi 合并初值和回边值 | 条件标签、mulw/addiw、回跳 |
| 函数参数/返回值 | i32 参数及 ret | a0，非叶函数保存 ra |
| 作用域中的同名 n | 输入 n 与 inner.n 的独立值/地址 | s0 保存输入，临时寄存器表示内部 n |
| && 与 || | 只在需要时进入调用 tick 的块 | 条件跳转跳过 tick |
| a[1] | 两层数组的 getelementptr | 基址加 12 字节，float 元素 4 字节 |
| float → int | fptosi | fcvt.w.s 的 rtz 模式 |

非叶 main 在调用外部函数前维持 16 字节栈对齐；使用 s 寄存器的实现保存并恢复它们。整数使用 word 运算保持 SysY int 的 32 位语义，地址用 64 位操作。浮点调用遵循 LP64D 的浮点寄存器规则。

LLVM IR 的 @limit、@probes 对应静态存储；control_scope 有意保留内存式局部变量，factorial 和 sum 使用显式 phi 展示 SSA 回边。

## 测试范围

42 个用例的预期值来自 `scripts/test.py` 的独立模型：正负整数除法/取余、全部比较运算、除零保护、阶乘边界、输入整数极值、带计数副作用的短路逻辑，以及逐步 float32 舍入和向零转换。`tests/cases.json` 是便于阅读的用例快照。

所有进程均有 5 秒超时，stdout 包含空格和换行的精确比较；课程库的计时信息在 stderr。没有对无定义的整数溢出、非法数组下标或无效输入格式承诺行为。

这套测试验证五个具体程序的等价实现，并不等同于完整编译器语言覆盖测试。

## 来源

- 课程资料：了解编译器___LLVM_IR编程.pdf、预备工作课件、总体要求、SysY 语言定义及文法补充、lib.tar.gz。
- LLVM 14 Language Reference: https://releases.llvm.org/14.0.0/docs/LangRef.html
- RISC-V psABI: https://riscv-non-isa.github.io/riscv-elf-psabi-doc/
- MLIR 官方教程: https://mlir.llvm.org/docs/Tutorials/Toy/

五组 SysY/IR/RV64 实现和测试脚本在本项目中编写；未复制公开获奖编译器的前端或后端源码。
