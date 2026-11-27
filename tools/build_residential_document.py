#!/usr/bin/env python3
"""Build the v0.13 residence and telecommunications supplement.

Uses the same typography, tables and deterministic DOCX packaging as the v0.12
supplement. The build report records authoring only. Render the resulting DOCX
with the Documents skill renderer, inspect every page, and run the separate
content checker before claiming a document review.

    "$CODEX_PRIMARY_RUNTIME_PYTHON" tools/build_residential_document.py
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
SOURCE = ROOT / "docs/CONTINUATION_A19_A17_V0.13.md"
OUTPUT = ROOT / "docs/The-Tower-Descent-Continuation-v0.13.docx"
REPORT = ROOT / "docs/validation/v0.13/DOCUMENT_BUILD.json"
STAMP = datetime(2026, 11, 26, 0, 0, 0, tzinfo=timezone.utc)
ORIGINAL_WIDTHS = layout.widths_for


def relative(path: Path) -> str:
    return str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def plain_heading(text: str) -> str:
    text = re.sub(r"\[([^]]+)\]\([^)]+\)", r"\1", text)
    return " ".join("".join(c if c.isalnum() or c.isspace() else " " for c in text).split())


def widths_for(rows: list[list[str]]) -> list[float]:
    known = {
        ("Liaison", "Paliers", "Position", "Usage prévu"): [2.1, 2.1, 3.3, 9.5],
        ("Étape", "Condition à vérifier", "Résultat attendu"): [3.8, 6.5, 6.7],
        ("Personne", "Départ", "Vitesse", "Route jusqu'au 20"): [3.1, 5.1, 2.4, 6.4],
        ("Constat", "Lieu", "Fait conservé"): [5.2, 4.2, 7.6],
        ("Modèle", "Identifiant", "Placement et fonction"): [4.3, 4.6, 8.1],
        ("Matière", "Répétition de départ", "Réglage artistique"): [5.2, 4.5, 7.3],
        ("Domaine", "Contrôle attendu", "Preuve à conserver"): [3.0, 8.0, 6.0],
    }
    return known.get(tuple(rows[0]), ORIGINAL_WIDTHS(rows))


def stable_package(document: Document) -> bytes:
    original = io.BytesIO()
    document.save(original)
    result = io.BytesIO()
    with zipfile.ZipFile(original) as source, zipfile.ZipFile(
        result, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9
    ) as target:
        for name in sorted(source.namelist()):
            info = zipfile.ZipInfo(name, (2026, 11, 26, 0, 0, 0))
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
    section.top_margin = section.bottom_margin = Cm(1.9)
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
    layout.set_font(header.add_run("THE TOWER DESCENT   SUPPLÉMENT V0 13"), 9)
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
    subtitle = document.add_paragraph("Résidences et télécommunications", style="Subtitle")
    subtitle.paragraph_format.space_after = Pt(4)
    scope = document.add_paragraph("Continuation aux étages 19 à 17", style="Subtitle")
    scope.paragraph_format.space_after = Pt(11)
    layout.clean_heading = plain_heading
    layout.widths_for = widths_for
    layout.add_markdown(document, markdown, 100)
    for table in document.tables:
        heading = table.cell(0, 0).text
        for row in list(table.rows)[1:]:
            if heading == "Liaison":
                for column in (0, 1):
                    row.cells[column].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
            if heading == "Personne":
                row.cells[2].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
            if heading == "Matière":
                row.cells[1].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
    props = document.core_properties
    props.title = "The Tower Descent résidences et télécommunications"
    props.subject = "Continuation aux étages 19 à 17 et secours vers le refuge 20"
    props.author = props.last_modified_by = "Darknigthmare"
    props.created = props.modified = STAMP
    props.revision = 1
    props.keywords = "The Tower Descent, A19, A18, A17, Jeanne, Marc, Inès, sauvetage, Godot"
    props.comments = "Supplément 0.13. Les bibles et suppléments historiques restent conservés."
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(stable_package(document))
    return {
        "schema_version": 1,
        "version": "0.13.0",
        "source": relative(source),
        "source_sha256": digest(source),
        "source_word_count": len(markdown.split()),
        "generator": relative(Path(__file__).resolve()),
        "generator_sha256": digest(Path(__file__).resolve()),
        "layout_dependency": "tools/build_bible.py",
        "layout_dependency_sha256": digest(ROOT / "tools/build_bible.py"),
        "output": relative(output),
        "docx_sha256": digest(output),
        "body_paragraphs": len(document.paragraphs),
        "tables": len(document.tables),
        "table_rows": sum(len(table.rows) for table in document.tables),
        "page_size": "Letter portrait",
        "body_font": "Arial 11 pt",
        "visual_review": "Not performed by this authoring script",
        "gameplay_validation": "Not performed by this authoring script",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--output", type=Path, default=OUTPUT)
    parser.add_argument("--report", type=Path, default=REPORT)
    args = parser.parse_args()
    report = build(args.source.resolve(), args.output.resolve())
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
