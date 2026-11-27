#!/usr/bin/env python3
"""Fail when DOCX body text disappears from its exported PDF.

Usage: verify_document_content.py --docx FILE --pdf FILE --output REPORT.json

Only the Python standard library and Poppler's pdftotext are required. This is a
text-completeness gate, not a substitute for reviewing the rendered pages.
"""

from __future__ import annotations

import argparse
import bisect
import hashlib
import io
import json
import re
import shutil
import subprocess
import sys
import unicodedata
import xml.etree.ElementTree as ET
import zipfile
from datetime import datetime, timezone
from pathlib import Path


W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
LIMITATIONS = [
    "Unicode NFKC, case folding and removal of non-alphanumeric characters make "
    "line wrapping, spacing and punctuation differences insignificant. This "
    "check therefore does not certify punctuation, signs, units or typography.",
    "Ordered matching preserves the multiplicity of source paragraphs and table "
    "rows. Each cell and its paragraphs are checked inside its matched row; a "
    "copy of the same text elsewhere cannot validate a missing row.",
    "Extra PDF text, including repeated table headings, is allowed. This is a "
    "source-content inclusion check, not a byte-for-byte or semantic comparison.",
    "DOCX running headers, footers and page fields are excluded from body-text "
    "matching. Images, drawing content and hyperlink destinations require other "
    "checks. Nested tables or unenumerated body paragraphs fail closed.",
    "A successful text check does not prove that text is visible, unclipped or "
    "legible. A separate visual review of every final page remains required.",
]


def normalize(text: str) -> str:
    return "".join(
        char for char in unicodedata.normalize("NFKC", text).casefold()
        if char.isalnum()
    )


def paragraph_text(node: ET.Element) -> str:
    # Includes ordinary runs and hyperlink text, unlike Paragraph.text in some
    # python-docx versions. Tabs and explicit breaks disappear in normalization.
    return "".join(part.text or "" for part in node.iter(W + "t"))


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_source(data: bytes) -> dict:
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        document = ET.fromstring(archive.read("word/document.xml"))
        body = document.find(W + "body")
        if body is None:
            raise ValueError("The DOCX has no document body")
        if body.findall(".//" + W + "tc//" + W + "tbl"):
            raise ValueError("Nested tables require a dedicated reading-order check")

        margins = {"header": [], "footer": []}
        for name in archive.namelist():
            match = re.fullmatch(r"word/(header|footer)\d+\.xml", name)
            if not match:
                continue
            for paragraph in ET.fromstring(archive.read(name)).iter(W + "p"):
                # Static prefix before PAGE/NUMPAGES; dynamic field results are
                # deliberately not mistaken for body text or fixed page counts.
                parts = []
                for item in paragraph.iter():
                    if item.tag in (W + "fldChar", W + "fldSimple"):
                        break
                    if item.tag == W + "t":
                        parts.append(item.text or "")
                prefix = normalize("".join(parts))
                if prefix:
                    margins[match.group(1)].append(prefix)

    flow = []
    heading = []
    paragraph_count = cell_paragraph_count = table_count = row_count = cell_count = 0
    punctuation_only = 0
    for block_number, node in enumerate(body, 1):
        if node.tag == W + "p":
            text = paragraph_text(node)
            if not text.strip():
                continue
            paragraph_count += 1
            style_node = node.find(W + "pPr/" + W + "pStyle")
            style = style_node.get(W + "val", "") if style_node is not None else ""
            if re.search(r"Heading|Titre", style, re.IGNORECASE):
                level_match = re.search(r"\d+", style)
                level = int(level_match.group()) if level_match else 1
                heading = [part for part in heading if part[0] < level] + [(level, text)]
            key = normalize(text)
            if not key:
                punctuation_only += 1
            flow.append({
                "id": f"p{paragraph_count}", "kind": "paragraph",
                "block": block_number, "paragraph": paragraph_count,
                "heading": [part[1] for part in heading], "text": text, "key": key,
            })
        elif node.tag == W + "tbl":
            table_count += 1
            for row_number, row in enumerate(node.findall(W + "tr"), 1):
                cells = []
                for column, cell in enumerate(row.findall(W + "tc"), 1):
                    paragraphs = [
                        paragraph_text(paragraph) for paragraph in cell.iter(W + "p")
                        if paragraph_text(paragraph).strip()
                    ]
                    cell_paragraph_count += len(paragraphs)
                    text = "\n".join(paragraphs)
                    if text.strip():
                        cell_count += 1
                    cells.append({
                        "id": f"t{table_count}r{row_number}c{column}",
                        "column": column, "text": text, "key": normalize(text),
                        "paragraphs": paragraphs,
                    })
                text = " ".join(cell["text"] for cell in cells)
                if not text.strip():
                    continue
                row_count += 1
                flow.append({
                    "id": f"t{table_count}r{row_number}", "kind": "table_row",
                    "block": block_number, "table": table_count, "row": row_number,
                    "heading": [part[1] for part in heading],
                    "text": text, "key": normalize(text), "cells": cells,
                })

    actual_paragraphs = sum(
        bool(paragraph_text(node).strip()) for node in body.iter(W + "p")
    )
    if actual_paragraphs != paragraph_count + cell_paragraph_count:
        raise ValueError(
            "Unsupported body structure: some paragraphs were not enumerated "
            f"({actual_paragraphs} present, {paragraph_count + cell_paragraph_count} checked)"
        )
    return {
        "flow": flow, "margins": margins,
        "counts": {
            "body_paragraphs": paragraph_count,
            "cell_paragraphs": cell_paragraph_count,
            "all_paragraphs": actual_paragraphs,
            "tables": table_count, "nonempty_table_rows": row_count,
            "nonempty_cells": cell_count, "ordered_blocks": len(flow),
            "punctuation_only_body_paragraphs": punctuation_only,
        },
    }


def clean_pages(text: str, margins: dict) -> tuple[list[str], int]:
    pages = text.split("\f")
    if pages and not pages[-1].strip():
        pages.pop()
    if not pages or not any(page.strip() for page in pages):
        raise ValueError("pdftotext produced no text")
    cleaned = []
    removed = 0
    for number, page in enumerate(pages, 1):
        lines = [line for line in page.splitlines() if line.strip()]
        kept = []
        # Content-stream order varies by LibreOffice version: raw extraction
        # can place both running header and footer before the page body.
        margin_lines = lines[:8] + lines[-8:]
        has_footer = any(
            normalize(line).startswith(prefix)
            for line in margin_lines for prefix in margins["footer"]
        )
        for index, line in enumerate(lines):
            key = normalize(line)
            header = index < 6 and key in margins["header"]
            at_margin = index < 8 or index >= len(lines) - 8
            footer = at_margin and any(
                key == prefix or key == prefix + f"{number}{len(pages)}"
                for prefix in margins["footer"]
            )
            page_field = (
                has_footer and at_margin
                and re.fullmatch(rf"\s*{number}\s*/\s*{len(pages)}\s*", line)
            )
            if header or footer or page_field:
                removed += 1
            else:
                kept.append(line)
        cleaned.append(normalize("\n".join(kept)))
    return cleaned, removed


def compare(source: dict, pages: list[str]) -> dict:
    full = "".join(pages)
    page_ends = []
    end = 0
    for page in pages:
        end += len(page)
        page_ends.append(end)

    counts = {
        "ordered_blocks_checked": 0, "ordered_blocks_matched": 0,
        "body_paragraphs_checked": 0, "body_paragraphs_matched": 0,
        "table_rows_checked": 0, "table_rows_matched": 0,
        "cells_checked": 0, "cells_matched_in_expected_row": 0,
        "cell_paragraphs_checked": 0, "cell_paragraphs_matched_in_expected_cell": 0,
        "cell_texts_absent_everywhere": 0,
    }
    failures = []
    matches = []
    cursor = 0
    for unit in source["flow"]:
        counts["ordered_blocks_checked"] += 1
        category = "body_paragraphs" if unit["kind"] == "paragraph" else "table_rows"
        counts[category + "_checked"] += 1
        start = full.find(unit["key"], cursor) if unit["key"] else cursor
        found = start >= 0
        if found:
            end = start + len(unit["key"])
            page_range = [bisect.bisect_right(page_ends, start) + 1,
                          bisect.bisect_left(page_ends, end) + 1]
            counts["ordered_blocks_matched"] += 1
            counts[category + "_matched"] += 1
            matches.append({"id": unit["id"], "pages": page_range,
                            "normalized_characters": len(unit["key"])})
            cursor = end
        else:
            failures.append({
                key: value for key, value in unit.items()
                if key not in ("key", "cells")
            } | {
                "reason": "Source block not found in PDF after the preceding matched block",
                "search_from_normalized_offset": cursor,
                "last_matched_block": matches[-1] if matches else None,
            })

        if unit["kind"] != "table_row":
            continue
        row_text = full[start:start + len(unit["key"])] if found else ""
        local_cursor = 0
        for cell in unit["cells"]:
            if not cell["text"].strip():
                continue
            counts["cells_checked"] += 1
            global_present = cell["key"] in full
            counts["cell_texts_absent_everywhere"] += not global_present
            position = row_text.find(cell["key"], local_cursor) if found else -1
            cell_found = position >= 0
            if cell_found:
                counts["cells_matched_in_expected_row"] += 1
                local_cursor = position + len(cell["key"])
            else:
                failures.append({
                    "id": cell["id"], "kind": "table_cell", "table": unit["table"],
                    "row": unit["row"], "column": cell["column"],
                    "heading": unit["heading"], "text": cell["text"],
                    "reason": "Cell is absent from its expected ordered table row",
                    "same_text_exists_elsewhere": global_present,
                })
            cell_text = row_text[position:position + len(cell["key"])] if cell_found else ""
            paragraph_cursor = 0
            for paragraph_number, text in enumerate(cell["paragraphs"], 1):
                counts["cell_paragraphs_checked"] += 1
                key = normalize(text)
                position = cell_text.find(key, paragraph_cursor) if cell_found else -1
                if position >= 0:
                    counts["cell_paragraphs_matched_in_expected_cell"] += 1
                    paragraph_cursor = position + len(key)
                elif cell_found:
                    failures.append({
                        "id": f"{cell['id']}p{paragraph_number}", "kind": "cell_paragraph",
                        "text": text, "reason": "Paragraph missing from its matched cell",
                    })
    return {
        "complete": not failures, "counts": counts,
        "missing_ordered_blocks": [f for f in failures if f["kind"] in ("paragraph", "table_row")],
        "failures": failures, "matched_blocks": matches,
    }


def verify(docx_path: Path, pdf_path: Path) -> dict:
    docx_bytes = docx_path.read_bytes()
    pdf_bytes = pdf_path.read_bytes()
    source = read_source(docx_bytes)
    executable = shutil.which("pdftotext")
    if not executable:
        raise RuntimeError("pdftotext is required but is not on PATH")
    extraction = subprocess.run(
        [executable, "-raw", "-enc", "UTF-8", str(pdf_path.resolve()), "-"],
        check=True, capture_output=True, encoding="utf-8", timeout=180,
    )
    if sha256(pdf_path.read_bytes()) != sha256(pdf_bytes):
        raise RuntimeError("PDF changed during extraction; retry against stable inputs")
    pages, removed = clean_pages(extraction.stdout, source["margins"])
    result = compare(source, pages)
    return {
        "schema": 1, "tool": "verify_document_content.py",
        "checked_utc": datetime.now(timezone.utc).isoformat(),
        "status": "pass" if result["complete"] else "fail",
        "scope": "DOCX body text, table rows, cells and their paragraphs in source order",
        "docx": {"file": str(docx_path.resolve()), "bytes": len(docx_bytes), "sha256": sha256(docx_bytes)},
        "pdf": {"file": str(pdf_path.resolve()), "bytes": len(pdf_bytes), "sha256": sha256(pdf_bytes),
                "pages": len(pages)},
        "source_counts": source["counts"],
        "extraction": {"command": "pdftotext -raw -enc UTF-8 PDF -",
                       "margin_lines_removed": removed, "warnings": extraction.stderr.strip()},
        "normalization": "NFKC; Unicode casefold; retain alphanumeric characters only",
        "limitations": LIMITATIONS, "visual_review_required": True,
        **result,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--docx", required=True, type=Path)
    parser.add_argument("--pdf", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    if args.output.resolve() in (args.docx.resolve(), args.pdf.resolve()):
        parser.error("The report must not overwrite an input document")
    try:
        report = verify(args.docx, args.pdf)
        exit_code = 0 if report["complete"] else 1
    except (OSError, ValueError, RuntimeError, ET.ParseError, zipfile.BadZipFile,
            KeyError, subprocess.SubprocessError) as exc:
        report = {
            "schema": 1, "tool": "verify_document_content.py", "status": "error",
            "complete": False, "error": str(exc), "visual_review_required": True,
        }
        exit_code = 2
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if "counts" in report:
        counts = report["counts"]
        print(
            f"DOCUMENT CONTENT {report['status'].upper()}: "
            f"{counts['ordered_blocks_matched']}/{counts['ordered_blocks_checked']} ordered blocks; "
            f"{counts['cells_matched_in_expected_row']}/{counts['cells_checked']} cells; "
            f"report {args.output}"
        )
        for failure in report["missing_ordered_blocks"]:
            print(f"MISSING {failure['id']}: {failure['text'][:180]}")
    else:
        print(f"DOCUMENT CONTENT ERROR: {report['error']}", file=sys.stderr)
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
