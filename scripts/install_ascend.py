"""Extract pinned official compiler components; no CANN install or NPU driver."""
import argparse
import hashlib
import os
from pathlib import Path
import subprocess
import sys
from common import ROOT, write_json

URL = ("https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%209.0.0/"
       "Ascend-cann-toolkit_9.0.0_linux-x86_64.run")
SHA256 = "56f0ea2cc3c193921bcd35b814ef635b668d1bce349fdb6a04cb0ec4b6f1bc06"
COMPONENTS = {
    "ir-package": ("ascendnpu-ir_1.1.0_linux-x86.run", "bishengir/bin/bishengir-compile"),
    "bisheng-package": ("cann-bisheng-compiler_9.0.0_linux-x86_64.run", "bisheng_compiler/bin/bisheng"),
}


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def extract(package, destination, log):
    print(f"Checking and extracting {package.name}", flush=True)
    with log.open("wb") as stream:
        subprocess.run(["bash", str(package), "--noexec", f"--extract={destination}"],
                       stdout=stream, stderr=subprocess.STDOUT, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prefix", type=Path,
                        default=Path.home() / ".local/share/compile-prepare/ascend")
    parser.add_argument("--package", type=Path, help="Use an already downloaded toolkit package")
    args = parser.parse_args()
    if sys.platform != "linux" or os.uname().machine != "x86_64":
        sys.exit("Run this installer inside x86_64 Ubuntu/WSL.")
    prefix = args.prefix.expanduser().resolve()
    if any(c in str(prefix) for c in "'\"\\$#\n\r" + chr(96)):
        sys.exit("Choose a Linux prefix without shell or Make special characters.")
    prefix.mkdir(parents=True, exist_ok=True)
    downloads = prefix / "downloads"
    downloads.mkdir(exist_ok=True)
    package = args.package.resolve() if args.package else downloads / URL.rsplit("/", 1)[1]
    if args.package:
        if not package.is_file():
            sys.exit(f"Package does not exist: {package}")
    elif not package.exists() or sha256(package) != SHA256:
        subprocess.run(["curl", "--fail", "--location", "--retry", "2",
                        "--connect-timeout", "20", "--continue-at", "-",
                        "--output", str(package), URL], check=True)
    digest = sha256(package)
    if digest != SHA256:
        sys.exit(f"Toolkit SHA-256 mismatch: {digest}; extraction refused.")
    bundle = prefix / "toolkit-package"
    if not all((bundle / "run_package" / name).is_file() for name, _ in COMPONENTS.values()):
        extract(package, bundle, prefix / "extract.log")
    component_hashes = {}
    for directory, (name, executable) in COMPONENTS.items():
        source = bundle / "run_package" / name
        component_hashes[name] = sha256(source)
        if not (prefix / directory / executable).is_file():
            extract(source, prefix / directory, prefix / f"{directory}-extract.log")
    bindir = prefix / "bin"
    bindir.mkdir(exist_ok=True)
    for name in ["bishengir-compile", "bishengir-opt"]:
        wrapper = bindir / name
        wrapper.write_text('''#!/usr/bin/env bash
set -e
compiler_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
export ASCEND_REAL_BISHENG="$compiler_root/bisheng-package/bisheng_compiler/bin/bisheng"
export ASCEND_REAL_HIVMC="$compiler_root/ir-package/bishengir/bin/hivmc"
export PATH="${ASCEND_CAPTURE_BIN:+$ASCEND_CAPTURE_BIN:}$compiler_root/ir-package/bishengir/bin:$compiler_root/bisheng-package/bisheng_compiler/bin:$PATH"
exec "$compiler_root/ir-package/bishengir/bin/''' + name + '''" "$@"
''', encoding="utf-8")
        wrapper.chmod(0o755)
    versions = {}
    version_tools = {name: bindir / name for name in ["bishengir-compile", "bishengir-opt"]}
    version_tools.update({"hivmc": prefix / "ir-package/bishengir/bin/hivmc",
                          "bisheng": prefix / "bisheng-package/bisheng_compiler/bin/bisheng"})
    for name, path in version_tools.items():
        result = subprocess.run([str(path), "--version"], capture_output=True, check=True)
        versions[name] = result.stdout.decode().strip()
    local = ROOT / "toolchain.local.mk"
    lines = local.read_text(encoding="utf-8").splitlines() if local.exists() else []
    lines = [line for line in lines
             if line.split(":=", 1)[0].strip() not in {"BISHENGIR", "BISHENGIR_OPT"}]
    lines += [f'BISHENGIR := "{bindir / "bishengir-compile"}"',
              f'BISHENGIR_OPT := "{bindir / "bishengir-opt"}"']
    local.write_text("\n".join(lines) + "\n", encoding="utf-8")
    write_json(ROOT / "results/ascend-install.json",
               {"status": "ready", "url": URL, "sha256": digest, "prefix": str(prefix),
                "components": component_hashes, "versions": versions,
                "method": "makeself --noexec extraction; no driver installation"})
    print("Ascend compiler ready. Run: make doctor && make ascend")


if __name__ == "__main__":
    main()
