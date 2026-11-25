#!/usr/bin/env python3
"""Build the complete, editable design bible from the repository Markdown sources.

Run with the primary document runtime:
    "$CODEX_PRIMARY_RUNTIME_PYTHON" tools/build_bible.py

Rendering is a separate, mandatory delivery check:
    "$CODEX_PRIMARY_RUNTIME_PYTHON" /home/agent/.codex/skills/builtins/documents/render_docx.py \
        docs/The-Tower-Descent-Bible-v0.7.docx --output_dir docs/rendered --emit_pdf
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Iterable

from docx import Document
from docx.enum.section import WD_SECTION_START
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK, WD_TAB_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor
from docx.opc.constants import RELATIONSHIP_TYPE as RT


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
DEFAULT_OUTPUT = DOCS / "The-Tower-Descent-Bible-v0.7.docx"
REPO_DOCS = "https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/"
BODY_FONT = "Arial"
MONO_FONT = "Consolas"
BODY_SIZE = 11
TABLE_SIZE = 10
BODY_WIDTH_CM = 17.0
PARTS = [
    ("BIBLE_DU_JEU.md", "Partie 1 Bible de conception", "part_bible"),
    ("CATALOGUE_ETAGES.md", "Partie 2 Catalogue des étages et des profondeurs", "part_floors"),
    ("SYSTEMES_PROCEDURAUX.md", "Annexe A Génération et sauvegardes", "part_systems"),
    ("ARCHITECTURE_ET_PORTAGE_UE5.md", "Annexe B Architecture et portage vers Unreal Engine 5", "part_architecture"),
    ("EFFONDREMENT_EN_DIRECT.md", "Annexe C Effondrement en direct et mise en scène", "part_collapse"),
    ("COMMUNICATIONS_ET_EQUIPES.md", "Annexe D Communications et continuité des équipes", "part_communications"),
    ("PROPS_INTERACTIONS.md", "Annexe E Props et interactions", "part_props"),
    ("ENNEMIS_STATISTIQUES.md", "Annexe F Présences, adversaires et statistiques", "part_enemies"),
    ("SCENES_CINEMATIQUES.md", "Annexe G Scènes, cinématiques et accueil", "part_cinematics"),
    ("GAMEPLAY_DETAILLE.md", "Annexe H Gameplay détaillé et personnages", "part_gameplay"),
    ("SAUVETAGE_V0.6.md", "Annexe I Portage, treuillage et réception des rescapés", "part_rescue"),
    ("AMBIANCE_V0.6.md", "Annexe J Atmosphère maritime et présentation", "part_atmosphere"),
    ("CONFORT_V0.6.md", "Annexe K Réglages, confort et accessibilité", "part_comfort"),
    ("DOSSIER_ET_EPILOGUE_V0.7.md", "Annexe L Dossier de mission, bilan et épilogue", "part_dossier_epilogue"),
]


def node(tag: str, **attributes) -> OxmlElement:
    element = OxmlElement(tag)
    for key, value in attributes.items():
        element.set(qn(key), str(value))
    return element


def set_font(run, size: float | None = None, bold: bool | None = None):
    run.font.name = BODY_FONT
    fonts = run._element.get_or_add_rPr().get_or_add_rFonts()
    fonts.set(qn("w:ascii"), BODY_FONT)
    fonts.set(qn("w:hAnsi"), BODY_FONT)
    fonts.set(qn("w:eastAsia"), BODY_FONT)
    if size is not None:
        run.font.size = Pt(size)
    if bold is not None:
        run.bold = bold
    return run


def clean_heading(text: str) -> str:
    # Source headings remain recognisable while document titles use plain text.
    text = re.sub(r"\*\*|`", "", text)
    text = re.sub(r"\[([^]]+)\]\([^)]+\)", r"\1", text)
    text = text.replace("→", " à ").replace("&", " et ")
    text = re.sub(r"[—–:/()\[\]{}+•]", " ", text)
    text = re.sub(r"(?<=\d)\.(?=\s)", "", text)
    return re.sub(r"\s+", " ", text).strip()


def hyperlink(paragraph, label: str, href: str, *, internal: bool = False):
    link = OxmlElement("w:hyperlink")
    if internal:
        link.set(qn("w:anchor"), href)
    else:
        if not re.match(r"^(?:https?://|mailto:)", href):
            href = REPO_DOCS + href
        relation_id = paragraph.part.relate_to(href, RT.HYPERLINK, is_external=True)
        link.set(qn("r:id"), relation_id)
    r = OxmlElement("w:r")
    props = OxmlElement("w:rPr")
    props.append(node("w:rFonts", **{"w:ascii": BODY_FONT, "w:hAnsi": BODY_FONT}))
    props.append(node("w:color", **{"w:val": "244B5A"}))
    props.append(node("w:u", **{"w:val": "single"}))
    r.append(props)
    text = OxmlElement("w:t")
    text.text = label
    r.append(text)
    link.append(r)
    paragraph._p.append(link)


INLINE = re.compile(r"(\[[^\]]+\]\([^\)]+\)|\*\*[^*]+\*\*|`[^`]+`|\*[^*]+\*)")


def inline(paragraph, text: str, *, size: float | None = None, white: bool = False):
    for fragment in INLINE.split(text):
        if not fragment:
            continue
        match = re.fullmatch(r"\[([^\]]+)\]\(([^\)]+)\)", fragment)
        if match:
            hyperlink(paragraph, match.group(1), match.group(2))
            continue
        code = fragment.startswith("`") and fragment.endswith("`")
        bold = fragment.startswith("**") and fragment.endswith("**")
        italic = not bold and fragment.startswith("*") and fragment.endswith("*")
        value = fragment[2:-2] if bold else fragment[1:-1] if code or italic else fragment
        run = set_font(paragraph.add_run(value), size)
        run.bold = bold
        run.italic = italic
        if code:
            run.font.name = MONO_FONT
            fonts = run._element.get_or_add_rPr().get_or_add_rFonts()
            fonts.set(qn("w:ascii"), MONO_FONT)
            fonts.set(qn("w:hAnsi"), MONO_FONT)
            run.font.size = Pt(min(size or BODY_SIZE, 9.5))
        run.font.color.rgb = RGBColor.from_string("FFFFFF" if white else "000000")


def bookmark(paragraph, name: str, index: int):
    start = node("w:bookmarkStart", **{"w:id": index, "w:name": name})
    end = node("w:bookmarkEnd", **{"w:id": index})
    paragraph._p.insert(0, start)
    paragraph._p.append(end)


def field(paragraph, instruction: str, display: str = "1"):
    begin = node("w:fldChar", **{"w:fldCharType": "begin"})
    paragraph.add_run()._r.append(begin)
    inst = OxmlElement("w:instrText")
    inst.set(qn("xml:space"), "preserve")
    inst.text = f" {instruction} "
    paragraph.add_run()._r.append(inst)
    paragraph.add_run()._r.append(node("w:fldChar", **{"w:fldCharType": "separate"}))
    set_font(paragraph.add_run(display), 9)
    paragraph.add_run()._r.append(node("w:fldChar", **{"w:fldCharType": "end"}))


def configure(document: Document):
    section = document.sections[0]
    section.page_width = Cm(21)
    section.page_height = Cm(29.7)
    section.top_margin = Cm(2)
    section.bottom_margin = Cm(2)
    section.left_margin = Cm(2)
    section.right_margin = Cm(2)
    section.header_distance = Cm(0.8)
    section.footer_distance = Cm(0.9)
    section.different_first_page_header_footer = True
    for style_name, size in [("Normal", 11), ("Title", 30), ("Subtitle", 17),
                             ("Heading 1", 20), ("Heading 2", 15), ("Heading 3", 12),
                             ("Heading 4", 11), ("List Bullet", 11), ("List Number", 11),
                             ("Header", 9), ("Footer", 9)]:
        style = document.styles[style_name]
        style.font.name = BODY_FONT
        style.font.size = Pt(size)
        style.font.color.rgb = RGBColor(0, 0, 0)
        style.font.underline = False
        rpr = style.element.get_or_add_rPr()
        fonts = rpr.get_or_add_rFonts()
        fonts.set(qn("w:ascii"), BODY_FONT)
        fonts.set(qn("w:hAnsi"), BODY_FONT)
        color = rpr.find(qn("w:color"))
        if color is not None:
            for attr in ("w:themeColor", "w:themeTint", "w:themeShade"):
                color.attrib.pop(qn(attr), None)
        ppr = style.element.get_or_add_pPr()
        for border in list(ppr.findall(qn("w:pBdr"))):
            ppr.remove(border)
    normal = document.styles["Normal"].paragraph_format
    normal.space_after = Pt(5)
    normal.line_spacing = 1.06
    normal.widow_control = True
    for level in range(1, 5):
        p = document.styles[f"Heading {level}"].paragraph_format
        p.space_before = Pt(15 if level < 3 else 10)
        p.space_after = Pt(7 if level < 3 else 4)
        p.keep_with_next = True
        p.keep_together = True
    for style_name in ["List Bullet", "List Number"]:
        pf = document.styles[style_name].paragraph_format
        pf.space_after = Pt(3)
        pf.line_spacing = 1.04
    header = section.header.paragraphs[0]
    header.alignment = WD_ALIGN_PARAGRAPH.LEFT
    set_font(header.add_run("THE TOWER DESCENT   |   Bible de conception   |   Version 0.7.0"), 9)
    footer = section.footer.paragraphs[0]
    footer.paragraph_format.tab_stops.add_tab_stop(Cm(BODY_WIDTH_CM), WD_TAB_ALIGNMENT.RIGHT)
    set_font(footer.add_run("Darknigthmare  ·  25 novembre 2026\t"), 9)
    field(footer, "PAGE")
    set_font(footer.add_run(" / "), 9)
    field(footer, "NUMPAGES")
    document.core_properties.title = "The Tower Descent Bible de conception"
    document.core_properties.subject = "Bible du jeu, étages, props, personnages, menaces, gameplay et cinématiques"
    document.core_properties.author = "Darknigthmare"
    document.core_properties.keywords = "The Tower Descent, The-Descents, Godot, Unreal Engine 5, sauvetage, horreur"
    document.core_properties.comments = ""
    settings = document.settings.element
    settings.append(node("w:updateFields", **{"w:val": "true"}))
    # French proofing and automatic hyphenation improve the narrow table columns.
    document.styles["Normal"].element.get_or_add_rPr().append(node("w:lang", **{"w:val": "fr-FR"}))
    settings.append(node("w:autoHyphenation", **{"w:val": "true"}))


def widths_for(rows: list[list[str]]) -> list[float]:
    columns = len(rows[0])
    if rows[0] == ["Niveau", "Objet examinable", "Rôle dans la lecture du lieu", "Référence"]:
        return [1.9, 4.9, 7.9, 2.3]
    if rows[0] == ["Événement", "Temps de séquence", "Résultat visible"]:
        return [5.0, 3.0, 9.0]
    if columns == 5 and rows[0][0] == "Temps relatif":
        return [2.0, 2.3, 2.1, 5.9, 4.7]
    if columns == 4 and rows[0][0] == "Repère":
        return [1.8, 3.7, 3.3, 8.2]
    if columns == 5 and rows[0][:2] == ["Code", "Niveau"]:
        return [1.3, 2.7, 4.0, 4.7, 4.3]
    if columns == 6 and rows[0][0] == "Niveau":
        return [1.8, 3.1, 3.0, 2.4, 3.8, 2.9]
    if columns == 2 and rows[0][0] == "Élément proposé":
        return [6.1, 10.9]
    if columns == 2 and rows[0][0].startswith("Fichier dans"):
        return [5.4, 11.6]
    if columns == 2:
        first = 4.3
        if max(len(re.sub(r"[`*]", "", row[0])) for row in rows) > 30:
            first = 5.5
        return [first, BODY_WIDTH_CM - first]
    if columns == 3:
        return [4.3, 6.35, 6.35]
    if columns == 4:
        return [3.0, 5.0, 4.5, 4.5]
    if columns == 5:
        return [2.5, 4.0, 3.75, 3.75, 3.0]
    if columns == 6:
        return [1.4, 3.1, 2.8, 3.0, 2.8, 3.9]
    return [BODY_WIDTH_CM / columns] * columns


def add_table(document: Document, rows: list[list[str]]):
    if not rows:
        return
    cols = len(rows[0])
    # This transition matrix closes Annex A. Modest cell padding keeps its
    # explanation and final production paragraph together without smaller type.
    compact = rows[0] == ["Moment", "Valeur persistante", "Comportement de reprise"]
    rows = [row + [""] * (cols - len(row)) for row in rows]
    table = document.add_table(rows=0, cols=cols)
    table.autofit = False
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    widths = widths_for(rows)
    for column, width in zip(table.columns, widths):
        column.width = Cm(width)
    props = table._tbl.tblPr
    props.append(node("w:tblW", **{"w:w": int(Cm(BODY_WIDTH_CM).twips), "w:type": "dxa"}))
    borders = OxmlElement("w:tblBorders")
    for border in ["top", "left", "bottom", "right", "insideH", "insideV"]:
        borders.append(node(f"w:{border}", **{"w:val": "single", "w:sz": 4, "w:color": "D9D9D9"}))
    props.append(borders)
    margins = OxmlElement("w:tblCellMar")
    vertical_padding = 45 if compact else 90
    for side, size in [("top", vertical_padding), ("bottom", vertical_padding), ("left", 100), ("right", 100)]:
        margins.append(node(f"w:{side}", **{"w:w": size, "w:type": "dxa"}))
    props.append(margins)
    for index, values in enumerate(rows):
        row = table.add_row()
        row._tr.get_or_add_trPr().append(node("w:cantSplit"))
        if index == 0:
            row._tr.get_or_add_trPr().append(node("w:tblHeader", **{"w:val": "true"}))
        for col_index, (cell, text) in enumerate(zip(row.cells, values)):
            cell.width = Cm(widths[col_index])
            cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            fill = "24424E" if index == 0 else "F2F5F6" if index % 2 == 0 else "FFFFFF"
            cell._tc.get_or_add_tcPr().append(node("w:shd", **{"w:fill": fill, "w:val": "clear"}))
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(0 if compact else 2)
            p.paragraph_format.space_before = Pt(0 if compact else 2)
            p.paragraph_format.line_spacing = 1.0
            p.paragraph_format.keep_with_next = False
            inline(p, text, size=TABLE_SIZE, white=index == 0)
            if index == 0:
                for run in p.runs:
                    run.bold = True
            elif col_index == 0 and re.fullmatch(r"[0-9 +.%/−–-]+", text):
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    spacer = document.add_paragraph()
    spacer.paragraph_format.space_after = Pt(3)
    spacer.paragraph_format.space_before = Pt(0)
    spacer.paragraph_format.line_spacing = 0.25
    set_font(spacer.add_run(""), 2)


def is_table_separator(line: str) -> bool:
    return bool(re.fullmatch(r"\s*\|?[\s:|-]+\|?\s*", line)) and "---" in line


def table_cells(line: str) -> list[str]:
    return [part.strip().replace("\\|", "|") for part in re.split(r"(?<!\\)\|", line.strip().strip("|"))]


def new_numbering(document: Document, start: int = 1) -> int:
    numbering = document.part.numbering_part.element
    abstract_ids = [int(x.get(qn("w:abstractNumId"))) for x in numbering.findall(qn("w:abstractNum"))]
    num_ids = [int(x.get(qn("w:numId"))) for x in numbering.findall(qn("w:num"))]
    abstract_id = max(abstract_ids, default=-1) + 1
    num_id = max(num_ids, default=0) + 1
    abstract = node("w:abstractNum", **{"w:abstractNumId": abstract_id})
    abstract.append(node("w:multiLevelType", **{"w:val": "singleLevel"}))
    level = node("w:lvl", **{"w:ilvl": 0})
    level.append(node("w:start", **{"w:val": start}))
    level.append(node("w:numFmt", **{"w:val": "decimal"}))
    level.append(node("w:lvlText", **{"w:val": "%1."}))
    level.append(node("w:lvlJc", **{"w:val": "left"}))
    paragraph_props = OxmlElement("w:pPr")
    paragraph_props.append(node("w:ind", **{"w:left": 360, "w:hanging": 360}))
    level.append(paragraph_props)
    abstract.append(level)
    numbering.append(abstract)
    actual = node("w:num", **{"w:numId": num_id})
    actual.append(node("w:abstractNumId", **{"w:val": abstract_id}))
    numbering.append(actual)
    return num_id


def add_markdown(document: Document, markdown: str, part_number: int):
    lines = markdown.splitlines()
    index = 0
    active_numbering = None
    tables_seen = 0
    while index < len(lines):
        line = lines[index].strip()
        if not line:
            index += 1
            continue
        heading = re.match(r"^(#{1,6})\s+(.+)$", line)
        if heading:
            depth = len(heading.group(1))
            text = heading.group(2)
            if depth == 1 or (part_number == 0 and text == "Bible de conception du jeu"):
                index += 1
                continue
            p = document.add_paragraph(clean_heading(text), style=f"Heading {min(depth, 4)}")
            if part_number == 8 and tables_seen == 0:
                p.paragraph_format.space_before = Pt(10 if depth == 2 else 7)
            index += 1
            continue
        if line.startswith("```"):
            index += 1
            code_lines = []
            while index < len(lines) and not lines[index].strip().startswith("```"):
                code_lines.append(lines[index])
                index += 1
            for code in code_lines:
                p = document.add_paragraph()
                p.paragraph_format.left_indent = Cm(0.3)
                p.paragraph_format.space_after = Pt(2)
                run = p.add_run(code)
                run.font.name = MONO_FONT
                run.font.size = Pt(9.5)
            index += 1
            continue
        if line.startswith("|") and index + 1 < len(lines) and is_table_separator(lines[index + 1]):
            rows = [table_cells(line)]
            index += 2
            while index < len(lines) and lines[index].strip().startswith("|"):
                if not is_table_separator(lines[index]):
                    rows.append(table_cells(lines[index]))
                index += 1
            add_table(document, rows)
            tables_seen += 1
            continue
        if re.fullmatch(r"[-*_]{3,}", line):
            index += 1
            continue
        bullet = re.match(r"^[-*+]\s+(.+)$", line)
        numbered = re.match(r"^(\d+)\.\s+(.+)$", line)
        quote = line.startswith(">")
        if bullet or numbered:
            text = bullet.group(1) if bullet else numbered.group(2)
            p = document.add_paragraph(style="List Bullet" if bullet else "List Number")
            if numbered:
                start = int(numbered.group(1))
                if start == 1 or active_numbering is None:
                    active_numbering = new_numbering(document, start)
                num_props = OxmlElement("w:numPr")
                num_props.append(node("w:ilvl", **{"w:val": 0}))
                num_props.append(node("w:numId", **{"w:val": active_numbering}))
                p._p.get_or_add_pPr().append(num_props)
            inline(p, text)
            index += 1
            continue
        if quote:
            p = document.add_paragraph()
            p.paragraph_format.left_indent = Cm(0.5)
            inline(p, line.lstrip("> "))
            for run in p.runs:
                run.italic = True
            index += 1
            continue
        paragraph_lines = [line]
        index += 1
        while index < len(lines) and lines[index].strip():
            candidate = lines[index].strip()
            if re.match(r"^(#{1,6}\s|```|\||[-*+]\s|\d+\.\s|>)", candidate):
                break
            paragraph_lines.append(candidate)
            index += 1
        p = document.add_paragraph()
        # Annex G needs a little room to keep its four launch cards together;
        # retain the existing font and leading throughout the introduction.
        if part_number == 8 and tables_seen == 0:
            p.paragraph_format.space_after = Pt(3)
        inline(p, " ".join(paragraph_lines))


def cover(document: Document):
    title = document.add_paragraph("The Tower Descent", style="Title")
    title.paragraph_format.space_before = Pt(35)
    title.paragraph_format.space_after = Pt(15)
    subtitle = document.add_paragraph("Bible de conception et catalogue des niveaux", style="Subtitle")
    subtitle.paragraph_format.space_after = Pt(18)
    inline(document.add_paragraph(), "**Version 0.7.0 — 25 novembre 2026**")
    inline(document.add_paragraph(), "**Création et direction du projet : Darknigthmare**")
    p = document.add_paragraph()
    hyperlink(p, "Dépôt The-Descents sur GitHub", "https://github.com/darknigthmare/The-Descents")
    p.paragraph_format.space_after = Pt(18)
    document.add_paragraph(
        "Ce document définit un jeu de sauvetage et d’horreur à la première personne sur une île "
        "de luxe ravagée. Les équipes arrivent sur deux tours intactes et se répartissent sur leurs toits. "
        "Pendant la descente de sauvetage, une nouvelle réplique provoque l’effondrement partiel "
        "d’Hespérie vers Aube, sous les yeux du joueur. Les secours continuent dans le bâtiment "
        "transformé, où des traces révèlent des événements antérieurs à la catastrophe."
    )
    document.add_paragraph(
        "La bible présente l’univers, les personnages, les règles et les choix de production. "
        "Le catalogue détaille les étages et les profondeurs. Douze annexes développent systèmes, "
        "architecture, incident, équipes, 52 props, 11 formes de présence, scènes, gameplay chiffré, "
        "sauvetage visible, atmosphère maritime, réglages de confort, dossier de mission et épilogue."
    )
    document.add_paragraph("Périmètre de cette version", style="Heading 2")
    add_table(document, [
        ["État", "Contenu"],
        ["Prototype Godot 0.7.0", "Toit et six étages de 30 à 25, effondrement vécu, trois sauvetages avec réception visible, radio persistante et sauvegarde 3. Prologue de 15 s, accueil contextuel, dépose animée de 28 s, 12 observations facultatives, portage, treuillage, réception médicale, atmosphère maritime et réglages de confort. Dossier à quatre onglets, bilan lié à la mission et épilogue de 15 s rejouable. Modèles procéduraux."],
        ["Conception de campagne", "Trente étages principaux, seconde tour, socle, souterrains, bunker et profondeur 666; personnages, révélation, fins et extension Mountain Hole. Contenu à produire."],
        ["Référence de production", "Le contrat de jeu, les critères de revue et la mise en scène sont décrits ici. Le rapport de livraison du dépôt présente séparément les exécutables et les résultats de vérification."],
    ])
    contents = document.add_paragraph("Organisation du document", style="Heading 2")
    contents.paragraph_format.page_break_before = True
    for _, title_text, anchor in PARTS:
        p = document.add_paragraph()
        p.paragraph_format.space_after = Pt(5)
        hyperlink(p, title_text, anchor, internal=True)
    document.add_paragraph(
        "Les noms, révélations et fins constituent la proposition de canon 0.7.0. "
        "L’état des fonctionnalités jouables est distinct des objectifs de campagne."
    )
    document.add_paragraph("Lecture et usage", style="Heading 2")
    document.add_paragraph(
        "Les deux premières parties exposent le récit, les choix de conception et le parcours complet. "
        "Les annexes apportent les contrats techniques, les fiches de production et les paramètres. "
        "Les mentions actuel ou livré désignent le prototype ; cible, proposé et campagne désignent "
        "un contenu à construire ou à éprouver. Les tableaux de statistiques futures ne sont pas des résultats de test."
    )
    document.add_paragraph(
        "Le volume reprend intégralement les quatorze sources Markdown du dépôt. Les liens de cette page "
        "mènent aux parties dans le document ; les références de source mènent aux fichiers du dépôt. "
        "L’état des exports, les captures et les résultats de vérification sont conservés dans les rapports de livraison."
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    missing = [name for name, _, _ in PARTS if not (DOCS / name).exists()]
    if missing:
        raise SystemExit("Required source documents are missing: " + ", ".join(missing))
    document = Document()
    configure(document)
    cover(document)
    total_words = 0
    for index, (filename, heading, anchor) in enumerate(PARTS):
        p = document.add_paragraph(heading, style="Heading 1")
        p.paragraph_format.page_break_before = True
        bookmark(p, anchor, index + 1)
        source = (DOCS / filename).read_text(encoding="utf-8")
        total_words += len(source.split())
        add_markdown(document, source, index)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    document.save(args.output)
    print(f"Built {args.output} from {len(PARTS)} Markdown sources ({total_words:,} source words).")
    print(f"Document contains {len(document.paragraphs)} paragraphs and {len(document.tables)} tables.")


if __name__ == "__main__":
    main()
