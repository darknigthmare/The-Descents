"""Package the validated exports and editable project without caches or secrets."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import hashlib
import shutil
import re

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
        for directory in ["prototype", "docs", "tools"]:
            for file in sorted((ROOT / directory).rglob("*")):
                rel = file.relative_to(ROOT)
                if not file.is_file() or any(p in {".godot", "rendered", "__pycache__", "visual_output"} for p in rel.parts):
                    continue
                if file.suffix in {".log", ".tmp"}:
                    continue
                z.write(file, "The-Tower-Descent/" + str(rel))
        workflow = ROOT / ".github/workflows/cinematic-review.yml"
        if workflow.exists():
            z.write(workflow, "The-Tower-Descent/.github/workflows/cinematic-review.yml")
        for name in ["README.md", "JOUER_WINDOWS.cmd", "jouer.sh", ".gitignore"]:
            z.write(ROOT / name, "The-Tower-Descent/" + name)
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
