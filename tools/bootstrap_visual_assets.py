#!/usr/bin/env python3
"""Generate the v0.11 asset candidate; this job cannot approve or release it."""
from __future__ import annotations
import json, os, subprocess, sys
from datetime import datetime, timezone
from qa_common import ROOT, git_head, runtime_hashes, sha256
BRANCH = "feat/live-tower-collapse"
REQUEST = ".review/v0.11/assets-request.json"
OUT = ROOT / "docs/validation/v0.11"
REPORT = OUT / "ASSET_BOOTSTRAP.json"

def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()

def guard():
    request = json.loads((ROOT / REQUEST).read_text())
    assert request["format"] == 1 and request["version"] == "0.11.0"
    assert request["source_commit"] == git("rev-parse", "HEAD^")
    assert git("diff", "--name-only", "HEAD^", "HEAD").splitlines() == [REQUEST]
    assert os.environ.get("GITHUB_REF") == "refs/heads/" + BRANCH
    assert os.environ.get("GITHUB_SHA") == git_head()
    return request

def record(p):
    return {"file": p.relative_to(ROOT).as_posix(), "bytes": p.stat().st_size, "sha256": sha256(p)}

def generate():
    request = guard()
    OUT.mkdir(parents=True, exist_ok=True)
    subprocess.run([sys.executable, "-m", "py_compile", "tools/generate_rescue_models.py"], cwd=ROOT, check=True)
    command = ["blender", "--background", "--factory-startup", "--threads", "2", "--python-exit-code", "1",
               "--python", "tools/generate_rescue_models.py", "--", "--root", str(ROOT), "--render"]
    with (OUT / "model-generation.txt").open("w") as log:
        result = subprocess.run(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, timeout=1200)
    if result.returncode:
        print((OUT / "model-generation.txt").read_text(errors="replace")[-20000:])
        raise SystemExit(result.returncode)
    validator = ROOT / "tools/validate_rescue_models.py"
    if validator.exists():
        subprocess.run([sys.executable, str(validator), "--root", str(ROOT), "--previews"], check=True, cwd=ROOT)
    glbs = sorted((ROOT / "prototype/assets/models/rescue_v011").glob("*.glb"))
    assert len(glbs) == 16, "All sixteen exported models are required."
    assert all(p.read_bytes()[:4] == b"glTF" for p in glbs)
    assert (ROOT / "docs/assets/v0.11/rescue_equipment.blend").is_file()
    checks = subprocess.run([sys.executable, "tools/run_validation.py", "--godot", os.environ["GODOT_BINARY"]], cwd=ROOT)
    verified = json.loads((OUT / "VERIFICATION.json").read_text()) if (OUT / "VERIFICATION.json").exists() else {}
    generated = glbs + [p for p in sorted((ROOT / "docs/assets/v0.11").rglob("*")) if p.is_file()]
    generated += [ROOT / "prototype/scripts/rescue_asset_catalog.gd"]
    report = {
        "format": 1, "version": "0.11.0", "phase": "asset_candidate", "source_commit": request["source_commit"],
        "request_commit": git_head(), "generated_utc": datetime.now(timezone.utc).isoformat(),
        "blender": subprocess.check_output(["blender", "--version"], text=True).splitlines()[0],
        "godot": subprocess.check_output([os.environ["GODOT_BINARY"], "--version"], text=True).strip(),
        "generator_sha256": sha256(ROOT / "tools/generate_rescue_models.py"),
        "generated": [record(p) for p in generated], "runtime_sha256": runtime_hashes(),
        "source_tests_passed": checks.returncode == 0 and verified.get("all_pass") is True,
        "release_approved": False, "native_game_review_done": False,
        "note": "Generated asset candidate only. Native captures, visual review and release packaging are separate gates."
    }
    REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({k: report[k] for k in ["phase", "source_tests_passed", "release_approved"]}))

def publish():
    guard()
    report = json.loads(REPORT.read_text())
    assert report["request_commit"] == git_head() and report["phase"] == "asset_candidate"
    expected = os.environ["GITHUB_SHA"]
    target = "refs/heads/" + BRANCH
    if git("ls-remote", "origin", target).split()[0] != expected:
        print("Branch advanced; candidate retained only in workflow artifact.")
        return
    paths = ["prototype/assets/models/rescue_v011", "prototype/scripts/rescue_asset_catalog.gd",
             "docs/assets/v0.11", "docs/validation/v0.11"]
    paths += [p for p in git("ls-files", "--others", "--exclude-standard", "--", "prototype").splitlines() if p.endswith(".uid")]
    subprocess.run(["git", "add", "--", *paths], cwd=ROOT, check=True)
    staged = git("diff", "--cached", "--name-only").splitlines()
    assert all(any(p == q or p.startswith(q + "/") for q in paths) for p in staged)
    if staged:
        git("config", "user.name", "github-actions[bot]")
        git("config", "user.email", "41898282+github-actions[bot]@users.noreply.github.com")
        git("commit", "-m", "Generate v0.11 rescue asset candidate for visual review")
        subprocess.run(["git", "push", "origin", "HEAD:" + target], cwd=ROOT, check=True)

if __name__ == "__main__":
    action = sys.argv[1]
    if action == "guard": guard()
    elif action == "generate": generate()
    elif action == "publish": publish()
    elif action == "check":
        assert json.loads(REPORT.read_text())["source_tests_passed"], "Candidate tests failed; inspect reports before review."
    else: raise SystemExit("Unknown action")
