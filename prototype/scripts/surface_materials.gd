extends RefCounted
class_name DescentSurfaceMaterials

## Authored albedo PNGs plus small deterministic procedural microdetail maps.
## The normal/roughness maps are authored approximations, not scanned PBR data.
## World-space triplanar UVs keep walls, slabs and furniture at metre scale.
## Movers get object-space variants so surfaces do not swim as they move.

const ASSET_ROOT: String = "res://assets/materials/v011/"
const DETAIL_SIZE: int = 128
const CATALOG: Dictionary = {
	"salt_concrete": {"repeat_m": 2.0, "roughness": 0.92, "metallic": 0.0, "normal": 0.24, "fallback": Color("697275")},
	"smoked_oak": {"repeat_m": 1.4, "roughness": 0.73, "metallic": 0.0, "normal": 0.16, "fallback": Color("675449")},
	"dark_stone": {"repeat_m": 1.8, "roughness": 0.47, "metallic": 0.0, "normal": 0.13, "fallback": Color("3b444a")},
	"brushed_steel": {"repeat_m": 0.8, "roughness": 0.44, "metallic": 0.78, "normal": 0.09, "fallback": Color("9ba5a8")},
	"rescue_red_paint": {"repeat_m": 0.8, "roughness": 0.57, "metallic": 0.15, "normal": 0.09, "fallback": Color("a84336")},
	"black_rubber": {"repeat_m": 0.5, "roughness": 0.88, "metallic": 0.0, "normal": 0.17, "fallback": Color("283034")},
	"teal_carpet": {"repeat_m": 1.0, "roughness": 0.96, "metallic": 0.0, "normal": 0.27, "fallback": Color("42656c")},
	"porcelain_tile": {"repeat_m": 1.2, "roughness": 0.34, "metallic": 0.0, "normal": 0.10, "fallback": Color("c0c4bd")}
}

var _materials: Dictionary = {}
var _detail_maps: Dictionary = {}
var _local_variants: Dictionary = {}

func get_surface(id: String, tint: Color = Color.WHITE) -> StandardMaterial3D:
	if not CATALOG.has(id):
		return _plain_fallback(tint)
	var key: String = id + ":" + tint.to_html()
	if _materials.has(key):
		return _materials[key]
	var spec: Dictionary = CATALOG[id]
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.resource_name = "v011_" + id
	var asset: String = ASSET_ROOT + id + ".png"
	var texture: Texture2D = load(asset) as Texture2D if ResourceLoader.exists(asset) else null
	material.albedo_texture = texture
	material.albedo_color = tint if texture != null else (spec["fallback"] as Color) * tint
	material.roughness = float(spec["roughness"])
	material.metallic = float(spec["metallic"])
	material.metallic_specular = 0.5
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	material.texture_repeat = true
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_triplanar_sharpness = 6.0
	material.uv1_scale = Vector3.ONE / float(spec["repeat_m"])
	var detail: Dictionary = _get_detail_maps(id)
	material.normal_enabled = true
	material.normal_texture = detail["normal"]
	material.normal_scale = float(spec["normal"])
	material.roughness_texture = detail["roughness"]
	material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	material.set_meta("v011_surface", id)
	material.set_meta("albedo_asset", asset)
	material.set_meta("asset_loaded", texture != null)
	material.set_meta("metres_per_repeat", float(spec["repeat_m"]))
	material.set_meta("microdetail_source", "deterministic procedural approximation")
	_materials[key] = material
	return material

func local_variant(material: Material) -> Material:
	if not material is StandardMaterial3D or not material.has_meta("v011_surface"):
		return material
	if not material.uv1_world_triplanar:
		return material
	var key: int = material.get_instance_id()
	if _local_variants.has(key):
		return _local_variants[key]
	var variant: StandardMaterial3D = material.duplicate()
	variant.resource_name = material.resource_name + "_local"
	variant.uv1_world_triplanar = false
	_local_variants[key] = variant
	return variant

func localize_moving_branch(branch: Node) -> void:
	if branch is MeshInstance3D and branch.material_override != null:
		branch.material_override = local_variant(branch.material_override)
	for child: Node in branch.get_children():
		localize_moving_branch(child)

func snapshot() -> Dictionary:
	var assets: Array[Dictionary] = []
	for id: String in CATALOG:
		var path: String = ASSET_ROOT + id + ".png"
		assets.append({"id": id, "file": path, "loaded": ResourceLoader.exists(path), "repeat_m": CATALOG[id]["repeat_m"]})
	return {"assets": assets, "albedo_source": "authored PNG assets", "microdetail_source": "deterministic procedural approximation", "projection": "world-space triplanar; local-space for movers"}

func _get_detail_maps(id: String) -> Dictionary:
	if _detail_maps.has(id):
		return _detail_maps[id]
	var height: Image = Image.create(DETAIL_SIZE, DETAIL_SIZE, false, Image.FORMAT_RGB8)
	var roughness: Image = Image.create(DETAIL_SIZE, DETAIL_SIZE, false, Image.FORMAT_RGB8)
	# Integer-frequency waves are periodic across each edge, preventing a
	# generated seam. They only add restrained relief to the authored colour.
	for y in range(DETAIL_SIZE):
		for x in range(DETAIL_SIZE):
			var u: float = TAU * float(x) / float(DETAIL_SIZE)
			var v: float = TAU * float(y) / float(DETAIL_SIZE)
			var relief: float = 0.5 + 0.10 * sin(u * 17.0 + sin(v * 9.0)) + 0.08 * sin(v * 23.0 + u * 11.0)
			if id == "smoked_oak":
				relief = 0.5 + 0.14 * sin(u * 25.0 + 0.8 * sin(v * 2.0)) + 0.03 * sin(v * 11.0)
			elif id == "brushed_steel":
				relief = 0.5 + 0.06 * sin(u * 51.0) + 0.025 * sin(u * 29.0 + v * 2.0)
			elif id == "teal_carpet":
				relief = 0.5 + 0.12 * sin(u * 39.0) * sin(v * 37.0)
			elif id == "porcelain_tile":
				relief = 0.5 + 0.025 * sin(u * 21.0 + v * 13.0)
			height.set_pixel(x, y, Color(relief, relief, relief))
			var rough: float = 0.88 + 0.10 * relief
			roughness.set_pixel(x, y, Color(rough, rough, rough))
	height.bump_map_to_normal_map(0.8)
	height.generate_mipmaps(true)
	roughness.generate_mipmaps()
	var result: Dictionary = {"normal": ImageTexture.create_from_image(height), "roughness": ImageTexture.create_from_image(roughness)}
	_detail_maps[id] = result
	return result

static func _plain_fallback(tint: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.8
	material.set_meta("asset_loaded", false)
	return material
