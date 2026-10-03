"""Capture actual frontend, assembler, linker and O0/O2 outputs."""
import shlex
from common import ROOT, run, tool, write_json

out = ROOT / "results/inspection"
out.mkdir(parents=True, exist_ok=True)
commands = []

def capture(name, command, stderr=False):
    p = run(command)
    target = out / name
    target.write_bytes(p.stderr if stderr else p.stdout)
    commands.append({"artifact": str(target.relative_to(ROOT)), "command": shlex.join(command)})

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
    run(rv + ["-march=rv64gc", "-mabi=lp64d", "-c", str(out / f"{name}.s"), "-o", str(obj)])
    capture(f"{name}.symbols.txt", [prefix + "nm", str(obj)])
    capture(f"{name}.relocations.txt", [prefix + "readelf", "-rW", str(obj)])
    capture(f"{name}.disassembly.txt", [prefix + "objdump", "-dr", str(obj)])
exe = out / "pipeline"
run(rv + [str(out / "main.o"), str(out / "compute.o"), "build/runtime/libsysy-rv.a", "-static", "-o", str(exe)])
capture("executable.elf.txt", [prefix + "readelf", "-h", str(exe)])
capture("executable.symbols.txt", [prefix + "nm", str(exe)])
capture("executable.disassembly.txt", [prefix + "objdump", "-d", str(exe)])
p = run(tool("QEMU", "qemu-riscv64") + [str(exe)], input=b"5\n")
assert p.stdout == b"120\n", p.stdout
(out / "pipeline.stdout.txt").write_bytes(p.stdout)
(out / "pipeline.stderr.txt").write_bytes(p.stderr)
sizes = []
for level in (0, 2):
    common = ["-include", "runtime/sylib.h", "-x", "c", "src/factorial.sy", f"-O{level}"]
    capture(f"factorial.O{level}.ll", clang + common + ["-S", "-emit-llvm", "-o", "-"])
    capture(f"factorial.O{level}.s", rv + ["-march=rv64gc", "-mabi=lp64d"] + common + ["-S", "-o", "-"])
    obj = out / f"factorial.O{level}.o"
    run(rv + ["-march=rv64gc", "-mabi=lp64d", "-c", str(out / f"factorial.O{level}.s"), "-o", str(obj)])
    capture(f"factorial.O{level}.size.txt", [prefix + "size", str(obj)])
    sizes.append({"optimization": level, "output": (out / f"factorial.O{level}.size.txt").read_text()})
    binary = out / f"factorial.O{level}"
    run(rv + [str(obj), "build/runtime/libsysy-rv.a", "-static", "-o", str(binary)])
    for n, expected in [(0, 1), (5, 120), (12, 479001600), (13, -1)]:
        p = run(tool("QEMU", "qemu-riscv64") + [str(binary)], input=f"{n}\n".encode())
        assert p.stdout == f"{expected}\n".encode(), (level, n, p.stdout)
write_json(out / "commands.json", commands)
write_json(out / "optimization.json", sizes)
print("Captured frontend, RV64 assembly/object/linking, and verified O0/O2 output equivalence")
