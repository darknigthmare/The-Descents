extends Node3D
## Contextual work sites stay outside protected rescue and traversal sockets.
const Assets = preload("res://scripts/rescue_asset_catalog.gd")
const Director = preload("res://scripts/equipment_director.gd")
const POSITIONS: Dictionary = {
	"equipment_boards_29": Vector3(-8.4, 30.0, 4.35),
	"equipment_fire_28": Vector3(-6.5, 24.0, -3.8),
	"equipment_cabinet_25": Vector3(-7.0, 6.0, -3.9),
	# North of the first auditorium row, south of the escorted route at z=-4.5.
	"equipment_chain_24": Vector3(9.2, 0.0, -2.4)
}
var targets: Dictionary = {}
var changing: Dictionary = {}
var view_root: Node3D
var held_root: Node3D
var selected: String = ""
var host: Node3D
var local_fire: Node3D
var smoke: CPUParticles3D
var spray: CPUParticles3D
var work_light: SpotLight3D
var base_view_position: Vector3
var base_view_rotation: Vector3
var asset_instances: Array[Node3D] = []

func build(world: Node3D, camera: Camera3D, continuation_enabled: bool) -> Array[Node3D]:
	host = world
	name = "RescueEquipment"
	var result: Array[Node3D] = []
	for id: String in Director.ACTIONS:
		var action: Dictionary = Director.ACTIONS[id]
		if int(action["floor"]) == 24 and not continuation_enabled:
			continue
		var target: Node3D = Node3D.new()
		target.name = id
		add_child(target)
		target.position = POSITIONS[id]
		target.set_meta("kind", "equipment")
		target.set_meta("id", id)
		target.set_meta("floor", action["floor"])
		target.set_meta("title", action["title"])
		target.set_meta("focus_offset", Vector3(0, 0.85, 0))
		target.set_meta("used", false)
		targets[id] = target
		result.append(target)
		_build_worksite(id, target)
	_build_stations()
	view_root = Node3D.new()
	view_root.name = "RescueToolView"
	camera.add_child(view_root)
	view_root.hide()
	_mark_dynamic(self)
	return result

func _asset(id: String, parent: Node3D, at: Vector3, angles: Vector3 = Vector3.ZERO) -> Node3D:
	var instance: Node3D = Assets.instantiate(id)
	if instance == null:
		return null
	parent.add_child(instance)
	instance.position = at
	instance.rotation_degrees = angles
	asset_instances.append(instance)
	return instance

func _build_stations() -> void:
	var station: Node3D = Node3D.new()
	station.name = "AlphaEquipmentStation"
	add_child(station)
	# Command counter top is at y=43.98; feet remain clear of its collision.
	_asset("rescue_radio", station, Vector3(7.0, 44.0, 8.55), Vector3(0, 15, 0))
	_asset("rescue_helmet", station, Vector3(7.65, 44.0, 8.6), Vector3(0, -10, 0))
	_asset("trauma_bag", station, Vector3(8.6, 44.0, 8.65), Vector3(0, 10, 0))
	_asset("rescue_flashlight", station, Vector3(9.35, 44.0, 8.65), Vector3(0, 150, 0))
	_asset("extinguisher", station, Vector3(10.5, 42.03, 7.6), Vector3(0, 45, 0))
	_asset("oxygen_cylinder", station, Vector3(10.9, 42.03, 8.4))
	_asset("portable_worklight", station, Vector3(5.4, 42.03, 8.5), Vector3(0, -40, 0))
	_asset("equipment_case", station, Vector3(-8.0, 42.03, 4.5))
	_asset("rope_coil", station, Vector3(-8.0, 42.40, 4.5))
	_asset("rescue_stretcher", station, Vector3(10.0, 42.03, -3.6), Vector3(0, 90, 0))
	_asset("emergency_beacon", station, Vector3(5.2, 42.03, 7.0))
	var rack: Node3D = Node3D.new()
	rack.name = "InterventionRack"
	station.add_child(rack)
	rack.position = Vector3(-7.7, 42.0, 2.9)
	host._box(rack, Vector3(0, 0.72, 0), Vector3(2.25, 1.44, 0.12), host.materials["dark"])
	_asset("fire_axe", rack, Vector3(-0.72, 0.24, -0.10))
	_asset("halligan", rack, Vector3(-0.20, 0.24, -0.11))
	_asset("bolt_cutter", rack, Vector3(0.35, 0.34, -0.12))
	_asset("carabiner", rack, Vector3(0.8, 0.93, -0.15))
	_asset("descender", rack, Vector3(0.8, 0.58, -0.15))
	host._label(rack, Vector3(0, 1.75, 0), "MATÉRIEL D’INTERVENTION\n1 Hache · 2 Extincteur · 3 Halligan · 4 Coupe-boulon", 24, Color("c8d9d5"), 0.0045, true)
	var refuge_stretcher: Vector3 = Vector3(-9.2, 6.03, -6.0)
	_asset("rescue_stretcher", self, refuge_stretcher, Vector3(0, 90, 0))
	# The central fabric top is 0.088 + 0.038/2 m above the asset origin;
	# total model bounds include the higher headrest. Leave 2 mm of clearance.
	var stretcher_deck_top: float = refuge_stretcher.y + 0.107 + 0.002
	_asset("trauma_bag", self, Vector3(-9.4, stretcher_deck_top, -6.0))
	_asset("oxygen_cylinder", self, Vector3(-10.5, 6.03, -4.0))
	_asset("emergency_beacon", self, Vector3(-6.2, 6.03, -4.1))

func _build_worksite(id: String, target: Node3D) -> void:
	if id == "equipment_fire_28":
		host._cylinder(target, Vector3(0, 0.28, 0), 0.25, 0.55, host.materials["black_metal"])
		local_fire = Node3D.new()
		local_fire.name = "LocalizedFire"
		target.add_child(local_fire)
		var fire_material: StandardMaterial3D = StandardMaterial3D.new()
		fire_material.albedo_color = Color(1.0, 0.31, 0.035, 0.72)
		fire_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fire_material.emission_enabled = true
		fire_material.emission = Color(1.0, 0.22, 0.02)
		fire_material.emission_energy_multiplier = 1.4
		for index: int in range(5):
			var flame: MeshInstance3D = host._sphere(local_fire, Vector3(sin(index * 2.4) * 0.13, 0.55 + index * 0.045, cos(index * 2.4) * 0.13), Vector3(0.10, 0.20 + index * 0.025, 0.10), fire_material)
			flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		host._light(local_fire, Vector3(0, 0.8, 0), Color("ff8f3b"), 0.5, 3.5)
		smoke = _cloud(Color(0.20, 0.23, 0.24, 0.20), 18, 0.14, 0.38)
		local_fire.add_child(smoke)
		smoke.position = Vector3(0, 0.65, 0)
		smoke.emitting = false
		spray = _cloud(Color(0.89, 0.93, 0.91, 0.35), 26, 0.035, 0.10)
		target.add_child(spray)
		spray.position = Vector3(0, 0.65, 0.70)
		spray.direction = Vector3(0, -0.10, -1)
		spray.gravity = Vector3(0, -0.15, 0)
		spray.initial_velocity_min = 1.2
		spray.initial_velocity_max = 2.0
		spray.lifetime = 0.7
		spray.emitting = false
		return
	# The bounded cabinet is never a gate across a through-route.
	host._box(target, Vector3(0, 0.48, 0), Vector3(1.15, 0.96, 0.52), host.materials["metal"], true)
	var door: Node3D = Node3D.new()
	door.name = "WorksiteFront"
	target.add_child(door)
	door.position = Vector3(-0.55, 0, 0.31)
	host._box(door, Vector3(0.55, 0.53, 0), Vector3(1.06, 0.83, 0.045), host.materials["green"] if id == "equipment_cabinet_25" else host.materials["dark"])
	changing[id] = door
	if id == "equipment_boards_29":
		for tilt: float in [-0.23, 0.23]:
			var board: MeshInstance3D = host._box(door, Vector3(0.55, 0.54, 0.055), Vector3(1.05, 0.16, 0.04), host.materials["wood"])
			board.rotation.z = tilt
	elif id == "equipment_cabinet_25":
		host._box(door, Vector3(0.55, 0.55, 0.04), Vector3(0.33, 0.09, 0.02), host.materials["white"])
		host._box(door, Vector3(0.55, 0.55, 0.045), Vector3(0.09, 0.33, 0.02), host.materials["white"])
	else:
		for index: int in range(7):
			var link: MeshInstance3D = host._sphere(door, Vector3(0.2 + index * 0.12, 0.65, 0.09), Vector3(0.08, 0.035, 0.025), host.materials["metal"])
			link.rotation.z = 0.15 if index % 2 else -0.15
		# The light stays outside the door sweep and clear of the held tool.
		_asset("portable_worklight", target, Vector3(-0.95, 0.01, -0.10), Vector3(0, 65, 0))
		work_light = SpotLight3D.new()
		work_light.position = Vector3(-0.95, 0.50, -0.15)
		work_light.rotation_degrees = Vector3(-10, 65, 0)
		work_light.spot_range = 12
		work_light.spot_angle = 45
		work_light.light_color = Color("ffe3bb")
		work_light.light_energy = 2.0
		work_light.shadow_enabled = true
		work_light.visible = false
		target.add_child(work_light)
	host._label(target, Vector3(0, 1.45, 0), "SECOURS" if id != "equipment_chain_24" else "PROJECTEUR DE SECOURS", 25, Color("c2d8cc"), 0.005, true)

func _cloud(color: Color, amount: int, minimum: float, maximum: float) -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.amount = amount
	particles.lifetime = 2.2
	particles.preprocess = 0.0
	particles.direction = Vector3.UP
	particles.spread = 18
	particles.gravity = Vector3(0, 0.08, 0)
	particles.initial_velocity_min = 0.14
	particles.initial_velocity_max = 0.32
	particles.scale_amount_min = minimum
	particles.scale_amount_max = maximum
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 8
	mesh.rings = 4
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = material
	particles.mesh = mesh
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return particles

func _choose_view(id: String) -> void:
	if selected == id:
		return
	selected = id
	if is_instance_valid(held_root):
		held_root.free()
	held_root = Node3D.new()
	held_root.name = "HeldTool"
	view_root.add_child(held_root)
	var poses: Dictionary = {
		"fire_axe": [Vector3(0.39, -0.65, -0.87), Vector3(7, 168, -17)],
		"extinguisher": [Vector3(0.40, -0.58, -0.82), Vector3(-8, 195, 8)],
		"halligan": [Vector3(0.43, -0.72, -0.88), Vector3(6, 195, -16)],
		"bolt_cutter": [Vector3(0.42, -0.51, -0.86), Vector3(8, 175, -12)]}
	base_view_position = poses[id][0]
	base_view_rotation = (poses[id][1] as Vector3) * PI / 180.0
	var asset: Node3D = Assets.instantiate(id)
	if asset != null:
		held_root.add_child(asset)
		var grip: Vector3 = Assets.grip_offset(id)
		var glove: MeshInstance3D = host._sphere(held_root, grip + Vector3(0.015, 0, 0.01), Vector3(0.07, 0.09, 0.055), host.materials["dark"])
		glove.rotation.z = -0.2
		for finger: int in range(4):
			host._box(held_root, grip + Vector3(-0.025 + finger * 0.016, -0.025, -0.041), Vector3(0.013, 0.07, 0.015), host.materials["black_metal"])
	_view_layers(held_root)

func sample(state: Dictionary, show_tool: bool, after_impact: bool, reduced_motion: bool = true, time: float = 0.0) -> void:
	var done: Array = state.get("completed", [])
	for id: String in targets:
		var target: Node3D = targets[id]
		target.visible = after_impact
		target.set_meta("used", id in done)
		if changing.has(id):
			(changing[id] as Node3D).rotation.y = -1.2 if id in done else 0.0
	if is_instance_valid(local_fire):
		local_fire.visible = after_impact and "equipment_fire_28" not in done
		smoke.emitting = local_fire.visible and show_tool
		if not reduced_motion:
			local_fire.scale.y = 1.0 + sin(time * 5.0) * 0.05
		spray.emitting = show_tool and str(state.get("active_id", "")) == "equipment_fire_28"
	if is_instance_valid(work_light):
		work_light.visible = after_impact and "equipment_chain_24" in done
	if is_instance_valid(view_root):
		_choose_view(str(state.get("selected", "fire_axe")))
		view_root.visible = show_tool
		held_root.position = base_view_position
		held_root.rotation = base_view_rotation
		if not str(state.get("active_id", "")).is_empty():
			var amplitude: float = 0.035 if reduced_motion else 0.20
			held_root.rotation.x += sin(float(state.get("ratio", 0.0)) * TAU * 2.0) * amplitude

func aim_spray(origin: Vector3) -> void:
	if not is_instance_valid(spray):
		return
	spray.global_position = origin
	var focus: Vector3 = POSITIONS["equipment_fire_28"] + Vector3(0, 0.55, 0)
	spray.direction = (focus - origin).normalized()

func _view_layers(node: Node) -> void:
	if node is GeometryInstance3D:
		node.layers = 4
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	for child: Node in node.get_children():
		_view_layers(child)

func _mark_dynamic(node: Node) -> void:
	if node is GeometryInstance3D:
		node.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	for child: Node in node.get_children():
		_mark_dynamic(child)
