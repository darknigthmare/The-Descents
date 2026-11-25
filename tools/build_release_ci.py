#!/usr/bin/env python3
"""Build a frozen v0.9 candidate, then package it only after explicit visual review.

The GitHub workflow accepts a separate request-only commit. Review builds run the
actual source suites, native renderer, platform exports and document renderer.
Release builds reuse the approved screenshots and document bytes, rebuild and
verify the platform packs, and run every archive/provenance gate. No manual
review is inferred from an automated test result.
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
import tempfile
from zipfile import ZipFile

from qa_common import DOCUMENT_SOURCES, ROOT, git_head, godot_binary, run, runtime_hashes, sha256, version

BRANCH = "feat/live-tower-collapse"
VERSION = "0.9.0"
SHORT = "0.9"
REQUEST = ROOT / ".review/v0.9/build-request.json"
CAPTURE_REQUEST = ROOT / ".review/v0.9/request.json"
CANONICAL_DOCUMENT = ROOT / ".review/v0.9/canonical-document.json"
VALIDATION = ROOT / "docs/validation/v0.9"
CAPTURES = ROOT / "docs/captures/v0.9"
RENDERED = VALIDATION / "rendered"
BIBLE_DOCX = ROOT / "docs/The-Tower-Descent-Bible-v0.9.docx"
BIBLE_PDF = ROOT / "docs/The-Tower-Descent-Bible-v0.9.pdf"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit("FAIL: " + message)


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def git(*arguments: str) -> str:
    return subprocess.check_output(["git", *arguments], cwd=ROOT, text=True).strip()


def read_request() -> dict:
    data = json.loads(REQUEST.read_text(encoding="utf-8"))
    require(data.get("format") == 1 and data.get("version") == VERSION == version(), "Build request and project version disagree.")
    require(data.get("phase") in {"review", "release"}, "Unknown build phase.")
    require(bool(re.fullmatch(r"[a-zA-Z0-9][a-zA-Z0-9._-]{0,79}", data.get("request_id", ""))), "Invalid request identifier.")
    require(bool(re.fullmatch(r"[0-9a-f]{40}", data.get("source_commit", ""))), "Invalid source revision.")
    require(os.environ.get("GITHUB_REF", "refs/heads/" + BRANCH) == "refs/heads/" + BRANCH, "This workflow may only publish to its existing feature branch.")
    require(os.environ.get("GITHUB_SHA", git_head()) == git_head(), "Checkout differs from the requested workflow revision.")
    parent = git("rev-parse", "HEAD^")
    require(parent == data["source_commit"], "The request does not name its immediately preceding source revision.")
    changed = git("diff", "--name-only", "--no-renames", parent, "HEAD").splitlines()
    require(changed == [REQUEST.relative_to(ROOT).as_posix()], "Submit the build request in its own commit, after source and review changes.")
    return data


def tool(script: str, *arguments: str) -> None:
    subprocess.run([sys.executable, str(ROOT / "tools" / script), *arguments], cwd=ROOT, check=True)


def checked(command: list[str], log: Path, timeout: int = 240) -> dict:
    log.parent.mkdir(parents=True, exist_ok=True)
    entry = run(command, cwd=ROOT, timeout=timeout, log=log)
    entry["pass"] = entry["returncode"] == 0 and not entry["error_lines"]
    if not entry["pass"]:
        print(log.read_text(errors="replace")[-30000:], flush=True)
    require(entry["pass"], "Command failed or reported an engine error: " + " ".join(command))
    return entry


def record(path: Path) -> dict:
    return {"file": path.relative_to(ROOT).as_posix(), "bytes": path.stat().st_size, "sha256": sha256(path)}


def verify_canonical_document() -> dict:
    """Bind a prepared PDF to the fresh DOCX package and every authored input."""
    require(CANONICAL_DOCUMENT.is_file(), "The canonical document manifest is missing or is not a file.")
    prepared = json.loads(CANONICAL_DOCUMENT.read_text(encoding="utf-8"))
    require(isinstance(prepared, dict) and prepared.get("format") == 1 and
            prepared.get("version") == VERSION == version(), "Canonical document manifest format or version differs from this release.")
    rows = prepared.get("sources")
    require(isinstance(rows, list) and len(rows) == len(DOCUMENT_SOURCES) and
            all(isinstance(row, dict) and isinstance(row.get("file"), str) and
                isinstance(row.get("sha256"), str) for row in rows), "Canonical document manifest must identify all sixteen sources.")
    expected_sources = {row["file"]: row["sha256"] for row in rows}
    require(set(expected_sources) == set(DOCUMENT_SOURCES), "Canonical document source names are missing, duplicated or unexpected.")
    require(expected_sources == {name: sha256(ROOT / name) for name in DOCUMENT_SOURCES},
            "A Bible source changed after canonical PDF preparation.")
    require(prepared.get("build_bible_sha256") == sha256(ROOT / "tools/build_bible.py"),
            "The Bible generator differs from the canonical PDF preparation.")
    expected_members = prepared.get("docx_members")
    require(isinstance(expected_members, dict) and bool(expected_members), "Canonical document manifest omits the DOCX package members.")
    require(BIBLE_DOCX.is_file(), "The fresh Word document is missing.")
    with ZipFile(BIBLE_DOCX) as package:
        names = package.namelist()
        require(len(names) == len(set(names)), "The Word document contains duplicate ZIP members.")
        actual_members = {name: hashlib.sha256(package.read(name)).hexdigest() for name in names}
    require(set(actual_members) == set(expected_members), "The fresh Word package has missing or unexpected canonical members.")
    require(actual_members == expected_members, "The fresh Word package contents differ from the canonical PDF preparation.")
    require(BIBLE_PDF.is_file() and sha256(BIBLE_PDF) == prepared.get("pdf_sha256"),
            "The prepared canonical PDF is missing or its fingerprint differs from the manifest.")
    require(BIBLE_PDF.read_bytes()[:5] == b"%PDF-", "The prepared canonical document is not a PDF.")
    if "pdf_bytes" in prepared:
        require(BIBLE_PDF.stat().st_size == prepared["pdf_bytes"], "The prepared canonical PDF size differs from the manifest.")
    renderer = prepared.get("canonical_renderer")
    require(isinstance(renderer, dict) and all(isinstance(renderer.get(key), str) and renderer[key].strip()
            for key in ("script", "libreoffice", "method")), "Canonical renderer provenance is incomplete.")
    if "script_sha256" in renderer:
        require(isinstance(renderer["script_sha256"], str) and bool(re.fullmatch(r"[0-9a-f]{64}", renderer["script_sha256"])),
                "Canonical renderer script fingerprint is malformed.")
    require(isinstance(prepared.get("created_utc"), str) and bool(prepared["created_utc"].strip()),
            "Canonical document preparation time is missing.")
    return prepared


def canonical_document_renderer(prepared: dict) -> dict:
    return {
        "method": "Fresh repository DOCX matched against every prepared package member; canonical PDF retained unchanged; CI Poppler PNG rendering at 2000 px.",
        "pdf_preparation": "prepared_canonical_document",
        "libreoffice": prepared["canonical_renderer"]["libreoffice"],
        "canonical_renderer": prepared["canonical_renderer"],
        "canonical_source_provenance": {
            "created_utc": prepared["created_utc"],
            "build_bible_sha256": prepared["build_bible_sha256"],
            "origin": prepared.get("origin"), "reason": prepared.get("reason"),
        },
        "rasterizer": "CI Poppler pdftoppm -png -scale-to 2000",
        "requested_body_font": "Arial",
        "font_report": "docs/validation/v0.9/document-fonts.txt",
        "canonical_local_skill_renderer_used": True,
    }


def install_templates() -> None:
    destination = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))) / "godot/export_templates/4.7.2.stable"
    tool("fetch_export_templates.py", "--version", "4.7.2-stable", "--destination", str(destination))
    pinned = json.loads((ROOT / "docs/EXPORT_TEMPLATE_PROVENANCE.json").read_text())
    require(pinned["version"] == "4.7.2-stable", "Template provenance version changed.")
    require({row["name"] for row in pinned["files"]} == {"version.txt", "web_nothreads_release.zip", "windows_release_x86_64.exe"}, "Template provenance is incomplete.")
    for row in pinned["files"]:
        path = destination / row["name"]
        require(path.stat().st_size == row["size"] and sha256(path) == row["sha256"], "The official export template differs from its pinned file fingerprint: " + row["name"])
    write_json(VALIDATION / "TEMPLATES.json", {
        "version": VERSION, "engine_version": "4.7.2.stable",
        "source_provenance": "docs/EXPORT_TEMPLATE_PROVENANCE.json",
        "source_provenance_sha256": sha256(ROOT / "docs/EXPORT_TEMPLATE_PROVENANCE.json"),
        "files": pinned["files"], "template_file_sha256_verified": True,
        "complete_archive_sha256_verified": False,
    })


def export_packs(binary: str, captured_source_commit: str) -> None:
    verified = json.loads((VALIDATION / "VERIFICATION.json").read_text())
    before = runtime_hashes()
    require(verified["all_pass"] and verified["version"] == VERSION and verified["sha256_after"] == before, "The final runtime has no matching passing source verification.")
    install_templates()
    windows = ROOT / "builds/windows"
    web = ROOT / "builds/web"
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
                        VALIDATION / ("export-" + platform + ".txt"), timeout=360)
        entry["platform"] = platform
        exports.append(entry)
    require((windows / "TheTowerDescent.exe").read_bytes()[:2] == b"MZ", "Windows export is not an executable.")
    require((web / "index.pck").is_file() and (web / "index.wasm").is_file(), "Web export is incomplete.")
    distribution = ROOT / "dist"
    if distribution.exists():
        shutil.rmtree(distribution)
    shutil.copytree(web, distribution)
    shutil.copy2(ROOT / "docs/GODOT_LICENSES.txt", distribution / "GODOT_LICENSES.txt")
    for name in ["LICENSE", "NOTICE"]:
        shutil.copy2(ROOT / "prototype/assets/fonts" / (name + ".txt"), distribution / ("OPEN_SANS_" + name + ".txt"))
    after = runtime_hashes()
    require(before == after, "An export modified the tested authored runtime.")
    outputs = [record(windows / "TheTowerDescent.exe")]
    outputs.extend(record(path) for path in sorted(web.iterdir()) if path.is_file())
    outputs.extend(record(path) for path in sorted(distribution.iterdir()) if path.is_file())
    write_json(VALIDATION / "EXPORTS.json", {
        "version": VERSION, "all_pass": True, "built_utc": datetime.now(timezone.utc).isoformat(),
        "build_commit": git_head(), "captured_source_commit": captured_source_commit,
        "source_verification_sha256": sha256(VALIDATION / "VERIFICATION.json"),
        "runtime_sha256_before": before, "runtime_sha256_after": after,
        "engine": subprocess.check_output([binary, "--version"], text=True).strip(),
        "exports": exports, "outputs": outputs,
        "limitations": ["Exports are built on Linux. The separate resource-pack checks do not execute Windows or WebAssembly."],
    })
    tool("verify_exported_packs.py", "--godot", binary)


def capture(binary: str) -> None:
    if CAPTURES.exists():
        shutil.rmtree(CAPTURES)
    CAPTURES.mkdir(parents=True)
    tool("capture_evidence.py", "request", "--request", str(CAPTURE_REQUEST))
    checked([
        "xvfb-run", "-a", "-s", "-screen 0 1440x900x24", binary,
        "--path", str(ROOT / "prototype"), "--rendering-method", "gl_compatibility",
        "--rendering-driver", "opengl3", "--audio-driver", "Dummy", "--resolution", "1440x900",
        "res://tests/visual_frontend_preview.tscn", "--", "--capture-root=" + str(CAPTURES),
    ], VALIDATION / "native-render.txt", timeout=600)
    tool("capture_evidence.py", "verify", "--request", str(CAPTURE_REQUEST), "--capture-root", str(CAPTURES),
         "--log", str(VALIDATION / "native-render.txt"))



def build_review_derivatives() -> None:
    """Expose large captures to review tools without replacing the native PNGs."""
    from PIL import Image

    provenance_path = CAPTURES / "CI_PROVENANCE.json"
    provenance = json.loads(provenance_path.read_text(encoding="utf-8"))
    require(provenance["version"] == VERSION and provenance["source_commit"] == git_head(),
            "Review derivatives require this build's verified native captures.")
    threshold = 900_000
    destination = CAPTURES / "review_jpeg"
    if destination.exists():
        shutil.rmtree(destination)
    destination.mkdir()
    derivatives = []
    for capture_row in provenance["captures"]:
        source = CAPTURES / capture_row["file"]
        require(source.stat().st_size == capture_row["bytes"] and sha256(source) == capture_row["sha256"],
                "Native capture changed before review conversion: " + capture_row["file"])
        if source.stat().st_size <= threshold:
            continue
        output = destination / (source.stem + ".jpg")
        with Image.open(source) as original:
            original.load()
            require(original.format == "PNG" and original.size == (1440, 900),
                    "Review conversion received an unexpected native image.")
            require(original.mode in {"RGB", "RGBA"}, "Review conversion requires a true-color native capture.")
            if original.mode == "RGBA":
                require(original.getextrema()[3] == (255, 255),
                        "Review conversion would discard native transparency.")
            with original.convert("RGB") as converted:
                converted.save(output, format="JPEG", quality=95, subsampling=0, optimize=True, progressive=False)
        with Image.open(output) as decoded:
            decoded.load()
            require(decoded.format == "JPEG" and decoded.size == (1440, 900),
                    "A review derivative changed the native dimensions.")
        require(output.stat().st_size < 1_000_000,
                "A full-resolution quality-95 derivative is still too large for the review file reader.")
        require(sha256(source) == capture_row["sha256"], "Review conversion modified its native PNG.")
        derivatives.append({
            "source_file": capture_row["file"], "source_bytes": capture_row["bytes"],
            "source_sha256": capture_row["sha256"],
            "file": output.relative_to(CAPTURES).as_posix(), "bytes": output.stat().st_size,
            "sha256": sha256(output), "width": 1440, "height": 900,
        })
    write_json(CAPTURES / "REVIEW_DERIVATIVES.json", {
        "format": 1, "version": VERSION, "source_commit": provenance["source_commit"],
        "source_provenance": "CI_PROVENANCE.json", "source_provenance_sha256": sha256(provenance_path),
        "built_utc": datetime.now(timezone.utc).isoformat(),
        "selection": {"native_png_bytes_strictly_greater_than": threshold},
        "conversion": {"format": "JPEG", "quality": 95, "chroma_subsampling": "4:4:4",
                       "resize": False, "crop": False, "lossy": True},
        "derivatives": derivatives, "manual_visual_review": False,
        "limitations": [
            "These full-size JPEG derivatives support visual inspection in file readers that cannot return PNGs above 1 MiB.",
            "JPEG is lossy. The original PNGs and CI_PROVENANCE.json remain the authoritative capture evidence.",
            "Derivative generation does not approve a visual review or change any PNG release gate.",
        ],
    })

def build_documents() -> None:
    from build_bible import PARTS

    require(tuple("docs/" + part[0] for part in PARTS) == DOCUMENT_SOURCES, "Bible builder does not include exactly the sixteen required sources in order.")
    sources = [record(ROOT / name) for name in DOCUMENT_SOURCES]
    tool("build_bible.py", "--output", str(BIBLE_DOCX))
    prepared = None
    preparation_record = None
    if CANONICAL_DOCUMENT.exists():
        prepared = verify_canonical_document()
        preparation_record = record(CANONICAL_DOCUMENT)
    if RENDERED.exists():
        shutil.rmtree(RENDERED)
    RENDERED.mkdir(parents=True)
    if prepared is not None:
        renderer = canonical_document_renderer(prepared)
        (VALIDATION / "document-conversion.txt").write_text(
            "Prepared canonical PDF retained byte-for-byte; no CI LibreOffice conversion was performed.\n"
            + json.dumps({"manifest": preparation_record, "renderer": renderer}, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8")
    else:
        with tempfile.TemporaryDirectory(prefix="tower-v09-document-") as temporary:
            directory = Path(temporary)
            converted = directory / "pdf"
            converted.mkdir()
            checked([
                "libreoffice", "-env:UserInstallation=" + (directory / "profile").as_uri(),
                "--headless", "--convert-to", "pdf:writer_pdf_Export", "--outdir", str(converted), str(BIBLE_DOCX),
            ], VALIDATION / "document-conversion.txt", timeout=360)
            produced = converted / BIBLE_PDF.name
            require(produced.is_file() and produced.read_bytes()[:5] == b"%PDF-", "LibreOffice did not produce the requested PDF.")
            shutil.copy2(produced, BIBLE_PDF)
        renderer = {
            "method": "Repository DOCX builder, LibreOffice PDF conversion, Poppler PNG rendering at 2000 px.",
            "libreoffice": subprocess.check_output(["libreoffice", "--version"], text=True).strip(),
            "requested_body_font": "Arial", "resolved_body_font": subprocess.check_output(["fc-match", "Arial", "--format=%{family}"], text=True).strip(),
            "font_report": "docs/validation/v0.9/document-fonts.txt",
            "canonical_local_skill_renderer_used": False,
        }
    info = subprocess.check_output(["pdfinfo", str(BIBLE_PDF)], text=True)
    match = re.search(r"^Pages:\s+(\d+)", info, re.M)
    require(match is not None, "The rendered PDF has no readable page count.")
    page_count = int(match.group(1))
    require(page_count > 0, "The rendered PDF is empty.")
    if prepared is not None and "page_count" in prepared:
        require(page_count == prepared["page_count"], "The canonical PDF page count differs from its preparation manifest.")
    checked(["pdftoppm", "-png", "-scale-to", "2000", str(BIBLE_PDF), str(RENDERED / "page")],
            VALIDATION / "document-pages.txt", timeout=360)
    checked(["pdftotext", "-layout", str(BIBLE_PDF), str(RENDERED / "document.txt")],
            VALIDATION / "document-text.txt")
    # A converter can exit successfully while silently dropping continued rows.
    # Compare the actual ordered DOCX content before recording a review candidate.
    tool("verify_document_content.py", "--docx", str(BIBLE_DOCX), "--pdf", str(BIBLE_PDF),
         "--output", str(VALIDATION / "DOCUMENT_CONTENT.json"))
    font_report = subprocess.check_output(["pdffonts", str(BIBLE_PDF)], text=True)
    (VALIDATION / "document-fonts.txt").write_text(font_report, encoding="utf-8")
    paths = sorted(RENDERED.glob("page-*.png"), key=lambda path: int(path.stem.rsplit("-", 1)[1]))
    require(len(paths) == page_count, "Poppler did not render every PDF page.")
    pages = []
    for index, path in enumerate(paths, start=1):
        require(int(path.stem.rsplit("-", 1)[1]) == index, "Document pages are missing or duplicated.")
        data = path.read_bytes()
        require(data[:8] == b"\x89PNG\r\n\x1a\n" and data[12:16] == b"IHDR", "A rendered document page is not a PNG.")
        width, height = struct.unpack(">II", data[16:24])
        require(height == 2000 and 1400 <= width <= 1430, "Document page no longer has the expected A4 portrait shape.")
        pages.append({"page": index, **record(path), "width": width, "height": height})
    require(sources == [record(ROOT / name) for name in DOCUMENT_SOURCES], "The Bible source changed during document construction.")
    if prepared is not None:
        require(record(CANONICAL_DOCUMENT) == preparation_record and verify_canonical_document() == prepared,
                "Canonical document inputs changed during CI page rendering.")
    text_pages = (RENDERED / "document.txt").read_text().split("\f")
    if text_pages and not text_pages[-1].strip():
        text_pages.pop()
    for row, page_text in zip(pages, text_pages):
        row["text_characters"] = len(page_text.strip())
    write_json(VALIDATION / "DOCUMENT_BUILD.json", {
        "version": VERSION, "source_commit": git_head(), "built_utc": datetime.now(timezone.utc).isoformat(),
        "source_count": len(sources), "source_words": sum(len((ROOT / name).read_text().split()) for name in DOCUMENT_SOURCES),
        "sources": sources, "artifacts": [record(BIBLE_DOCX), record(BIBLE_PDF)],
        "content_verification": record(VALIDATION / "DOCUMENT_CONTENT.json"),
        **({"canonical_document": preparation_record} if preparation_record is not None else {}),
        "page_count": page_count, "pages": pages,
        "manual_visual_review": False,
        "renderer": renderer,
        "limitations": ["A successful conversion and page count do not approve visual layout. Every final page requires a separate visual review."],
    })


def verify_reviews() -> None:
    from capture_evidence import EXPECTED_CAPTURES

    source = json.loads((VALIDATION / "VERIFICATION.json").read_text())
    require(source["all_pass"] and source["sha256_after"] == runtime_hashes(), "Runtime changed after source validation.")
    provenance = json.loads((CAPTURES / "CI_PROVENANCE.json").read_text())
    visual = json.loads((VALIDATION / "VISUAL_REVIEW.json").read_text())
    require(visual.get("all_pass") is True and visual.get("source_commit") == provenance["source_commit"], "The native captures do not have a matching completed visual review.")
    require(len(visual.get("captures", [])) == len(EXPECTED_CAPTURES) and
            all(row.get("status") == "pass" for row in visual["captures"]), "A native capture lacks its individual visual approval.")
    require({row["file"] for row in provenance["captures"]} == EXPECTED_CAPTURES, "The native capture set is incomplete.")
    require({row["file"]: row["sha256"] for row in visual["captures"]} ==
            {row["file"]: row["sha256"] for row in provenance["captures"]}, "Visual review does not cover the exact final capture set.")
    require(provenance["runtime_sha256"] == runtime_hashes(), "Native capture runtime is stale.")
    for row in provenance["captures"]:
        require(sha256(CAPTURES / row["file"]) == row["sha256"], "A reviewed native capture changed.")
    document = json.loads((VALIDATION / "DOCUMENT_REVIEW.json").read_text())
    built = json.loads((VALIDATION / "DOCUMENT_BUILD.json").read_text())
    if built.get("canonical_document") is not None:
        prepared = verify_canonical_document()
        require(built["canonical_document"] == record(CANONICAL_DOCUMENT), "The canonical preparation manifest changed after document construction.")
        require(built["renderer"] == canonical_document_renderer(prepared), "Canonical document renderer provenance changed after construction.")
        if "page_count" in prepared:
            require(built["page_count"] == prepared["page_count"], "Reviewed canonical document page count differs from its preparation.")
    else:
        require(not CANONICAL_DOCUMENT.exists() and built["renderer"].get("canonical_local_skill_renderer_used") is False,
                "The document build does not record its canonical preparation manifest.")
    require(document.get("all_pass") is True and built["version"] == VERSION, "The document is not fully reviewed.")
    require(document.get("source_commit") == built["source_commit"], "The document review identifies a different construction revision.")
    require(document["source_count"] == len(DOCUMENT_SOURCES) and {row["file"] for row in document["sources"]} == set(DOCUMENT_SOURCES), "Document review omits a Bible source.")
    require(document["page_count"] == built["page_count"] and
            [row["page"] for row in document["pages"]] == list(range(1, built["page_count"] + 1)), "Document review omits or duplicates pages.")
    require(all(row["status"] == "pass" for row in document["pages"]), "A document page has unresolved findings.")
    require({row["page"]: row["sha256"] for row in document["pages"]} ==
            {row["page"]: row["sha256"] for row in built["pages"]}, "Document review does not refer to the final rendered pages.")
    for category in ["sources", "artifacts"]:
        require({row["file"]: row["sha256"] for row in document[category]} ==
                {row["file"]: row["sha256"] for row in built[category]}, "Reviewed document differs from its build.")
        for row in built[category]:
            require(sha256(ROOT / row["file"]) == row["sha256"], "A reviewed document source or artifact changed.")
    require({row["file"] for row in document["artifacts"]} ==
            {BIBLE_DOCX.relative_to(ROOT).as_posix(), BIBLE_PDF.relative_to(ROOT).as_posix()}, "Both Word and PDF require review.")
    from verify_document_content import verify as verify_document_content
    content = verify_document_content(BIBLE_DOCX, BIBLE_PDF)
    require(content["complete"], "The reviewed PDF no longer contains the complete ordered Word text.")


def build(binary: str, request: dict) -> None:
    VALIDATION.mkdir(parents=True, exist_ok=True)
    before = runtime_hashes()
    engine = subprocess.check_output([binary, "--version"], text=True).strip()
    require(engine.startswith("4.7.2.stable.official"), "The review runner does not use the pinned Godot release.")
    if request["phase"] == "review":
        for name in ["VISUAL_REVIEW.json", "DOCUMENT_REVIEW.json"]:
            (VALIDATION / name).unlink(missing_ok=True)
        tool("run_validation.py", "--godot", binary)
        require(runtime_hashes() == before, "Import or source tests modified authored runtime files.")
        export_packs(binary, git_head())
        capture(binary)
        build_review_derivatives()
        build_documents()
    else:
        verify_reviews()
        checked([binary, "--headless", "--path", str(ROOT / "prototype"), "--editor", "--import", "--quit"],
                VALIDATION / "release-import.txt", timeout=180)
        provenance = json.loads((CAPTURES / "CI_PROVENANCE.json").read_text())
        export_packs(binary, provenance["source_commit"])
    require(before == runtime_hashes(), "The pipeline changed the frozen authored runtime.")
    write_json(VALIDATION / "CI_BUILD.json", {
        "version": VERSION, "phase": request["phase"], "request_id": request["request_id"],
        "source_commit": git_head(), "source_parent_commit": request["source_commit"],
        "run_url": f'https://github.com/{os.environ.get("GITHUB_REPOSITORY", "darknigthmare/The-Descents")}/actions/runs/{os.environ.get("GITHUB_RUN_ID", "local")}',
        "completed_utc": datetime.now(timezone.utc).isoformat(),
        "runtime_sha256": before, "automated_steps_passed": True,
        "manual_visual_review_required": request["phase"] == "review",
        "archive_verification_report": "releases/VERIFICATION_V0.9.json" if request["phase"] == "release" else None,
        "pipeline_sha256": sha256(Path(__file__)),
    })
    if request["phase"] == "release":
        tool("package_release.py")
        result = subprocess.run([sys.executable, str(ROOT / "tools/verify_release.py")], cwd=ROOT,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        print(result.stdout, flush=True)
        require(result.returncode == 0, "Release verification failed.")
        report = json.loads(result.stdout)
        require(report.get("status") == "PASS", "Release verifier did not return PASS.")
        write_json(ROOT / "releases/VERIFICATION_V0.9.json", report)
    print(json.dumps({"phase": request["phase"], "automated_steps_passed": True, "manual_visual_review_required": request["phase"] == "review"}), flush=True)


def publish(request: dict) -> None:
    require(os.environ.get("GITHUB_ACTIONS") == "true", "Publication is restricted to the repository's configured Actions runner.")
    target = "refs/heads/" + BRANCH
    expected = os.environ["GITHUB_SHA"]
    current = git("ls-remote", "origin", target).split()[0]
    if current != expected:
        print("The branch advanced. Generated files remain available in the workflow artifact; no branch update was attempted.")
        return
    require(git_head() == expected, "The publication checkout advanced unexpectedly.")
    paths = ["docs/validation/v0.9"]
    if request["phase"] == "review":
        paths += ["docs/captures/v0.9", "docs/The-Tower-Descent-Bible-v0.9.docx",
                  "docs/The-Tower-Descent-Bible-v0.9.pdf", ".review/v0.9/request.json"]
        # Godot assigns stable identifiers to newly imported authored resources.
        for value in git("ls-files", "--others", "--exclude-standard", "--", "prototype").splitlines():
            if value.endswith(".uid"):
                paths.append(value)
    else:
        paths += ["dist", "releases/The-Tower-Descent-v0.9-Windows-x64.zip",
                  "releases/The-Tower-Descent-v0.9-Sources.zip", "releases/SHA256SUMS.txt",
                  "releases/VERIFICATION_V0.9.json"]
    subprocess.run(["git", "add", "--", *paths], cwd=ROOT, check=True)
    staged = git("diff", "--cached", "--name-only").splitlines()
    require(all(any(name == path or name.startswith(path + "/") for path in paths) for name in staged), "Unexpected staged path outside generated outputs.")
    if not staged:
        print("The verified generated files are already committed.")
        return
    git("config", "user.name", "github-actions[bot]")
    git("config", "user.email", "41898282+github-actions[bot]@users.noreply.github.com")
    git("commit", "-m", "Build v0.9 " + request["phase"] + " evidence from frozen source " + expected[:12])
    result = subprocess.run(["git", "push", "origin", "HEAD:" + target], cwd=ROOT)
    if result.returncode:
        current = git("ls-remote", "origin", target).split()[0]
        require(current != expected, "Publication failed while the requested branch remained unchanged.")
        print("The branch changed during publication. No force push was attempted; use the retained workflow artifact.")
    else:
        print("Verified generated files committed to the existing feature branch.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["guard", "build", "publish"])
    parser.add_argument("--godot")
    args = parser.parse_args()
    request = read_request()
    if args.action == "guard":
        print(json.dumps({"version": VERSION, "phase": request["phase"], "source_parent": request["source_commit"]}))
    elif args.action == "build":
        build(godot_binary(args.godot), request)
    else:
        publish(request)


if __name__ == "__main__":
    main()
