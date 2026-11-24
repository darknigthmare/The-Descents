extends Node3D
## Cosmetic rescue staging. Mission IDs, timers and saves remain owned by main.gd.
## No physics bodies, random draws, input handling or independent process clock.
const Geometry = preload("res://scripts/presentation_geometry.gd")
const HOIST_DURATION: float = 5.0
const RECEPTION_DURATION: float = 4.2
const DOCK: Vector3 = Vector3(3.3, 42.08, 0.0)

var world: Node3D
var camera: Camera3D
var carry_rig: Node3D
var carry_people: Dictionary = {}
var carry_id: String = ""
var hoist_rig: Node3D
var cable: MeshInstance3D
var hoist_id: String = ""
var reception_id: String = ""
var reception_elapsed: float = 0.0
var presentation_time: float = 0.0
var reception_origins: Dictionary = {}
var crew_origins: Array[Transform3D] = []
var crew_limbs: Array[Dictionary] = []

func build(source_world: Node3D, source_camera: Camera3D) -> void:
	name = "RescuePresentation"
	world = source_world
	camera = source_camera
	_build_carry()
	_build_hoist()
	for id_value: String in world.roof_rescued_people:
		reception_origins[id_value] = world.roof_rescued_people[id_value].transform
	for member: Node3D in world.alpha_roof_members:
		crew_origins.append(member.transform)
		var limbs: Dictionary = {}
		for limb: String in ["LeftArm", "RightArm", "LeftLeg", "RightLeg"]:
			var node: Node3D = member.get_node_or_null(limb)
			if is_instance_valid(node):
				limbs[limb] = node.transform
		crew_limbs.append(limbs)
	set_process(false)

static func hoist_position(seconds: float, floor_number: int) -> Vector3:
	var t: float = clampf(seconds, 0.0, HOIST_DURATION)
	var start: float = float(clampi(floor_number, 25, 30) - 24) * 6.0 + 0.6
	var lift: float = smoothstep(0.45, 4.2, t)
	var docking: float = smoothstep(4.2, HOIST_DURATION, t)
	return Vector3(lerpf(1.8, DOCK.x, docking), lerpf(start, DOCK.y, lift), 0.0)

func _build_carry() -> void:
	carry_rig = Node3D.new()
	carry_rig.name = "FirstPersonHarness"
	add_child(carry_rig)
	# The casualty sits below and to the right of the sight line. These are
	# presentation meshes only; the existing carrying speed stays authoritative.
	for record: Array in [["survivor_30", "cream"], ["survivor_28", "blue"], ["survivor_26", "cream"]]:
		var figure: Node3D = Geometry.human(world, carry_rig, Vector3(0.48, -1.49, -0.99), world.materials[record[1]], false)
		figure.name = "Carried_" + str(record[0])
		figure.scale = Vector3.ONE * 0.78
		figure.rotation.y = 2.9
		for side: String in ["Left", "Right"]:
			figure.get_node(side + "Leg").rotation.x = -0.62
			figure.get_node(side + "Arm").rotation.x = -0.9
		# Sling and crossed restraints move with the casualty.
		world._box(figure, Vector3(0, 0.99, -0.20), Vector3(0.53, 0.52, 0.045), world.materials["orange"])
		var restraint: MeshInstance3D = world._box(figure, Vector3(0, 1.06, -0.235), Vector3(0.06, 0.62, 0.022), world.materials["yellow"])
		restraint.rotation.z = 0.51
		restraint = world._box(figure, Vector3(0, 1.06, -0.25), Vector3(0.06, 0.62, 0.022), world.materials["yellow"])
		restraint.rotation.z = -0.51
		world._box(figure, Vector3(0, 1.01, -0.28), Vector3(0.12, 0.11, 0.045), world.materials["metal"])
		figure.hide()
		carry_people[record[0]] = figure
	# Alex's gloved hands and sleeves visibly support the rescue sling.
	for side: float in [-1.0, 1.0]:
		var hand_position: Vector3 = Vector3(0.17 + side * 0.29, -0.48, -0.70)
		var arm: MeshInstance3D = Geometry._capsule(carry_rig, hand_position + Vector3(side * 0.09, -0.22, 0.19), 0.075, 0.46, world.materials["orange"])
		arm.rotation.x = -0.85
		arm.rotation.z = -side * 0.28
		Geometry._sphere(carry_rig, hand_position, Vector3(0.085, 0.075, 0.12), world.materials["black_metal"])
		world._box(carry_rig, hand_position + Vector3(0, -0.10, 0.07), Vector3(0.15, 0.035, 0.13), world.materials["yellow"])
	world._box(carry_rig, Vector3(0.17, -0.44, -0.78), Vector3(0.73, 0.045, 0.06), world.materials["orange"])
	_set_view_layers(carry_rig)
	carry_rig.hide()

func _set_view_layers(node: Node) -> void:
	if node is GeometryInstance3D:
		node.layers = 4
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child: Node in node.get_children():
		_set_view_layers(child)

func _build_hoist() -> void:
	hoist_rig = Node3D.new()
	hoist_rig.name = "EvacuationHarness"
	add_child(hoist_rig)
	var m: Dictionary = world.materials
	world._box(hoist_rig, Vector3(0, 0.53, 0.04), Vector3(0.80, 0.12, 0.72), m["orange"])
	for side: float in [-1.0, 1.0]:
		Geometry._beam(world, hoist_rig, Vector3(side * 0.39, 0.59, -0.31), Vector3(side * 0.28, 1.66, -0.10), 0.025, m["yellow"])
		Geometry._beam(world, hoist_rig, Vector3(side * 0.39, 0.59, 0.36), Vector3(side * 0.28, 1.66, 0.12), 0.025, m["yellow"])
		Geometry._beam(world, hoist_rig, Vector3(side * 0.28, 1.66, 0), Vector3(0, 2.05, 0), 0.018, m["metal"])
	world._box(hoist_rig, Vector3(0, 1.05, -0.21), Vector3(0.64, 0.095, 0.07), m["yellow"])
	Geometry._sphere(hoist_rig, Vector3(0, 2.07, 0), Vector3(0.09, 0.10, 0.06), m["metal"])
	cable = world._cylinder(self, Vector3(1.8, 43, 0), 0.021, 1.0, m["cream"])
	cable.name = "TensionedEvacuationCable"
	hoist_rig.hide()
	cable.hide()

func set_carried(survivor: Node3D) -> void:
	carry_id = str(survivor.get_meta("id", "")) if is_instance_valid(survivor) else ""
	for id_value: String in carry_people:
		carry_people[id_value].visible = id_value == carry_id
	carry_rig.visible = carry_people.has(carry_id)
	_update_carry(true)

func begin_hoist(survivor: Node3D) -> void:
	finish_reception()
	set_carried(null)
	hoist_id = str(survivor.get_meta("id", ""))
	hoist_rig.show()
	cable.show()
	var body: Node3D = survivor.get_node_or_null("CivilianFigure")
	if is_instance_valid(body):
		# A seated, supported pose inside the harness, not a rigid standing lift.
		for side: String in ["Left", "Right"]:
			body.get_node(side + "Leg").rotation.x = -0.55
			body.get_node(side + "Arm").rotation.x = -0.82
	sample_hoist(survivor, 0.0, int(survivor.get_meta("floor", 30)))

func sample_hoist(survivor: Node3D, seconds: float, floor_number: int) -> void:
	if not is_instance_valid(survivor):
		return
	var location: Vector3 = hoist_position(seconds, floor_number)
	survivor.global_position = location
	hoist_rig.global_position = location
	var lower: Vector3 = location + Vector3(0, 2.13, 0)
	var upper: Vector3 = Vector3(location.x, 45.0, 0)
	cable.global_position = (lower + upper) * 0.5
	cable.scale = Vector3(1, maxf(upper.y - lower.y, 0.01), 1)
	if not world.alpha_roof_members.is_empty():
		var operator: Node3D = world.alpha_roof_members[0]
		operator.position = Vector3(4.35, 42, -1.15)
		operator.rotation.y = 1.05
		_pose_limbs(operator, 0.0, -1.05)

func finish_hoist(id_value: String) -> void:
	hoist_id = ""
	hoist_rig.hide()
	cable.hide()
	if not reception_origins.has(id_value):
		_restore_crew()
		return
	reception_id = id_value
	reception_elapsed = 0.0
	_sample_reception()

func advance(delta: float, reduced_motion: bool) -> void:
	presentation_time += maxf(delta, 0.0)
	_update_carry(reduced_motion)
	if not reception_id.is_empty():
		reception_elapsed = minf(RECEPTION_DURATION, reception_elapsed + maxf(delta, 0.0))
		_sample_reception()
		if reception_elapsed >= RECEPTION_DURATION:
			finish_reception()

func _update_carry(reduced_motion: bool) -> void:
	if not is_instance_valid(camera) or not carry_rig.visible:
		return
	var sway: Vector3 = Vector3.ZERO
	if not reduced_motion:
		sway = Vector3(sin(presentation_time * 1.3) * 0.004, sin(presentation_time * 2.1) * 0.003, 0)
	carry_rig.global_transform = camera.global_transform * Transform3D(Basis.IDENTITY, sway)

func _sample_reception() -> void:
	var patient: Node3D = world.roof_rescued_people.get(reception_id)
	if not is_instance_valid(patient):
		return
	var destination: Transform3D = reception_origins[reception_id]
	var t: float = clampf(reception_elapsed / RECEPTION_DURATION, 0.0, 1.0)
	var from: Vector3 = DOCK
	var bend: Vector3 = Vector3(4.9, 42, -4.0)
	var progress: float = smoothstep(0.0, 1.0, t)
	var location: Vector3 = from.lerp(bend, progress * 2.0) if progress < 0.5 else bend.lerp(destination.origin, (progress - 0.5) * 2.0)
	patient.position = location
	# The existing medical figure is transported. There is never a second patient.
	var body: Node3D = patient.get_node_or_null("Patient")
	if is_instance_valid(body) and reception_id != "survivor_30":
		_pose_limbs(body, sin(t * TAU * 3.0) * 0.25 * sin(t * PI), -0.25)
	if world.alpha_roof_members.size() >= 2:
		var escort: Node3D = world.alpha_roof_members[1]
		var escort_target: Vector3 = location + Vector3(0.9, 0, 0.1)
		escort_target.y = 42.0
		escort.position = escort_target
		escort.rotation.y = -0.2
		_pose_limbs(escort, sin(t * TAU * 3.0) * 0.35, -0.88)
	if not world.alpha_roof_members.is_empty():
		var operator: Node3D = world.alpha_roof_members[0]
		var return_weight: float = smoothstep(0.0, 1.0, t)
		operator.position = Vector3(4.35, 42, -1.15).lerp(crew_origins[0].origin, return_weight)
		_pose_limbs(operator, sin(t * TAU * 3.0) * 0.25, -0.25)

func _pose_limbs(figure: Node3D, stride: float, arm_angle: float) -> void:
	for side: String in ["Left", "Right"]:
		var sign_value: float = -1.0 if side == "Left" else 1.0
		var leg: Node3D = figure.get_node_or_null(side + "Leg")
		var arm: Node3D = figure.get_node_or_null(side + "Arm")
		if is_instance_valid(leg):
			leg.rotation.x = stride * sign_value
		if is_instance_valid(arm):
			arm.rotation.x = arm_angle - stride * sign_value * 0.35

func finish_reception() -> void:
	if not reception_id.is_empty() and reception_origins.has(reception_id):
		var patient: Node3D = world.roof_rescued_people[reception_id]
		patient.transform = reception_origins[reception_id]
		var body: Node3D = patient.get_node_or_null("Patient")
		if is_instance_valid(body) and reception_id != "survivor_30":
			_pose_limbs(body, 0.0, 0.0)
	reception_id = ""
	reception_elapsed = 0.0
	_restore_crew()

func _restore_crew() -> void:
	for index in range(crew_origins.size()):
		var member: Node3D = world.alpha_roof_members[index]
		member.transform = crew_origins[index]
		for limb: String in crew_limbs[index]:
			member.get_node(limb).transform = crew_limbs[index][limb]
