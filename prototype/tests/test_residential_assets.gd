extends SceneTree
## Import, resource bounds, rendering data and required authored asset contract.
const Assets = preload("res://scripts/residential_asset_catalog.gd")
const EXPECTED: Array[String] = ["rest_armchair", "medicine_cabinet", "resident_bookcase", "coffee_table", "reading_lamp", "wall_intercom", "service_latch_panel", "telecom_rack", "patch_panel", "ups_battery", "relay_console", "voice_recorder"]
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_check(Assets.all_ids().size() == EXPECTED.size(), "The residential library has an unexpected number of assets.")
	_check(Assets.asset_path("unknown").is_empty() and Assets.metadata_for("unknown").is_empty(), "Unknown asset ID invented data.")
	for id: String in EXPECTED:
		_check(id in Assets.all_ids(), "Missing authored asset: " + id)
		var instance: Node3D = Assets.instantiate(id)
		_check(is_instance_valid(instance), "Cannot instantiate authored model: " + id)
		if not is_instance_valid(instance): continue
		root.add_child(instance)
		var data: Dictionary = {"mesh_count": 0, "triangles": 0, "points": []}
		_inspect(instance, instance, data, id)
		_check(int(data["mesh_count"]) == 1, "Runtime mesh consolidation was lost: " + id)
		_check(int(data["triangles"]) > 0, "The asset contains no rendering triangles: " + id)
		var points: Array = data["points"]
		if not points.is_empty():
			var low: Vector3 = points[0]
			var high: Vector3 = points[0]
			for point: Vector3 in points:
				low = low.min(point)
				high = high.max(point)
			_check(low.is_finite() and high.is_finite(), "An asset contains non-finite geometry: " + id)
			_check(absf(low.y) < 0.002, "The bottom-centred model floats or embeds below its pivot: " + id)
			_check((high - low).distance_to(Assets.dimensions(id)) < 0.003, "Collision metadata differs from imported geometry: " + id)
			_check(absf(low.x + high.x) < 0.003 and absf(low.z + high.z) < 0.003, "The asset pivot is not horizontally centred: " + id)
		instance.free()
	if failures.is_empty():
		print("PASS residential assets: %d checks; 12 GLBs instantiated, finite bounds/pivots/mesh surfaces verified against collision metadata." % checks)
		quit(0)
	else:
		for failure: String in failures: push_error(failure)
		print("FAIL residential assets: %d failures / %d checks" % [failures.size(), checks])
		quit(1)

func _inspect(node: Node, model: Node3D, data: Dictionary, id: String) -> void:
	_check(not (node is CollisionObject3D or node is CollisionShape3D or node is Light3D or node is Camera3D), "Unrequested physics/camera/light embedded in model: " + id)
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		data["mesh_count"] = int(data["mesh_count"]) + 1
		_check(mesh_node.mesh != null and mesh_node.mesh.get_surface_count() > 0, "Missing render mesh surfaces: " + id)
		if mesh_node.mesh != null:
			for surface in range(mesh_node.mesh.get_surface_count()):
				var arrays: Array = mesh_node.mesh.surface_get_arrays(surface)
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
				data["triangles"] = int(data["triangles"]) + (indices.size() / 3 if indices.size() > 0 else vertices.size() / 3)
				_check(vertices.size() > 0 and arrays[Mesh.ARRAY_TEX_UV] is PackedVector2Array, "Missing vertices or authored UVs: " + id)
				var local: Transform3D = model.global_transform.affine_inverse() * mesh_node.global_transform
				for vertex: Vector3 in vertices: data["points"].append(local * vertex)
	for child: Node in node.get_children(): _inspect(child, model, data, id)

func _check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures.append(message)
