#!/usr/bin/env python3
"""Check the generated rescue library independently of Blender and Godot.

python tools/validate_rescue_models.py --root . --previews
This verifies files, glTF geometry/material/UV data, budgets and manifest hashes.
It deliberately does not turn an automated check into a visual-review verdict.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct

EXPECTED_IDS = {
    "fire_axe","extinguisher","halligan","bolt_cutter","rescue_flashlight",
    "portable_worklight","rescue_radio","trauma_bag","rope_coil","carabiner",
    "descender","oxygen_cylinder","rescue_helmet","rescue_stretcher",
    "equipment_case","emergency_beacon",
}
DETAIL_IDS = {"fire_axe","extinguisher","halligan","bolt_cutter"}


def read_glb(path):
    data = path.read_bytes()
    assert len(data) >= 28, f"{path}: truncated GLB"
    magic,version,length = struct.unpack_from("<4sII",data)
    assert magic == b"glTF" and version == 2 and length == len(data), f"{path}: invalid GLB header"
    offset,chunks = 12,[]
    while offset < len(data):
        size,kind = struct.unpack_from("<II",data,offset)
        offset += 8
        assert offset + size <= len(data), f"{path}: truncated GLB chunk"
        chunks.append((kind,data[offset:offset+size]))
        offset += size
    assert chunks and chunks[0][0] == 0x4E4F534A, f"{path}: missing JSON chunk"
    document = json.loads(chunks[0][1])
    assert document["asset"]["version"] == "2.0", f"{path}: unexpected glTF version"
    return data,document


def png_size(path):
    data = path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n" and data[12:16] == b"IHDR", f"{path}: invalid PNG"
    return struct.unpack_from(">II",data,16)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root",type=Path,default=Path(__file__).resolve().parents[1])
    parser.add_argument("--previews",action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    model_dir = root/"prototype/assets/models/rescue_v011"
    manifest = json.loads((model_dir/"manifest.json").read_text(encoding="utf-8"))
    records = manifest["assets"]
    assert {r["id"] for r in records} == EXPECTED_IDS and len(records) == 16
    assert manifest["units"] == "metres"
    assert manifest["runtime_axes"] == {"up":"+Y","front":"-Z","right":"+X"}
    assert manifest == json.loads((root/"docs/assets/v0.11/rescue_equipment_manifest.json").read_text(encoding="utf-8"))
    total_bytes,total_triangles = 0,0
    for record in records:
        path = model_dir/f"{record['id']}.glb"
        data,doc = read_glb(path)
        assert hashlib.sha256(data).hexdigest() == record["sha256"], f"{path}: SHA-256 mismatch"
        assert len(data) == record["bytes"], f"{path}: byte count mismatch"
        assert not doc.get("images") and not doc.get("textures"), f"{path}: duplicated image textures"
        assert not doc.get("animations") and not doc.get("skins") and not doc.get("cameras")
        assert doc.get("scenes") and doc.get("nodes") and doc.get("meshes")
        assert len(doc.get("materials",[])) >= 1
        names = {m.get("name","") for m in doc["materials"]}
        assert set(record["materials"]) == names, f"{path}: material metadata mismatch"
        triangles = 0
        for mesh in doc["meshes"]:
            for primitive in mesh["primitives"]:
                assert primitive.get("mode",4) == 4, f"{path}: non-triangle primitive"
                attributes = primitive["attributes"]
                assert {"POSITION","NORMAL","TEXCOORD_0"}.issubset(attributes), f"{path}: missing geometry, normals or UVs"
                for attr in ["POSITION","NORMAL","TEXCOORD_0"]:
                    assert doc["accessors"][attributes[attr]]["count"] > 0
                count = doc["accessors"][primitive["indices"]]["count"] if "indices" in primitive else doc["accessors"][attributes["POSITION"]]["count"]
                assert count % 3 == 0
                triangles += count // 3
        assert triangles == record["triangles"], f"{path}: triangle count {triangles} != {record['triangles']}"
        assert 200 < triangles < 100000, f"{path}: implausible geometry count"
        dimensions = record["dimensions_m"]
        assert set(dimensions) == {"x","y","z"}
        assert all(.005 < v < 3.0 for v in dimensions.values()), f"{path}: flat or wrongly scaled equipment"
        assert len(record["grip_offset_m"]) == 3
        total_bytes += len(data)
        total_triangles += triangles
        print(f"PASS {record['id']}: {triangles} triangles, {len(data)} bytes, {dimensions}")
    assert total_bytes == manifest["total_glb_bytes"]
    assert total_triangles == manifest["total_triangles"]
    assert total_bytes < 15*1024*1024, f"Runtime model budget exceeded: {total_bytes}"
    source = root/manifest["source"]["path"]
    source_data = source.read_bytes()
    assert source_data and len(source_data) == manifest["source"]["bytes"]
    assert hashlib.sha256(source_data).hexdigest() == manifest["source"]["sha256"]
    assert len(source_data) < 30*1024*1024, "Editable source unexpectedly large"
    if args.previews:
        preview_root = root/"docs/assets/v0.11"
        assert png_size(preview_root/"rescue_equipment_contact_sheet.png") == (1600,900)
        for asset_id in EXPECTED_IDS:
            assert png_size(preview_root/"renders"/f"{asset_id}.png") == (400,172)
        for asset_id in DETAIL_IDS:
            assert png_size(preview_root/"renders"/f"detail_{asset_id}.png") == (800,800)
    print(f"PASS rescue library: 16 models, {total_triangles} triangles, {total_bytes} bytes; visual inspection remains separate.")


if __name__ == "__main__":
    main()
