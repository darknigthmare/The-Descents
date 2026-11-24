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

ROOT = Path(__file__).resolve().parents[1]
VERSION = re.search(r'config/version="([^"]+)"', (ROOT / "prototype/project.godot").read_text()).group(1)
SHORT = ".".join(VERSION.split(".")[:2])


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
        "docs/PROPS_INTERACTIONS.md", "docs/ENNEMIS_STATISTIQUES.md", "docs/SCENES_CINEMATIQUES.md",
        "docs/GAMEPLAY_DETAILLE.md", "docs/COMMUNICATIONS_ET_EQUIPES.md",
        "docs/validation/v0.4/VERIFICATION.json", "docs/captures/v0.4/MANIFEST.json",
        "docs/validation/v0.4/EXPORTED_PACK_VERIFICATION.json",
        "docs/validation/v0.4/VISUAL_REVIEW.json",
        "docs/validation/v0.4/DOCUMENT_REVIEW.json",
        "docs/captures/v0.4/CI_PROVENANCE.json", "docs/CAPTURES_V0.4.md",
        f"docs/The-Tower-Descent-Bible-v{SHORT}.docx", f"docs/The-Tower-Descent-Bible-v{SHORT}.pdf",
        ".github/workflows/cinematic-review.yml", "tools/package_release.py", "tools/verify_release.py"
    }
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

    validation = json.loads((ROOT / "docs/validation/v0.4/VERIFICATION.json").read_text())
    require(validation["all_pass"], "Runtime validation is not clean")
    for rel, expected in validation["sha256_after"].items():
        require(digest((ROOT / rel).read_bytes()) == expected, "Runtime changed after verification: " + rel)
    for suite in validation["suites"]:
        log = ROOT / "docs/validation/v0.4" / suite["log"]
        require(log.is_file() and digest(log.read_bytes()) == suite["sha256"], "Missing or altered test log")
    exported = json.loads((ROOT / "docs/validation/v0.4/EXPORTED_PACK_VERIFICATION.json").read_text())
    require(exported["all_pass"] and exported["total_checks"] == 36, "Exported pack verification is incomplete")
    for row in exported["packs"]:
        pack = ROOT / ("builds/windows/TheTowerDescent.exe" if row["platform"] == "windows" else "builds/web/index.pck")
        require(digest(pack.read_bytes()) == row["pack_sha256"], "Exported pack changed after its tests")
        require(digest((ROOT / "docs/validation/v0.4" / row["log"]).read_bytes()) == row["log_sha256"], "Exported pack test log changed")

    provenance = json.loads((ROOT / "docs/captures/v0.4/CI_PROVENANCE.json").read_text())
    capture_manifest = json.loads((ROOT / "docs/captures/v0.4/MANIFEST.json").read_text())
    require(len(provenance["captures"]) == 13, "Expected thirteen native captures")
    require({row["file"] for row in provenance["captures"]} == {row["file"] for row in capture_manifest["captures"]}, "Capture manifest disagrees with provenance")
    for row in provenance["captures"]:
        capture = (ROOT / "docs/captures/v0.4" / row["file"]).read_bytes()
        require(digest(capture) == row["sha256"], "Native capture changed after CI: " + row["file"])
        require(capture[:8] == b"\x89PNG\r\n\x1a\n", "Native capture is not a PNG")
        require(struct.unpack_from(">II", capture, 16) == (1440, 900), "Unexpected capture dimensions")
    visual_review = json.loads((ROOT / "docs/validation/v0.4/VISUAL_REVIEW.json").read_text())
    require(visual_review["all_pass"] and visual_review["source_commit"] == provenance["source_commit"], "Visual review does not match the captured source")
    require({row["file"]: row["sha256"] for row in visual_review["captures"]} == {row["file"]: row["sha256"] for row in provenance["captures"]}, "Visual review does not cover every final capture")
    document_review = json.loads((ROOT / "docs/validation/v0.4/DOCUMENT_REVIEW.json").read_text())
    require(document_review["all_pass"], "Document review has unresolved findings")
    require(document_review["source_count"] == 10 and len(document_review["sources"]) == 10, "Bible review does not include all ten sources")
    for row in document_review["artifacts"] + document_review["sources"]:
        require(digest((ROOT / row["file"]).read_bytes()) == row["sha256"], "Document changed after review: " + row["file"])
    require({row["file"] for row in document_review["artifacts"]} == {
        f"docs/The-Tower-Descent-Bible-v{SHORT}.docx", f"docs/The-Tower-Descent-Bible-v{SHORT}.pdf"
    }, "Document review does not cover both final formats")
    require([row["page"] for row in document_review["pages"]] == list(range(1, document_review["page_count"] + 1)), "Document review has missing or duplicate pages")
    require(all(row["status"] == "pass" for row in document_review["pages"]), "Document contains an unapproved page")
    for name in ["LICENSE", "NOTICE"]:
        require((ROOT / "dist" / ("OPEN_SANS_" + name + ".txt")).read_bytes() == (ROOT / "prototype/assets/fonts" / (name + ".txt")).read_bytes(), "Web font notices are missing or stale")

    print(json.dumps({"status": "PASS", "version": VERSION, "archives": archive_results,
                      "source_members_verified": len(members), "runtime_checks": validation["total_checks"], "exported_pack_checks": exported["total_checks"],
                      "document_pages_reviewed": document_review["page_count"], "document_sources_verified": document_review["source_count"],
                      "checks": ["ZIP integrity", "SHA256 manifest", "every source member equals local source", "required deliverables", "PE x64 and embedded executable bytes", "Windows guide and font license", "Web sizes and distribution equality", "frozen runtime hashes and test logs", "thirteen native captures against CI provenance", "complete document review and final Word/PDF/source hashes", "Web font notices"]}, indent=2))


if __name__ == "__main__":
    main()
