#!/usr/bin/env python3
"""Verify the v0.12 delivery against its frozen, explicitly reviewed candidate.

Run after package_release.py and an exact builds/web -> dist copy:
    python3 tools/verify_commerce_release.py
Use --evidence-only to check the candidate and reviews before packaging; this
mode writes no release report. --describe-reviews prints the schemas below.
No review, approval, archive, Git commit, push or publication is generated.
releases/VERIFICATION_V0.12.json is written atomically only after every gate
passes. Failure leaves existing evidence unchanged and exits unsuccessfully.

REVIEW CONTRACT (JSON paths are relative to the repository root)
Every file record is {"file": "path", "bytes": integer, "sha256": lowercase64}.
Every reviewed image also has "status": "pass" and a nonempty "observation"
written after inspecting that exact image. The verifier checks evidence and
fingerprints; it cannot perform or manufacture the review itself.

docs/validation/v0.12/VISUAL_REVIEW.json:
  format: 1; version: "0.12.0"; all_pass: true
  source_commit: candidate.source_commit; request_commit: candidate.request_commit
  candidate_sha256: SHA256 of CANDIDATE.json; runtime_sha256: exact runtime map
  reviewer: nonempty identity; reviewed_utc: ISO8601 with timezone
  prepared_states: true; human_playthrough: false
  coverage: {"compatibility": 18, "forward_plus": 3}
  captures: one reviewed file record for every captured PNG, using full paths
    docs/captures/v0.12/commerce/{compatibility,forward_plus}/NAME.png
If the retained Vulkan probe proves unavailability, forward_plus coverage is
0 and its three PNGs must be absent. This partial coverage remains explicit
in the release report; a failed attempted render cannot become an optional skip.

docs/validation/v0.12/DOCUMENT_REVIEW.json:
  format: 1; version: "0.12.0"; all_pass: true
  source_commit, request_commit, reviewer, reviewed_utc: as above
  sources: [record of docs/CONTINUATION_A22_A20_V0.12.md]
  generator: record of tools/build_commerce_document.py (an object, not a list)
  artifacts: records of docs/The-Tower-Descent-Continuation-v0.12.docx and .pdf
  page_count: 9; rendered_from_pdf_sha256: exact reviewed PDF SHA256
  content_verification: record of docs/validation/v0.12/DOCUMENT_CONTENT.json
  pages: nine reviewed image records with page: 1..9, in that order, under
    docs/validation/v0.12/document-pages/page-1.png through page-9.png
DOCUMENT_CONTENT.json must be produced by verify_document_content.py for the
final DOCX/PDF. Its completeness checks are rerun read-only during verification.
The source, generator and both documents must already exist at request_commit.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import struct
import subprocess
import sys
from zipfile import ZipFile

import build_commerce_candidate as candidate_tool
from qa_common import ERROR, PASS, MAX_ARCHIVE_BYTES, ROOT, git_head, runtime_hashes, sha256, source_package_paths, version
from run_validation import REQUIRED
from verify_document_content import verify as verify_document_text


VERSION = "0.12.0"
VALIDATION = ROOT / "docs/validation/v0.12"
CAPTURES = ROOT / "docs/captures/v0.12/commerce"
REQUEST = ROOT / ".review/v0.12/candidate-request.json"
REPORT = ROOT / "releases/VERIFICATION_V0.12.json"
DOC_SOURCE = ROOT / "docs/CONTINUATION_A22_A20_V0.12.md"
DOC_GENERATOR = ROOT / "tools/build_commerce_document.py"
DOCX = ROOT / "docs/The-Tower-Descent-Continuation-v0.12.docx"
PDF = ROOT / "docs/The-Tower-Descent-Continuation-v0.12.pdf"
DOCUMENT_PAGES = VALIDATION / "document-pages"
SHA = re.compile(r"[0-9a-f]{64}")
COMMIT = re.compile(r"[0-9a-f]{40}")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def read_json(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    require(isinstance(value, dict), "Expected a JSON object: " + str(path))
    return value


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def local_file(name: object) -> Path:
    require(isinstance(name, str) and bool(name) and "\\" not in name, "Invalid evidence path.")
    parsed = PurePosixPath(name)
    require(not parsed.is_absolute() and ".." not in parsed.parts and parsed.as_posix() == name,
            "Evidence paths must be canonical repository-relative names: " + name)
    path = ROOT / name
    require(path.is_file() and not path.is_symlink() and path.resolve().is_relative_to(ROOT),
            "Evidence is missing, linked or outside the repository: " + name)
    return path


def record(path: Path) -> dict:
    require(path.is_file(), "Missing evidence: " + str(path))
    return {"file": relative(path), "bytes": path.stat().st_size, "sha256": sha256(path)}


def check_record(row: object, expected: Path | None = None) -> dict:
    require(isinstance(row, dict), "Malformed file record.")
    path = local_file(row.get("file"))
    if expected is not None:
        require(path == expected, "Unexpected evidence path: " + relative(path))
    actual = record(path)
    require(all(row.get(key) == value for key, value in actual.items()),
            "Evidence size or SHA256 changed: " + actual["file"])
    return actual


def check_records(rows: object, expected: set[Path]) -> list[dict]:
    require(isinstance(rows, list) and all(isinstance(row, dict) for row in rows), "Malformed record list.")
    names = [row.get("file") for row in rows]
    require(all(isinstance(name, str) for name in names) and len(names) == len(set(names))
            and set(names) == {relative(path) for path in expected}, "Evidence file membership differs.")
    return [check_record(row) for row in rows]


def log_text(entry: dict, hash_key: str = "sha256") -> str:
    name = entry.get("log")
    require(isinstance(name, str) and Path(name).name == name and "/" not in name and "\\" not in name,
            "Invalid retained log name.")
    path = local_file(relative(VALIDATION / name))
    require(entry.get(hash_key) == sha256(path), "Retained log changed: " + name)
    return path.read_text(encoding="utf-8", errors="replace")


def check_log(entry: dict, *, suite: bool = False, hash_key: str = "sha256") -> None:
    text = log_text(entry, hash_key)
    require(entry.get("pass") is True and entry.get("returncode") == 0 and entry.get("error_lines") == [],
            "A retained command did not pass: " + str(entry.get("log")))
    require(not any(ERROR.search(line) for line in text.splitlines()), "A retained log contains an error.")
    if suite:
        matches = PASS.findall(text)
        require(len(matches) == 1 and int(matches[0]) > 0 and entry.get("checks") == int(matches[0])
                and entry.get("pass_markers") == 1, "Check count differs from its actual PASS marker.")


def git(*arguments: str) -> str:
    return subprocess.check_output(["git", *arguments], cwd=ROOT, text=True).strip()


def review_header(review: dict, candidate: dict) -> None:
    require(review.get("format") == 1 and review.get("version") == VERSION and review.get("all_pass") is True,
            "Review is incomplete or identifies another version.")
    for key in ("source_commit", "request_commit"):
        require(review.get(key) == candidate[key], "Review refers to another " + key + ".")
    require(isinstance(review.get("reviewer"), str) and bool(review["reviewer"].strip()), "Review has no reviewer identity.")
    stamp = review.get("reviewed_utc")
    require(isinstance(stamp, str), "Review has no timestamp.")
    parsed = datetime.fromisoformat(stamp.replace("Z", "+00:00"))
    require(parsed.tzinfo is not None and parsed.utcoffset().total_seconds() == 0,
            "Review timestamp must identify UTC explicitly.")


def reviewed_image(row: dict) -> None:
    check_record(row)
    require(row.get("status") == "pass" and isinstance(row.get("observation"), str)
            and bool(row["observation"].strip()), "Each exact image needs its own explicit review observation.")
    from PIL import Image
    with Image.open(local_file(row["file"])) as image:
        require(image.format == "PNG", "Reviewed image is not a PNG.")
        image.verify()


def verify_candidate(runtime: dict) -> dict:
    path = VALIDATION / "CANDIDATE.json"
    candidate = read_json(path)
    require(version() == VERSION == candidate.get("version"), "Release/project/candidate version differs.")
    require(candidate.get("automated_steps_passed") is True and candidate.get("stage") == "complete"
            and candidate.get("status") in {"awaiting_visual_review", "partial_renderer_coverage"},
            "Candidate generation did not finish successfully.")
    require(candidate.get("runtime_sha256") == runtime and candidate.get("manual_visual_review") is False
            and candidate.get("human_playthrough") is False, "Candidate runtime or method differs.")
    require(all(candidate.get(key) is False for key in ("approval_generated", "release_packaged", "published")),
            "The candidate must precede explicit review and packaging.")
    for key in ("source_commit", "request_commit"):
        require(isinstance(candidate.get(key), str) and COMMIT.fullmatch(candidate[key]) is not None,
                "Invalid candidate " + key + ".")
    check_record(candidate.get("request"), REQUEST)
    request = read_json(REQUEST)
    require(request.get("format") == 1 and request.get("phase") == "candidate" and request.get("version") == VERSION
            and request.get("runtime_sha256") == runtime and request.get("source_commit") == candidate["source_commit"],
            "Candidate request does not match its frozen runtime or source.")
    expected = request.get("expected_captures", {})
    require(set(expected) == set(candidate_tool.EXPECTED_CAPTURES), "Request capture groups differ.")
    for group, names in candidate_tool.EXPECTED_CAPTURES.items():
        require(isinstance(expected[group], list) and sorted(expected[group]) == sorted(names),
                "Request capture membership differs: " + group)
    parent = git("rev-list", "--parents", "-n", "1", candidate["request_commit"]).split()
    require(parent == [candidate["request_commit"], candidate["source_commit"]],
            "Candidate request is not an isolated direct child of its source commit.")
    changed = git("diff", "--name-only", "--no-renames", candidate["source_commit"], candidate["request_commit"]).splitlines()
    require(changed == [relative(REQUEST)], "The candidate request commit changed other source files.")
    committed_request = subprocess.check_output(["git", "show", candidate["request_commit"] + ":" + relative(REQUEST)], cwd=ROOT)
    require(hashlib.sha256(committed_request).hexdigest() == sha256(REQUEST), "The retained request differs from its Git commit.")
    require(subprocess.run(["git", "merge-base", "--is-ancestor", candidate["request_commit"], "HEAD"], cwd=ROOT).returncode == 0,
            "Current checkout does not descend from the reviewed candidate request.")
    pipeline = ROOT / "tools/build_commerce_candidate.py"
    require(candidate.get("pipeline_sha256") == sha256(pipeline), "Candidate pipeline changed after generation.")
    fixture = {candidate_tool.FIXTURE, candidate_tool.FIXTURE.with_suffix(".gd")}
    check_records(candidate.get("fixture"), fixture)
    frozen = sorted(set(runtime) | {relative(path) for path in fixture}
                    | {relative(path) for path in (pipeline, DOC_SOURCE, DOC_GENERATOR, DOCX, PDF)}
                    | {"tools/qa_common.py", "tools/run_validation.py", "tools/verify_exported_packs.py"}
                    | {relative(path) for path in (ROOT / "prototype/tests").rglob("*")
                       if path.is_file() and path.suffix not in {".uid", ".import", ".tmp", ".log"}
                       and not any(part in {".godot", "__pycache__", "visual_output"} for part in path.parts)})
    require(not git("diff", "--name-only", candidate["request_commit"], "--", *frozen),
            "A runtime, test, fixture, pipeline or document changed after the candidate request.")
    tracked = set(git("ls-tree", "-r", "--name-only", candidate["request_commit"], "--", *frozen).splitlines())
    require(set(frozen) <= tracked, "The frozen Git candidate omits a required authored input.")
    guard = read_json(VALIDATION / "CANDIDATE_REQUEST_GUARD.json")
    require(guard.get("version") == VERSION and guard.get("source_commit") == candidate["source_commit"]
            and guard.get("request_commit") == candidate["request_commit"] and guard.get("isolated_request") is True
            and guard.get("runtime_matches") is True and guard.get("approval_generated") is False,
            "Retained request guard differs from this candidate.")
    check_record(guard.get("request"), REQUEST)
    require(guard.get("expected_captures") == expected, "Guard capture scope differs from the request.")
    engine = candidate.get("engine", {})
    require(str(engine.get("version", "")).startswith("4.7.2.stable.official")
            and engine.get("archive_url") == candidate_tool.GODOT_ARCHIVE_URL
            and engine.get("archive_sha256") == candidate_tool.GODOT_ARCHIVE_SHA256
            and SHA.fullmatch(str(engine.get("binary_sha256", ""))) is not None,
            "Candidate engine provenance differs from the official pin.")
    return candidate


def verify_source(candidate: dict, runtime: dict) -> dict:
    path = VALIDATION / "VERIFICATION.json"
    check_record(candidate.get("source_validation"), path)
    validation = read_json(path)
    require(validation.get("all_pass") is True and validation.get("version") == VERSION
            and validation.get("sha256_before") == validation.get("sha256_after") == runtime
            and validation.get("runtime_unchanged_during_run") is True, "Source validation is incomplete or stale.")
    require(validation.get("runtime_freeze_commit") == validation.get("git_head") == candidate["request_commit"],
            "Source tests identify another checkout.")
    check_log(validation["import"])
    suites = validation.get("suites", [])
    expected_scripts = {relative(path) for path in (ROOT / "prototype/tests").glob("test_*.gd")
                        if path.name != "test_exported_pack.gd"}
    require(isinstance(suites, list) and len(suites) == len(expected_scripts)
            and {row.get("script") for row in suites} == expected_scripts, "Source test membership is incomplete or duplicated.")
    require(set(validation.get("required_suites", [])) == REQUIRED and validation.get("missing_suites") == []
            and REQUIRED <= {row.get("suite") for row in suites}, "Mandatory source suites are missing.")
    for row in suites:
        script = local_file(row["script"])
        require(row.get("script_sha256") == sha256(script) and row.get("suite") == script.stem.removeprefix("test_"),
                "Source suite script or identity changed.")
        check_log(row, suite=True)
    require(validation.get("total_checks") == sum(row["checks"] for row in suites) > 0,
            "Source validation total differs from its actual logs.")
    return validation


def verify_exports(candidate: dict, runtime: dict) -> dict:
    export_path = VALIDATION / "CANDIDATE_EXPORTS.json"
    pack_path = VALIDATION / "EXPORTED_PACK_VERIFICATION.json"
    check_record(candidate.get("exports"), export_path)
    check_record(candidate.get("exported_resource_verification"), pack_path)
    exports = read_json(export_path)
    require(exports.get("version") == VERSION and exports.get("all_pass") is True
            and exports.get("runtime_sha256") == runtime and exports.get("source_commit") == candidate["source_commit"]
            and exports.get("request_commit") == candidate["request_commit"], "Export construction differs from the candidate.")
    require(exports.get("windows_application_executed") is False and exports.get("webassembly_browser_executed") is False,
            "Resource exports cannot claim native platform playthroughs.")
    commands = exports.get("exports", [])
    require(len(commands) == 2 and {row.get("platform") for row in commands} == {"windows", "web"}, "Both export commands are required.")
    for row in commands:
        check_log(row)
    expected = {path for folder in (ROOT / "builds/windows", ROOT / "builds/web")
                for path in folder.rglob("*") if path.is_file()}
    check_records(exports.get("outputs"), expected)
    require({ROOT / "builds/windows/TheTowerDescent.exe", ROOT / "builds/web/index.html", ROOT / "builds/web/index.js",
             ROOT / "builds/web/index.wasm", ROOT / "builds/web/index.pck"} <= expected, "Export outputs are incomplete.")
    templates = read_json(VALIDATION / "CANDIDATE_TEMPLATES.json")
    check_record(templates.get("source_provenance"), ROOT / "docs/EXPORT_TEMPLATE_PROVENANCE.json")
    require(templates.get("version") == VERSION and templates.get("template_file_sha256_verified") is True
            and templates.get("complete_archive_sha256_verified") is False
            and {row["name"]: (row["size"], row["sha256"]) for row in templates.get("files", [])} == candidate_tool.PINNED_TEMPLATES,
            "Export templates do not match the exact verified file pins.")
    packs = read_json(pack_path)
    require(packs.get("version") == VERSION and packs.get("all_pass") is True and packs.get("runtime_sha256") == runtime
            and packs.get("git_head") == packs.get("runtime_freeze_commit") == candidate["request_commit"],
            "Exported pack tests refer to another runtime or checkout.")
    test = ROOT / "prototype/tests/test_exported_pack.gd"
    require(packs.get("test_script") == relative(test) and packs.get("test_script_sha256") == sha256(test),
            "Exported pack test changed after execution.")
    rows = packs.get("packs", [])
    require(len(rows) == 2 and {row.get("platform") for row in rows} == {"windows", "web"}, "Both final resource packs need their own test.")
    for row in rows:
        path = ROOT / ("builds/windows/TheTowerDescent.exe" if row["platform"] == "windows" else "builds/web/index.pck")
        require(row.get("pack") == relative(path) and row.get("pack_sha256") == sha256(path)
                and row.get("pack_bytes") == path.stat().st_size and row.get("execution_directory_was_empty") is True
                and row.get("pack_unchanged_during_test") is True, "Exported pack isolation or fingerprint differs.")
        check_log(row, suite=True, hash_key="log_sha256")
    require(packs.get("total_checks") == sum(row["checks"] for row in rows) > 0, "Exported pack check total differs.")
    with (ROOT / "builds/windows/TheTowerDescent.exe").open("rb") as executable:
        header = executable.read(64)
        require(len(header) == 64 and header[:2] == b"MZ", "Windows executable lacks a DOS header.")
        offset = struct.unpack_from("<I", header, 0x3C)[0]
        require(offset <= (ROOT / "builds/windows/TheTowerDescent.exe").stat().st_size - 6, "Invalid Windows PE offset.")
        executable.seek(offset)
        pe = executable.read(6)
        require(pe[:4] == b"PE\0\0" and struct.unpack_from("<H", pe, 4)[0] == 0x8664, "Windows executable is not PE x64.")
    return packs


def verify_captures(candidate: dict, runtime: dict) -> tuple[list[dict], dict]:
    renderers = candidate.get("renderers", {})
    require(set(renderers) == {"compatibility", "forward_plus"}, "Candidate renderer coverage is incomplete.")
    vulkan = read_json(VALIDATION / "CANDIDATE_VULKAN.json")
    require(type(vulkan.get("available")) is bool and isinstance(vulkan.get("reason"), str) and bool(vulkan["reason"].strip()),
            "Vulkan availability is undocumented.")
    if "probe" in vulkan:
        probe = vulkan["probe"]
        text = log_text(probe)
        observed = probe.get("returncode") == 0 and ("deviceName" in text or "GPU" in text)
        require(vulkan["available"] == observed and probe.get("pass") == observed, "Vulkan coverage differs from its retained probe.")
    else:
        require(vulkan["available"] is False and vulkan["reason"] == "vulkaninfo is unavailable; Forward+ was not attempted.",
                "A skipped Vulkan probe has no explicit unavailability reason.")
    available = vulkan["available"]
    require(candidate.get("all_requested_renderers_captured") == available
            and candidate["status"] == ("awaiting_visual_review" if available else "partial_renderer_coverage"),
            "Candidate status hides incomplete renderer coverage.")
    captures, native_files = [], set()
    coverage = {"compatibility": 18, "forward_plus": 3 if available else 0}
    for group, renderer in (("compatibility", "gl_compatibility"), ("forward_plus", "forward_plus")):
        entry = renderers[group]
        if coverage[group] == 0:
            require(entry.get("status") == "skipped_unavailable" and entry.get("capture_count") == 0
                    and entry.get("reason") == vulkan["reason"], "An attempted renderer failure cannot be treated as a skip.")
            continue
        require(entry.get("status") == "captured_awaiting_visual_review" and entry.get("capture_count") == coverage[group]
                and entry.get("rendering_method") == renderer, "Candidate capture count or renderer differs.")
        rows = candidate_tool.validate_capture_group(group, renderer)
        require(entry.get("captures") == rows, "Candidate PNG fingerprints changed.")
        destination = CAPTURES / group
        check_record(entry.get("provenance"), destination / "PROVENANCE.json")
        provenance = read_json(destination / "PROVENANCE.json")
        require(provenance.get("version") == VERSION and provenance.get("source_commit") == candidate["source_commit"]
                and provenance.get("request_commit") == candidate["request_commit"] and provenance.get("runtime_sha256") == runtime
                and provenance.get("rendering_method") == renderer and provenance.get("captures") == rows,
                "Capture provenance differs from the tested candidate.")
        require(provenance.get("prepared_states") is True and provenance.get("human_playthrough") is False
                and provenance.get("manual_visual_review") is False and provenance.get("approval_generated") is False,
                "Capture provenance misstates its review or playthrough status.")
        require(provenance.get("fixture") == candidate["fixture"], "Capture fixture differs from the candidate.")
        check_record(provenance.get("manifest"), destination / "MANIFEST.json")
        check_log(provenance["execution"])
        captures.extend(rows)
        native_files |= {local_file(row["file"]) for row in rows} | {destination / "MANIFEST.json", destination / "PROVENANCE.json"}
    actual_native = {path for path in (ROOT / "docs/captures/v0.12").rglob("*") if path.is_file()}
    require(actual_native == native_files, "The native evidence tree contains extra, stale or missing files.")
    visual = read_json(VALIDATION / "VISUAL_REVIEW.json")
    review_header(visual, candidate)
    require(visual.get("candidate_sha256") == sha256(VALIDATION / "CANDIDATE.json") and visual.get("runtime_sha256") == runtime
            and visual.get("prepared_states") is True and visual.get("human_playthrough") is False
            and visual.get("coverage") == coverage, "Visual review identifies another candidate or hides its method/coverage.")
    approved = visual.get("captures")
    check_records(approved, {local_file(row["file"]) for row in captures})
    for row in approved:
        reviewed_image(row)
    return captures, coverage


def verify_documents(candidate: dict) -> dict:
    review = read_json(VALIDATION / "DOCUMENT_REVIEW.json")
    review_header(review, candidate)
    check_records(review.get("sources"), {DOC_SOURCE})
    check_record(review.get("generator"), DOC_GENERATOR)
    check_records(review.get("artifacts"), {DOCX, PDF})
    require(review.get("page_count") == 9 and review.get("rendered_from_pdf_sha256") == sha256(PDF),
            "Document review refers to another PDF or page count.")
    pages = review.get("pages", [])
    require(isinstance(pages, list) and [row.get("page") for row in pages] == list(range(1, 10)),
            "Document review must approve exactly nine ordered pages.")
    expected = {DOCUMENT_PAGES / f"page-{page}.png" for page in range(1, 10)}
    check_records(pages, expected)
    require({path for path in DOCUMENT_PAGES.rglob("*") if path.is_file()} == expected, "Document page evidence has extra or missing files.")
    for row in pages:
        require(row["file"] == relative(DOCUMENT_PAGES / f"page-{row['page']}.png"), "Document page index differs from its file.")
        reviewed_image(row)
    path = VALIDATION / "DOCUMENT_CONTENT.json"
    check_record(review.get("content_verification"), path)
    content = read_json(path)
    fresh = verify_document_text(DOCX, PDF)
    for value in (content, fresh):
        require(value.get("schema") == 1 and value.get("tool") == "verify_document_content.py"
                and value.get("status") == "pass" and value.get("complete") is True,
                "Document content verification is incomplete.")
        require(value["docx"]["sha256"] == sha256(DOCX) and value["pdf"]["sha256"] == sha256(PDF)
                and value["pdf"].get("pages") == 9, "Document content report refers to other final artifacts.")
        counts = value["counts"]
        require(counts["ordered_blocks_matched"] == counts["ordered_blocks_checked"] > 0
                and counts["cells_matched_in_expected_row"] == counts["cells_checked"] > 0,
                "Document verification did not match every ordered block and table cell.")
    require(content["counts"] == fresh["counts"] and content["source_counts"] == fresh["source_counts"],
            "Retained content counts differ from the fresh read-only verification.")
    return {"page_count": 9, "counts": fresh["counts"], "review": record(VALIDATION / "DOCUMENT_REVIEW.json"),
            "content_verification": record(path), "fresh_content_verification_passed": True}


def verify_web() -> dict:
    web, dist = ROOT / "builds/web", ROOT / "dist"
    built = {path.relative_to(web).as_posix(): path for path in web.rglob("*") if path.is_file()}
    published = {path.relative_to(dist).as_posix(): path for path in dist.rglob("*") if path.is_file()}
    require(bool(built) and set(built) == set(published), "Web distribution has extra or missing files.")
    for name, path in built.items():
        require(path.stat().st_size == published[name].stat().st_size and sha256(path) == sha256(published[name]),
                "Web distribution differs from its frozen export: " + name)
    legal = {"GODOT_LICENSES.txt": ROOT / "docs/GODOT_LICENSES.txt",
             "OPEN_SANS_LICENSE.txt": ROOT / "prototype/assets/fonts/LICENSE.txt",
             "OPEN_SANS_NOTICE.txt": ROOT / "prototype/assets/fonts/NOTICE.txt"}
    for name, original in legal.items():
        require(name in built and sha256(built[name]) == sha256(original), "Web license is absent or changed: " + name)
    html = (dist / "index.html").read_text(encoding="utf-8")
    require("feat/live-tower-collapse" in html and "feat/tower-descent-prototype-bible" not in html, "Wrong source branch in Web shell.")
    match = re.search(r"(?:const|var) GODOT_CONFIG\s*=\s*(\{.*?\});", html, re.S)
    require(match is not None, "Web engine configuration is missing.")
    config = json.loads(match.group(1))
    sizes = config.get("fileSizes", {})
    require(isinstance(sizes, dict) and {"index.pck", "index.wasm"} <= set(sizes), "Web engine omits pack or WebAssembly sizes.")
    for name, size in sizes.items():
        require(name in built and built[name].stat().st_size == size, "Web configured size differs: " + name)
    return {"exact_export_mirror": True, "files": [record(path) for path in sorted(published.values())]}


def archive_maps(captures: list[dict], coverage: dict) -> tuple[dict[str, dict[str, Path]], dict]:
    prefix = "The-Tower-Descent/"
    source_paths = source_package_paths()
    original = {prefix + relative(path): path for path in source_paths}
    require(len(original) == len(source_paths), "Source contract contains duplicated members.")
    native_prefix = prefix + "docs/captures/v0.12/"
    native = {name: path for name, path in original.items() if name.startswith(native_prefix)}
    expected_native = {prefix + row["file"] for row in captures}
    expected_native |= {prefix + relative(CAPTURES / group / name) for group, count in coverage.items() if count
                        for name in ("MANIFEST.json", "PROVENANCE.json")}
    require(set(native) == expected_native, "Native ZIP scope differs from the explicitly reviewed images and manifests.")
    sources = {name: path for name, path in original.items() if name not in native}
    require(not set(sources) & set(native) and set(sources) | set(native) == set(original), "Source/native partition is not an exact disjoint union.")
    required = {relative(DOC_SOURCE), relative(DOC_GENERATOR), relative(DOCX), relative(PDF),
                "tools/verify_commerce_release.py", "tools/build_commerce_candidate.py", ".github/workflows/commerce-review.yml",
                relative(REQUEST), "docs/validation/v0.12/VISUAL_REVIEW.json", "docs/validation/v0.12/DOCUMENT_REVIEW.json",
                "docs/validation/v0.12/DOCUMENT_CONTENT.json", "docs/validation/v0.12/VERIFICATION.json",
                "docs/validation/v0.12/EXPORTED_PACK_VERIFICATION.json", "docs/validation/v0.12/CANDIDATE.json"}
    required |= set(runtime_hashes()) | {relative(path) for path in DOCUMENT_PAGES.glob("*.png")}
    require({prefix + name for name in required} <= set(sources), "Sources ZIP omits a required authored or reviewed input.")
    windows = {
        prefix + "TheTowerDescent.exe": ROOT / "builds/windows/TheTowerDescent.exe",
        prefix + "README.md": ROOT / "docs/DEMARRAGE_WINDOWS.md",
        prefix + "GODOT_LICENSES.txt": ROOT / "docs/GODOT_LICENSES.txt",
        prefix + "EXPORTS.md": ROOT / "docs/EXPORTS.md",
        prefix + "fonts/LICENSE.txt": ROOT / "prototype/assets/fonts/LICENSE.txt",
        prefix + "fonts/NOTICE.txt": ROOT / "prototype/assets/fonts/NOTICE.txt",
        prefix + "JOUER_CINEMATIQUE.cmd": ROOT / "docs/launchers/JOUER_CINEMATIQUE.cmd",
        prefix + "JOUER_COMPATIBILITE.cmd": ROOT / "docs/launchers/JOUER_COMPATIBILITE.cmd",
    }
    return {"Windows-x64": windows, "Sources": sources, "Captures-native": native}, {
        "original_source_members": len(original), "sources_members": len(sources), "native_members": len(native),
        "native_png_members": len(captures), "native_metadata_members": len(expected_native) - len(captures),
        "shared_extraction_root": prefix, "disjoint": True, "complete_original_source_union": True,
        "original_member_names_sha256": hashlib.sha256(json.dumps(sorted(original), separators=(",", ":")).encode()).hexdigest(),
    }


def verify_archives(captures: list[dict], coverage: dict) -> dict:
    maps, partition = archive_maps(captures, coverage)
    reports = []
    for role, expected in maps.items():
        path = ROOT / "releases" / f"The-Tower-Descent-v0.12-{role}.zip"
        require(path.is_file() and path.stat().st_size < MAX_ARCHIVE_BYTES, "Archive is missing or reaches the exclusive 100 MiB limit: " + path.name)
        contents = []
        with ZipFile(path) as archive:
            names = archive.namelist()
            require(len(names) == len(set(names)) and set(names) == set(expected), "ZIP members differ from their exact contract: " + path.name)
            require(archive.testzip() is None, "ZIP CRC failure: " + path.name)
            for name, original in sorted(expected.items()):
                require(not name.startswith("/") and ".." not in PurePosixPath(name).parts and "\\" not in name,
                        "Unsafe ZIP member.")
                info = archive.getinfo(name)
                require(not info.is_dir() and (info.external_attr >> 16) & 0o170000 != 0o120000, "ZIP contains a linked or directory member.")
                digest, size = hashlib.sha256(), 0
                with archive.open(name) as stream:
                    for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                        digest.update(chunk)
                        size += len(chunk)
                actual = record(original)
                require(size == actual["bytes"] and digest.hexdigest() == actual["sha256"], "Archived bytes differ: " + name)
                contents.append({"member": name, "source_file": actual["file"], "bytes": size, "sha256": actual["sha256"]})
        reports.append({**record(path), "role": role, "members": len(contents), "contents": contents,
                        "crc_and_exact_members_verified": True})
    checksums = ROOT / "releases/SHA256SUMS.txt"
    listed = {}
    for line in checksums.read_text(encoding="utf-8").splitlines():
        match = re.fullmatch(r"([0-9a-f]{64})  ([^/\\]+\.zip)", line)
        require(match is not None and match.group(2) not in listed, "Malformed or duplicate archive checksum row.")
        listed[match.group(2)] = match.group(1)
    actual_zips = {path.name: path for path in (ROOT / "releases").glob("*.zip")}
    require(set(listed) == set(actual_zips), "SHA256SUMS must cover every retained ZIP exactly once.")
    for name, path in actual_zips.items():
        require(listed[name] == sha256(path), "ZIP checksum mismatch: " + name)
    require({name for name in listed if name.startswith("The-Tower-Descent-v0.12-")} == {Path(row["file"]).name for row in reports},
            "Unexpected v0.12 archive in the checksum manifest.")
    return {"archives": reports, "partition": partition, "checksums": record(checksums),
            "max_archive_bytes_exclusive": MAX_ARCHIVE_BYTES}


def verify_evidence() -> tuple[dict, list[dict], dict]:
    runtime = runtime_hashes()
    candidate = verify_candidate(runtime)
    source = verify_source(candidate, runtime)
    packs = verify_exports(candidate, runtime)
    captures, coverage = verify_captures(candidate, runtime)
    document = verify_documents(candidate)
    require(runtime_hashes() == runtime, "Runtime changed during evidence verification.")
    result = {"version": VERSION, "source_commit": candidate["source_commit"], "request_commit": candidate["request_commit"],
              "verified_checkout": git_head(), "runtime_sha256": runtime,
              "candidate": record(VALIDATION / "CANDIDATE.json"), "request": record(REQUEST),
              "source_verification": record(VALIDATION / "VERIFICATION.json"),
              "export_verification": record(VALIDATION / "EXPORTED_PACK_VERIFICATION.json"),
              "export_construction": record(VALIDATION / "CANDIDATE_EXPORTS.json"),
              "visual_review": record(VALIDATION / "VISUAL_REVIEW.json"), "document": document,
              "runtime_checks": source["total_checks"], "exported_pack_checks": packs["total_checks"],
              "native_capture_count": len(captures), "renderer_coverage": coverage,
              "vulkan": record(VALIDATION / "CANDIDATE_VULKAN.json"),
              "human_playthrough": False, "approval_generated": False, "published": False,
              "limitations": ["Visual approval records an explicit assistant review of prepared native states.",
                              "Linux resource-pack checks do not execute Windows or browser WebAssembly.",
                              "Software-rendered captures do not establish player GPU performance."]}
    if coverage["forward_plus"] == 0:
        result["limitations"].append("Forward+ was unavailable according to its retained Vulkan probe; only Compatibility was visually reviewed.")
    return result, captures, coverage


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--evidence-only", action="store_true", help="Check the candidate and explicit reviews without ZIP/dist checks or report writes")
    parser.add_argument("--describe-reviews", action="store_true", help="Print the review contract without reading or creating a review")
    args = parser.parse_args()
    if args.describe_reviews:
        print(__doc__)
        return 0
    try:
        result, captures, coverage = verify_evidence()
        if args.evidence_only:
            print(json.dumps({"status": "EVIDENCE_PASS", "version": VERSION, "release_verified": False,
                              "runtime_checks": result["runtime_checks"], "exported_pack_checks": result["exported_pack_checks"],
                              "native_capture_count": len(captures), "document_pages": 9, "report_written": False}, indent=2))
            return 0
        result["web_distribution"] = verify_web()
        result.update(verify_archives(captures, coverage))
        require(runtime_hashes() == result["runtime_sha256"], "Runtime changed during archive verification.")
        result.update({"status": "PASS", "verified_utc": datetime.now(timezone.utc).isoformat(),
                       "verifier": record(Path(__file__).resolve()), "all_archive_members_and_bytes_verified": True})
        REPORT.parent.mkdir(parents=True, exist_ok=True)
        temporary = REPORT.with_suffix(".json.tmp")
        temporary.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        temporary.replace(REPORT)
        print(json.dumps({"status": "PASS", "version": VERSION, "report": relative(REPORT),
                          "runtime_checks": result["runtime_checks"], "exported_pack_checks": result["exported_pack_checks"],
                          "native_capture_count": len(captures), "document_pages": 9,
                          "archives": len(result["archives"]), "published": False}, indent=2))
        return 0
    except Exception as error:
        print("FAIL: " + str(error) + "; no release verification report was written or updated.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
