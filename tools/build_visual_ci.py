#!/usr/bin/env python3
"""Review and release v0.11 rescue equipment, materials and native lighting.

Assets must already have been generated, committed and frozen by the separate
bootstrap. This pipeline never regenerates reviewed Blender/texture inputs.
An isolated request names its immediate source parent and runtime fingerprints.
Only an independently authored assistant approval can authorize final packaging.
This script never generates approvals, merges main or force-pushes a branch.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
from zipfile import ZipFile

from qa_common import (
    MAX_ARCHIVE_BYTES, ROOT, SOURCE_ARCHIVE_SCOPE, git_head, godot_binary,
    run, runtime_hashes, sha256, source_package_paths, version,
)

VERSION = "0.11.0"
SHORT = "0.11"
BRANCH = "feat/live-tower-collapse"
REQUEST = ROOT / f".review/v{SHORT}/build-request.json"
APPROVAL = ROOT / f".review/v{SHORT}/approval.json"
VALIDATION = ROOT / f"docs/validation/v{SHORT}"
CAPTURES = ROOT / f"docs/captures/v{SHORT}"
REVIEW = VALIDATION / "REVIEW_MANIFEST.json"
ASSET_DOCS = ROOT / "docs/assets/v0.11"
MODEL_ROOT = ROOT / "prototype/assets/models/rescue_v011"
MATERIAL_ROOT = ROOT / "prototype/assets/materials/v011"
GUIDES = (
    "docs/VISUELS_ET_SECOURS_V0.11.md",
    "prototype/assets/materials/v011/README.md",
    "prototype/assets/materials/v011/manifest.json",
    "prototype/assets/models/rescue_v011/manifest.json",
)
REFERENCE_DOCUMENTS = {
    "docs/The-Tower-Descent-Bible-v0.9.docx": "f718404121ba6c6990cf7df6e0988455881a0aa9e4188af6e63da14b319dbe20",
    "docs/The-Tower-Descent-Bible-v0.9.pdf": "25776d758dfb7070afb4157f15859864c6f991809fba71f78cf6f442cbe61121",
    "docs/The-Tower-Descent-Continuation-v0.10.docx": "d794de99d6c96c476c93fc1c8ad8495ee493d565cbf402933bc209bd15a2bf75",
    "docs/The-Tower-Descent-Continuation-v0.10.pdf": "5e76315b269f28d1ca8bc07652981408704524af444fcfc33528605c4e47d25c",
}
MODEL_IDS = {
    "fire_axe", "extinguisher", "halligan", "bolt_cutter", "rescue_flashlight",
    "portable_worklight", "rescue_radio", "trauma_bag", "rope_coil", "carabiner",
    "descender", "oxygen_cylinder", "rescue_helmet", "rescue_stretcher",
    "equipment_case", "emergency_beacon",
}
MATERIAL_IDS = {
    "salt_concrete", "smoked_oak", "dark_stone", "brushed_steel",
    "rescue_red_paint", "black_rubber", "teal_carpet", "porcelain_tile",
}
DETAIL_IDS = {"fire_axe", "extinguisher", "halligan", "bolt_cutter"}
WINDOWS_LAUNCHERS = (
    "docs/launchers/JOUER_CINEMATIQUE.cmd",
    "docs/launchers/JOUER_COMPATIBILITE.cmd",
)
REQUIRED_SUITES = {
    "generation", "save", "mission", "routes", "collapse", "incident_integration", "incident_routes",
    "incident_effects", "team_reactions", "radio", "radio_integration", "cinematics", "preferences",
    "cinematic_integration", "field_props", "world_presentation", "arrival_staging", "field_integration",
    "rescue_presentation", "comfort", "atmosphere", "mission_dossier", "epilogue", "epilogue_integration",
    "horror", "horror_integration", "rope_traversal", "vertical_routes", "traversal_integration",
    "continuation", "continuation_integration", "continuation_routes",
    "equipment", "equipment_integration", "lighting_v011", "surface_materials_v011", "rescue_assets_v011",
}
FIXTURES = {
    "baseline": {"path": "prototype/tests/visual_frontend_preview", "renderer": "gl_compatibility", "timeout": 720},
    "continuation": {"path": "prototype/tests/visual_continuation_preview", "renderer": "gl_compatibility", "timeout": 720},
    "equipment": {"path": "prototype/tests/visual_equipment_v011", "renderer": "gl_compatibility", "timeout": 720},
    "lighting_forward": {"path": "prototype/tests/lighting_v011_preview", "renderer": "forward_plus", "timeout": 1800},
    "lighting_compat": {"path": "prototype/tests/lighting_v011_preview", "renderer": "gl_compatibility", "timeout": 900},
}
CONTINUATION_CAPTURES = {
    "01_bilan_poursuite.png", "02_escalier_25_24.png", "03_congres_auditorium.png", "04_cabine_signes.png",
    "05_escorte_escalier.png", "06_reception_refuge.png", "07_rappel_24_23.png", "08_maquette_souterrains.png",
    "09_archive_bains.png", "10_remanence_exposition.png", "11_dossier_nacre.png",
    "12_bilan_reconnaissance.png", "13_menu_exposition.png",
}
EQUIPMENT_CAPTURES = {
    "01_rack_toit.png", "02_comptoir_toit.png", "03_hache_29.png", "04_extincteur_28_actif.png",
    "05_foyer_28_eteint.png", "06_halligan_25.png", "07_coupe_boulon_24.png", "08_inventaire_refuge25.png",
}
LIGHTING_CAPTURES = {
    "01_roof_rescue.png", "02_restaurant_materials.png",
    "03_congress_lighting.png", "04_archive_after_impact.png",
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit("FAIL: " + message)


def read_json(path: Path) -> dict:
    require(path.is_file(), "Required file is missing: " + path.relative_to(ROOT).as_posix())
    data = json.loads(path.read_text(encoding="utf-8"))
    require(isinstance(data, dict), "Expected a JSON object: " + path.name)
    return data


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def git(*arguments: str) -> str:
    return subprocess.check_output(["git", *arguments], cwd=ROOT, text=True).strip()


def record(path: Path) -> dict:
    require(path.is_file() and not path.is_symlink() and path.resolve().is_relative_to(ROOT.resolve()),
            "Missing, linked or escaped evidence file: " + path.relative_to(ROOT).as_posix())
    return {"file": path.relative_to(ROOT).as_posix(), "bytes": path.stat().st_size, "sha256": sha256(path)}


def check_records(rows: list[dict]) -> None:
    require(isinstance(rows, list), "Evidence records must be a list.")
    names: set[str] = set()
    for row in rows:
        require(isinstance(row, dict) and isinstance(row.get("file"), str), "Invalid file record.")
        relative = Path(row["file"])
        require(not relative.is_absolute() and ".." not in relative.parts and row["file"] not in names,
                "Unsafe or duplicate evidence path.")
        names.add(row["file"])
        require(record(ROOT / relative) == {key: row[key] for key in ["file", "bytes", "sha256"]},
                "Evidence changed: " + row["file"])


def source_inputs() -> dict[str, str]:
    # Bind every test, build tool, guide and asset-source byte separately from
    # the exported runtime. No harness/source edit may reuse reviewed evidence.
    paths = list((ROOT / "tools").glob("*.py")) + list((ROOT / "tools").glob("*.gd"))
    paths += list((ROOT / "prototype/tests").glob("*.gd")) + list((ROOT / "prototype/tests").glob("*.tscn"))
    paths += list((ROOT / ".github/workflows").glob("*.yml"))
    paths += [ROOT / name for name in GUIDES + WINDOWS_LAUNCHERS]
    paths += [ROOT / name for name in ("docs/DEMARRAGE_WINDOWS.md", "docs/EXPORTS.md", "docs/GODOT_LICENSES.txt")]
    paths += [path for path in ASSET_DOCS.rglob("*") if path.is_file()]
    return {path.relative_to(ROOT).as_posix(): record(path)["sha256"] for path in sorted(set(paths))}


def require_frozen_assets() -> None:
    require(ASSET_DOCS.is_dir(), "Generate and commit the model source/previews before freezing a request.")
    require({path.stem for path in MODEL_ROOT.glob("*.glb")} == MODEL_IDS, "The frozen runtime must contain exactly sixteen rescue GLBs.")
    require({path.stem for path in MATERIAL_ROOT.glob("*.png")} == MATERIAL_IDS, "The frozen runtime must contain the eight authored surface PNGs.")
    hashes = runtime_hashes()
    for path in [*(MODEL_ROOT / (name + ".glb") for name in sorted(MODEL_IDS)),
                 *(MATERIAL_ROOT / (name + ".png") for name in sorted(MATERIAL_IDS))]:
        require(path.relative_to(ROOT).as_posix() in hashes, "Runtime fingerprints omit an authored binary asset: " + path.name)
        record(path)
    for name in GUIDES + WINDOWS_LAUNCHERS:
        record(ROOT / name)
    manifest = read_json(MODEL_ROOT / "manifest.json")
    require(isinstance(manifest.get("assets"), list) and len(manifest["assets"]) == 16
            and {row.get("id") for row in manifest["assets"]} == MODEL_IDS, "Frozen model manifest has the wrong asset set.")
    source = manifest.get("source", {})
    require(isinstance(source.get("path"), str), "The model manifest does not identify its editable Blender source.")
    source_path = Path(source["path"])
    require(not source_path.is_absolute() and ".." not in source_path.parts and source_path.suffix == ".blend"
            and source_path.parts[:3] == ("docs", "assets", "v0.11"), "Editable Blender source must stay under docs/assets/v0.11.")
    source_record = record(ROOT / source_path)
    require(source_record["sha256"] == source.get("sha256") and source_record["bytes"] == source.get("bytes"),
            "Frozen Blender source differs from the runtime model provenance.")
    expected_previews = {"rescue_equipment_contact_sheet.png"}
    expected_previews |= {"renders/" + name + ".png" for name in MODEL_IDS}
    expected_previews |= {"renders/detail_" + name + ".png" for name in DETAIL_IDS}
    present_previews = {path.relative_to(ASSET_DOCS).as_posix() for path in ASSET_DOCS.rglob("*.png")}
    require(expected_previews.issubset(present_previews), "The twenty-one required model previews are incomplete.")
    for name in expected_previews:
        width, height = png_shape(ASSET_DOCS / name)
        require(width > 0 and height > 0, "A frozen model preview is invalid.")


def expected_captures(request: dict) -> dict[str, list[str]]:
    from capture_evidence import EXPECTED_CAPTURES

    fixed = {
        "baseline": set(EXPECTED_CAPTURES), "continuation": CONTINUATION_CAPTURES,
        "equipment": EQUIPMENT_CAPTURES, "lighting_forward": LIGHTING_CAPTURES, "lighting_compat": LIGHTING_CAPTURES,
    }
    require(len(fixed["baseline"]) == 42, "Established baseline scope must remain forty-two native states.")
    result = request.get("expected_captures")
    require(isinstance(result, dict) and set(result) == set(FIXTURES), "Declare all five exact native capture groups.")
    for group, names in result.items():
        require(isinstance(names, list) and names and all(isinstance(name, str) for name in names),
                "Capture set is empty or malformed: " + group)
        require(len(set(names)) == len(names) and all(re.fullmatch(r"[A-Za-z0-9_-]+\.png", name) for name in names),
                "Capture names must be unique PNG basenames.")
        require(set(names) == fixed[group], "Capture scope differs from the required native states: " + group)
    require(sum(len(names) for names in result.values()) == 71, "The v0.11 review requires exactly seventy-one native captures.")
    return {group: sorted(names) for group, names in result.items()}


def read_request() -> dict:
    request = read_json(REQUEST)
    require(request.get("format") == 1 and request.get("version") == VERSION == version(), "Request/project versions differ.")
    require(request.get("phase") in {"review", "release"}, "Unknown build phase.")
    require(isinstance(request.get("request_id"), str) and re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,79}", request["request_id"]) is not None,
            "Invalid request identifier.")
    require(isinstance(request.get("source_commit"), str) and re.fullmatch(r"[0-9a-f]{40}", request["source_commit"]) is not None,
            "Invalid source revision.")
    require(os.environ.get("GITHUB_REF", "refs/heads/" + BRANCH) == "refs/heads/" + BRANCH, "Only the existing PR branch can be published.")
    require(os.environ.get("GITHUB_SHA", git_head()) == git_head(), "Checkout differs from the requested revision.")
    require(git("rev-parse", "HEAD^") == request["source_commit"], "Request must name its immediately preceding source commit.")
    require(git("diff", "--name-only", "--no-renames", "HEAD^", "HEAD").splitlines() == [REQUEST.relative_to(ROOT).as_posix()],
            "Submit the request alone in a separate commit after source or approval changes.")
    require(request.get("runtime_sha256") == runtime_hashes(), "Runtime differs from the explicit request fingerprints.")
    expected_captures(request)
    for name, expected in REFERENCE_DOCUMENTS.items():
        require(record(ROOT / name)["sha256"] == expected, "Historical Word/PDF must remain unchanged: " + name)
    require_frozen_assets()
    return request


def checked(command: list[str], log_name: str, timeout: int = 240) -> dict:
    log = VALIDATION / log_name
    log.parent.mkdir(parents=True, exist_ok=True)
    entry = run(command, cwd=ROOT, timeout=timeout, log=log)
    entry["pass"] = entry["returncode"] == 0 and not entry["error_lines"]
    if not entry["pass"]:
        print(log.read_text(errors="replace")[-25000:], flush=True)
    require(entry["pass"], "Command failed or emitted an engine error: " + " ".join(command))
    return entry


def tool(script: str, *arguments: str) -> None:
    subprocess.run([sys.executable, str(ROOT / "tools" / script), *arguments], cwd=ROOT, check=True)


def install_templates() -> None:
    destination = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))) / "godot/export_templates/4.7.2.stable"
    pinned = read_json(ROOT / "docs/EXPORT_TEMPLATE_PROVENANCE.json")
    require(pinned.get("version") == "4.7.2-stable", "Export template provenance version changed.")
    require({row["name"] for row in pinned["files"]} == {"version.txt", "web_nothreads_release.zip", "windows_release_x86_64.exe"},
            "Export template provenance is incomplete.")
    available = all((destination / row["name"]).is_file() and (destination / row["name"]).stat().st_size == row["size"]
                    and sha256(destination / row["name"]) == row["sha256"] for row in pinned["files"])
    if not available:
        tool("fetch_export_templates.py", "--version", "4.7.2-stable", "--destination", str(destination))
    for row in pinned["files"]:
        path = destination / row["name"]
        require(path.stat().st_size == row["size"] and sha256(path) == row["sha256"], "Pinned official template differs: " + row["name"])
    write_json(VALIDATION / "TEMPLATES.json", {
        "version": VERSION, "source_provenance": record(ROOT / "docs/EXPORT_TEMPLATE_PROVENANCE.json"),
        "files": pinned["files"], "template_file_sha256_verified": True, "complete_archive_sha256_verified": False,
    })


def verify_source() -> dict:
    verified = read_json(VALIDATION / "VERIFICATION.json")
    require(verified.get("version") == VERSION and verified.get("all_pass") is True
            and verified.get("sha256_after") == runtime_hashes(), "No passing source validation for this exact runtime.")
    suites = verified.get("suites", [])
    names = [row.get("suite") for row in suites]
    current = {path.stem.removeprefix("test_") for path in (ROOT / "prototype/tests").glob("test_*.gd")
               if path.name != "test_exported_pack.gd"}
    require(len(names) == len(set(names)) and set(names) == current and REQUIRED_SUITES.issubset(set(names)),
            "All thirty-seven required source suites and every current test must have matching evidence.")
    require(REQUIRED_SUITES.issubset(set(verified.get("required_suites", []))) and not verified.get("missing_suites")
            and verified.get("import", {}).get("pass") is True, "Source-suite requirements or import evidence are incomplete.")
    for suite in suites:
        require(suite.get("pass") is True and suite.get("returncode") == 0 and suite.get("checks", 0) > 0,
                "A current source suite did not pass: " + str(suite.get("suite")))
        require(sha256(ROOT / suite["script"]) == suite["script_sha256"], "A source suite changed after validation.")
        require(sha256(VALIDATION / suite["log"]) == suite["sha256"], "A source-suite log changed.")
    return verified


def export_packs(binary: str, source_commit: str) -> None:
    verify_source()
    before = runtime_hashes()
    install_templates()
    windows, web, distribution = ROOT / "builds/windows", ROOT / "builds/web", ROOT / "dist"
    windows.mkdir(parents=True, exist_ok=True)
    if web.exists():
        shutil.rmtree(web)
    web.mkdir(parents=True)
    exports = []
    for platform, preset, output in [
        ("windows", "Windows Desktop", windows / "TheTowerDescent.exe"),
        ("web", "Web", web / "index.html"),
    ]:
        entry = checked([binary, "--headless", "--path", str(ROOT / "prototype"), "--export-release", preset, str(output)],
                        "export-" + platform + ".txt", 360)
        entry["platform"] = platform
        exports.append(entry)
    require((windows / "TheTowerDescent.exe").read_bytes()[:2] == b"MZ", "Windows export is not an executable.")
    require((web / "index.pck").is_file() and (web / "index.wasm").is_file(), "Web export is incomplete.")
    if distribution.exists():
        shutil.rmtree(distribution)
    shutil.copytree(web, distribution)
    shutil.copy2(ROOT / "docs/GODOT_LICENSES.txt", distribution / "GODOT_LICENSES.txt")
    for name in ["LICENSE", "NOTICE"]:
        shutil.copy2(ROOT / "prototype/assets/fonts" / (name + ".txt"), distribution / ("OPEN_SANS_" + name + ".txt"))
    require(before == runtime_hashes(), "Export modified the tested runtime.")
    outputs = [record(windows / "TheTowerDescent.exe")]
    outputs += [record(path) for directory in [web, distribution] for path in sorted(directory.iterdir()) if path.is_file()]
    write_json(VALIDATION / "EXPORTS.json", {
        "version": VERSION, "all_pass": True, "source_commit": source_commit, "build_commit": git_head(),
        "built_utc": datetime.now(timezone.utc).isoformat(), "runtime_sha256": before,
        "source_verification": record(VALIDATION / "VERIFICATION.json"), "outputs": outputs, "exports": exports,
        "engine": subprocess.check_output([binary, "--version"], text=True).strip(),
        "limitations": ["Linux export construction does not execute the Windows program or the WebAssembly browser game."],
    })
    tool("verify_exported_packs.py", "--godot", binary)


def reusable_exports() -> bool:
    if not (VALIDATION / "EXPORTS.json").is_file():
        return False
    exported = read_json(VALIDATION / "EXPORTS.json")
    if exported.get("version") != VERSION or exported.get("runtime_sha256") != runtime_hashes() or exported.get("all_pass") is not True:
        return False
    return bool(exported.get("outputs")) and all((ROOT / row["file"]).is_file() and record(ROOT / row["file"]) == row for row in exported["outputs"])


def png_shape(path: Path) -> tuple[int, int]:
    header = path.read_bytes()[:24]
    require(header[:8] == b"\x89PNG\r\n\x1a\n" and header[12:16] == b"IHDR", "Not a PNG: " + path.name)
    return struct.unpack(">II", header[16:24])


def validate_capture_group(group: str, expected: list[str]) -> list[dict]:
    fixture = FIXTURES[group]
    destination = CAPTURES / group
    manifest = read_json(destination / "MANIFEST.json")
    renderer = fixture["renderer"]
    require(manifest.get("version") == VERSION and manifest.get("prepared_states") is True
            and manifest.get("human_playthrough") is False, "Capture fixture misidentifies its version or method: " + group)
    require(manifest.get("display") not in {None, "", "headless"} and manifest.get("rendering_method") == renderer,
            "Native renderer mismatch; automatic fallback cannot satisfy review: " + group)
    shots = manifest.get("captures", [])
    require(isinstance(shots, list) and all(isinstance(row, dict) for row in shots), "Malformed capture manifest: " + group)
    names = [row.get("file") for row in shots]
    require(all(isinstance(name, str) for name in names) and len(names) == len(set(names)) and sorted(names) == expected,
            "Capture set is incomplete: " + group)
    require({path.name for path in destination.glob("*.png")} == set(names), "Unlisted or missing native PNGs: " + group)
    rows = []
    for shot in shots:
        path = destination / shot["file"]
        width, height = png_shape(path)
        require((width, height) == (1440, 900) and shot.get("width") == width and shot.get("height") == height,
                "Native image dimensions differ from the fixture manifest.")
        # The established baseline predates per-shot hashes. Its bytes are
        # fingerprinted here and in REVIEW; all newer fixtures supply them too.
        if "sha256" in shot:
            require(shot["sha256"] == sha256(path), "Native image differs from the bytes captured by its fixture.")
        else:
            require(group == "baseline", "A new capture fixture omitted its image fingerprint.")
        if group.startswith("lighting_"):
            state = shot.get("lighting", {})
            require(manifest.get("warmup_frames", 0) >= 96 and shot.get("warmup_frames", 0) >= 96,
                    "Each lighting view requires at least ninety-six actual warmup frames.")
            require(state.get("rendering_method") == renderer and state.get("display") == manifest["display"],
                    "Lighting profile reports different native capabilities from its capture.")
            cinematic = renderer == "forward_plus"
            require(state.get("active_profile") == ("cinematic" if cinematic else "portable"),
                    "Lighting capture uses an unexpected quality profile.")
            require(all(state.get(effect) is cinematic for effect in ["sdfgi", "ssil", "ssr", "ssao", "volumetric_fog", "glow"]),
                    "Lighting effect flags do not match the tested renderer/profile.")
            if cinematic:
                require(state.get("native_forward_plus") is True and state.get("rendering_device") is True,
                        "Forward+ review did not obtain a real rendering device.")
            inventory = state.get("geometry", {})
            require(inventory.get("moving_static_violations") == 0 and inventory.get("static_meshes", 0) > 100
                    and state.get("refresh_pending") is False, "Lighting GI inventory is invalid or still rebuilding.")
        rows.append({**record(path), "width": width, "height": height,
                     "description": str(shot.get("description", "")), "group": group})
    return rows


def capture_metadata() -> list[dict]:
    paths = []
    for group in FIXTURES:
        paths += [CAPTURES / group / "MANIFEST.json", CAPTURES / group / "PROVENANCE.json",
                  VALIDATION / ("native-" + group + ".txt")]
    return [record(path) for path in paths]


def capture(binary: str, request: dict) -> list[dict]:
    expected = expected_captures(request)
    all_records: list[dict] = []
    for group, fixture in FIXTURES.items():
        destination = CAPTURES / group
        if destination.exists():
            shutil.rmtree(destination)
        destination.mkdir(parents=True)
        scene = "res://" + fixture["path"].removeprefix("prototype/") + ".tscn"
        renderer = fixture["renderer"]
        driver = "vulkan" if renderer == "forward_plus" else "opengl3"
        checked(["xvfb-run", "-a", "-s", "-screen 0 1440x900x24", binary,
                 "--path", str(ROOT / "prototype"), "--rendering-method", renderer,
                 "--rendering-driver", driver, "--audio-driver", "Dummy", "--resolution", "1440x900",
                 scene, "--", "--capture-root=" + str(destination), "--expected-renderer=" + renderer],
                "native-" + group + ".txt", fixture["timeout"])
        rows = validate_capture_group(group, expected[group])
        write_json(destination / "PROVENANCE.json", {
            "format": 1, "version": VERSION, "source_commit": request["source_commit"], "request_commit": git_head(),
            "runtime_sha256": runtime_hashes(), "rendering_method": renderer,
            "manifest": record(destination / "MANIFEST.json"),
            "fixture": [record(ROOT / (fixture["path"] + suffix)) for suffix in [".gd", ".tscn"]],
            "captures": rows, "manual_visual_review": False,
        })
        all_records.extend(rows)
    require(len(all_records) == 71, "Not all five capture groups completed.")
    return all_records


def asset_evidence() -> dict:
    require_frozen_assets()
    entry = checked([sys.executable, str(ROOT / "tools/validate_rescue_models.py"), "--root", str(ROOT), "--previews"],
                    "asset-library-validation.txt", 180)
    files = sorted(path for path in ASSET_DOCS.rglob("*") if path.is_file())
    previews = [record(path) for path in files if path.suffix.lower() == ".png"]
    source_files = [record(path) for path in files if path.suffix.lower() != ".png"]
    require(len(previews) >= 21 and any(row["file"].endswith(".blend") for row in source_files),
            "Review must contain the complete preview set and editable Blender source.")
    return {
        "guides": [record(ROOT / name) for name in GUIDES],
        "source_files": source_files, "previews": previews,
        "models": [record(MODEL_ROOT / (name + ".glb")) for name in sorted(MODEL_IDS)],
        "materials": [record(MATERIAL_ROOT / (name + ".png")) for name in sorted(MATERIAL_IDS)],
        "reference_documents": [record(ROOT / name) for name in REFERENCE_DOCUMENTS],
        "validation": {"command": entry["command"], "returncode": entry["returncode"],
                       "log": record(VALIDATION / entry["log"]), "pass": entry["pass"]},
        "method": "Frozen authored PNGs, sixteen validated GLBs, editable Blender source and every prepared Blender preview are fingerprinted; the reference Word/PDF files remain untouched.",
        "manual_visual_review": False,
    }


def verify_review() -> dict:
    review = read_json(REVIEW)
    require(review.get("format") == 1 and review.get("version") == VERSION
            and review.get("manual_visual_review_required") is True and review.get("approval_generated") is False,
            "Wrong review manifest or misleading automatic approval.")
    require(review.get("runtime_sha256") == runtime_hashes(), "Reviewed runtime differs from the current runtime.")
    require(review.get("source_inputs") == source_inputs(), "A source asset, guide, test, fixture or delivery tool changed after review.")
    verify_source()
    require(review["source_verification"] == record(VALIDATION / "VERIFICATION.json"), "Source validation changed after review.")
    expected = expected_captures({"expected_captures": review.get("expected_captures")})
    current = [row for group in FIXTURES for row in validate_capture_group(group, expected[group])]
    require(current == review.get("captures"), "Native capture evidence changed after review.")
    require(review.get("capture_metadata") == capture_metadata(), "Capture manifests, provenance or native logs changed after review.")
    assets = review.get("assets", {})
    require(isinstance(assets, dict), "Review has no asset evidence.")
    for key in ["guides", "source_files", "previews", "models", "materials", "reference_documents"]:
        check_records(assets.get(key))
    current_asset_files = {path.relative_to(ROOT).as_posix() for path in ASSET_DOCS.rglob("*") if path.is_file()}
    require(current_asset_files == {row["file"] for key in ["source_files", "previews"] for row in assets[key]},
            "Asset-source or preview membership changed after review.")
    require({row["file"] for row in assets["models"]} == {str((MODEL_ROOT / (name + ".glb")).relative_to(ROOT)) for name in MODEL_IDS}
            and {row["file"] for row in assets["materials"]} == {str((MATERIAL_ROOT / (name + ".png")).relative_to(ROOT)) for name in MATERIAL_IDS},
            "Review omits a required runtime model or surface texture.")
    require({row["file"] for row in assets["guides"]} == set(GUIDES)
            and {row["file"]: row["sha256"] for row in assets["reference_documents"]} == REFERENCE_DOCUMENTS,
            "Review guides or preserved document scope differ from the required contract.")
    validation = assets.get("validation", {})
    require(validation.get("pass") is True and validation.get("returncode") == 0, "Model/source validation did not pass.")
    check_records([validation.get("log")])
    require_frozen_assets()
    return review


def verify_approval() -> dict:
    review = verify_review()
    approval = read_json(APPROVAL)
    require(approval.get("format") == 1 and approval.get("version") == VERSION
            and approval.get("decision") == "approved" and approval.get("reviewer") == "assistant",
            "Release requires an explicit assistant-authored approval of the exact reviewed files.")
    require(isinstance(approval.get("reviewed_utc"), str) and approval["reviewed_utc"].strip(), "Approval has no review date.")
    require(approval.get("review_manifest_sha256") == sha256(REVIEW), "Approval names another review manifest.")
    require(approval.get("runtime_sha256") == review["runtime_sha256"], "Approval names another runtime.")

    def approved_records(key: str, expected: list[dict], supplied: object, visual: bool = False) -> None:
        require(isinstance(supplied, list), "Missing approval records: " + key)
        require(len(supplied) == len(expected) and all(isinstance(row, dict) for row in supplied), "Incomplete approval: " + key)
        names = [row.get("file") for row in supplied]
        require(all(isinstance(name, str) for name in names) and len(names) == len(set(names))
                and set(names) == {row["file"] for row in expected}, "Missing or duplicate approved files: " + key)
        index = {row["file"]: row for row in supplied}
        for row in expected:
            accepted = index[row["file"]]
            require(accepted.get("sha256") == row["sha256"] and accepted.get("status") == "pass",
                    "Unapproved or stale file: " + row["file"])
            if visual:
                require(isinstance(accepted.get("observation"), str) and bool(accepted["observation"].strip()),
                        "Each image needs an individual observation from actual visual review: " + row["file"])
        check_records(expected)

    approved_records("captures", review["captures"], approval.get("captures"), visual=True)
    accepted_assets = approval.get("assets")
    require(isinstance(accepted_assets, dict), "The model, texture and editable-source evidence lacks separate approval.")
    require(isinstance(accepted_assets.get("review_method"), str) and accepted_assets["review_method"].strip(),
            "Asset approval must describe the actual visual/document inspection method.")
    for key in ["guides", "source_files", "previews", "models", "materials", "reference_documents"]:
        approved_records("assets." + key, review["assets"][key], accepted_assets.get(key), visual=key == "previews")
    return review


def verify_archives() -> dict:
    windows = ROOT / f"releases/The-Tower-Descent-v{SHORT}-Windows-x64.zip"
    source = ROOT / f"releases/The-Tower-Descent-v{SHORT}-Sources.zip"
    prefix = "The-Tower-Descent/"
    windows_inputs = {
        prefix + "TheTowerDescent.exe": ROOT / "builds/windows/TheTowerDescent.exe",
        prefix + "README.md": ROOT / "docs/DEMARRAGE_WINDOWS.md",
        prefix + "GODOT_LICENSES.txt": ROOT / "docs/GODOT_LICENSES.txt",
        prefix + "EXPORTS.md": ROOT / "docs/EXPORTS.md",
        prefix + "fonts/LICENSE.txt": ROOT / "prototype/assets/fonts/LICENSE.txt",
        prefix + "fonts/NOTICE.txt": ROOT / "prototype/assets/fonts/NOTICE.txt",
        prefix + "JOUER_CINEMATIQUE.cmd": ROOT / "docs/launchers/JOUER_CINEMATIQUE.cmd",
        prefix + "JOUER_COMPATIBILITE.cmd": ROOT / "docs/launchers/JOUER_COMPATIBILITE.cmd",
    }
    source_inputs_map = {prefix + path.relative_to(ROOT).as_posix(): path for path in source_package_paths()}
    required_sources = set(REFERENCE_DOCUMENTS) | set(GUIDES) | set(WINDOWS_LAUNCHERS)
    required_sources |= {path.relative_to(ROOT).as_posix() for path in ASSET_DOCS.rglob("*") if path.is_file()}
    required_sources |= {path.relative_to(ROOT).as_posix() for directory in [MODEL_ROOT, MATERIAL_ROOT] for path in directory.rglob("*") if path.is_file() and path.suffix not in {".import", ".uid"}}
    required_sources |= {row["file"] for row in read_json(REVIEW)["captures"]}
    require(all(prefix + name in source_inputs_map for name in required_sources),
            "Source ZIP omits a preserved document, current capture, authored model/texture, preview or editable source.")
    reports = []
    for archive_path, expected in [(windows, windows_inputs), (source, source_inputs_map)]:
        require(archive_path.stat().st_size < MAX_ARCHIVE_BYTES, "Archive exceeds the strict 100MiB publication limit.")
        with ZipFile(archive_path) as archive:
            names = archive.namelist()
            require(len(names) == len(set(names)) and set(names) == set(expected), "Archive membership differs from its exact contract: " + archive_path.name)
            require(archive.testzip() is None, "Archive has a CRC error: " + archive_path.name)
            for name, path in expected.items():
                digest = hashlib.sha256()
                size = 0
                with archive.open(name) as stream:
                    for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                        digest.update(chunk)
                        size += len(chunk)
                require(size == path.stat().st_size and digest.hexdigest() == sha256(path), "Archived bytes differ from their source: " + name)
        reports.append({**record(archive_path), "members": len(expected), "all_members_and_bytes_verified": True})
    return {"version": VERSION, "status": "PASS", "archives": reports, "source_archive_scope": SOURCE_ARCHIVE_SCOPE,
            "max_archive_bytes_exclusive": MAX_ARCHIVE_BYTES, "approved_review": record(APPROVAL),
            "source_verification": record(VALIDATION / "VERIFICATION.json"),
            "export_verification": record(VALIDATION / "EXPORTED_PACK_VERIFICATION.json"),
            "limitations": ["Automated Linux checks and prepared native captures do not establish a human Windows or Web playthrough."]}


def verify_exports() -> None:
    require(reusable_exports(), "Export outputs are missing or no longer match their fingerprints.")
    packs = read_json(VALIDATION / "EXPORTED_PACK_VERIFICATION.json")
    require(packs.get("all_pass") is True and packs.get("version") == VERSION and packs.get("runtime_sha256") == runtime_hashes(),
            "Exported packs have no matching passing verification.")
    require(packs.get("test_script_sha256") == sha256(ROOT / "prototype/tests/test_exported_pack.gd"), "Pack test changed after verification.")
    require({row["platform"] for row in packs["packs"]} == {"windows", "web"}, "Both platform packs need validation.")
    for pack in packs["packs"]:
        require(sha256(ROOT / pack["pack"]) == pack["pack_sha256"] and pack.get("pass") is True, "A final resource pack changed.")
        require(sha256(VALIDATION / pack["log"]) == pack["log_sha256"], "A pack-verification log changed.")


def build(binary: str, request: dict) -> None:
    VALIDATION.mkdir(parents=True, exist_ok=True)
    before = runtime_hashes()
    inputs = source_inputs()
    require_frozen_assets()
    engine = subprocess.check_output([binary, "--version"], text=True).strip()
    require(engine.startswith("4.7.2.stable.official"), "The builder must use the pinned official Godot release.")
    if request["phase"] == "review":
        tool("run_validation.py", "--godot", binary)
        require(before == runtime_hashes(), "Source import or tests changed the requested runtime.")
        export_packs(binary, request["source_commit"])
        captures = capture(binary, request)
        assets = asset_evidence()
        require(inputs == source_inputs(), "A delivery input changed while review evidence was built.")
        write_json(REVIEW, {
            "format": 1, "version": VERSION, "request_id": request["request_id"], "source_commit": request["source_commit"],
            "request_commit": git_head(), "runtime_sha256": before, "source_inputs": inputs,
            "source_verification": record(VALIDATION / "VERIFICATION.json"),
            "expected_captures": expected_captures(request), "captures": captures,
            "capture_metadata": capture_metadata(), "assets": assets,
            "manual_visual_review_required": True, "approval_generated": False,
        })
    else:
        review = verify_approval()
        require(review["expected_captures"] == expected_captures(request), "Release request changes the reviewed capture scope.")
        if not reusable_exports():
            checked([binary, "--headless", "--path", str(ROOT / "prototype"), "--editor", "--import", "--quit"], "release-import.txt", 180)
            export_packs(binary, review["source_commit"])
        else:
            tool("verify_exported_packs.py", "--godot", binary)
    verify_exports()
    require(before == runtime_hashes() and inputs == source_inputs(), "The build changed its frozen source inputs.")
    if request["phase"] == "review":
        verify_review()
    write_json(VALIDATION / "CI_BUILD.json", {
        "version": VERSION, "phase": request["phase"], "request_id": request["request_id"],
        "source_commit": request["source_commit"], "request_commit": git_head(), "runtime_sha256": before,
        "completed_utc": datetime.now(timezone.utc).isoformat(), "automated_steps_passed": True,
        "manual_visual_review_required": request["phase"] == "review",
        "run_url": f'https://github.com/{os.environ.get("GITHUB_REPOSITORY", "darknigthmare/The-Descents")}/actions/runs/{os.environ.get("GITHUB_RUN_ID", "local")}',
        "pipeline_sha256": sha256(Path(__file__)), "approval_generated": False,
    })
    if request["phase"] == "release":
        tool("package_release.py")
        write_json(ROOT / f"releases/VERIFICATION_V{SHORT}.json", verify_archives())
    print(json.dumps({"phase": request["phase"], "automated_steps_passed": True,
                      "manual_visual_review_required": request["phase"] == "review"}), flush=True)


def publish(request: dict) -> None:
    require(os.environ.get("GITHUB_ACTIONS") == "true", "Publication is restricted to the configured Actions runner.")
    built = read_json(VALIDATION / "CI_BUILD.json")
    require(built.get("automated_steps_passed") is True and built.get("request_commit") == git_head()
            and built.get("request_id") == request["request_id"] and built.get("phase") == request["phase"],
            "Only this successful build's generated evidence can be published.")
    target = "refs/heads/" + BRANCH
    expected = os.environ["GITHUB_SHA"]
    advertised = git("ls-remote", "origin", target).split()
    require(bool(advertised), "The existing publication branch is unavailable.")
    if advertised[0] != expected:
        print("The branch advanced; generated files remain in the workflow artifact. No branch update attempted.")
        return
    require(git_head() == expected, "The checked-out request advanced unexpectedly.")
    require(built.get("runtime_sha256") == runtime_hashes() and built.get("pipeline_sha256") == sha256(Path(__file__)),
            "Build runtime or delivery script changed before publication.")
    paths = [f"docs/validation/v{SHORT}"]
    if request["phase"] == "review":
        verify_review()
        paths.append(f"docs/captures/v{SHORT}")
        paths += [name for name in git("ls-files", "--others", "--exclude-standard", "--", "prototype").splitlines() if name.endswith(".uid")]
    else:
        verify_approval()
        verify_exports()
        release = read_json(ROOT / f"releases/VERIFICATION_V{SHORT}.json")
        require(release.get("status") == "PASS" and release.get("version") == VERSION, "No final archive verification.")
        check_records(release["archives"])
        require(release.get("approved_review") == record(APPROVAL)
                and release.get("source_verification") == record(VALIDATION / "VERIFICATION.json")
                and release.get("export_verification") == record(VALIDATION / "EXPORTED_PACK_VERIFICATION.json"),
                "Published archives no longer bind the approved source/export evidence.")
        paths += ["dist", f"releases/The-Tower-Descent-v{SHORT}-Windows-x64.zip",
                  f"releases/The-Tower-Descent-v{SHORT}-Sources.zip", "releases/SHA256SUMS.txt", f"releases/VERIFICATION_V{SHORT}.json"]
    subprocess.run(["git", "add", "--", *paths], cwd=ROOT, check=True)
    staged = git("diff", "--cached", "--name-only").splitlines()
    require(all(any(name == path or name.startswith(path + "/") for path in paths) for name in staged), "Unexpected staged path outside generated outputs.")
    if not staged:
        print("Generated evidence is already committed.")
        return
    git("config", "user.name", "github-actions[bot]")
    git("config", "user.email", "41898282+github-actions[bot]@users.noreply.github.com")
    git("commit", "-m", f"Build v{SHORT} {request['phase']} evidence from source {request['source_commit'][:12]}")
    result = subprocess.run(["git", "push", "origin", "HEAD:" + target], cwd=ROOT)
    if result.returncode:
        current = git("ls-remote", "origin", target).split()
        require(bool(current) and current[0] != expected, "Publication failed while the requested branch was unchanged.")
        print("The branch changed during publication. No force push was attempted; use the workflow artifact.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["guard", "build", "publish", "verify-approval"])
    parser.add_argument("--godot")
    args = parser.parse_args()
    if args.action == "verify-approval":
        verify_approval()
        print("Explicit assistant approval matches all seventy-one native captures, authored assets, Blender previews and preserved documents.")
        return
    request = read_request()
    if args.action == "guard":
        print(json.dumps({"version": VERSION, "phase": request["phase"], "source_parent": request["source_commit"]}))
    elif args.action == "build":
        build(godot_binary(args.godot), request)
    else:
        publish(request)


if __name__ == "__main__":
    main()
