"""Request and verify an explicit native render review of one frozen runtime."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import struct

from qa_common import ROOT, ERROR, evidence_root, git_head, runtime_hashes, sha256, version

FIXTURE = ROOT / "prototype/tests/visual_frontend_preview.gd"
EXPECTED_CAPTURES = {
    "01_menu_arrivee.png", "02_options.png", "03_nouvelle_intervention.png",
    "04_signature_studio.png", "05_titre.png",
    "06_approche_03.png", "06_approche_10.png", "06_approche_17.png", "06_approche_25.png",
    "07_pause_intro.png", "08_menu_archives.png", "09_dossier_apres.png", "10_menu_refuge.png",
    "11_inspection_toit.png", "12_inspection_archives.png", "13_inspection_apres.png", "14_toit_equipe.png",
    "15_portage.png", "16_treuillage.png", "17_reception.png", "18_meteo_toit.png", "19_options_pause.png",
    "20_journal_situation.png", "21_journal_rescapes.png", "22_journal_indices.png", "23_journal_transmissions.png",
    "24_epilogue_02.png", "24_epilogue_07.png", "24_epilogue_12.png", "25_bilan_refuge.png",
    "26_suites_presence.png", "27_archives_traces.png", "28_spa_remanence.png",
    "29_station_rappel_toit.png", "30_rappel_descente.png", "31_rappel_verrouille.png",
    "32_escalier_30_29.png", "33_escalier_palier.png", "34_rappel_remontee.png",
    "35_aide_deplacements.png", "36_escalier_28_27.png", "37_escalier_26_25.png",
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit("FAIL: " + message)


def read_request(path: Path) -> dict:
    data = json.loads(path.read_text())
    require(data["format"] == 1 and data["version"] == version(), "Capture request version does not match this project.")
    require(data["runtime_sha256"] == runtime_hashes(), "Runtime changed after its capture request.")
    require(data["fixture_sha256"] == sha256(FIXTURE), "Visual fixture changed after its capture request.")
    require(data["expected_captures"] == sorted(EXPECTED_CAPTURES), "Capture request does not cover the expected visual states.")
    validation = evidence_root() / "VERIFICATION.json"
    require(data["verification_sha256"] == sha256(validation), "Source verification changed after its capture request.")
    verified = json.loads(validation.read_text())
    require(verified["all_pass"] and verified["sha256_after"] == data["runtime_sha256"], "Requested runtime lacks passing source verification.")
    return data


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["request", "check-request", "verify"])
    parser.add_argument("--request", type=Path, default=ROOT / ".review" / ("v" + ".".join(version().split(".")[:2])) / "request.json")
    parser.add_argument("--capture-root", type=Path)
    parser.add_argument("--log", type=Path)
    args = parser.parse_args()
    if args.action == "request":
        validation = evidence_root() / "VERIFICATION.json"
        verified = json.loads(validation.read_text())
        require(verified["all_pass"] and verified["sha256_after"] == runtime_hashes(), "Run source validation on the frozen runtime first.")
        request = {
            "format": 1, "version": version(), "requested_utc": datetime.now(timezone.utc).isoformat(),
            "local_freeze_commit": git_head(), "runtime_sha256": runtime_hashes(),
            "fixture_sha256": sha256(FIXTURE), "verification_sha256": sha256(validation),
            "expected_captures": sorted(EXPECTED_CAPTURES),
            "purpose": "Explicitly render the frozen source using Godot Compatibility, Xvfb and Mesa; prepared states, not a human playthrough.",
        }
        args.request.parent.mkdir(parents=True, exist_ok=True)
        args.request.write_text(json.dumps(request, indent=2, ensure_ascii=False) + "\n")
        print(f"Prepared explicit request for {len(EXPECTED_CAPTURES)} native captures: {args.request}")
        return
    request = read_request(args.request)
    if args.action == "check-request":
        print(f"Verified capture request against {len(request['runtime_sha256'])} frozen runtime files.")
        return
    require(args.capture_root is not None, "--capture-root is required for verification.")
    root = args.capture_root
    manifest = json.loads((root / "MANIFEST.json").read_text())
    records = manifest.get("captures", [])
    names = [row["file"] for row in records]
    require(len(names) == len(set(names)) and set(names) == EXPECTED_CAPTURES, "Capture set is incomplete or contains duplicates.")
    require(manifest.get("version") == version(), "Wrong captured project version.")
    require(manifest.get("human_playthrough") is False and manifest.get("prepared_states") is True, "Capture protocol must identify prepared states.")
    require(manifest.get("display") != "headless" and manifest.get("rendering_method") == "gl_compatibility", "Native Compatibility renderer was not used.")
    if args.log:
        errors = [line for line in args.log.read_text(errors="replace").splitlines() if ERROR.search(line)]
        require(not errors, "Native capture log contains runtime errors: " + repr(errors[:5]))
    evidence = []
    for record in records:
        name = record["file"]
        require(Path(name).name == name, "Unsafe capture path.")
        data = (root / name).read_bytes()
        require(data[:8] == b"\x89PNG\r\n\x1a\n" and data[12:16] == b"IHDR", "Invalid PNG: " + name)
        width, height = struct.unpack(">II", data[16:24])
        require((width, height) == (1440, 900) and (record["width"], record["height"]) == (width, height), "Unexpected capture dimensions.")
        evidence.append({"file": name, "bytes": len(data), "sha256": sha256(root / name), "width": width, "height": height})
    report = {
        "version": version(), "source_commit": os.environ.get("GITHUB_SHA", git_head()),
        "run_url": f'{os.environ.get("GITHUB_SERVER_URL", "https://github.com")}/{os.environ.get("GITHUB_REPOSITORY", "darknigthmare/The-Descents")}/actions/runs/{os.environ.get("GITHUB_RUN_ID", "local")}',
        "godot_archive_sha256": os.environ.get("GODOT_ARCHIVE_SHA256", ""),
        "engine": manifest.get("engine"), "display": manifest.get("display"), "rendering_method": manifest.get("rendering_method"),
        "capture_protocol": "Native Godot Compatibility renderer via Xvfb and Mesa software rendering; prepared game states.",
        "human_playthrough": False, "manual_visual_review": False,
        "request_sha256": sha256(args.request), "fixture_sha256": request["fixture_sha256"],
        "runtime_sha256": request["runtime_sha256"], "verification_sha256": request["verification_sha256"],
        "captures": evidence,
    }
    (root / "CI_PROVENANCE.json").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
    print(f"Verified {len(evidence)} native 1440x900 captures of the frozen runtime.")


if __name__ == "__main__":
    main()
