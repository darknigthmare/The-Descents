#!/usr/bin/env python3
"""Fetch only the Godot Web/Windows release templates from the official ZIP.

The HTTP server must honor byte ranges (206). A server returning the full
archive is rejected before its body is read. ZIP metadata, entry sizes and
CRC32 are verified; the complete archive SHA256 is deliberately not claimed.
Only Python's standard library is required.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import re
import tempfile
import time
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen
import zipfile
import zlib


MIB = 1024 * 1024
REQUIRED = ("version.txt", "web_nothreads_release.zip", "windows_release_x86_64.exe")
CONTENT_RANGE = re.compile(r"bytes (\d+)-(\d+)/(\d+)$")


class HttpRangeReader(io.RawIOBase):
    """Seekable, bounded remote reader used by zipfile's central-directory parser."""

    def __init__(self, url: str, timeout: float, maximum_bytes: int):
        super().__init__()
        self.source_url = url
        self.resolved_url = url
        self.timeout = timeout
        self.maximum_bytes = maximum_bytes
        self.downloaded_bytes = 0
        self.requests = 0
        self.position = 0
        self.size = 0
        self._read_range(0, 1, discover_size=True)

    def readable(self):
        return True

    def seekable(self):
        return True

    def tell(self):
        return self.position

    def seek(self, offset, whence=io.SEEK_SET):
        if whence == io.SEEK_SET:
            target = offset
        elif whence == io.SEEK_CUR:
            target = self.position + offset
        elif whence == io.SEEK_END:
            target = self.size + offset
        else:
            raise ValueError("Unknown seek mode")
        if target < 0:
            raise ValueError("Negative remote seek")
        self.position = target
        return target

    def read(self, size=-1):
        if self.closed:
            raise ValueError("Remote archive is closed")
        remaining = max(0, self.size - self.position)
        count = remaining if size is None or size < 0 else min(size, remaining)
        if count == 0:
            return b""
        if count > 8 * MIB:
            raise ValueError("Refusing an unexpectedly large single archive read")
        data = self._read_range(self.position, count)
        self.position += len(data)
        return data

    def _read_range(self, start, count, discover_size=False):
        if self.downloaded_bytes + count > self.maximum_bytes:
            raise ValueError("Configured total download limit would be exceeded")
        end = start + count - 1
        for attempt in range(3):
            request = Request(self.resolved_url, headers={
                "Range": f"bytes={start}-{end}",
                "Accept-Encoding": "identity",
                "Cache-Control": "no-cache",
                "User-Agent": "The-Tower-Descent-template-fetch/1.0",
            })
            try:
                with urlopen(request, timeout=self.timeout) as response:
                    self.requests += 1
                    if response.status != 206:
                        raise ValueError(f"Range request returned HTTP {response.status}; refusing a full-archive download")
                    match = CONTENT_RANGE.fullmatch(response.headers.get("Content-Range", ""))
                    if not match:
                        raise ValueError("Missing or invalid Content-Range header")
                    got_start, got_end, total = map(int, match.groups())
                    if (got_start, got_end) != (start, end) or total <= end:
                        raise ValueError(f"Unexpected returned byte range {got_start}-{got_end}")
                    if discover_size:
                        self.size = total
                    elif total != self.size:
                        raise ValueError("Remote archive size changed during extraction")
                    if response.headers.get("Content-Encoding", "identity") != "identity":
                        raise ValueError("Content encoding would invalidate byte offsets")
                    length = response.headers.get("Content-Length")
                    if length is not None and int(length) != count:
                        raise ValueError("Content-Length differs from the requested range")
                    data = response.read(count + 1)
                    self.downloaded_bytes += len(data)
                    if len(data) != count:
                        raise ValueError("Incomplete or overlong byte-range response")
                    self.resolved_url = response.geturl()
                    return data
            except HTTPError as error:
                if error.code not in (429, 500, 502, 503, 504) or attempt == 2:
                    raise
            except (URLError, TimeoutError):
                if attempt == 2:
                    raise
            time.sleep(0.5 * (attempt + 1))
        raise RuntimeError("Range request exhausted retries")


def file_fingerprints(path):
    sha = hashlib.sha256()
    crc = 0
    length = 0
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(MIB), b""):
            length += len(block)
            crc = zlib.crc32(block, crc)
            sha.update(block)
    return length, crc & 0xFFFFFFFF, sha.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", default="4.7.2-stable")
    parser.add_argument("--destination", type=Path, help="Override the exact Godot template-version directory")
    parser.add_argument("--list-only", action="store_true", help="Inspect central ZIP metadata without downloading template bodies")
    parser.add_argument("--timeout", type=float, default=40)
    parser.add_argument("--max-download-mib", type=int, default=192)
    args = parser.parse_args()
    if not re.fullmatch(r"\d+\.\d+(?:\.\d+)?-(?:stable|rc\d+|beta\d+)", args.version):
        parser.error("Unsupported Godot version format")
    if args.max_download_mib < 1 or args.timeout <= 0:
        parser.error("Download limit and timeout must be positive")
    version_name = args.version.replace("-", ".")
    data_home = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
    destination = args.destination or data_home / "godot/export_templates" / version_name
    source = f"https://github.com/godotengine/godot-builds/releases/download/{args.version}/Godot_v{args.version}_export_templates.tpz"
    report = {"source_url": source, "version": args.version, "archive_sha256_verified": False, "files": []}
    with HttpRangeReader(source, args.timeout, args.max_download_mib * MIB) as remote:
        with zipfile.ZipFile(remote) as archive:
            entries = {}
            for name in REQUIRED:
                matches = [info for info in archive.infolist() if info.filename == f"templates/{name}"]
                if len(matches) != 1:
                    raise ValueError(f"Expected one exact templates/{name} archive entry")
                info = matches[0]
                if info.flag_bits & 1 or info.file_size > 192 * MIB:
                    raise ValueError(f"Unsupported or unexpectedly large template entry: {name}")
                entries[name] = info
                print(f"{name}: {info.file_size:,} bytes unpacked, {info.compress_size:,} bytes compressed, CRC32 {info.CRC:08x}", flush=True)
            if not args.list_only:
                destination.mkdir(parents=True, exist_ok=True)
                for name, info in entries.items():
                    target = destination / name
                    existing = file_fingerprints(target) if target.is_file() else None
                    if existing and existing[0] == info.file_size and existing[1] == info.CRC:
                        length, crc, sha = existing
                        print(f"Verified existing {name}", flush=True)
                    else:
                        descriptor, temporary_name = tempfile.mkstemp(prefix=f".{name}.", suffix=".tmp", dir=destination)
                        temporary = Path(temporary_name)
                        try:
                            sha_digest = hashlib.sha256()
                            crc = 0
                            length = 0
                            with os.fdopen(descriptor, "wb") as output, archive.open(info) as entry:
                                for block in iter(lambda: entry.read(MIB), b""):
                                    output.write(block)
                                    length += len(block)
                                    crc = zlib.crc32(block, crc)
                                    sha_digest.update(block)
                                output.flush()
                                os.fsync(output.fileno())
                            crc &= 0xFFFFFFFF
                            if length != info.file_size or crc != info.CRC:
                                raise ValueError(f"Unpacked size or CRC32 mismatch: {name}")
                            if name == "version.txt" and temporary.read_text(encoding="utf-8").strip() != version_name:
                                raise ValueError("Template version does not match the requested Godot version")
                            sha = sha_digest.hexdigest()
                            os.replace(temporary, target)
                        except Exception:
                            temporary.unlink(missing_ok=True)
                            raise
                        print(f"Installed and verified {name}", flush=True)
                    report["files"].append({"name": name, "size": length, "crc32": f"{crc:08x}", "sha256": sha})
        report.update({"archive_size": remote.size, "downloaded_bytes": remote.downloaded_bytes, "range_requests": remote.requests, "list_only": args.list_only})
    if not args.list_only:
        (destination / "template_fetch_manifest.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2), flush=True)


if __name__ == "__main__":
    main()
