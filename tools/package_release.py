"""Package Windows, editable sources and complementary native capture evidence."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import hashlib
import shutil
import re

from qa_common import MAX_ARCHIVE_BYTES, source_package_paths

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "releases"
VERSION = re.search(r'config/version="([^"]+)"', (ROOT / "prototype/project.godot").read_text()).group(1)
SHORT_VERSION = ".".join(VERSION.split(".")[:2])


def split_source_package_paths(paths: list[Path]) -> tuple[list[Path], list[Path]]:
    """Partition the complete source contract without dropping any of its files.

    Both ZIPs retain The-Tower-Descent/ as their extraction root. Only the
    current native capture tree moves to the companion archive; authored
    textures, GLBs, Blender sources/previews, documents and reports stay in
    Sources. The release verifier checks the exact 71-image/10-manifest set
    independently against the approved review.
    """
    current_captures = Path("docs/captures") / f"v{SHORT_VERSION}"
    native = [path for path in paths if path.relative_to(ROOT).is_relative_to(current_captures)]
    source = [path for path in paths if not path.relative_to(ROOT).is_relative_to(current_captures)]
    if len(paths) != len(set(paths)) or set(source) & set(native) or set(source) | set(native) != set(paths):
        raise SystemExit("Source/native archive partition lost or duplicated files.")
    if not source or not native:
        raise SystemExit("Both editable sources and native capture evidence are required.")
    return sorted(source), sorted(native)


def write_project_archive(archive: Path, paths: list[Path]) -> None:
    with ZipFile(archive, "w", ZIP_DEFLATED, compresslevel=9) as output:
        for path in paths:
            output.write(path, "The-Tower-Descent/" + path.relative_to(ROOT).as_posix())


def main():
    OUT.mkdir(exist_ok=True)
    exe = ROOT / "builds/windows/TheTowerDescent.exe"
    if not exe.exists():
        raise SystemExit("Export Windows Desktop in Godot first.")
    windows = OUT / f"The-Tower-Descent-v{SHORT_VERSION}-Windows-x64.zip"
    with ZipFile(windows, "w", ZIP_DEFLATED, compresslevel=9) as z:
        z.write(exe, "The-Tower-Descent/TheTowerDescent.exe")
        z.write(ROOT / "docs/DEMARRAGE_WINDOWS.md", "The-Tower-Descent/README.md")
        for name in ["JOUER_CINEMATIQUE.cmd", "JOUER_COMPATIBILITE.cmd"]:
            z.write(ROOT / "docs/launchers" / name, "The-Tower-Descent/" + name)
        for file in [ROOT / "docs/GODOT_LICENSES.txt", ROOT / "docs/EXPORTS.md"]:
            z.write(file, "The-Tower-Descent/" + file.name)
        for name in ["LICENSE.txt", "NOTICE.txt"]:
            z.write(ROOT / "prototype/assets/fonts" / name, "The-Tower-Descent/fonts/" + name)
    source = OUT / f"The-Tower-Descent-v{SHORT_VERSION}-Sources.zip"
    native = OUT / f"The-Tower-Descent-v{SHORT_VERSION}-Captures-native.zip"
    source_paths, native_paths = split_source_package_paths(source_package_paths())
    write_project_archive(source, source_paths)
    write_project_archive(native, native_paths)
    for archive in [windows, source, native]:
        if archive.stat().st_size >= MAX_ARCHIVE_BYTES:
            raise SystemExit("Archive exceeds the strict 100 MiB publication limit: " + archive.name)
    hashes = []
    for file in sorted(OUT.glob("*.zip")):
        digest = hashlib.sha256(file.read_bytes()).hexdigest()
        hashes.append(f"{digest}  {file.name}")
        print(f"{file.name}: {file.stat().st_size:,} bytes")
    (OUT / "SHA256SUMS.txt").write_text("\n".join(hashes) + "\n", encoding="utf-8")
    # Runtime notices must accompany the web distribution too.
    shutil.copy2(ROOT / "docs/GODOT_LICENSES.txt", ROOT / "dist/GODOT_LICENSES.txt")
    for name in ["LICENSE", "NOTICE"]:
        shutil.copy2(ROOT / "prototype/assets/fonts" / (name + ".txt"), ROOT / "dist" / ("OPEN_SANS_" + name + ".txt"))


if __name__ == "__main__":
    main()
