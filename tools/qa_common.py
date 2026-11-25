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
    "docs/PROGRESSION_HORREUR_V0.8.md",
    "docs/TRAVERSEE_ET_RAPPEL_V0.9.md",
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


SOURCE_ARCHIVE_SCOPE = "All project sources and textual history; current-version captures and documents. Versions 0.10–0.12 retain the complete v0.9 reference Bible and continuation supplements."
MAX_ARCHIVE_BYTES = 100 * 1024 * 1024


def historical_source_media(relative: Path, short_version: str) -> bool:
    """Only versioned native media are excluded; their repository files stay intact."""
    parts = relative.parts
    if len(parts) >= 4 and parts[:2] == ("docs", "captures") and re.fullmatch(r"v\d+\.\d+", parts[2]):
        return parts[2] != "v" + short_version
    if len(parts) == 2 and parts[0] == "docs":
        match = re.fullmatch(r"The-Tower-Descent-Bible-v(\d+\.\d+)\.(?:docx|pdf)", parts[1])
        if short_version in {"0.10", "0.11", "0.12"} and match is not None and match.group(1) == "0.9":
            return False
        return match is not None and match.group(1) != short_version
    return False


def source_package_paths() -> list[Path]:
    """One exact archive contract shared by the packager and release verifier.

    Every authored module, asset, test and guide stays included. Historical
    captures and compiled Bibles remain in Git and their earlier releases;
    copying them into each new source ZIP would eventually exceed GitHub's
    per-file limit without adding any current project source. Versions 0.10 and 0.11 extend the playable prototype and retain the complete v0.9 Bible.
    """
    short_version = ".".join(version().split(".")[:2])
    selected: set[Path] = set()
    for directory in ["prototype", "docs", "tools"]:
        for path in (ROOT / directory).rglob("*"):
            relative = path.relative_to(ROOT)
            if not path.is_file() or any(part in {".godot", "rendered", "__pycache__", "visual_output"} for part in relative.parts):
                continue
            if path.suffix in {".log", ".tmp"} or historical_source_media(relative, short_version):
                continue
            selected.add(path)
    selected.update(path for path in (ROOT / ".github/workflows").glob("*.yml") if path.is_file())
    selected.update(path for path in (ROOT / ".review").rglob("*.json") if path.is_file())
    selected.update(ROOT / name for name in ["README.md", "JOUER_WINDOWS.cmd", "jouer.sh", ".gitignore"])
    return sorted(selected)


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
