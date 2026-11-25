#!/usr/bin/env python3
"""Build the editable v0.10 supplement from its single Markdown source.

Run with the primary document runtime:
    "$CODEX_PRIMARY_RUNTIME_PYTHON" tools/build_continuation_document.py

Then render and review every page, separately from this authoring operation:
    "$CODEX_PRIMARY_RUNTIME_PYTHON" /home/agent/.codex/skills/builtins/documents/render_docx.py \
        docs/The-Tower-Descent-Continuation-v0.10.docx \
        --output_dir /tmp/tower-v010-document-render --emit_pdf

The complete historical v0.9 Bible is not rebuilt or modified. ZIP timestamps
and document core timestamps are fixed for reproducible DOCX bytes under the
same python-docx version. Rendering does not create a visual-review verdict.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import io
import json
from pathlib import Path
import re
import zipfile

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Cm, Inches, Pt, RGBColor

import build_bible as layout


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/CONTINUATION_A24_A23_V0.10.md"
OUTPUT = ROOT / "docs/The-Tower-Descent-Continuation-v0.10.docx"
STAMP = datetime(2026, 11, 25, 0, 0, 0, tzinfo=timezone.utc)


def plain_heading(text: str) -> str:
    """Only words, numbers and spaces in Word titles; the MD stays untouched."""
    text = re.sub(r"\[([^]]+)\]\([^)]+\)", r"\1", text)
    return " ".join("".join(char if char.isalnum() or char.isspace() else " " for char in text).split())


def stable_package(document: Document) -> bytes:
    original = io.BytesIO()
    document.save(original)
    result = io.BytesIO()
    with zipfile.ZipFile(original) as source, zipfile.ZipFile(result, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as target:
        for name in sorted(source.namelist()):
            info = zipfile.ZipInfo(name, (2026, 11, 25, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = 3
            info.external_attr = 0o644 << 16
            target.writestr(info, source.read(name))
    return result.getvalue()


def build(source: Path, output: Path) -> dict:
    markdown = source.read_text(encoding="utf-8")
    document = Document()
    layout.configure(document)
    # Maintain the Bible's Arial typography and restrained tables, with the
    # standard Letter page geometry for this standalone supplement.
    section = document.sections[0]
    section.page_width = Inches(8.5)
    section.page_height = Inches(11)
    section.left_margin = section.right_margin = Cm((21.59 - 17.0) / 2)
    section.top_margin = Cm(1.9)
    section.bottom_margin = Cm(1.9)
    section.different_first_page_header_footer = False
    normal = document.styles["Normal"].paragraph_format
    normal.space_after = Pt(6)
    normal.line_spacing = 1.10
    document.styles["Title"].font.size = Pt(28)
    document.styles["Subtitle"].font.size = Pt(16)
    for level in range(1, 5):
        style = document.styles[f"Heading {level}"]
        style.font.color.rgb = RGBColor(0, 0, 0)
        style.font.underline = False
        style.paragraph_format.space_before = Pt(14)
        style.paragraph_format.space_after = Pt(7)
    header = section.header.paragraphs[0]
    header.clear()
    # The title page identifies this short supplement; a neutral running
    # footer keeps every page consistent across the supported PDF renderer.
    footer = section.footer.paragraphs[0]
    footer.clear()
    footer.alignment = WD_ALIGN_PARAGRAPH.CENTER
    layout.set_font(footer.add_run("Page "), 9)
    layout.field(footer, "PAGE")
    layout.set_font(footer.add_run(" / "), 9)
    layout.field(footer, "NUMPAGES")
    title = document.add_paragraph("The Tower Descent", style="Title")
    title.paragraph_format.space_before = Pt(0)
    title.paragraph_format.space_after = Pt(5)
    subtitle = document.add_paragraph("Continuation au congrès et à Histoire de Nacre", style="Subtitle")
    subtitle.paragraph_format.space_after = Pt(11)
    # The generic parser skips the source H1, which is represented by the
    # explicit Title/Subtitle above. All body paragraphs and table rows remain.
    layout.clean_heading = plain_heading
    layout.add_markdown(document, markdown, 100)
    for table in document.tables:
        if table.cell(0, 0).text == "Liaison":
            for row in list(table.rows)[1:]:
                row.cells[0].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
    properties = document.core_properties
    properties.title = "The Tower Descent continuation A24 A23"
    properties.subject = "Accompagnement du congrès et reconnaissance de l’exposition Histoire de Nacre"
    properties.author = "Darknigthmare"
    properties.last_modified_by = "Darknigthmare"
    properties.created = properties.modified = STAMP
    properties.revision = 1
    properties.keywords = "The Tower Descent, continuation, A24, A23, sauvetage, Nacre"
    properties.comments = "Supplément v0.10 ; la Bible complète v0.9 reste conservée."
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(stable_package(document))
    return {
        "source": str(source.relative_to(ROOT)) if source.is_relative_to(ROOT) else str(source),
        "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
        "source_word_count": len(markdown.split()),
        "output": str(output.relative_to(ROOT)) if output.is_relative_to(ROOT) else str(output),
        "docx_sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
        "body_paragraphs": len(document.paragraphs),
        "tables": len(document.tables),
        "table_rows": sum(len(table.rows) for table in document.tables),
        "page_size": "Letter portrait",
        "body_font": "Arial 11 pt",
        "visual_review": "Not performed by this authoring script",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--output", type=Path, default=OUTPUT)
    args = parser.parse_args()
    print(json.dumps(build(args.source.resolve(), args.output.resolve()), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
