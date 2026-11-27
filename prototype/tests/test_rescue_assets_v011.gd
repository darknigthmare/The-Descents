extends SceneTree
## Asset contract only. Gameplay, persistence and action integration have separate suites.
const Assets = preload("res://scripts/rescue_asset_catalog.gd")
const EXPECTED_IDS: Array[String] = [
	"fire_axe", "extinguisher", "halligan", "bolt_cutter",
	"rescue_radio", "rescue_helmet", "trauma_bag", "rescue_flashlight",
	"oxygen_cylinder", "portable_worklight", "equipment_case", "rope_coil",
	"rescue_stretcher", "emergency_beacon", "carabiner", "descender"
]
const MATERIAL_IDS: Array[String] = [
	"salt_concrete", "smoked_oak", "dark_stone", "brushed_steel",
	"rescue_red_paint", "black_rubber", "teal_carpet", "porcelain_tile"
]
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var ids: PackedStringArray = PackedStringArray(Assets.all_ids())
	_check(ids.size() == 16, "The rescue catalog must expose exactly 16 asset IDs.")
	var seen: Dictionary = {}
	for id: String in ids:
		_check(id in EXPECTED_IDS, "Unexpected rescue asset ID: " + id)
		_check(not seen.has(id), "Duplicate rescue asset ID: " + id)
		seen[id] = true
		var path: String = Assets.asset_path(id)
		_check(not path.is_empty() and ResourceLoader.exists(path), "Missing asset resource: " + id)
		var instance: Node3D = Assets.instantiate(id)
		_check(is_instance_valid(instance), "Cannot instantiate rescue asset: " + id)
		if not is_instance_valid(instance):
			continue
		root.add_child(instance)
		var stats: Dictionary = {"meshes": 0, "surfaces": 0}
		_inspect(instance, id, stats)
		_check(int(stats["meshes"]) > 0, "Asset has no MeshInstance3D: " + id)
		_check(int(stats["surfaces"]) > 0, "Asset has no mesh surface: " + id)
		instance.free()
	for id: String in EXPECTED_IDS:
		_check(seen.has(id), "Required rescue asset absent: " + id)
	for id: String in MATERIAL_IDS:
		var path: String = "res://assets/materials/v011/" + id + ".png"
		_check(ResourceLoader.exists(path), "Missing material texture: " + path)
		if not ResourceLoader.exists(path):
			continue
		var resource: Resource = load(path)
		_check(resource is Texture2D, "Material is not a Texture2D: " + id)
		if resource is Texture2D:
			var texture: Texture2D = resource as Texture2D
			_check(texture.get_width() == 1254 and texture.get_height() == 1254,
				"Native material dimensions differ from 1254 x 1254: " + id)
	if failures.is_empty():
		print("PASS rescue assets v0.11: %d checks, 16 models and 8 native textures" % checks)
		quit(0)
	else:
		for message: String in failures:
			push_error(message)
		print("FAIL rescue assets v0.11: %d failures / %d checks" % [failures.size(), checks])
		quit(1)

func _inspect(node: Node, id: String, stats: Dictionary) -> void:
	var forbidden: bool = node is CollisionObject3D or node is CollisionShape3D or node is CollisionPolygon3D or node is Camera3D or node is Light3D
	_check(not forbidden, "Asset embeds a collider, camera or light: %s / %s" % [id, node.name])
	if node is MeshInstance3D:
		var instance: MeshInstance3D = node as MeshInstance3D
		stats["meshes"] = int(stats["meshes"]) + 1
		_check(instance.mesh != null, "Null mesh: %s / %s" % [id, node.name])
		if instance.mesh != null:
			var count: int = instance.mesh.get_surface_count()
			stats["surfaces"] = int(stats["surfaces"]) + count
			_check(count > 0, "Empty mesh surfaces: %s / %s" % [id, node.name])
	for child: Node in node.get_children():
		_inspect(child, id, stats)

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
