"""Diagnose the unmodified course archive; do not claim failed links passed."""
from common import ROOT, run, tool, write_json
out = ROOT / "results/course-runtime-probe"
out.mkdir(parents=True, exist_ok=True)
command = tool("RV_CC", "riscv64-linux-gnu-gcc") + ["-march=rv64gc", "-mabi=lp64d",
    "asm/echo.s", "runtime/course-libsysy_riscv.a", "-static", "-o", str(out / "echo")]
p = run(command, check=False)
(out / "link.stdout.txt").write_bytes(p.stdout)
(out / "link.stderr.txt").write_bytes(p.stderr)
record = {"link_command": command, "link_exit_code": p.returncode,
          "status": "link-failed" if p.returncode else "linked", "runtime_executed": False}
if p.returncode == 0:
    executed = run(tool("QEMU", "qemu-riscv64") + [str(out / "echo")], input=b"7\n", check=False)
    record.update(status="compatible" if executed.returncode == 0 and executed.stdout == b"7\n" else "execution-failed",
                  runtime_executed=True, exit_code=executed.returncode, stdout=executed.stdout.decode(errors="replace"))
    (out / "run.stderr.txt").write_bytes(executed.stderr)
elif b"_impure_ptr" in p.stderr:
    record["diagnosis"] = "Course archive depends on Newlib _impure_ptr; Linux/glibc cannot resolve it. Rebuild sylib.c with the Linux cross compiler."
write_json(out / "status.json", record)
print("Course archive diagnostic:", record["status"], record.get("diagnosis", ""))
# A probe reports compatibility. Strict execution validation is make test-course-runtime.
