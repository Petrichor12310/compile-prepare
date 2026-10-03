"""Run real AscendNPU conversion and preserve pass IR and backend inputs."""
from datetime import datetime, timezone
import hashlib
import json
import os
import re
import shlex
import shutil
import sys
from common import ROOT, run, tool, write_json

OUT = ROOT / "results/ascend"
OUT.mkdir(parents=True, exist_ok=True)
RUN = OUT / ("run-" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ"))
RUN.mkdir()
RECORD = {"status": "running", "npu_executed": False, "run": str(RUN.relative_to(ROOT)),
          "target": os.environ.get("ASCEND_TARGET", "Ascend910B1"), "commands": []}
write_json(OUT / "status.json", RECORD)


def execute(command, *, timeout=300):
    RECORD["commands"].append(command)
    return run(command, timeout=timeout, check=False)


def split_passes(text):
    headers = list(re.finditer(r"^// -----// IR Dump After (.+?) //----- //\s*$", text, re.M))
    directory = RUN / "passes"
    directory.mkdir()
    rows = []
    for index, header in enumerate(headers):
        end = headers[index + 1].start() if index + 1 < len(headers) else len(text)
        body = text[header.end():end]
        # Module printing is enabled. Exclude any trailing backend diagnostics.
        start, close = body.find("module "), body.rfind("\n}")
        if start < 0 or close < start:
            raise RuntimeError(f"Pass dump is not a full module: {header.group(1)}")
        argument = re.search(r"\(([-\w]+)\)", header.group(1)).group(1)
        name = f"{index + 1:03d}-{argument}.mlir"
        (directory / name).write_text(body[start:close + 2] + "\n", encoding="utf-8")
        rows.append({"index": index + 1, "pass": argument, "header": header.group(1),
                     "artifact": str((directory / name).relative_to(ROOT))})
    write_json(RUN / "pass-index.json", rows)
    return rows


def main():
    compiler = tool("BISHENGIR", "bishengir-compile")
    optimizer = tool("BISHENGIR_OPT", "bishengir-opt")
    RECORD["tool"] = compiler
    if not compiler or not shutil.which(compiler[0]):
        RECORD["status"] = "unavailable"
        raise RuntimeError("Ascend compiler is missing. Run: python3 scripts/install_ascend.py")
    version = execute(compiler + ["--version"], timeout=30)
    if version.returncode:
        raise RuntimeError(version.stderr.decode(errors="replace"))
    RECORD["version"] = version.stdout.decode(errors="replace").strip()
    help_result = execute(compiler + ["--help-hidden"], timeout=30)
    help_text = (help_result.stdout + help_result.stderr).decode(errors="replace")
    (RUN / "compiler-help.txt").write_text(help_text, encoding="utf-8")
    required = ["--enable-hivm-compile", "--target=", "--mlir-print-ir-after-all",
                "--mlir-print-ir-module-scope", "--mlir-disable-threading"]
    if help_result.returncode or any(flag not in help_text for flag in required):
        raise RuntimeError("Compiler lacks the required options; use the pinned CANN 9.0.0 tool.")
    source = ROOT / "mlir/ascend_vecadd.mlir"
    RECORD["input_sha256"] = hashlib.sha256(source.read_bytes()).hexdigest()
    capture = RUN / "backend-inputs"
    capture.mkdir()
    bindir = RUN / "backend-bin"
    bindir.mkdir()
    for mode in ["hivmc", "bisheng"]:
        wrapper = bindir / mode
        wrapper.write_text("#!/usr/bin/env bash\nexec " + shlex.join(
            ["python3", str(ROOT / "scripts/capture_ascend_backend.py"), mode]) + ' "$@"\n',
            encoding="utf-8")
        wrapper.chmod(0o755)
    # The installer launcher adds this directory ahead of its real backend tools.
    os.environ["ASCEND_CAPTURE_BIN"] = str(bindir)
    os.environ["ASCEND_CAPTURE_DIR"] = str(capture)
    kernel = RUN / "kernel.o"
    command = compiler + [str(source), "--enable-hivm-compile",
                          "--target=" + RECORD["target"], "--mlir-print-ir-after-all",
                          "--mlir-print-ir-module-scope", "--mlir-disable-threading",
                          "-o", str(kernel)]
    result = execute(command)
    (RUN / "passes.txt").write_bytes(result.stderr)
    (RUN / "stdout.txt").write_bytes(result.stdout)
    RECORD["exit_code"] = result.returncode
    rows = split_passes(result.stderr.decode(errors="replace"))
    RECORD["pass_count"] = len(rows)
    if result.returncode:
        raise RuntimeError(f"Compiler exited {result.returncode}; see {RUN / 'passes.txt'}")
    if not rows or not kernel.is_file() or kernel.stat().st_size < 64:
        raise RuntimeError("Compiler returned success without pass dumps or a device ELF.")
    elf = kernel.read_bytes()
    if elf[:6] != b"\x7fELF\x02\x01" or int.from_bytes(elf[18:20], "little") != 0x1029:
        raise RuntimeError("Output is not the expected Ascend 64-bit little-endian ELF.")
    headers = execute(["readelf", "-h", "-s", str(kernel)], timeout=30)
    (RUN / "elf.txt").write_bytes(headers.stdout + headers.stderr)
    if headers.returncode or not re.search(r"\bGLOBAL\b.*\badd(?:\$local)?\s*$",
                                          headers.stdout.decode(errors="replace"), re.M):
        raise RuntimeError("Device ELF does not expose the expected add symbol.")
    stages = RUN / "stages"
    stages.mkdir()
    shutil.copyfile(source, stages / "01-input.mlir")
    selected = {"02-planned-memory.mlir": "hivm-plan-memory",
                "03-synchronized.mlir": "hivm-graph-sync-solver",
                "04-template-calls.mlir": "convert-hivm-to-std"}
    for name, argument in selected.items():
        row = next((row for row in reversed(rows) if row["pass"] == argument), None)
        if row is None:
            raise RuntimeError(f"Expected pass is absent: {argument}")
        shutil.copyfile(ROOT / row["artifact"], stages / name)
    for path in sorted(stages.glob("*.mlir")):
        verified = execute(optimizer + [str(path), "-o", os.devnull], timeout=30)
        if verified.returncode:
            raise RuntimeError(f"Stage IR verification failed: {path.name}\n"
                               + verified.stderr.decode(errors="replace"))
    llvm_inputs = [path for path in sorted(capture.glob("*.ll"))
                   if re.search(r"define\b[^\n]*@add\b", path.read_text(encoding="utf-8"))]
    RECORD["llvm_ir_captured"] = bool(llvm_inputs)
    if llvm_inputs:
        shutil.copyfile(llvm_inputs[-1], stages / "05-device.ll")
    RECORD["backend_calls"] = [json.loads(path.read_text(encoding="utf-8"))
                               for path in sorted(capture.glob("*.json"))]
    RECORD["elf"] = {"sha256": hashlib.sha256(elf).hexdigest(), "bytes": len(elf),
                     "machine": "0x1029 (Ascend/HIIPU)", "type": int.from_bytes(elf[16:18], "little")}
    RECORD["status"] = "compiled"
    write_json(RUN / "status.json", RECORD)
    print(f"Ascend conversion passed: {len(rows)} pass dumps; device ELF {len(elf)} bytes.")
    print(f"LLVM IR captured: {bool(llvm_inputs)}. NPU hardware executed: False.")


try:
    main()
except Exception as error:
    if RECORD["status"] != "unavailable":
        RECORD["status"] = "failed"
    RECORD["reason"] = str(error)
    write_json(RUN / "status.json", RECORD)
    print(str(error), file=sys.stderr)
finally:
    write_json(OUT / "status.json", RECORD)
sys.exit(0 if RECORD["status"] == "compiled" else 1)
