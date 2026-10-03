"""Behavioral equivalence across C, handwritten IR, generated RV IR and RV asm.

Expected values are independent Python models, not the output of another lane.
Each process has a timeout; crashes, mismatched output and exit codes fail the run.
"""
import argparse
import math
import struct
import sys
from common import ROOT, run, tool, write_json

def f32(value):
    return struct.unpack("f", struct.pack("f", value))[0]

def hex_float(value):
    if value == 0:
        return "-0x0p+0" if math.copysign(1, value) < 0 else "0x0p+0"
    mantissa, exponent = value.hex().split("p")
    mantissa = mantissa.rstrip("0").rstrip(".")
    return mantissa + "p" + exponent

def cases():
    result = []
    for n in [-2147483648, -7, 0, 7, 2147483647]:
        result.append(("echo", f"echo_{n}", f"{n}\n", f"{n}\n"))
    for n in [-2147483648, -1, 0, 1, 2, 5, 10, 12, 13, 2147483647]:
        expected = math.factorial(n) if 0 <= n <= 12 else -1
        result.append(("factorial", f"factorial_{n}", f"{n}\n", f"{expected}\n"))
    for n in [-2147483648, -5, 0, 1, 2, 3, 8, 9, 10, 12, 2147483647]:
        odd_sum = sum(i for i in range(1, min(max(n, 0), 9) + 1) if i % 2)
        total = odd_sum + (100 if n > 0 else 0) + 10 + (1 if n == 0 else 0)
        probes = (1 if n > 0 else 0) + (1 if n >= 0 else 0)
        result.append(("control_scope", f"control_{n}", f"{n}\n", f"{total} {probes}\n"))
    for bias, x in [(0, 5), (2, 1.5), (-1, -1.25), (-20, 0.5), (0, -10), (1, 0.1), (5, -20.25)]:
        value = f32(f32(f32(4.0 + f32(x)) + 6.0) + f32(bias))
        result.append(("array_float", f"array_{bias}_{x}", f"{bias} {x}\n",
                       f"{hex_float(value)}\n{int(value)}\n"))
    return result

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--course-runtime", action="store_true")
    args = parser.parse_args()
    lanes = ["native", "ir-native", "rv-reference", "rv-ir", "rv-asm"]
    if args.course_runtime:
        lanes = ["course-rv-asm"]
        out = ROOT / "build/course-rv-asm"
        out.mkdir(parents=True, exist_ok=True)
        for sample in sorted({case[0] for case in cases()}):
            run(tool("RV_CC", "riscv64-linux-gnu-gcc") + ["-march=rv64gc", "-mabi=lp64d",
                str(ROOT / f"asm/{sample}.s"), str(ROOT / "runtime/course-libsysy_riscv.a"),
                "-static", "-o", str(out / sample)])
    rows = []
    for sample, name, stdin, expected in cases():
        for lane in lanes:
            binary = str(ROOT / "build" / lane / sample)
            command = ([binary] if lane in ("native", "ir-native") else tool("QEMU", "qemu-riscv64") + [binary])
            log = ROOT / "results/tests" / name / lane
            log.mkdir(parents=True, exist_ok=True)
            try:
                p = run(command, input=stdin.encode(), timeout=5, check=False)
                passed = p.returncode == 0 and p.stdout == expected.encode()
                row = {"case": name, "sample": sample, "lane": lane, "passed": passed,
                       "exit_code": p.returncode, "stdin": stdin, "expected": expected,
                       "stdout": p.stdout.decode("utf-8", errors="replace")}
                (log / "stdout.txt").write_bytes(p.stdout)
                (log / "stderr.txt").write_bytes(p.stderr)
            except Exception as exc:
                row = {"case": name, "lane": lane, "passed": False, "error": str(exc)}
            rows.append(row)
            if not row["passed"]:
                print("FAIL", row)
    suffix = "course-runtime" if args.course_runtime else "equivalence"
    record = {"cases": len(cases()), "lanes": lanes, "checks": len(rows),
              "passed": sum(row["passed"] for row in rows), "results": rows}
    write_json(ROOT / f"results/{suffix}.json", record)
    print(f"{suffix}: {record['passed']}/{record['checks']} checks passed")
    return 0 if record["passed"] == record["checks"] else 1

if __name__ == "__main__":
    sys.exit(main())
