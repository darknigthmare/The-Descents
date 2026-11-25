extends Node3D
class_name DescentHorrorPresentation
## Collision-free material impressions. No autonomous ticking or gameplay effects.
const Director = preload("res://scripts/horror_director.gd")

var suites_figure: Node3D
var trace_root: Node3D
var spa_figure: Node3D
var _suites_materials: Array[StandardMaterial3D] = []
var _spa_materials: Array[StandardMaterial3D] = []
var _trace_materials: Array[StandardMaterial3D] = []
var _prints: Array[Node3D] = []

func build(_world: Node3D) -> void:
	for child: Node in get_children():
		child.free()
	_suites_materials.clear()
	_spa_materials.clear()
	_trace_materials.clear()
	_prints.clear()
	name = "EarlyManifestations"
	set_process(false)
	set_physics_process(false)
	suites_figure = _figure("PeripheralSuites", Director.SUITES_POSITION, _suites_materials, false)
	suites_figure.rotation.y = -0.4
	spa_figure = _figure("SpaPresence", Director.SPA_POSITION, _spa_materials, true)
	spa_figure.rotation.y = 1.05
	trace_root = Node3D.new()
	trace_root.name = "DampArchiveTraces"
	add_child(trace_root)
	for index: int in range(8):
		var footprint: Node3D = Node3D.new()
		footprint.name = "Print%02d" % index
		trace_root.add_child(footprint)
		var side: float = -1.0 if index % 2 == 0 else 1.0
		footprint.position = Vector3(-6.0 + side * 0.14, 24.018, 0.8 + float(index) * 0.51)
		footprint.rotation.y = side * 0.13
		var mat: StandardMaterial3D = _material(Color("182a30"), 0.19)
		_trace_materials.append(mat)
		# A tapered sole, heel and broken toe marks read as wet shoes rather
		# than magical symbols. Each print has its own reversible opacity.
		_flat_oval(footprint, Vector3(0, 0, -0.045), Vector2(0.13, 0.21), mat)
		_flat_oval(footprint, Vector3(0, 0.001, 0.115), Vector2(0.105, 0.105), mat)
		for groove: int in range(3):
			var glint: StandardMaterial3D = _material(Color("37515a"), 0.12)
			_trace_materials.append(glint)
			_box(footprint, Vector3(0, 0.002, -0.10 + groove * 0.035), Vector3(0.095, 0.002, 0.012), glint)
		_prints.append(footprint)
	clear()

func clear() -> void:
	if is_instance_valid(suites_figure):
		suites_figure.hide()
	if is_instance_valid(spa_figure):
		spa_figure.hide()
	if is_instance_valid(trace_root):
		trace_root.hide()
	_set_alpha(_suites_materials, 0.0)
	_set_alpha(_spa_materials, 0.0)
	_set_alpha(_trace_materials, 0.0)

func sample(frame: Dictionary, _reduced_motion: bool = true) -> void:
	var suites_alpha: float = _finite_alpha(frame.get("suites_alpha", 0.0))
	var spa_alpha: float = _finite_alpha(frame.get("spa_alpha", 0.0))
	var trace_alpha: float = _finite_alpha(frame.get("trace_alpha", 0.0))
	var progress: float = _finite_alpha(frame.get("trace_progress", 0.0))
	if is_instance_valid(suites_figure):
		suites_figure.visible = suites_alpha > 0.001
	if is_instance_valid(spa_figure):
		spa_figure.visible = spa_alpha > 0.001
	if is_instance_valid(trace_root):
		trace_root.visible = trace_alpha > 0.001 and progress > 0.0
	_set_alpha(_suites_materials, suites_alpha)
	_set_alpha(_spa_materials, spa_alpha)
	for index: int in range(_prints.size()):
		var print_alpha: float = trace_alpha * clampf(progress * 8.0 - float(index), 0.0, 1.0)
		_prints[index].visible = print_alpha > 0.001
		for child: Node in _prints[index].get_children():
			if child is MeshInstance3D:
				var material: StandardMaterial3D = child.material_override
				material.albedo_color.a = print_alpha

func _figure(id_value: String, position_value: Vector3, materials: Array[StandardMaterial3D], spa: bool) -> Node3D:
	var figure: Node3D = Node3D.new()
	figure.name = id_value
	add_child(figure)
	figure.position = position_value
	figure.set_meta("role", "unverified_perception")
	figure.set_meta("collision_free", true)
	var coat: StandardMaterial3D = _material(Color("283338") if spa else Color("293438"), 0.96)
	var seam: StandardMaterial3D = _material(Color("414746"), 0.92)
	var skin: StandardMaterial3D = _material(Color("57615e"), 0.98)
	var dark: StandardMaterial3D = _material(Color("101c22"), 0.92)
	materials.append_array([coat, seam, skin, dark])
	# Human proportions and a closed coat, with no eye lights, horns, weapon
	# or aggressive pose. The bowed head gives a plausible distant bystander.
	_sphere(figure, Vector3(0, 1.57, -0.025), Vector3(0.17, 0.225, 0.17), skin)
	_sphere(figure, Vector3(0, 1.70, 0.015), Vector3(0.18, 0.11, 0.175), dark)
	_sphere(figure, Vector3(0, 1.17, 0), Vector3(0.25, 0.34, 0.15), coat)
	var hem: MeshInstance3D = _cylinder(figure, Vector3(0, 0.78, 0), 0.21, 0.27, 0.52, coat)
	hem.scale.z = 0.67
	_box(figure, Vector3(0.01, 1.11, -0.152), Vector3(0.025, 0.53, 0.012), seam)
	for side: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = _cylinder(figure, Vector3(side * 0.285, 1.08, 0.015), 0.073, 0.085, 0.54, coat)
		arm.rotation.z = side * 0.075
		_sphere(figure, Vector3(side * 0.31, 0.79, 0.015), Vector3(0.065, 0.10, 0.055), dark)
		_cylinder(figure, Vector3(side * 0.105, 0.32, 0.02), 0.082, 0.075, 0.55, dark)
		_sphere(figure, Vector3(side * 0.105, 0.07, -0.045), Vector3(0.085, 0.075, 0.15), dark)
	if spa:
		# A folded towel is just a pale edge; the figure remains interpretable
		# as a resident without copying the named survivor or medical receipt.
		_box(figure, Vector3(-0.12, 1.25, -0.16), Vector3(0.10, 0.35, 0.025), seam)
	return figure

func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_BACK
	material.disable_receive_shadows = true
	return material

func _set_alpha(materials: Array[StandardMaterial3D], alpha: float) -> void:
	for material: StandardMaterial3D in materials:
		material.albedo_color.a = alpha

func _finite_alpha(value: Variant) -> float:
	if typeof(value) not in [TYPE_FLOAT, TYPE_INT] or not is_finite(float(value)):
		return 0.0
	return clampf(float(value), 0.0, 1.0)

func _mesh(parent: Node3D, position_value: Vector3, mesh: Mesh, material: Material) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	node.position = position_value
	node.mesh = mesh
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	return node

func _box(parent: Node3D, position_value: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	return _mesh(parent, position_value, mesh, material)

func _sphere(parent: Node3D, position_value: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	var node: MeshInstance3D = _mesh(parent, position_value, mesh, material)
	node.scale = size
	return node

func _cylinder(parent: Node3D, position_value: Vector3, top: float, bottom: float, height: float, material: Material) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = top
	mesh.bottom_radius = bottom
	mesh.height = height
	mesh.radial_segments = 16
	return _mesh(parent, position_value, mesh, material)

func _flat_oval(parent: Node3D, position_value: Vector3, size: Vector2, material: Material) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 1.0
	mesh.bottom_radius = 1.0
	mesh.height = 0.003
	mesh.radial_segments = 16
	var node: MeshInstance3D = _mesh(parent, position_value, mesh, material)
	node.scale = Vector3(size.x, 1.0, size.y)
	return node
