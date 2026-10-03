"""Record the actual tools used, without installing or changing configuration."""
import platform
import shutil
import sys
from common import ROOT, run, tool, write_json

required = {"CC": "gcc", "CLANG": "clang-14", "LLVM_AS": "llvm-as-14",
            "OPT": "opt-14", "LLC": "llc-14", "RV_CC": "riscv64-linux-gnu-gcc",
            "QEMU": "qemu-riscv64"}
optional = {"MLIR_OPT": "mlir-opt-14", "MLIR_TRANSLATE": "mlir-translate-14",
            "BISHENGIR": "bishengir-compile", "BISHENGIR_OPT": "bishengir-opt"}
rows = []
for key, default in {**required, **optional}.items():
    command = tool(key, default)
    resolved = shutil.which(command[0])
    row = {"key": key, "command": command, "path": resolved, "required": key in required}
    if resolved:
        result = run(command + ["--version"], check=False)
        row["version"] = (result.stdout + result.stderr).decode("utf-8", errors="replace").splitlines()[:3]
    rows.append(row)
record = {"system": platform.platform(), "machine": platform.machine(), "tools": rows}
if shutil.which(tool("RV_CC", required["RV_CC"])[0]):
    record["rv_target"] = run(tool("RV_CC", required["RV_CC"]) + ["-dumpmachine"]).stdout.decode().strip()
write_json(ROOT / "results/environment.json", record)
for row in rows:
    print(f"{row['key']:15} {row['path'] or 'MISSING'}")
missing = [row['key'] for row in rows if row['required'] and not row['path']]
if missing:
    sys.exit("Missing required tools: " + ", ".join(missing))
