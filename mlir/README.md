# VecAdd 的两条真实转换链

## 通用 MLIR 14

`make mlir` 实际执行 SCF → 分支控制流 → LLVM 方言 → LLVM IR → 主机程序。
完整向量为 1～16，校验和为 136，产物保存在 `results/mlir/`。

## 安装 AscendNPU 编译工具

在 x86_64 Ubuntu 22.04 / WSL Ubuntu 的项目目录运行：

```bash
make install-ascend
make doctor
make ascend
```

安装脚本下载官方 CANN 9.0.0 包，校验固定 SHA-256，用
`--noexec --extract` 提取 AscendNPU IR 1.1.0 和毕昇编译组件。
下载约 1.2 GB，缓存及解包需要约 4 GB。工具默认位于
`~/.local/share/compile-prepare/ascend/`，路径写入 `toolchain.local.mk`，
保留已有 QEMU 等设置。不安装 CANN 服务或 NPU 驱动。

已有安装包时可离线复用：

```bash
python3 scripts/install_ascend.py --package /path/to/Ascend-cann-toolkit_9.0.0_linux-x86_64.run
```

包来源、哈希和工具版本保存在 `results/ascend-install.json`：

- `bishengir-compile` / `bishengir-opt`：1.1.0，版本 `428ab8fdab46`，LLVM 19.1.7。
- `hivmc`：0.2.0，版本 `3af4c111df44`。
- `bisheng`：CANN 9.0.0 中的 clang 15.0.5。

Ascend 使用独立工具链，RV64 和通用 MLIR 实验仍使用 LLVM 14。
编译器会从 PATH 调用 hivmc，后者再调用 bisheng；安装启动器补齐两项依赖。

## AscendNPU 实测转换

`ascend_vecadd.mlir` 来自官方 VecAdd：三个长度 16 的 i16 GM 参数、
两次 GM → UB 加载、UB 上的向量加法及一次 UB → GM 存储。

2026-10-03 在 WSL 中显式选择 `Ascend910B1` 编译，退出码为 0。
采集 **142 次前端 pass 执行的 IR**，生成 **2648 字节的 Ascend 设备 ELF**。
`results/ascend/status.json` 指向本次运行目录，产物如下：

| 产物 | 本次观察 |
| --- | --- |
| `stages/01-input.mlir` | GM/UB memref 与 load/vadd/store |
| `stages/02-planned-memory.mlir` | 最后一次 PlanMemory 后，alloc 成为 UB 地址 0、32；输出复用第一个输入缓冲区 |
| `stages/03-synchronized.mlir` | MTE2 → V、V → MTE3 的 set_flag/wait_flag 和结尾 pipe_barrier |
| `stages/04-template-calls.mlir` | load/vadd/store 降为 i16 模板调用，仍保留内存和同步信息 |
| `stages/05-device.ll` | hivmc 实际交给毕昇的 LLVM IR；GM/UB 成为地址空间 1/6，入口参数成为裸指针 |
| `passes.txt`、`passes/`、`pass-index.json` | 原始日志、独立模块 IR、pass 索引 |
| `backend-inputs/` | 实际后端命令及临时 IR 副本 |
| `kernel.o`、`elf.txt` | 设备 ELF 与头部/符号检查，存在 GLOBAL 函数 add |

`capture_ascend_backend.py` 复制临时 IR、记录命令，然后 exec 原始后端；
不改写 IR 或编译参数。实际命令确认使用 `--cce-aicore-arch=dav-c220-vec`
并链接 `meta_op.aiv.bc`。142 份日志属于前端；hivmc 内部 pass 没有逐项导出，
本项目保留其输入、最终 LLVM IR 和后端调用作为证据。

四个关键 MLIR 快照通过真实 bishengir-opt 的解析及验证。
ELF Machine 为 `0x1029`（Ascend/HIIPU）。虽名为 kernel.o，其 ELF Type 是 EXEC，
不应按普通 RV64 可重定位对象使用。

每次运行创建独立目录，验证 ELF 和导出符号后才报告成功。
工具缺失或转换失败时返回非零、写入失败状态；已实测不会沿用旧成功记录。

## 验证边界及证据

本次完成 Ascend 编译转换，尚未在 NPU 硬件启动 kernel，
`npu_executed=false`，没有 NPU 实测向量输出。
上面的 1～16 / 136 属于通用 MLIR 主机运行。

`evidence/ascend/` 保留本次完整 pass 日志、关键 IR、LLVM IR、ELF 头部和命令。
命令中的本地目录以 `${PROJECT}`、`${ASCEND_TOOLS}`、`${ASCEND_RUN}` 占位，
完整路径见本地 results。

来源：

- [官方 VecAdd](https://github.com/Ascend/AscendNPU-IR/blob/428ab8fdab46a879c7349caba4cde705bc8c9bb6/bishengir/test/Integration/HIVM/VecAdd/README.md)
- [官方安装说明](https://github.com/Ascend/AscendNPU-IR/blob/master/docs/source/en/introduction/quick_start/installing_guide.md)
- [官方 Dockerfile 中的安装包及提取方式](https://github.com/Ascend/AscendNPU-IR/blob/master/docker/Dockerfile.x86_64)
