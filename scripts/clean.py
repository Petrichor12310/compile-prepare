"""Delete only the build directory immediately inside this repository."""
from pathlib import Path
import shutil
root = Path(__file__).resolve().parents[1]
build = root / "build"
if build.is_symlink() or (build.exists() and build.resolve().parent != root):
    raise SystemExit("Refusing to clean a build directory outside this repository")
if build.exists():
    shutil.rmtree(build)
