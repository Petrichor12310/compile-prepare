# 本地验收快照

2026-10-03 在 Ubuntu 22.04 WSL 中从干净 build 目录构建。33 个用例、5 条链路的 165 次检查全部通过；O0/O2 对照及两文件链接实验输出也已验证。

通用 MLIR 保存实际逐级转换产物，输出完整向量 1～16 和校验和 136。

课程原始库的 Linux 链接因 `_impure_ptr` 失败，默认使用课程源码重建的库。AscendNPU 编译器当前未安装，未声称完成 Ascend 转换或设备运行。

`validation.json` 保存摘要及工具版本，`mlir/` 和 `inspection/` 保存部分真实产物。完整可再生结果在本地 results 目录或 GitHub Actions 的实验产物中。
