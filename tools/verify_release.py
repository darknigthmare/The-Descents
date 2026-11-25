"""Verify archive contents and Web export consistency against the frozen source tree.

Run after package_release.py. This complements runtime tests and native render review.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import struct
from zipfile import ZipFile

from capture_evidence import EXPECTED_CAPTURES
from qa_common import DOCUMENT_SOURCES, runtime_hashes
from run_validation import REQUIRED

ROOT = Path(__file__).resolve().parents[1]
VERSION = re.search(r'config/version="([^"]+)"', (ROOT / "prototype/project.godot").read_text()).group(1)
SHORT = ".".join(VERSION.split(".")[:2])
VALIDATION = ROOT / f"docs/validation/v{SHORT}"
CAPTURES = ROOT / f"docs/captures/v{SHORT}"


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit("FAIL: " + message)


def main() -> None:
    archive_results = []
    listed = set()
    for line in (ROOT / "releases/SHA256SUMS.txt").read_text().splitlines():
        if not line.strip():
            continue
        expected, name = line.split("  ", 1)
        require(Path(name).name == name, "Unsafe archive filename")
        archive = ROOT / "releases" / name
        require(archive.is_file(), "Missing " + name)
        require(digest(archive.read_bytes()) == expected, "Checksum mismatch for " + name)
        with ZipFile(archive) as zipped:
            require(zipped.testzip() is None, "Corrupt ZIP " + name)
            require(len(zipped.namelist()) == len(set(zipped.namelist())), "Duplicate ZIP members " + name)
            for member in zipped.namelist():
                require(not member.startswith("/") and ".." not in Path(member).parts, "Unsafe ZIP member " + member)
        listed.add(name)
        archive_results.append({"file": name, "bytes": archive.stat().st_size, "sha256": expected})
    require(listed == {p.name for p in (ROOT / "releases").glob("*.zip")}, "Archive manifest is incomplete")

    source = ROOT / "releases" / f"The-Tower-Descent-v{SHORT}-Sources.zip"
    required = {
        "prototype/project.godot", "prototype/scripts/main.gd", "prototype/scripts/frontend_menu.gd",
        "prototype/scripts/cinematic_director.gd", "prototype/scripts/cinematic_overlay.gd",
        "prototype/scripts/preferences_store.gd", "prototype/scripts/radio_director.gd",
        "prototype/tests/test_cinematic_integration.gd", "prototype/tests/test_exported_pack.gd",
        "prototype/scripts/field_props.gd", "prototype/scripts/inspection_panel.gd",
        "prototype/tests/test_arrival_staging.gd", "prototype/tests/test_field_integration.gd",
        "prototype/tests/test_world_presentation.gd", "prototype/tests/test_field_props.gd",
        "docs/PROPS_INTERACTIONS.md", "docs/ENNEMIS_STATISTIQUES.md", "docs/SCENES_CINEMATIQUES.md",
        "docs/GAMEPLAY_DETAILLE.md", "docs/COMMUNICATIONS_ET_EQUIPES.md",
        f"docs/validation/v{SHORT}/VERIFICATION.json", f"docs/captures/v{SHORT}/MANIFEST.json",
        f"docs/validation/v{SHORT}/EXPORTED_PACK_VERIFICATION.json",
        f"docs/validation/v{SHORT}/EXPORTS.json",
        f"docs/validation/v{SHORT}/VISUAL_REVIEW.json",
        f"docs/validation/v{SHORT}/DOCUMENT_REVIEW.json",
        f"docs/captures/v{SHORT}/CI_PROVENANCE.json", f"docs/CAPTURES_V{SHORT}.md",
        f"docs/The-Tower-Descent-Bible-v{SHORT}.docx", f"docs/The-Tower-Descent-Bible-v{SHORT}.pdf",
        ".github/workflows/release-v" + SHORT.replace(".", "") + ".yml",
        "tools/build_release_ci.py", f".review/v{SHORT}/build-request.json",
        f"docs/validation/v{SHORT}/DOCUMENT_BUILD.json",
        "prototype/scripts/rescue_presentation.gd", "prototype/scripts/maritime_atmosphere.gd",
        "prototype/tests/test_rescue_presentation.gd", "prototype/tests/test_atmosphere.gd", "prototype/tests/test_comfort.gd",
        "prototype/scripts/mission_dossier.gd", "prototype/scripts/mission_dossier_panel.gd",
        "prototype/scripts/epilogue_director.gd", "prototype/tests/test_mission_dossier.gd",
        "prototype/tests/test_epilogue.gd", "prototype/tests/test_epilogue_integration.gd",
        "prototype/scripts/horror_director.gd", "prototype/scripts/horror_presentation.gd",
        "prototype/tests/test_horror.gd", "prototype/tests/test_horror_integration.gd",
        f".review/v{SHORT}/request.json",
        "tools/package_release.py", "tools/verify_release.py", "tools/qa_common.py",
        "tools/run_validation.py", "tools/verify_exported_packs.py", "tools/capture_evidence.py"
    }
    required.update(DOCUMENT_SOURCES)
    required.update(f"docs/captures/v{SHORT}/{name}" for name in EXPECTED_CAPTURES)
    members = set()
    with ZipFile(source) as zipped:
        for member in zipped.namelist():
            require(member.startswith("The-Tower-Descent/"), "Unexpected source root")
            rel = member[len("The-Tower-Descent/"):]
            actual = ROOT / rel
            require(actual.is_file(), "Archive member has no source file: " + rel)
            require(digest(zipped.read(member)) == digest(actual.read_bytes()), "Stale source member: " + rel)
            members.add(rel)
    require(required <= members, "Missing required source members: " + ", ".join(sorted(required - members)))

    windows = ROOT / "releases" / f"The-Tower-Descent-v{SHORT}-Windows-x64.zip"
    with ZipFile(windows) as zipped:
        executable = zipped.read("The-Tower-Descent/TheTowerDescent.exe")
        require(digest(executable) == digest((ROOT / "builds/windows/TheTowerDescent.exe").read_bytes()), "Stale Windows executable")
        require(executable[:2] == b"MZ", "Missing DOS header")
        pe_offset = struct.unpack_from("<I", executable, 0x3C)[0]
        require(executable[pe_offset:pe_offset+4] == b"PE\0\0", "Missing PE signature")
        require(struct.unpack_from("<H", executable, pe_offset+4)[0] == 0x8664, "Windows executable is not x64")
        require(zipped.read("The-Tower-Descent/README.md") == (ROOT / "docs/DEMARRAGE_WINDOWS.md").read_bytes(), "Stale Windows guide")
        require(zipped.read("The-Tower-Descent/fonts/LICENSE.txt") == (ROOT / "prototype/assets/fonts/LICENSE.txt").read_bytes(), "Font license missing or changed")

    html = (ROOT / "dist/index.html").read_text()
    require("feat/live-tower-collapse" in html and "feat/tower-descent-prototype-bible" not in html, "Wrong source branch in Web shell")
    config = re.search(r'(?:const|var) GODOT_CONFIG\s*=\s*(\{.*?\});', html, re.S)
    require(config is not None, "Web engine configuration missing")
    data = json.loads(config.group(1))
    for filename, size in data.get("fileSizes", {}).items():
        require((ROOT / "dist" / filename).stat().st_size == size, "Wrong configured Web size: " + filename)
    for built in sorted((ROOT / "builds/web").iterdir()):
        if built.is_file():
            published = ROOT / "dist" / built.name
            require(published.is_file() and digest(published.read_bytes()) == digest(built.read_bytes()), "Stale Web distribution: " + built.name)

    validation = json.loads((VALIDATION / "VERIFICATION.json").read_text())
    require(validation["all_pass"] and validation["version"] == VERSION, "Runtime validation is not clean or has the wrong version")
    require(validation["sha256_after"] == runtime_hashes(), "Runtime file set differs from the tested frozen source")
    require(set(validation["sha256_after"]) <= members, "Source archive omits an authored runtime file")
    require({row["script"] for row in validation["suites"]} <= members, "Source archive omits a verified test script")
    require(validation["total_checks"] == sum(row["checks"] for row in validation["suites"]), "Runtime count does not match its suites")
    require(set(validation["required_suites"]) == REQUIRED, "Runtime report does not declare the complete mandatory suite set")
    require(set(validation["required_suites"]) <= {row["suite"] for row in validation["suites"]}, "A required source suite is missing")
    require(all(row["pass"] and row["checks"] > 0 and not row["error_lines"] for row in validation["suites"]), "A source suite has unresolved errors")
    for rel, expected in validation["sha256_after"].items():
        require(digest((ROOT / rel).read_bytes()) == expected, "Runtime changed after verification: " + rel)
    for suite in validation["suites"]:
        log = VALIDATION / suite["log"]
        require(log.is_file() and digest(log.read_bytes()) == suite["sha256"], "Missing or altered test log")
        require(digest((ROOT / suite["script"]).read_bytes()) == suite["script_sha256"], "Source test changed after verification")
    exported = json.loads((VALIDATION / "EXPORTED_PACK_VERIFICATION.json").read_text())
    require(exported["all_pass"] and exported["version"] == VERSION, "Exported pack verification is incomplete")
    require({row["platform"] for row in exported["packs"]} == {"windows", "web"} and len(exported["packs"]) == 2, "Both final packs must be tested once")
    require(exported["total_checks"] == sum(row["checks"] for row in exported["packs"]), "Exported check count differs from its logs")
    require(exported["runtime_sha256"] == validation["sha256_after"], "Exports and source tests refer to different runtimes")
    require(digest((ROOT / exported["test_script"]).read_bytes()) == exported["test_script_sha256"], "External pack test changed after verification")
    for row in exported["packs"]:
        require(row["pass"] and row["checks"] > 0 and row["execution_directory_was_empty"] and row["pack_unchanged_during_test"], "Exported pack was not independently tested in isolation")
        pack = ROOT / ("builds/windows/TheTowerDescent.exe" if row["platform"] == "windows" else "builds/web/index.pck")
        require(digest(pack.read_bytes()) == row["pack_sha256"], "Exported pack changed after its tests")
        require(digest((VALIDATION / row["log"]).read_bytes()) == row["log_sha256"], "Exported pack test log changed")

    provenance = json.loads((CAPTURES / "CI_PROVENANCE.json").read_text())
    capture_manifest = json.loads((CAPTURES / "MANIFEST.json").read_text())
    require(len(provenance["captures"]) == len(EXPECTED_CAPTURES) and {row["file"] for row in provenance["captures"]} == EXPECTED_CAPTURES, "Native captures are incomplete")
    require(provenance["version"] == VERSION and capture_manifest["version"] == VERSION, "Capture version differs from release")
    require(provenance["runtime_sha256"] == validation["sha256_after"], "Native captures do not show the final tested runtime")
    require(provenance["fixture_sha256"] == digest((ROOT / "prototype/tests/visual_frontend_preview.gd").read_bytes()), "Visual fixture changed after capture")
    require(provenance["verification_sha256"] == digest((VALIDATION / "VERIFICATION.json").read_bytes()), "Native captures refer to different source validation")
    require(provenance["request_sha256"] == digest((ROOT / f".review/v{SHORT}/request.json").read_bytes()), "Capture request differs from the reviewed request")
    export_build = json.loads((VALIDATION / "EXPORTS.json").read_text())
    require(export_build["all_pass"] and export_build["version"] == VERSION, "Release export commands did not pass")
    require(export_build["runtime_sha256_before"] == export_build["runtime_sha256_after"] == validation["sha256_after"], "Runtime changed between source verification and export")
    require(export_build["captured_source_commit"] == provenance["source_commit"], "Export and visual review refer to different source revisions")
    require(export_build["source_verification_sha256"] == digest((VALIDATION / "VERIFICATION.json").read_bytes()), "Export refers to a different source verification report")
    require({row["platform"] for row in export_build["exports"]} == {"windows", "web"}, "Both export commands must be recorded")
    for row in export_build["exports"]:
        require(row["pass"] and not row["error_lines"] and digest((VALIDATION / row["log"]).read_bytes()) == row["sha256"], "Export command log is missing, changed or contains errors")
    for row in export_build["outputs"]:
        artifact = ROOT / row["file"]
        require(artifact.stat().st_size == row["bytes"] and digest(artifact.read_bytes()) == row["sha256"], "Export output changed after construction: " + row["file"])
    require({row["file"] for row in provenance["captures"]} == {row["file"] for row in capture_manifest["captures"]}, "Capture manifest disagrees with provenance")
    for row in provenance["captures"]:
        capture = (CAPTURES / row["file"]).read_bytes()
        require(digest(capture) == row["sha256"], "Native capture changed after CI: " + row["file"])
        require(capture[:8] == b"\x89PNG\r\n\x1a\n", "Native capture is not a PNG")
        require(struct.unpack_from(">II", capture, 16) == (1440, 900), "Unexpected capture dimensions")
    visual_review = json.loads((VALIDATION / "VISUAL_REVIEW.json").read_text())
    require(visual_review["all_pass"] and visual_review["source_commit"] == provenance["source_commit"], "Visual review does not match the captured source")
    require(len(visual_review.get("captures", [])) == len(EXPECTED_CAPTURES) and all(row.get("status") == "pass" for row in visual_review["captures"]), "A final native capture lacks individual visual approval")
    require({row["file"]: row["sha256"] for row in visual_review["captures"]} == {row["file"]: row["sha256"] for row in provenance["captures"]}, "Visual review does not cover every final capture")
    document_review = json.loads((VALIDATION / "DOCUMENT_REVIEW.json").read_text())
    require(document_review["all_pass"], "Document review has unresolved findings")
    require(document_review["source_count"] == len(DOCUMENT_SOURCES) and len(document_review["sources"]) == len(DOCUMENT_SOURCES), "Bible review does not include all required sources")
    require({row["file"] for row in document_review["sources"]} == set(DOCUMENT_SOURCES), "Bible review source names differ from the full document contract")
    for row in document_review["artifacts"] + document_review["sources"]:
        require(digest((ROOT / row["file"]).read_bytes()) == row["sha256"], "Document changed after review: " + row["file"])
    require({row["file"] for row in document_review["artifacts"]} == {
        f"docs/The-Tower-Descent-Bible-v{SHORT}.docx", f"docs/The-Tower-Descent-Bible-v{SHORT}.pdf"
    }, "Document review does not cover both final formats")
    require([row["page"] for row in document_review["pages"]] == list(range(1, document_review["page_count"] + 1)), "Document review has missing or duplicate pages")
    require(all(row["status"] == "pass" for row in document_review["pages"]), "Document contains an unapproved page")
    document_build = json.loads((VALIDATION / "DOCUMENT_BUILD.json").read_text())
    require(document_build["version"] == VERSION and document_build["source_count"] == len(DOCUMENT_SOURCES), "Wrong document build version or source count")
    require(document_review.get("source_commit") == document_build["source_commit"], "Document review refers to another construction revision")
    require(document_build["page_count"] == document_review["page_count"], "Document review page count differs from its rendered document")
    require({row["page"]: row["sha256"] for row in document_review["pages"]} ==
            {row["page"]: row["sha256"] for row in document_build["pages"]},
            "Document review does not approve the exact rendered pages")
    for category in ["artifacts", "sources"]:
        require({row["file"]: row["sha256"] for row in document_build[category]} ==
                {row["file"]: row["sha256"] for row in document_review[category]},
                "Document review differs from its build: " + category)
    for row in document_build["pages"]:
        image_path = ROOT / row["file"]
        if image_path.is_file():
            require(digest(image_path.read_bytes()) == row["sha256"], "Rendered document page changed after review")

    for name in ["LICENSE", "NOTICE"]:
        require((ROOT / "dist" / ("OPEN_SANS_" + name + ".txt")).read_bytes() == (ROOT / "prototype/assets/fonts" / (name + ".txt")).read_bytes(), "Web font notices are missing or stale")

    print(json.dumps({"status": "PASS", "version": VERSION, "archives": archive_results,
                      "source_members_verified": len(members), "runtime_checks": validation["total_checks"], "exported_pack_checks": exported["total_checks"],
                      "document_pages_reviewed": document_review["page_count"], "document_sources_verified": document_review["source_count"],
                      "checks": ["ZIP integrity", "SHA256 manifest", "every source member equals local source", "required deliverables", "PE x64 and embedded executable bytes", "Windows guide and font license", "Web sizes and distribution equality", "frozen runtime hashes and test logs", f"{len(EXPECTED_CAPTURES)} native captures against CI provenance and runtime hashes", "complete document review and final Word/PDF/source hashes", "Web font notices"]}, indent=2))


if __name__ == "__main__":
    main()
