"""Run and retain each actual upstream MLIR 14 lowering stage."""
import shutil
from common import ROOT, run, tool, write_json

out = ROOT / "results/mlir"
out.mkdir(parents=True, exist_ok=True)
opt = tool("MLIR_OPT", "mlir-opt-14")
translate = tool("MLIR_TRANSLATE", "mlir-translate-14")
for command in [opt, translate]:
    if not shutil.which(command[0]):
        raise SystemExit("Missing MLIR 14 tool: " + command[0])
stages = [
    ("01-input.mlir", [], "mlir/vecadd.mlir"),
    ("02-control-flow.mlir", ["--convert-scf-to-std"], str(out / "01-input.mlir")),
    ("03-llvm-dialect.mlir", ["--convert-memref-to-llvm", "--convert-arith-to-llvm",
                            "--convert-std-to-llvm", "--reconcile-unrealized-casts"], str(out / "02-control-flow.mlir")),
]
commands = []
for name, passes, source in stages:
    command = opt + [source] + passes
    p = run(command)
    (out / name).write_bytes(p.stdout)
    commands.append({"artifact": name, "command": command})
command = translate + [str(out / "03-llvm-dialect.mlir"), "--mlir-to-llvmir"]
p = run(command)
(out / "04-llvm.ll").write_bytes(p.stdout)
commands.append({"artifact": "04-llvm.ll", "command": command})
run(tool("CLANG", "clang-14") + ["-Wno-override-module", str(out / "04-llvm.ll"),
    "build/runtime/libsysy-native.a", "-o", str(out / "vecadd")])
p = run([str(out / "vecadd")])
(out / "stdout.txt").write_bytes(p.stdout)
(out / "stderr.txt").write_bytes(p.stderr)
expected = " ".join(str(i) for i in range(1, 17)) + " \n136\n"
assert p.stdout == expected.encode(), p.stdout
write_json(out / "validation.json", {"expected": expected, "stdout": p.stdout.decode(),
           "exit_code": p.returncode, "commands": commands, "backend": "native upstream MLIR; not Ascend NPU"})
print("MLIR 14: scf -> control flow -> LLVM dialect -> LLVM IR -> native execution: checksum 136")
