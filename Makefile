include config.mk
SAMPLES := echo factorial control_scope array_float arithmetic
NATIVE := $(addprefix build/native/,$(SAMPLES))
IR_NATIVE := $(addprefix build/ir-native/,$(SAMPLES))
RV_REFERENCE := $(addprefix build/rv-reference/,$(SAMPLES))
RV_IR := $(addprefix build/rv-ir/,$(SAMPLES))
RV_ASM := $(addprefix build/rv-asm/,$(SAMPLES))
CFLAGS := -std=c11 -O0 -g -Wall -Wextra -fno-common

.PHONY: all build test doctor inspect mlir ascend install-ascend test-course-runtime probe-course-runtime clean
all: build
build: $(NATIVE) $(IR_NATIVE) $(RV_REFERENCE) $(RV_IR) $(RV_ASM)

define settings
CC='$(CC)' CLANG='$(CLANG)' LLVM_AS='$(LLVM_AS)' OPT='$(OPT)' LLC='$(LLC)' RV_CC='$(RV_CC)' RV_PREFIX='$(RV_PREFIX)' QEMU='$(QEMU)' MLIR_OPT='$(MLIR_OPT)' MLIR_TRANSLATE='$(MLIR_TRANSLATE)' BISHENGIR='$(BISHENGIR)' BISHENGIR_OPT='$(BISHENGIR_OPT)'
endef

doctor:
	$(settings) python3 scripts/doctor.py

test: build
	$(settings) python3 scripts/test.py

inspect: build
	$(settings) python3 scripts/inspect.py

mlir: build/runtime/libsysy-native.a
	$(settings) python3 scripts/lower_mlir.py

ascend:
	$(settings) python3 scripts/ascend.py

install-ascend:
	python3 scripts/install_ascend.py

probe-course-runtime:
	$(settings) python3 scripts/probe_course_runtime.py

test-course-runtime: build
	$(settings) python3 scripts/test.py --course-runtime

build/runtime/native.o: runtime/sylib.c runtime/sylib.h
	@mkdir -p $(@D)
	$(CC) -std=c11 -O2 -fno-common -c $< -o $@
build/runtime/libsysy-native.a: build/runtime/native.o
	ar rcs $@ $<
build/runtime/rv.o: runtime/sylib.c runtime/sylib.h
	@mkdir -p $(@D)
	$(RV_CC) $(RV_FLAGS) -std=c11 -O2 -fno-common -c $< -o $@
build/runtime/libsysy-rv.a: build/runtime/rv.o
	$(RV_AR) rcs $@ $<

build/native/%: src/%.sy runtime/sylib.h build/runtime/libsysy-native.a
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -include runtime/sylib.h -x c $< -x none build/runtime/libsysy-native.a -o $@

build/ir-native/%: ir/%.ll build/runtime/libsysy-native.a
	@mkdir -p $(@D)
	$(LLVM_AS) $< -o $@.bc
	$(OPT) -verify -disable-output $@.bc
	$(CLANG) -Wno-override-module $< build/runtime/libsysy-native.a -o $@

build/rv-reference/%: src/%.sy runtime/sylib.h build/runtime/libsysy-rv.a
	@mkdir -p $(@D)
	$(RV_CC) $(RV_FLAGS) $(CFLAGS) -include runtime/sylib.h -x c $< -x none build/runtime/libsysy-rv.a -static -o $@

build/rv-ir/%: ir/%.ll build/runtime/libsysy-rv.a
	@mkdir -p $(@D)
	$(LLVM_AS) $< -o $@.bc
	$(OPT) -verify -disable-output $@.bc
	$(LLC) -mtriple=riscv64-unknown-linux-gnu -mattr=+m,+a,+f,+d,+c -target-abi=lp64d -filetype=obj $@.bc -o $@.o
	$(RV_CC) $(RV_FLAGS) $@.o build/runtime/libsysy-rv.a -static -o $@

build/rv-asm/%: asm/%.s build/runtime/libsysy-rv.a
	@mkdir -p $(@D)
	$(RV_CC) $(RV_FLAGS) -c $< -o $@.o
	$(RV_CC) $(RV_FLAGS) $@.o build/runtime/libsysy-rv.a -static -o $@

clean:
	python3 scripts/clean.py
