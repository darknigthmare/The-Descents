extends SceneTree
## Every final albedo asset is required; missing files only have a safe runtime
## fallback so a work-in-progress import cannot break script parsing.
const Surfaces = preload("res://scripts/surface_materials.gd")
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var library: RefCounted = Surfaces.new()
	_check(Surfaces.CATALOG.size() == 8, "Material source catalogue is incomplete.")
	for id: String in Surfaces.CATALOG:
		var material: StandardMaterial3D = library.get_surface(id)
		var spec: Dictionary = Surfaces.CATALOG[id]
		_check(ResourceLoader.exists(Surfaces.ASSET_ROOT + id + ".png"), "Required authored albedo asset is absent: " + id)
		_check(material.albedo_texture != null and bool(material.get_meta("asset_loaded", false)), "Final material still uses a placeholder colour: " + id)
		if material.albedo_texture != null:
			_check(material.albedo_texture.get_width() >= 256 and material.albedo_texture.get_height() >= 256, "Authored albedo is unexpectedly small: " + id)
		_check(material.uv1_triplanar and material.uv1_world_triplanar and material.texture_repeat, "Static surface is not repeated triplanar in world units: " + id)
		_check(material.uv1_scale.is_equal_approx(Vector3.ONE / float(spec["repeat_m"])), "Material repeat size does not match metres: " + id)
		_check(material.roughness >= 0.3 and material.roughness <= 1.0, "Roughness would erase useful material differentiation: " + id)
		_check(material.normal_enabled and material.normal_texture != null and material.roughness_texture != null, "Procedural microdetail is missing: " + id)
		_check(material.normal_scale > 0.0 and material.normal_scale <= 0.3, "Microdetail creates oversized relief: " + id)
		_check(material.normal_texture.get_width() == Surfaces.DETAIL_SIZE, "Normal map is not the bounded procedural detail texture: " + id)
		_check(material.get_meta("microdetail_source", "") == "deterministic procedural approximation", "Procedural maps are misidentified as scanned assets: " + id)
		_check(library.get_surface(id) == material, "Repeated material lookup duplicates resources: " + id)
		var local: StandardMaterial3D = library.local_variant(material)
		_check(local != material and local.uv1_triplanar and not local.uv1_world_triplanar, "Moving variant does not use object-local projection: " + id)
		_check(material.uv1_world_triplanar, "Requesting a moving variant mutates static world materials: " + id)
		_check(local.albedo_texture == material.albedo_texture and local.normal_texture == material.normal_texture and local.roughness_texture == material.roughness_texture, "Moving variant wastes or changes texture sources: " + id)
		_check(library.local_variant(material) == local and library.local_variant(local) == local, "Moving variants are not cached and idempotent.")
	_check(library.get_surface("brushed_steel").metallic > 0.7, "Brushed steel lost its metallic response.")
	_check(is_zero_approx(library.get_surface("black_rubber").metallic), "Rubber is incorrectly treated as a metal.")
	_check(library.get_surface("porcelain_tile").roughness < library.get_surface("salt_concrete").roughness, "Porcelain and concrete have identical roughness responses.")
	var tinted: StandardMaterial3D = library.get_surface("salt_concrete", Color("a1abad"))
	_check(tinted != library.get_surface("salt_concrete") and tinted.albedo_color.is_equal_approx(Color("a1abad")), "Tinted concrete variants collide in the cache.")
	var unknown: StandardMaterial3D = library.get_surface("missing_catalogue_entry", Color("aabbcc"))
	_check(unknown != null and unknown.albedo_texture == null and unknown.albedo_color.is_equal_approx(Color("aabbcc")), "Unknown material has no safe visible fallback.")
	var snapshot: Dictionary = library.snapshot()
	_check(snapshot["assets"].size() == 8 and str(snapshot["projection"]).contains("triplanar"), "Material provenance snapshot is incomplete.")
	for record: Dictionary in snapshot["assets"]:
		_check(record["loaded"], "Material manifest reports a missing final PNG: " + str(record["file"]))
	if failures.is_empty():
		print("PASS surface materials v0.11: %d checks; eight authored assets, metre-scale UVs, bounded procedural detail and local moving variants." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		quit(1)
