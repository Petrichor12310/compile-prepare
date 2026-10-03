# AscendNPU 转换验收快照

2026-10-03，WSL Ubuntu 22.04 / x86_64，官方 AscendNPU IR 1.1.0。
通过 `make ascend` 编译官方 i16 VecAdd，退出码 0，生成 2648 字节设备 ELF。
**没有 NPU 硬件执行；这里只验证真实编译转换。**

- `passes.txt`：142 次前端 pass 执行后的完整 IR 原始日志。
- `pass-index.json`：顺序、pass 名和运行时产物路径。
- `01-input.mlir`～`04-template-calls.mlir`：通过 bishengir-opt 验证的关键阶段。
- `05-device.ll`：hivmc 实际交给毕昇的 LLVM IR。
- `elf.txt`：ELF64 / Machine 0x1029 / Type EXEC / GLOBAL add。
- `status.json`：实际命令、工具版本和后端调用；毕昇链接 meta_op.aiv.bc。
- `install.json`：官方安装包来源、SHA-256、组件哈希、工具版本。
- `failure-check.json`：成功运行后模拟工具缺失，确认返回失败且无陈旧成功状态。
- `verification.json`：快照哈希与验证摘要；采集启动器启用前后设备 ELF 的 SHA-256 完全相同。

设备二进制留在本地 results，不加入源码仓库。
`${PROJECT}`、`${ASCEND_TOOLS}`、`${ASCEND_RUN}`、`${TEMP}`
分别表示项目、提取工具、本次运行及编译临时目录；
原始路径见本地 `results/ascend/status.json`。

复现入口和阶段观察见 [MLIR 说明](../../mlir/README.md)。
