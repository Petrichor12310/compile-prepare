"""Log unmodified backend invocations and copy temporary IR before execution."""
import json
import os
from pathlib import Path
import shutil
import sys
import time

mode = sys.argv[1]
real = os.environ["ASCEND_REAL_" + mode.upper()]
args = sys.argv[2:]
out = Path(os.environ["ASCEND_CAPTURE_DIR"])
out.mkdir(parents=True, exist_ok=True)
stem = f"{time.time_ns()}-{mode}"
inputs = []
for index, arg in enumerate(args):
    if arg.startswith("-"):
        continue
    source = Path(arg)
    if source.is_file() and source.suffix in {".ll", ".mlir"}:
        target = out / f"{stem}-{index}{source.suffix}"
        shutil.copyfile(source, target)
        inputs.append({"original": str(source), "saved": target.name})
(out / f"{stem}.json").write_text(json.dumps({"tool": mode, "executable": real,
    "arguments": args, "inputs": inputs}, indent=2) + "\n", encoding="utf-8")
os.execv(real, [real, *args])
