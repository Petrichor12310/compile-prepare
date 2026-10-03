# Default: Linux user-mode RV64GC / LP64D, tested with LLVM 14.
CC := gcc
CLANG := clang-14
LLVM_AS := llvm-as-14
OPT := opt-14
LLC := llc-14
RV_PREFIX := riscv64-linux-gnu-
RV_CC := $(RV_PREFIX)gcc
RV_AR := $(RV_PREFIX)ar
QEMU := qemu-riscv64
MLIR_OPT := mlir-opt-14
MLIR_TRANSLATE := mlir-translate-14
RV_FLAGS := -march=rv64gc -mabi=lp64d
-include toolchain.local.mk
