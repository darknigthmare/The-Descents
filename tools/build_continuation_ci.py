#!/usr/bin/env python3
"""Review and release the v0.10 continuation without rebuilding the v0.9 Bible.

An isolated build-request commit names its immediate source parent and runtime
fingerprints. A review renders prepared native states and the supplied supplement;
only an independently authored approval.json can authorize release packaging.
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

VERSION = "0.10.0"
SHORT = "0.10"
BRANCH = "feat/live-tower-collapse"
REQUEST = ROOT / f".review/v{SHORT}/build-request.json"
APPROVAL = ROOT / f".review/v{SHORT}/approval.json"
VALIDATION = ROOT / f"docs/validation/v{SHORT}"
CAPTURES = ROOT / f"docs/captures/v{SHORT}"
RENDERED = VALIDATION / "rendered"
REVIEW = VALIDATION / "REVIEW_MANIFEST.json"
SUPPLEMENT_DOCX = ROOT / f"docs/The-Tower-Descent-Continuation-v{SHORT}.docx"
SUPPLEMENT_PDF = SUPPLEMENT_DOCX.with_suffix(".pdf")
SUPPLEMENT_SOURCES = (
    "docs/CONTINUATION_A24_A23_V0.10.md", "docs/BIBLE_DU_JEU.md",
    "docs/CATALOGUE_ETAGES.md", "docs/GAMEPLAY_DETAILLE.md",
    "docs/PROGRESSION_HORREUR_V0.8.md",
)
REFERENCE_BIBLE = {
    "docs/The-Tower-Descent-Bible-v0.9.docx": "f718404121ba6c6990cf7df6e0988455881a0aa9e4188af6e63da14b319dbe20",
    "docs/The-Tower-Descent-Bible-v0.9.pdf": "25776d758dfb7070afb4157f15859864c6f991809fba71f78cf6f442cbe61121",
}
FIXTURES = {
    "baseline": "prototype/tests/visual_frontend_preview",
    "continuation": "prototype/tests/visual_continuation_preview",
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
    require(path.is_file() and not path.is_symlink(), "Missing or linked evidence file: " + path.relative_to(ROOT).as_posix())
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
    # Runtime hashes intentionally omit tests; bind the harness and release tools
    # separately so edited tests cannot reuse old passing evidence.
    paths = list((ROOT / "tools").glob("*.py")) + list((ROOT / "tools").glob("*.gd"))
    paths += list((ROOT / "prototype/tests").glob("*.gd")) + list((ROOT / "prototype/tests").glob("*.tscn"))
    paths.append(ROOT / ".github/workflows/release-v010.yml")
    return {path.relative_to(ROOT).as_posix(): sha256(path) for path in sorted(paths)}


def expected_captures(request: dict) -> dict[str, list[str]]:
    from capture_evidence import EXPECTED_CAPTURES

    result = request.get("expected_captures")
    require(isinstance(result, dict) and set(result) == set(FIXTURES), "Declare both exact native capture sets.")
    for group, names in result.items():
        require(isinstance(names, list) and names and all(isinstance(name, str) for name in names),
                "Capture set is empty or malformed: " + group)
        require(len(set(names)) == len(names) and all(re.fullmatch(r"[A-Za-z0-9_-]+\.png", name) for name in names),
                "Capture names must be unique PNG basenames.")
    require(set(result["baseline"]) == EXPECTED_CAPTURES, "The baseline must cover every established native state.")
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
    for name, expected in REFERENCE_BIBLE.items():
        require(sha256(ROOT / name) == expected, "The complete historical v0.9 Bible must remain unchanged: " + name)
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
    for suite in verified["suites"]:
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


def capture(binary: str, request: dict) -> list[dict]:
    expected = expected_captures(request)
    all_records: list[dict] = []
    for group, fixture in FIXTURES.items():
        destination = CAPTURES / group
        if destination.exists():
            shutil.rmtree(destination)
        destination.mkdir(parents=True)
        scene = "res://" + fixture.removeprefix("prototype/") + ".tscn"
        checked(["xvfb-run", "-a", "-s", "-screen 0 1440x900x24", binary,
                 "--path", str(ROOT / "prototype"), "--rendering-method", "gl_compatibility",
                 "--rendering-driver", "opengl3", "--audio-driver", "Dummy", "--resolution", "1440x900",
                 scene, "--", "--capture-root=" + str(destination)], "native-" + group + ".txt", 720)
        manifest = read_json(destination / "MANIFEST.json")
        require(manifest.get("version") == VERSION and manifest.get("prepared_states") is True
                and manifest.get("human_playthrough") is False, "Capture fixture misidentifies its version or method.")
        require(manifest.get("display") not in {None, "headless"} and manifest.get("rendering_method") == "gl_compatibility",
                "Captures did not use the native Compatibility renderer.")
        shots = manifest.get("captures", [])
        names = [row["file"] for row in shots]
        require(len(names) == len(set(names)) and sorted(names) == expected[group], "Capture set is incomplete: " + group)
        require({path.name for path in destination.glob("*.png")} == set(names), "Unlisted or missing native PNGs: " + group)
        rows = []
        for shot in shots:
            path = destination / shot["file"]
            width, height = png_shape(path)
            require((width, height) == (1440, 900) and shot.get("width") == width and shot.get("height") == height,
                    "Native image dimensions differ from the fixture manifest.")
            rows.append({**record(path), "width": width, "height": height, "description": str(shot.get("description", "")), "group": group})
        write_json(destination / "PROVENANCE.json", {
            "format": 1, "version": VERSION, "source_commit": request["source_commit"], "request_commit": git_head(),
            "runtime_sha256": runtime_hashes(), "manifest": record(destination / "MANIFEST.json"),
            "fixture": [record(ROOT / (fixture + suffix)) for suffix in [".gd", ".tscn"]],
            "captures": rows, "manual_visual_review": False,
        })
        all_records.extend(rows)
    return all_records


def document_evidence() -> dict:
    require(SUPPLEMENT_PDF.read_bytes()[:5] == b"%PDF-", "The prepared supplement is not a PDF.")
    artifacts = [record(SUPPLEMENT_DOCX), record(SUPPLEMENT_PDF)]
    sources = [record(ROOT / name) for name in SUPPLEMENT_SOURCES]
    tool("verify_document_content.py", "--docx", str(SUPPLEMENT_DOCX), "--pdf", str(SUPPLEMENT_PDF),
         "--output", str(VALIDATION / "SUPPLEMENT_CONTENT.json"))
    info = subprocess.check_output(["pdfinfo", str(SUPPLEMENT_PDF)], text=True)
    found = re.search(r"^Pages:\s+(\d+)", info, re.M)
    require(found is not None and int(found.group(1)) > 0, "Supplement has no readable pages.")
    count = int(found.group(1))
    if RENDERED.exists():
        shutil.rmtree(RENDERED)
    RENDERED.mkdir(parents=True)
    checked(["pdftoppm", "-png", "-scale-to", "2000", str(SUPPLEMENT_PDF), str(RENDERED / "page")], "supplement-pages.txt", 360)
    paths = sorted(RENDERED.glob("page-*.png"), key=lambda path: int(path.stem.rsplit("-", 1)[1]))
    require(len(paths) == count, "Not every supplement page was rendered.")
    pages = []
    for number, path in enumerate(paths, 1):
        require(int(path.stem.rsplit("-", 1)[1]) == number, "Supplement page numbering is incomplete.")
        width, height = png_shape(path)
        require(max(width, height) == 2000 and min(width, height) > 0, "Unexpected supplement raster dimensions.")
        pages.append({"page": number, **record(path), "width": width, "height": height})
    require(artifacts == [record(SUPPLEMENT_DOCX), record(SUPPLEMENT_PDF)], "Document rendering changed the reviewed artifact inputs.")
    return {
        "sources": sources, "artifacts": artifacts, "page_count": count, "pages": pages,
        "content_verification": record(VALIDATION / "SUPPLEMENT_CONTENT.json"),
        "reference_bible": [record(ROOT / name) for name in REFERENCE_BIBLE],
        "method": "Prepared Word/PDF retained unchanged; ordered text inclusion checked; PDF pages rasterized by CI Poppler at 2000px.",
        "manual_visual_review": False,
    }


def verify_approval() -> dict:
    review = read_json(REVIEW)
    approval = read_json(APPROVAL)
    require(review.get("format") == 1 and review.get("version") == VERSION, "Wrong review manifest version.")
    require(approval.get("format") == 1 and approval.get("version") == VERSION
            and approval.get("decision") == "approved" and approval.get("reviewer") == "assistant",
            "Release requires an explicit assistant-authored approval of the reviewed files.")
    require(isinstance(approval.get("reviewed_utc"), str) and approval["reviewed_utc"].strip(), "Approval has no review date.")
    require(approval.get("review_manifest_sha256") == sha256(REVIEW), "Approval names another review manifest.")
    require(approval.get("runtime_sha256") == review.get("runtime_sha256") == runtime_hashes(), "Reviewed runtime differs from the release runtime.")
    require(review.get("source_inputs") == source_inputs(), "A test, fixture or delivery tool changed after the review build.")
    verify_source()
    require(review["source_verification"] == record(VALIDATION / "VERIFICATION.json"), "Source validation changed after review.")

    def approved_records(key: str, expected: list[dict], supplied: object) -> None:
        require(isinstance(supplied, list), "Missing approval records: " + key)
        require(len(supplied) == len(expected) and all(isinstance(row, dict) for row in supplied), "Incomplete approval: " + key)
        names = [row.get("file") for row in supplied]
        require(len(names) == len(set(names)) and set(names) == {row["file"] for row in expected}, "Missing or duplicate approved files: " + key)
        index = {row["file"]: row for row in supplied}
        for row in expected:
            accepted = index[row["file"]]
            require(accepted.get("sha256") == row["sha256"] and accepted.get("status") == "pass", "Unapproved or stale file: " + row["file"])
        check_records(expected)

    approved_records("captures", review["captures"], approval.get("captures"))
    document = review["supplement"]
    accepted_document = approval.get("supplement")
    require(isinstance(accepted_document, dict), "The supplement lacks separate approval.")
    for key in ["artifacts", "sources", "reference_bible"]:
        approved_records("supplement." + key, document[key], accepted_document.get(key))
    approved_records("supplement.pages", document["pages"], accepted_document.get("pages"))
    approved_pages = accepted_document["pages"]
    require([row.get("page") for row in approved_pages] == list(range(1, document["page_count"] + 1)), "Every final PDF page needs ordered individual review.")
    word_review = accepted_document.get("word_review", {})
    require(word_review.get("reviewed") is True and word_review.get("artifact_sha256") == sha256(SUPPLEMENT_DOCX)
            and isinstance(word_review.get("method"), str) and bool(word_review["method"].strip()),
            "The exact editable Word supplement lacks its own visual review.")
    from verify_document_content import verify
    require(verify(SUPPLEMENT_DOCX, SUPPLEMENT_PDF)["complete"], "The approved PDF no longer contains the ordered Word text.")
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
    }
    source_inputs_map = {prefix + path.relative_to(ROOT).as_posix(): path for path in source_package_paths()}
    required_documents = set(REFERENCE_BIBLE) | {path.relative_to(ROOT).as_posix() for path in [SUPPLEMENT_DOCX, SUPPLEMENT_PDF]}
    require(all(prefix + name in source_inputs_map for name in required_documents), "Source ZIP omits the complete reference Bible or continuation supplement.")
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
    engine = subprocess.check_output([binary, "--version"], text=True).strip()
    require(engine.startswith("4.7.2.stable.official"), "The builder must use the pinned official Godot release.")
    if request["phase"] == "review":
        tool("run_validation.py", "--godot", binary)
        require(before == runtime_hashes(), "Source import or tests changed the requested runtime.")
        export_packs(binary, request["source_commit"])
        captures = capture(binary, request)
        supplement = document_evidence()
        require(inputs == source_inputs(), "A delivery input changed while review evidence was built.")
        write_json(REVIEW, {
            "format": 1, "version": VERSION, "request_id": request["request_id"], "source_commit": request["source_commit"],
            "request_commit": git_head(), "runtime_sha256": before, "source_inputs": inputs,
            "source_verification": record(VALIDATION / "VERIFICATION.json"),
            "expected_captures": expected_captures(request), "captures": captures, "supplement": supplement,
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
    write_json(VALIDATION / "CI_BUILD.json", {
        "version": VERSION, "phase": request["phase"], "request_id": request["request_id"],
        "source_commit": request["source_commit"], "request_commit": git_head(), "runtime_sha256": before,
        "completed_utc": datetime.now(timezone.utc).isoformat(), "automated_steps_passed": True,
        "manual_visual_review_required": request["phase"] == "review",
        "run_url": f'https://github.com/{os.environ.get("GITHUB_REPOSITORY", "darknigthmare/The-Descents")}/actions/runs/{os.environ.get("GITHUB_RUN_ID", "local")}',
        "pipeline_sha256": sha256(Path(__file__)),
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
    paths = [f"docs/validation/v{SHORT}"]
    if request["phase"] == "review":
        paths.append(f"docs/captures/v{SHORT}")
        paths += [name for name in git("ls-files", "--others", "--exclude-standard", "--", "prototype").splitlines() if name.endswith(".uid")]
    else:
        verify_approval()
        verify_exports()
        require(read_json(ROOT / f"releases/VERIFICATION_V{SHORT}.json").get("status") == "PASS", "No final archive verification.")
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
        print("Explicit approval matches all final native captures, supplement pages and editable artifacts.")
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
