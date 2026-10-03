# 行为测试

执行 `make test`。脚本会对 42 个输入分别比较 5 条链路的 stdout 和返回状态。

- arithmetic：9 个用例，验证符号组合、向零除法、取余、比较、零被除数及除零保护。
- echo：5 个用例，含 INT_MIN、INT_MAX。
- factorial：10 个用例，含非法范围、0、1、12 及整数极值。
- control_scope：11 个用例，验证 break、continue、作用域遮蔽及短路调用次数。
- array_float：7 个用例，验证正负小数、0 结果、float32 舍入及向零截断。

每个进程有超时限制。详细输出在 `results/tests/`，总结果在 `results/equivalence.json`。

`cases.json` 是独立 Python 模型当前生成的预期快照；测试脚本本身每次重新计算预期，不使用某条编译链路作为唯一答案。
