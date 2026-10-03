"""Capture real AscendNPU passes when a compatible compiler is available."""
import shutil
import sys
from common import ROOT, run, tool, write_json

out = ROOT / "results/ascend"
out.mkdir(parents=True, exist_ok=True)
compiler = tool("BISHENGIR", "bishengir-compile")
if not shutil.which(compiler[0]):
    write_json(out / "status.json", {"status": "unavailable", "tool": compiler,
        "npu_executed": False, "reason": "AscendNPU IR compiler is not installed; see mlir/README.md for sourced analysis."})
    sys.exit("AscendNPU IR compiler unavailable. Upstream MLIR results are not NPU execution results.")
help_result = run(compiler + ["--help"], check=False)
help_text = (help_result.stdout + help_result.stderr).decode(errors="replace")
flags = [f for f in ["--mlir-print-ir-after-all", "--print-ir-after-all"] if f in help_text]
if not flags:
    sys.exit("Compiler does not advertise a supported IR dump option; inspect its version-specific help.")
command = compiler + ["mlir/ascend_vecadd.mlir", "-enable-hivm-compile", flags[0], "-o", str(out / "kernel.o")]
p = run(command, timeout=300, check=False)
(out / "passes.txt").write_bytes(p.stderr)
(out / "stdout.txt").write_bytes(p.stdout)
write_json(out / "status.json", {"status": "compiled" if p.returncode == 0 else "failed",
           "command": command, "exit_code": p.returncode, "npu_executed": False})
sys.exit(p.returncode)
