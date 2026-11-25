"""Shared, dependency-free evidence helpers for native Godot validation."""
from __future__ import annotations

import hashlib
import os
from pathlib import Path
import re
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
DOCUMENT_SOURCES = (
    "docs/BIBLE_DU_JEU.md",
    "docs/CATALOGUE_ETAGES.md",
    "docs/SYSTEMES_PROCEDURAUX.md",
    "docs/ARCHITECTURE_ET_PORTAGE_UE5.md",
    "docs/EFFONDREMENT_EN_DIRECT.md",
    "docs/COMMUNICATIONS_ET_EQUIPES.md",
    "docs/PROPS_INTERACTIONS.md",
    "docs/ENNEMIS_STATISTIQUES.md",
    "docs/SCENES_CINEMATIQUES.md",
    "docs/GAMEPLAY_DETAILLE.md",
    "docs/SAUVETAGE_V0.6.md",
    "docs/AMBIANCE_V0.6.md",
    "docs/CONFORT_V0.6.md",
    "docs/DOSSIER_ET_EPILOGUE_V0.7.md",
)
ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")
ERROR = re.compile(r"(?:^|\s)(?:SCRIPT ERROR:|ERROR:|Parse Error:|FAIL\b)")
PASS = re.compile(r"^PASS[^\n]*?:\s*(\d+)\s+checks\b", re.M)


def sha256(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


def version() -> str:
    return re.search(r'config/version="([^"]+)"', (ROOT / "prototype/project.godot").read_text()).group(1)


def evidence_root() -> Path:
    return ROOT / "docs/validation" / ("v" + ".".join(version().split(".")[:2]))


def runtime_hashes() -> dict[str, str]:
    """Hash authored/export-affecting files, excluding caches and test harnesses."""
    files = {}
    for path in sorted((ROOT / "prototype").rglob("*")):
        rel = path.relative_to(ROOT)
        if not path.is_file() or any(part in {".godot", "tests", "__pycache__"} for part in rel.parts):
            continue
        if path.suffix in {".uid", ".import", ".tmp", ".log"}:
            continue
        files[rel.as_posix()] = sha256(path)
    return files


def git_head() -> str:
    return subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()


def godot_binary(argument: str | None) -> str:
    selected = argument or os.environ.get("GODOT_BINARY") or shutil.which("godot4") or shutil.which("godot")
    if not selected:
        raise SystemExit("Godot was not found; pass --godot /absolute/path/to/godot.")
    return str(Path(selected).resolve())


def run(command: list[str], *, cwd: Path, timeout: int, log: Path) -> dict:
    started = time.monotonic()
    environment = os.environ.copy()
    environment["GODOT_SILENCE_ROOT_WARNING"] = "1"
    try:
        result = subprocess.run(command, cwd=cwd, env=environment, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, timeout=timeout, text=True, errors="replace")
        content, code = result.stdout, result.returncode
    except subprocess.TimeoutExpired as error:
        captured = error.stdout or ""
        if isinstance(captured, bytes):
            captured = captured.decode("utf-8", errors="replace")
        content, code = captured + f"\nERROR: QA timeout after {timeout} seconds.\n", 124
    clean = ANSI.sub("", content)
    log.write_text(clean, encoding="utf-8")
    matches = PASS.findall(clean)
    errors = [line for line in clean.splitlines() if ERROR.search(line)]
    return {
        "command": command,
        "returncode": code,
        "duration_seconds": round(time.monotonic() - started, 3),
        "error_lines": errors,
        "checks": int(matches[0]) if len(matches) == 1 else 0,
        "pass_markers": len(matches),
        "log": log.name,
        "sha256": sha256(log),
        "pass": code == 0 and not errors and len(matches) == 1 and int(matches[0]) > 0,
    }
