#!/usr/bin/env python3
"""Validate and render a frozen v0.12 review candidate without publishing it.

The request is a separate child commit of the complete source commit. Its
runtime_sha256 must equal qa_common.runtime_hashes() exactly. Only the request
path may change in that child commit. The request also declares the exact PNG
basenames under expected_captures.compatibility and .forward_plus.

Commands:
    python3 tools/build_commerce_candidate.py guard
    python3 tools/build_commerce_candidate.py build --godot /path/to/godot

No approval file, distribution directory, release archive, Git commit or push
is created here. Prepared native captures remain unreviewed until a reviewer
opens the exact retained images. Linux resource-pack checks do not execute the
Windows application or WebAssembly in a browser.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

from qa_common import ROOT, git_head, godot_binary, run, runtime_hashes, sha256, version


VERSION = "0.12.0"
BRANCH = "feat/live-tower-collapse"
REQUEST = ROOT / ".review/v0.12/candidate-request.json"
VALIDATION = ROOT / "docs/validation/v0.12"
CAPTURES = ROOT / "docs/captures/v0.12/commerce"
FIXTURE = ROOT / "prototype/tests/visual_commerce_preview.tscn"
GODOT_ARCHIVE_URL = "https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip"
GODOT_ARCHIVE_SHA256 = "cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4"
TEMPLATE_URL = "https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz"
PINNED_TEMPLATES = {
    "version.txt": (13, "38885c88f75abbc797a1db7559719800279a00cfb9fa8b2e2868a7f6f84bad2e"),
    "web_nothreads_release.zip": (10245903, "d3ee2f08cef0cf3cf6678a6355a92a8db48ccdd35cbd2e8bfd5f0e8a0b4032a0"),
    "windows_release_x86_64.exe": (109268480, "d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562"),
}
EXPECTED_CAPTURES = {
    "compatibility": [
        "01_bilan_23.png", "02_gallery_22.png", "03_mina_shutter_closed.png",
        "04_mina_shutter_open.png", "05_retranche_close.png", "06_retranche_calm.png",
        "07_kitchen_before.png", "08_kitchen_after.png", "09_stairs_22_21.png",
        "10_rope_22_21.png", "11_refuge_20.png", "12_receptions_20.png",
        "13_journal_people.png", "14_journal_clues.png", "15_bilan_20.png",
        "16_menu_20.png", "17_compact_journal.png", "18_compact_bilan.png",
    ],
    "forward_plus": ["02_gallery_22.png", "07_kitchen_before.png", "11_refuge_20.png"],
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def read_json(path: Path) -> dict:
    result = json.loads(path.read_text(encoding="utf-8"))
    require(isinstance(result, dict), "Expected a JSON object: " + str(path))
    return result


def write_json(path: Path, value: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def record(path: Path) -> dict:
    require(path.is_file(), "Missing expected file: " + str(path))
    return {"file": path.relative_to(ROOT).as_posix(), "bytes": path.stat().st_size, "sha256": sha256(path)}


def git(*arguments: str) -> str:
    return subprocess.check_output(["git", *arguments], cwd=ROOT, text=True).strip()


def guard() -> dict:
    request = read_json(REQUEST)
    require(request.get("format") == 1 and request.get("version") == VERSION == version(),
            "Candidate request and project must both identify version 0.12.0.")
    require(request.get("phase") == "candidate", "This tool only accepts an unreviewed candidate request.")
    require(isinstance(request.get("request_id"), str)
            and re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,79}", request["request_id"]) is not None,
            "Invalid candidate request identifier.")
    require(isinstance(request.get("source_commit"), str)
            and re.fullmatch(r"[0-9a-f]{40}", request["source_commit"]) is not None,
            "The source commit must be its complete lowercase Git SHA.")
    head = git_head()
    expected_ref = "refs/heads/" + BRANCH
    require(os.environ.get("GITHUB_REF", expected_ref) == expected_ref, "Only the existing PR branch is permitted.")
    require(os.environ.get("GITHUB_SHA", head) == head, "Checkout differs from the requested GitHub revision.")
    parents = git("rev-list", "--parents", "-n", "1", "HEAD").split()
    require(len(parents) == 2 and parents[1] == request["source_commit"],
            "The isolated request must be a direct single-parent child of the declared source commit.")
    changed = git("diff", "--name-only", "--no-renames", "HEAD^", "HEAD").splitlines()
    require(changed == [REQUEST.relative_to(ROOT).as_posix()],
            "Commit candidate-request.json alone after all source and fixture changes.")
    require(not git("diff", "--name-only", "HEAD", "--", "prototype", "tools",
                    "docs/EXPORT_TEMPLATE_PROVENANCE.json", ".github/workflows/commerce-review.yml"),
            "Authored inputs must match the frozen checkout before validation.")
    require(request.get("runtime_sha256") == runtime_hashes(),
            "Runtime files differ from the request's exact SHA256 dictionary.")
    expected = request.get("expected_captures")
    require(isinstance(expected, dict) and set(expected) == set(EXPECTED_CAPTURES),
            "Declare both exact capture groups: compatibility and forward_plus.")
    for group, names in EXPECTED_CAPTURES.items():
        values = expected[group]
        require(isinstance(values, list) and all(isinstance(value, str) for value in values)
                and len(values) == len(set(values)) and sorted(values) == sorted(names),
                "The requested native capture set differs: " + group)
    require(FIXTURE.is_file() and FIXTURE.with_suffix(".gd").is_file(), "The commerce native fixture is missing.")
    write_json(VALIDATION / "CANDIDATE_REQUEST_GUARD.json", {
        "version": VERSION, "request": record(REQUEST), "source_commit": request["source_commit"],
        "request_commit": head, "isolated_request": True, "runtime_matches": True,
        "expected_captures": expected, "approval_generated": False,
    })
    return request


def checked(command: list[str], log_name: str, timeout: int = 240) -> dict:
    VALIDATION.mkdir(parents=True, exist_ok=True)
    path = VALIDATION / log_name
    result = run(command, cwd=ROOT, timeout=timeout, log=path)
    result["pass"] = result["returncode"] == 0 and not result["error_lines"]
    if not result["pass"]:
        print(path.read_text(errors="replace")[-20000:], flush=True)
    require(result["pass"], "Command failed or emitted an error; see " + path.relative_to(ROOT).as_posix())
    return result


def tool(name: str, *arguments: str, timeout: int = 300) -> dict:
    return checked([sys.executable, str(ROOT / "tools" / name), *arguments],
                   "candidate-" + Path(name).stem + ".txt", timeout)


def install_templates() -> None:
    provenance = ROOT / "docs/EXPORT_TEMPLATE_PROVENANCE.json"
    pinned = read_json(provenance)
    require(pinned.get("version") == "4.7.2-stable" and pinned.get("source_url") == TEMPLATE_URL,
            "Export template provenance changed its official version or source.")
    rows = pinned.get("files", [])
    require(isinstance(rows, list) and len(rows) == len(PINNED_TEMPLATES)
            and all(isinstance(row, dict) for row in rows), "Incomplete template provenance.")
    require({row.get("name"): (row.get("size"), row.get("sha256")) for row in rows} == PINNED_TEMPLATES,
            "Export template fingerprints differ from the pinned official files.")
    data_home = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share")))
    destination = data_home / "godot/export_templates/4.7.2.stable"
    available = all((destination / name).is_file() and (destination / name).stat().st_size == size
                    and sha256(destination / name) == digest for name, (size, digest) in PINNED_TEMPLATES.items())
    if not available:
        tool("fetch_export_templates.py", "--version", "4.7.2-stable", "--destination", str(destination), timeout=600)
    for name, (size, digest) in PINNED_TEMPLATES.items():
        path = destination / name
        require(path.is_file() and path.stat().st_size == size and sha256(path) == digest,
                "A downloaded official template differs: " + name)
    write_json(VALIDATION / "CANDIDATE_TEMPLATES.json", {
        "version": VERSION, "source_provenance": record(provenance), "files": rows,
        "template_file_sha256_verified": True, "complete_archive_sha256_verified": False,
    })


def export_packs(binary: str, request: dict) -> dict:
    install_templates()
    results = []
    for platform, preset, filename in [
        ("windows", "Windows Desktop", "TheTowerDescent.exe"), ("web", "Web", "index.html")
    ]:
        destination = ROOT / "builds" / platform
        if destination.exists():
            shutil.rmtree(destination)
        destination.mkdir(parents=True)
        result = checked([binary, "--headless", "--path", str(ROOT / "prototype"),
                          "--export-release", preset, str(destination / filename)],
                         "candidate-export-" + platform + ".txt", 600)
        result["platform"] = platform
        results.append(result)
    with (ROOT / "builds/windows/TheTowerDescent.exe").open("rb") as executable:
        require(executable.read(2) == b"MZ", "Windows export lacks its executable header.")
    web = ROOT / "builds/web"
    require(all((web / name).is_file() and (web / name).stat().st_size > 0
                for name in ("index.html", "index.js", "index.wasm", "index.pck")), "Web export is incomplete.")
    # Freeze the legal notices with the Web export so the distribution can
    # later be an exact byte-for-byte mirror, including these required files.
    shutil.copy2(ROOT / "docs/GODOT_LICENSES.txt", web / "GODOT_LICENSES.txt")
    for name in ("LICENSE", "NOTICE"):
        shutil.copy2(ROOT / "prototype/assets/fonts" / (name + ".txt"), web / ("OPEN_SANS_" + name + ".txt"))
    require(runtime_hashes() == request["runtime_sha256"], "Export changed the tested runtime.")
    report = {
        "version": VERSION, "source_commit": request["source_commit"], "request_commit": git_head(),
        "runtime_sha256": request["runtime_sha256"], "exports": results,
        "outputs": [record(path) for folder in (ROOT / "builds/windows", web)
                    for path in sorted(folder.rglob("*")) if path.is_file()],
        "all_pass": True, "windows_application_executed": False, "webassembly_browser_executed": False,
    }
    write_json(VALIDATION / "CANDIDATE_EXPORTS.json", report)
    tool("verify_exported_packs.py", "--godot", binary, "--output", str(VALIDATION), timeout=360)
    pack_report = read_json(VALIDATION / "EXPORTED_PACK_VERIFICATION.json")
    require(pack_report.get("version") == VERSION and pack_report.get("all_pass") is True
            and pack_report.get("runtime_sha256") == request["runtime_sha256"],
            "Exported resource packs lack passing verification for this runtime.")
    return report


def validate_capture_group(group: str, renderer: str) -> list[dict]:
    # Pillow is only needed after the workflow's dependency installation.
    from PIL import Image

    destination = CAPTURES / group
    manifest = read_json(destination / "MANIFEST.json")
    require(manifest.get("version") == VERSION and manifest.get("prepared_states") is True
            and manifest.get("human_playthrough") is False, "Capture manifest misidentifies its version or method.")
    require(manifest.get("display") not in {None, "", "headless"}
            and manifest.get("rendering_method") == renderer, "Capture silently fell back to another renderer.")
    require("4.7.2" in str(manifest.get("engine", "")), "Capture engine differs from the pinned version.")
    shots = manifest.get("captures")
    require(isinstance(shots, list) and all(isinstance(shot, dict) for shot in shots), "Malformed capture records.")
    names = [shot.get("file") for shot in shots]
    require(all(isinstance(name, str) for name in names) and len(names) == len(set(names))
            and sorted(names) == sorted(EXPECTED_CAPTURES[group]), "Missing, duplicate or unexpected native captures.")
    require({path.name for path in destination.glob("*.png")} == set(names), "Unlisted or absent PNG files.")
    records = []
    for shot in shots:
        path = destination / shot["file"]
        expected_size = (1024, 640) if shot["file"].startswith(("17_", "18_")) else (1440, 900)
        with Image.open(path) as captured:
            require(captured.format == "PNG", "A capture is not a PNG: " + path.name)
            captured.load()
            width, height = captured.size
        require((width, height) == expected_size and (shot.get("width"), shot.get("height")) == expected_size,
                "Capture dimensions differ from the prepared state: " + path.name)
        require(shot.get("prepared_state") is True and shot.get("sha256") == sha256(path),
                "Capture state or fingerprint differs: " + path.name)
        require(isinstance(shot.get("description"), str) and bool(shot["description"].strip()),
                "A prepared capture lacks its description: " + path.name)
        records.append({**record(path), "width": width, "height": height, "group": group,
                        "description": shot["description"], "prepared_state": True})
    return records


def capture(binary: str, request: dict, group: str) -> dict:
    renderer = "gl_compatibility" if group == "compatibility" else "forward_plus"
    driver = "opengl3" if group == "compatibility" else "vulkan"
    destination = CAPTURES / group
    if destination.exists():
        shutil.rmtree(destination)
    destination.mkdir(parents=True)
    command = ["xvfb-run", "-a", "-s", "-screen 0 1440x900x24", binary,
               "--path", str(ROOT / "prototype"), "--rendering-method", renderer,
               "--rendering-driver", driver, "--audio-driver", "Dummy", "--resolution", "1440x900",
               "res://tests/visual_commerce_preview.tscn", "--",
               "--capture-root=" + str(destination), "--expected-renderer=" + renderer]
    executed = checked(command, "candidate-native-" + group + ".txt", 900 if group == "compatibility" else 1800)
    records = validate_capture_group(group, renderer)
    provenance = {
        "version": VERSION, "source_commit": request["source_commit"], "request_commit": git_head(),
        "runtime_sha256": request["runtime_sha256"], "rendering_method": renderer,
        "fixture": [record(FIXTURE), record(FIXTURE.with_suffix(".gd"))],
        "manifest": record(destination / "MANIFEST.json"), "execution": executed,
        "captures": records, "prepared_states": True, "human_playthrough": False,
        "manual_visual_review": False, "approval_generated": False,
    }
    write_json(destination / "PROVENANCE.json", provenance)
    return {"status": "captured_awaiting_visual_review", "provenance": record(destination / "PROVENANCE.json"),
            "rendering_method": renderer, "capture_count": len(records), "captures": records}


def probe_vulkan() -> dict:
    executable = shutil.which("vulkaninfo")
    if not executable:
        result = {"available": False, "reason": "vulkaninfo is unavailable; Forward+ was not attempted."}
    else:
        path = VALIDATION / "candidate-vulkan-probe.txt"
        probe = run(["xvfb-run", "-a", "-s", "-screen 0 1440x900x24", executable, "--summary"],
                    cwd=ROOT, timeout=90, log=path)
        content = path.read_text(errors="replace")
        available = probe["returncode"] == 0 and ("deviceName" in content or "GPU" in content)
        probe["pass"] = available
        result = {"available": available, "probe": probe,
                  "reason": "Vulkan device enumeration succeeded." if available else "Vulkan device enumeration failed; Forward+ was not attempted."}
    write_json(VALIDATION / "CANDIDATE_VULKAN.json", result)
    return result


def append_summary(report: dict) -> None:
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if not summary:
        return
    lines = ["## The Tower Descent v0.12 candidate", "", "Status: " + report["status"], "",
             "Native captures are prepared states. Their exact PNG bytes still require visual review.",
             "This workflow creates no approval, release archive, distribution commit or publication.", ""]
    for group, value in report.get("renderers", {}).items():
        lines.append(f"- {group}: {value['status']} ({value.get('capture_count', 0)} captures)")
    if report.get("error"):
        lines.extend(["", "Failure: " + report["error"]])
    with Path(summary).open("a", encoding="utf-8") as destination:
        destination.write("\n".join(lines) + "\n")


def build(binary: str) -> None:
    report = {"version": VERSION, "status": "running", "stage": "request_guard",
              "started_utc": datetime.now(timezone.utc).isoformat(), "renderers": {},
              "approval_generated": False, "release_packaged": False, "published": False,
              "manual_visual_review": False, "human_playthrough": False}
    report_path = VALIDATION / "CANDIDATE.json"
    try:
        request = guard()
        report.update({"request": record(REQUEST), "source_commit": request["source_commit"],
                       "request_commit": git_head(), "runtime_sha256": request["runtime_sha256"],
                       "pipeline_sha256": sha256(Path(__file__)),
                       "fixture": [record(FIXTURE), record(FIXTURE.with_suffix(".gd"))]})
        engine = subprocess.check_output([binary, "--version"], text=True).strip()
        require(engine.startswith("4.7.2.stable.official"), "The builder must use official Godot 4.7.2.")
        if os.environ.get("GITHUB_ACTIONS") == "true":
            require(os.environ.get("GODOT_ARCHIVE_URL") == GODOT_ARCHIVE_URL
                    and os.environ.get("GODOT_ARCHIVE_SHA256") == GODOT_ARCHIVE_SHA256,
                    "Workflow Godot archive pin differs from the candidate pipeline.")
        report["engine"] = {"version": engine, "binary_sha256": sha256(Path(binary)),
                            "archive_url": GODOT_ARCHIVE_URL, "archive_sha256": GODOT_ARCHIVE_SHA256}
        report["stage"] = "source_validation"
        write_json(report_path, report)
        tool("run_validation.py", "--godot", binary, "--output", str(VALIDATION), timeout=2400)
        source = read_json(VALIDATION / "VERIFICATION.json")
        require(source.get("all_pass") is True and source.get("version") == VERSION
                and source.get("sha256_before") == source.get("sha256_after") == request["runtime_sha256"],
                "Source validation does not match this exact frozen runtime.")
        report["source_validation"] = record(VALIDATION / "VERIFICATION.json")
        report["stage"] = "resource_exports"
        write_json(report_path, report)
        export_packs(binary, request)
        report["exports"] = record(VALIDATION / "CANDIDATE_EXPORTS.json")
        report["exported_resource_verification"] = record(VALIDATION / "EXPORTED_PACK_VERIFICATION.json")
        report["stage"] = "compatibility_capture"
        write_json(report_path, report)
        report["renderers"]["compatibility"] = capture(binary, request, "compatibility")
        report["stage"] = "vulkan_probe"
        write_json(report_path, report)
        probe = probe_vulkan()
        if probe["available"]:
            report["stage"] = "forward_plus_capture"
            write_json(report_path, report)
            # A fixture or rendering error after a successful device probe is
            # a failed candidate, not an excuse to report an optional skip.
            report["renderers"]["forward_plus"] = capture(binary, request, "forward_plus")
        else:
            report["renderers"]["forward_plus"] = {"status": "skipped_unavailable", "capture_count": 0,
                                                       "reason": probe["reason"]}
        require(runtime_hashes() == request["runtime_sha256"], "Candidate generation modified authored runtime files.")
        complete = probe["available"]
        report.update({"stage": "complete", "automated_steps_passed": True,
                       "all_requested_renderers_captured": complete,
                       "status": "awaiting_visual_review" if complete else "partial_renderer_coverage",
                       "finished_utc": datetime.now(timezone.utc).isoformat(),
                       "limitations": ["Native images are prepared states, not a recorded human playthrough.",
                                       "CI uses software graphics; it is not a player's GPU benchmark.",
                                       "Linux resource-pack checks do not execute Windows or browser WebAssembly.",
                                       "Explicit review of exact retained images is required before release packaging or publication."]})
        write_json(report_path, report)
        append_summary(report)
        print(json.dumps({"status": report["status"], "all_requested_renderers_captured": complete,
                          "captures": sum(value["capture_count"] for value in report["renderers"].values()),
                          "published": False, "approval_generated": False}, ensure_ascii=False), flush=True)
    except Exception as error:
        report.update({"status": "failed", "automated_steps_passed": False, "error": str(error),
                       "finished_utc": datetime.now(timezone.utc).isoformat()})
        write_json(report_path, report)
        append_summary(report)
        raise


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["guard", "build"])
    parser.add_argument("--godot")
    args = parser.parse_args()
    if args.command == "guard":
        try:
            request = guard()
            print(json.dumps({"request_id": request["request_id"], "version": VERSION,
                              "source_commit": request["source_commit"], "request_commit": git_head(),
                              "guard_passed": True}, ensure_ascii=False))
        except Exception as error:
            report = {"version": VERSION, "status": "failed", "stage": "request_guard", "error": str(error),
                      "approval_generated": False, "release_packaged": False, "published": False}
            write_json(VALIDATION / "CANDIDATE.json", report)
            append_summary(report)
            raise
    else:
        build(godot_binary(args.godot))


if __name__ == "__main__":
    main()
