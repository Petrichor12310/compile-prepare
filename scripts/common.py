"""Small standard-library-only command and artifact helpers."""
import json
import os
from pathlib import Path
import shlex
import subprocess

ROOT = Path(__file__).resolve().parents[1]

def tool(key, fallback):
    return shlex.split(os.environ.get(key, fallback))

def run(command, *, input=None, timeout=30, check=True):
    result = subprocess.run(command, cwd=ROOT, input=input, capture_output=True, timeout=timeout)
    if check and result.returncode:
        raise RuntimeError(f"Command failed ({result.returncode}): {shlex.join(command)}\n"
                           + result.stderr.decode("utf-8", errors="replace"))
    return result

def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
