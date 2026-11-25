"""Run every source suite sequentially and bind the evidence to the frozen runtime.

Usage: python3 tools/run_validation.py --godot /usr/local/bin/godot4
Run after the runtime has been frozen. This does not render a visual review.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess

from qa_common import ROOT, evidence_root, git_head, godot_binary, run, runtime_hashes, sha256, version

REQUIRED = {
    "generation", "save", "mission", "routes", "collapse", "incident_integration", "incident_routes",
    "incident_effects", "team_reactions", "radio", "radio_integration", "cinematics", "preferences",
    "cinematic_integration", "field_props", "world_presentation", "arrival_staging", "field_integration",
    "rescue_presentation", "comfort", "atmosphere",
    "mission_dossier", "epilogue", "epilogue_integration",
}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    binary = godot_binary(args.godot)
    output = args.output or evidence_root()
    output.mkdir(parents=True, exist_ok=True)
    engine = subprocess.check_output([binary, "--version"], text=True).strip()
    imported = run([binary, "--headless", "--path", str(ROOT / "prototype"), "--editor", "--import", "--quit"],
                   cwd=ROOT, timeout=180, log=output / "final-import.txt")
    imported["pass"] = imported["returncode"] == 0 and not imported["error_lines"]
    if not imported["pass"]:
        print((output / imported["log"]).read_text(errors="replace")[-20000:], flush=True)
    before = runtime_hashes()
    scripts = sorted((ROOT / "prototype/tests").glob("test_*.gd"))
    scripts = [script for script in scripts if script.name != "test_exported_pack.gd"]
    missing = sorted(REQUIRED - {script.stem.removeprefix("test_") for script in scripts})
    suites = []
    if imported["pass"] and not missing:
        for script in scripts:
            name = script.stem.removeprefix("test_")
            command = [binary, "--headless", "--path", str(ROOT / "prototype")]
            if name in {"routes", "incident_routes"}:
                command += ["--fixed-fps", "60"]
            command += ["--script", "res://tests/" + script.name]
            entry = run(command, cwd=ROOT, timeout=180, log=output / ("final-" + name + ".txt"))
            entry.update({"suite": name, "script": script.relative_to(ROOT).as_posix(), "script_sha256": sha256(script)})
            suites.append(entry)
            print(f'{"PASS" if entry["pass"] else "FAIL"} {name}: {entry["checks"]} checks', flush=True)
            if not entry["pass"]:
                print((output / entry["log"]).read_text(errors="replace")[-20000:], flush=True)
    after = runtime_hashes()
    report = {
        "version": version(),
        "label": "v0.7 persistent mission dossier, contextual debrief and in-game rescue epilogue",
        "validated_utc": datetime.now(timezone.utc).isoformat(),
        "engine": engine,
        "runtime_freeze_commit": git_head(),
        "git_head": git_head(),
        "import": imported,
        "required_suites": sorted(REQUIRED),
        "missing_suites": missing,
        "suites": suites,
        "total_checks": sum(item["checks"] for item in suites),
        "all_pass": imported["pass"] and not missing and bool(suites) and all(item["pass"] for item in suites) and before == after,
        "runtime_unchanged_during_run": before == after,
        "sha256_before": before,
        "sha256_after": after,
        "limitations": [
            "Source logic and physical-collision tests run in Linux Godot headless; they do not launch Windows or a browser.",
            "Mission/UI integration uses prepared placements and sampled clocks. Actual capsule traversal is checked by the route suites.",
            "The renderer, text layout and visual staging require separate native captures and review.",
            "Imported audio streams do not establish audible playback quality or mix balance.",
        ],
    }
    (output / "VERIFICATION.json").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps({"all_pass": report["all_pass"], "suites": len(suites), "checks": report["total_checks"], "missing": missing}))
    raise SystemExit(0 if report["all_pass"] else 1)


if __name__ == "__main__":
    main()
