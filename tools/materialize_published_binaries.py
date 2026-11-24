"""Restore exact release binaries from connector-sized transport pieces.

This one-time publication helper needs only Python 3. It verifies every piece
and the complete file before placing it at the documented distribution path.
Existing matching binaries are left untouched; conflicting binaries cause an
error rather than replacing a newer export. No downloads or credentials needed.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / ".publication/v0.2/manifest.json"


def checksum(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def safe_path(relative):
    path = (ROOT / relative).resolve()
    if not path.is_relative_to(ROOT):
        raise ValueError("Publication path escapes the repository")
    return path


def matches(path, record):
    return path.is_file() and path.stat().st_size == record["size"] and checksum(path) == record["sha256"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", default=str(MANIFEST.relative_to(ROOT)), help="Repository-relative manifest path (defaults to the original v0.2 publication)")
    parser.add_argument("--clean-pieces", action="store_true", help="Remove transport pieces after every reconstructed binary passes verification")
    args = parser.parse_args()
    manifest = json.loads(safe_path(args.manifest).read_text(encoding="utf-8"))
    if manifest.get("format") != 1:
        raise ValueError("Unknown publication manifest format")
    for record in manifest["files"]:
        destination = safe_path(record["path"])
        if destination.exists():
            if not matches(destination, record):
                raise ValueError(f"Refusing to overwrite a different existing binary: {record['path']}")
            print(f"Verified existing {record['path']}")
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        temporary = destination.with_name(destination.name + ".publication.tmp")
        try:
            with temporary.open("xb") as output:
                for part in record["pieces"]:
                    piece = safe_path(part["path"])
                    if not matches(piece, part):
                        raise ValueError(f"Missing or corrupt transport piece: {part['path']}")
                    with piece.open("rb") as source:
                        for block in iter(lambda: source.read(1024 * 1024), b""):
                            output.write(block)
                output.flush()
                os.fsync(output.fileno())
            if not matches(temporary, record):
                raise ValueError(f"Reconstructed checksum mismatch: {record['path']}")
            temporary.rename(destination)
        except Exception:
            temporary.unlink(missing_ok=True)
            raise
        print(f"Reconstructed and verified {record['path']} ({record['size']} bytes)")
    if args.clean_pieces:
        for record in manifest["files"]:
            for part in record["pieces"]:
                safe_path(part["path"]).unlink(missing_ok=True)
        print("All transport pieces removed after complete verification")


if __name__ == "__main__":
    main()
