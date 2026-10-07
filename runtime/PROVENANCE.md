# 运行时来源

`sylib.c`、`sylib.h` 和 `course-libsysy_riscv.a` 来自课程资源 `lib.tar.gz`，没有引入公开获奖编译器代码。

源码只做了必要的链接修正：头文件中的计时变量定义改为 `extern` 声明，对应存储定义移至 `sylib.c`。I/O 行为保留课程实现，包括 `%a` 浮点输出和 stderr 计时日志。

默认构建在本机及 RV64 Linux 目标分别重建静态库。原始 RISC-V 库依赖 Newlib 的 `_impure_ptr`，与当前 Linux/glibc 环境不同，因此构建使用相同课程源码生成的 Linux 库。

课程资料未附明确许可文本，这些文件按课程提供的资源标明来源，不另行宣称第三方许可。

原始 RV64 库 SHA-256：`a36344add21fd7fe9e208f98fa65d08b60e383675d4863162dcf57c07d898b96`。
