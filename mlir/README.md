# VecAdd 的逐级降低

## 通用 MLIR 14

`vecadd.mlir` 在程序内初始化长度 16 的 i32 向量，计算 `A[i] + B[i]`，输出各元素及总和。

```bash
make mlir
```

转换顺序为 SCF → 分支控制流 → LLVM 方言 → LLVM IR → 主机执行。输出向量为 1～16，总和为 136。

本次的四个阶段文件和运行输出保存在 `artifacts/mlir/`，重新执行后的文件位于 `results/mlir/`。

## AscendNPU 编译工具

在 x86_64 Ubuntu 22.04 / WSL Ubuntu 的项目目录运行：

```bash
make install-ascend
make ascend
```

安装脚本使用官方 CANN 9.0.0 软件包，提取 AscendNPU IR 1.1.0、hivmc 及毕昇组件。安装包约 1.2 GB，缓存及解包需要约 4 GB 空间。工具默认安装到 `~/.local/share/compile-prepare/ascend/`，命令路径写入本地 `toolchain.local.mk`。

已有安装包时可离线复用：

```bash
python3 scripts/install_ascend.py \
  --package /path/to/Ascend-cann-toolkit_9.0.0_linux-x86_64.run
```

Ascend 使用独立工具链，基础 RV64 与通用 MLIR 实验仍使用 LLVM 14。

## Ascend VecAdd

`ascend_vecadd.mlir` 采用官方示例：三个长度 16 的 i16 GM 参数，函数内分配 UB 缓冲区，执行两次加载、向量加法和一次回写。编译目标为 `Ascend910B1`。

| 文件 | 表示的变化 |
| --- | --- |
| `01-input.mlir` | GM/UB 内存类型及 load、vadd、store |
| `02-planned-memory.mlir` | UB 地址 0、32，输出复用第一个输入的位置 |
| `03-synchronized.mlir` | MTE2 → V、V → MTE3 事件和流水线屏障 |
| `04-template-calls.mlir` | 加载、加法和存储转换为 i16 模板调用 |
| `05-device.ll` | GM/UB 地址空间指针及设备同步 intrinsic |
| `kernel.o` | Ascend 设备 ELF，包含函数 `add` |
| `elf.txt` | 设备文件的 ELF 头部与符号表 |

这些文件保存在 `artifacts/ascend/`。完整的逐 pass 输出及后端临时输入位于本地 `results/ascend/` 的运行目录。

后端采用 `dav-c220-vec` 架构并链接 `meta_op.aiv.bc`。虽然文件名为 `kernel.o`，其 ELF 类型为 EXEC，面向 Ascend 设备。本项目没有在 NPU 上启动 kernel；上面的 1～16 与 136 是通用 MLIR 的主机运行结果。

## 官方资料

- [VecAdd 示例](https://ascendnpu-ir.gitcode.com/zh_cn/sources/introduction/quick_start/examples_zh.html)
- [本次使用的示例版本](https://github.com/Ascend/AscendNPU-IR/blob/428ab8fdab46a879c7349caba4cde705bc8c9bb6/bishengir/test/Integration/HIVM/VecAdd/README.md)
- [工具安装说明](https://github.com/Ascend/AscendNPU-IR/blob/master/docs/source/en/introduction/quick_start/installing_guide.md)
