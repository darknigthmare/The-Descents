#!/usr/bin/env python3
"""Build the v0.12 commerce and refuge supplement from its Markdown source.

Authoring uses the primary runtime and preserves the historical bible files:
    "$CODEX_PRIMARY_RUNTIME_PYTHON" tools/build_commerce_document.py

Render separately, then inspect every page before publishing a new revision:
    "$CODEX_PRIMARY_RUNTIME_PYTHON" /home/agent/.codex/skills/builtins/documents/render_docx.py \
        docs/The-Tower-Descent-Continuation-v0.12.docx \
        --output_dir /tmp/tower-v012-document-render --emit_pdf

The renderer-produced PDF can be copied to the companion path after review.
This authoring script does not assert gameplay or visual validation.
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
SOURCE = ROOT / "docs/CONTINUATION_A22_A20_V0.12.md"
OUTPUT = ROOT / "docs/The-Tower-Descent-Continuation-v0.12.docx"
STAMP = datetime(2026, 11, 25, 0, 0, 0, tzinfo=timezone.utc)
ORIGINAL_WIDTHS = layout.widths_for


def plain_heading(text: str) -> str:
    text = re.sub(r"\[([^]]+)\]\([^)]+\)", r"\1", text)
    return " ".join("".join(c if c.isalnum() or c.isspace() else " " for c in text).split())


def widths_for(rows: list[list[str]]) -> list[float]:
    headers = rows[0]
    if headers == ["Liaison", "Paliers", "Position", "Fonction dans la tranche"]:
        return [2.1, 2.1, 3.7, 9.1]
    if headers == ["Personne", "Point de départ", "Réception au 20"]:
        return [3.4, 5.7, 7.9]
    if headers == ["Constat", "Lieu", "Ce qu'il établit"]:
        return [5.0, 4.0, 8.0]
    if headers == ["Modèle", "Dimensions en mètres", "Placement et fonction"]:
        return [4.0, 4.0, 9.0]
    if headers == ["Matière", "Échelle UV de départ", "Réglage conseillé"]:
        return [3.5, 5.0, 8.5]
    return ORIGINAL_WIDTHS(rows)


def stable_package(document: Document) -> bytes:
    original = io.BytesIO()
    document.save(original)
    result = io.BytesIO()
    with zipfile.ZipFile(original) as source, zipfile.ZipFile(
        result, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9
    ) as target:
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
    header.alignment = WD_ALIGN_PARAGRAPH.LEFT
    layout.set_font(header.add_run("THE TOWER DESCENT   SUPPLÉMENT V0 12"), 9)
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
    subtitle = document.add_paragraph("Continuation aux étages 22 à 20", style="Subtitle")
    subtitle.paragraph_format.space_after = Pt(11)
    layout.clean_heading = plain_heading
    layout.widths_for = widths_for
    layout.add_markdown(document, markdown, 100)
    for table in document.tables:
        heading = table.cell(0, 0).text
        for row in list(table.rows)[1:]:
            if heading == "Liaison":
                row.cells[0].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
                row.cells[1].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
            if heading == "Modèle":
                row.cells[1].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
    props = document.core_properties
    props.title = "The Tower Descent continuation aux étages 22 à 20"
    props.subject = "Galerie commerciale cuisines et refuge logistique"
    props.author = "Darknigthmare"
    props.last_modified_by = "Darknigthmare"
    props.created = props.modified = STAMP
    props.revision = 1
    props.keywords = "The Tower Descent, A22, A21, A20, sauvetage, Godot, Nacre"
    props.comments = "Candidature v0.12. La Bible historique et les suppléments précédents restent conservés."
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
