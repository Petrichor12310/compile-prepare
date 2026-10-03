"""Capture actual frontend, assembler, linker and controlled optimization outputs."""
import shlex
from common import ROOT, run, tool, write_json

out = ROOT / "results/inspection"
out.mkdir(parents=True, exist_ok=True)
commands = []

def execute(command, artifact=None, input=None):
    p = run(command, input=input)
    record = {"command": shlex.join(command), "exit_code": p.returncode}
    if artifact is not None:
        record["artifact"] = str(artifact.relative_to(ROOT))
    if input is not None:
        record["stdin"] = input.decode()
        record["stdout"] = p.stdout.decode()
    commands.append(record)
    return p

def capture(name, command, stderr=False):
    target = out / name
    p = execute(command, target)
    target.write_bytes(p.stderr if stderr else p.stdout)

clang = tool("CLANG", "clang-14")
rv = tool("RV_CC", "riscv64-linux-gnu-gcc")
prefix = tool("RV_PREFIX", "riscv64-linux-gnu-")[0]
source = "src/pipeline/main.c"
flags = ["-I", "runtime", "-I", "src/pipeline"]
capture("preprocessed.i", clang + flags + ["-E", source])
capture("tokens.txt", clang + flags + ["-Xclang", "-dump-tokens", "-fsyntax-only", source], stderr=True)
capture("ast.txt", clang + flags + ["-Xclang", "-ast-dump", "-fsyntax-only", source])
for name in ("main", "compute"):
    src = f"src/pipeline/{name}.c"
    capture(f"{name}.ll", clang + flags + ["-S", "-emit-llvm", "-O0", src, "-o", "-"])
    capture(f"{name}.s", rv + flags + ["-march=rv64gc", "-mabi=lp64d", "-S", "-O0", src, "-o", "-"])
    obj = out / f"{name}.o"
    execute(rv + ["-march=rv64gc", "-mabi=lp64d", "-c", str(out / f"{name}.s"), "-o", str(obj)], obj)
    capture(f"{name}.symbols.txt", [prefix + "nm", str(obj)])
    capture(f"{name}.relocations.txt", [prefix + "readelf", "-rW", str(obj)])
    capture(f"{name}.disassembly.txt", [prefix + "objdump", "-dr", str(obj)])
exe = out / "pipeline"
execute(rv + [str(out / "main.o"), str(out / "compute.o"), "build/runtime/libsysy-rv.a", "-static", "-o", str(exe)], exe)
capture("executable.elf.txt", [prefix + "readelf", "-h", str(exe)])
capture("executable.symbols.txt", [prefix + "nm", str(exe)])
capture("executable.disassembly.txt", [prefix + "objdump", "-d", str(exe)])
p = execute(tool("QEMU", "qemu-riscv64") + [str(exe)], input=b"5\n")
assert p.stdout == b"120\n", p.stdout
(out / "pipeline.stdout.txt").write_bytes(p.stdout)
(out / "pipeline.stderr.txt").write_bytes(p.stderr)
sizes = []
for label, level, extra in [("O0", 0, []), ("O2", 2, []), ("O2-noinline", 2, ["-fno-inline"])]:
    common = ["-include", "runtime/sylib.h", "-x", "c", "src/factorial.sy", f"-O{level}"] + extra
    capture(f"factorial.{label}.ll", clang + common + ["-S", "-emit-llvm", "-o", "-"])
    capture(f"factorial.{label}.s", rv + ["-march=rv64gc", "-mabi=lp64d"] + common + ["-S", "-o", "-"])
    obj = out / f"factorial.{label}.o"
    execute(rv + ["-march=rv64gc", "-mabi=lp64d", "-c", str(out / f"factorial.{label}.s"), "-o", str(obj)], obj)
    capture(f"factorial.{label}.size.txt", [prefix + "size", str(obj)])
    sizes.append({"variant": label, "optimization": level, "extra_flags": extra,
                  "output": (out / f"factorial.{label}.size.txt").read_text()})
    binary = out / f"factorial.{label}"
    execute(rv + [str(obj), "build/runtime/libsysy-rv.a", "-static", "-o", str(binary)], binary)
    for n, expected in [(0, 1), (5, 120), (12, 479001600), (13, -1)]:
        p = execute(tool("QEMU", "qemu-riscv64") + [str(binary)], input=f"{n}\n".encode())
        assert p.stdout == f"{expected}\n".encode(), (level, n, p.stdout)
write_json(out / "commands.json", commands)
write_json(out / "optimization.json", sizes)
print("Captured frontend, assembly/link commands, and verified O0/O2/O2-noinline output equivalence")
