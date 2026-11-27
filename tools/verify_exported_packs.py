"""Mount final Windows/Web resource packs from an empty directory and record proof.

This is a Linux headless resource/logic check, not a Windows or WebAssembly launch.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import tempfile

from qa_common import ROOT, evidence_root, git_head, godot_binary, run, runtime_hashes, sha256, version


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    binary = godot_binary(args.godot)
    output = args.output or evidence_root()
    output.mkdir(parents=True, exist_ok=True)
    verified = json.loads((output / "VERIFICATION.json").read_text())
    if not verified["all_pass"] or verified["sha256_after"] != runtime_hashes():
        raise SystemExit("The source runtime must pass and remain frozen before testing exports.")
    test = ROOT / "prototype/tests/test_exported_pack.gd"
    script_hash = sha256(test)
    packs = []
    for platform, relative in [("windows", "builds/windows/TheTowerDescent.exe"), ("web", "builds/web/index.pck")]:
        path = ROOT / relative
        before = sha256(path)
        with tempfile.TemporaryDirectory(prefix="tower-v09-pack-") as empty:
            directory = Path(empty)
            was_empty = not any(directory.iterdir())
            entry = run([binary, "--headless", "--main-pack", str(path), "--script", str(test)],
                        cwd=directory, timeout=120, log=output / ("exported-" + platform + ".txt"))
        unchanged = before == sha256(path)
        entry.update({"platform": platform, "pack": relative, "pack_bytes": path.stat().st_size,
                      "pack_sha256": before, "pack_unchanged_during_test": unchanged,
                      "execution_directory_was_empty": was_empty, "log_sha256": entry.pop("sha256")})
        entry["pass"] = entry["pass"] and unchanged and was_empty
        packs.append(entry)
        print(f'{"PASS" if entry["pass"] else "FAIL"} exported {platform}: {entry["checks"]} checks', flush=True)
    report = {
        "version": version(), "runtime_freeze_commit": verified["runtime_freeze_commit"], "git_head": git_head(),
        "verified_utc": datetime.now(timezone.utc).isoformat(),
        "engine": subprocess.check_output([binary, "--version"], text=True).strip(),
        "test_script": test.relative_to(ROOT).as_posix(), "test_script_sha256": script_hash,
        "runtime_sha256": verified["sha256_after"],
        "packs": packs, "total_checks": sum(entry["checks"] for entry in packs),
        "all_pass": all(entry["pass"] for entry in packs) and script_hash == sha256(test) and verified["sha256_after"] == runtime_hashes(),
        "included_in_source_suite_total": False,
        "method": "Linux Godot mounts each final EXE/PCK with --main-pack from a newly created empty directory, loading the absolute external test script. Every res:// resource comes from the exported pack.",
        "limitations": [
            "Mounts the Windows EXE embedded pack; does not execute the Windows binary.",
            "Mounts the Web PCK; does not launch WebAssembly or render WebGL in a browser.",
            "No claim of audible mix quality or platform-specific input compatibility.",
        ],
    }
    (output / "EXPORTED_PACK_VERIFICATION.json").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
    raise SystemExit(0 if report["all_pass"] else 1)


if __name__ == "__main__":
    main()
