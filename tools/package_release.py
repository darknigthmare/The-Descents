"""Package the validated exports and editable project without caches or secrets."""
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


def main():
    OUT.mkdir(exist_ok=True)
    exe = ROOT / "builds/windows/TheTowerDescent.exe"
    if not exe.exists():
        raise SystemExit("Export Windows Desktop in Godot first.")
    windows = OUT / f"The-Tower-Descent-v{SHORT_VERSION}-Windows-x64.zip"
    with ZipFile(windows, "w", ZIP_DEFLATED, compresslevel=9) as z:
        z.write(exe, "The-Tower-Descent/TheTowerDescent.exe")
        z.write(ROOT / "docs/DEMARRAGE_WINDOWS.md", "The-Tower-Descent/README.md")
        for file in [ROOT / "docs/GODOT_LICENSES.txt", ROOT / "docs/EXPORTS.md"]:
            z.write(file, "The-Tower-Descent/" + file.name)
        for name in ["LICENSE.txt", "NOTICE.txt"]:
            z.write(ROOT / "prototype/assets/fonts" / name, "The-Tower-Descent/fonts/" + name)
    source = OUT / f"The-Tower-Descent-v{SHORT_VERSION}-Sources.zip"
    with ZipFile(source, "w", ZIP_DEFLATED, compresslevel=9) as z:
        for file in source_package_paths():
            z.write(file, "The-Tower-Descent/" + file.relative_to(ROOT).as_posix())
    for archive in [windows, source]:
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
