extends RefCounted
## Bootstrap catalogue. Generation replaces these provisional dimensions with measured bounds.
## tools/generate_rescue_models.py creates every authored GLB before import.
## Metres; +Y up, -Z front. Origin is the bottom bounding-box centre.

const ASSET_ROOT := "res://assets/models/rescue_v011/"
const MODELS := {
	"fire_axe": {"dimensions": Vector3(0.39, 0.89, 0.055), "grip": Vector3(0, 0.2, 0), "triangles": 0},
	"extinguisher": {"dimensions": Vector3(0.23, 0.57, 0.19), "grip": Vector3(0.02, 0.55, 0), "triangles": 0},
	"halligan": {"dimensions": Vector3(0.26, 0.9, 0.075), "grip": Vector3(0, 0.43, 0), "triangles": 0},
	"bolt_cutter": {"dimensions": Vector3(0.3, 0.65, 0.055), "grip": Vector3(-0.09, 0.2, 0), "triangles": 0},
	"rescue_flashlight": {"dimensions": Vector3(0.1, 0.28, 0.12), "grip": Vector3(0, 0.12, 0), "triangles": 0},
	"portable_worklight": {"dimensions": Vector3(0.4, 0.51, 0.3), "grip": Vector3(0, 0.49, 0), "triangles": 0},
	"rescue_radio": {"dimensions": Vector3(0.1, 0.25, 0.07), "grip": Vector3(0, 0.075, 0), "triangles": 0},
	"trauma_bag": {"dimensions": Vector3(0.47, 0.35, 0.29), "grip": Vector3(0, 0.33, 0), "triangles": 0},
	"rope_coil": {"dimensions": Vector3(0.31, 0.11, 0.24), "grip": Vector3(0, 0.05, 0), "triangles": 0},
	"carabiner": {"dimensions": Vector3(0.08, 0.13, 0.017), "grip": Vector3(0, 0.065, 0), "triangles": 0},
	"descender": {"dimensions": Vector3(0.13, 0.15, 0.017), "grip": Vector3(0, 0.05, 0), "triangles": 0},
	"oxygen_cylinder": {"dimensions": Vector3(0.18, 0.49, 0.14), "grip": Vector3(0, 0.478, 0), "triangles": 0},
	"rescue_helmet": {"dimensions": Vector3(0.31, 0.25, 0.37), "grip": Vector3(0, 0.08, 0), "triangles": 0},
	"rescue_stretcher": {"dimensions": Vector3(0.56, 0.16, 2.05), "grip": Vector3(0, 0.08, -0.91), "triangles": 0},
	"equipment_case": {"dimensions": Vector3(0.56, 0.43, 0.36), "grip": Vector3(0, 0.4, 0), "triangles": 0},
	"emergency_beacon": {"dimensions": Vector3(0.15, 0.15, 0.15), "grip": Vector3(0, 0.07, 0), "triangles": 0},
}

static func all_ids() -> PackedStringArray:
	return PackedStringArray(MODELS.keys())

static func asset_path(id: String) -> String:
	return ASSET_ROOT + id + ".glb" if MODELS.has(id) else ""

static func grip_offset(id: String) -> Vector3:
	return MODELS.get(id, {}).get("grip", Vector3.ZERO)

static func dimensions(id: String) -> Vector3:
	return MODELS.get(id, {}).get("dimensions", Vector3.ZERO)

static func metadata_for(id: String) -> Dictionary:
	var result: Dictionary = MODELS.get(id, {}).duplicate(true)
	if not result.is_empty():
		result["id"] = id
		result["path"] = asset_path(id)
	return result

static func instantiate(id: String) -> Node3D:
	var path := asset_path(id)
	if path.is_empty() or not ResourceLoader.exists(path):
		push_warning("Rescue model unavailable: " + id)
		return null
	var scene := ResourceLoader.load(path) as PackedScene
	if scene == null:
		push_warning("Rescue model did not import as a PackedScene: " + id)
		return null
	var model := scene.instantiate() as Node3D
	if model == null:
		return null
	model.name = "RescueAsset_" + id
	model.set_meta("rescue_asset_id", id)
	model.set_meta("grip_offset", grip_offset(id))
	model.set_meta("authored_model", true)
	return model
