extends Node3D
class_name DescentCommercePresentation
## Three authored floors, coherent stair escort corridors, local fire state and
## a distressed resident. The mission owns clocks and confirmed rescue receipts.

const Director = preload("res://scripts/commerce_director.gd")
const Routes = preload("res://scripts/route_catalog.gd")
const Assets = preload("res://scripts/commerce_asset_catalog.gd")
const RescueAssets = preload("res://scripts/rescue_asset_catalog.gd")
const STARTS: Dictionary = {"mina": Vector3(8.0, -11.94, -8.6), "theo": Vector3(8.5, -17.94, -8.2), "sofia": Vector3(8.8, -23.94, -7.8)}
const RECEIVING: Dictionary = {"mina": Vector3(5.8, -23.94, 3.8), "theo": Vector3(7.4, -23.94, 3.8), "sofia": Vector3(9.0, -23.94, 3.8)}
const LEAD_DISTANCE: float = 5.0
const SPEED: float = 1.35
const SMOKE_BOUNDS := AABB(Vector3(5.2, -18.1, 0.8), Vector3(6.1, 4.5, 6.7))
var people: Dictionary = {}
var figures: Dictionary = {}
var paths: Dictionary = {}
var cursors: Dictionary = {}
var arrived: Dictionary = {}
var walk_clocks: Dictionary = {}
var statuses: Dictionary = {}
var person_targets: Dictionary = {}
var action_targets: Dictionary = {}
var name_labels: Dictionary = {}
var shutter: Node3D
var shutter_body: StaticBody3D
var fire_group: Node3D
var smoke_group: Node3D
var blanket_mesh: MeshInstance3D
var fire_light: OmniLight3D
var kitchen_light: OmniLight3D
var refuge_light: OmniLight3D
var relay_screen: MeshInstance3D
var resident: Node3D
var resident_target: Node3D
var resident_sign: Label3D
var relay_sign: Label3D
var remanence: Node3D
var remanence_clock: float = 0.0
var remanence_seen: bool = false
var last_actions: Array = []
var chapter_active: bool = false
var _world: Node3D

func build(world: Node3D) -> void:
	_world = world
	name = "CommerceKitchenAndRefuge"
	set_process(false)
	set_physics_process(false)
	_build_gallery(world.get_node("Floor22"))
	_build_kitchen(world.get_node("Floor21"))
	_build_refuge(world.get_node("Floor20"))
	_build_people()
	for branch: Node in [shutter, fire_group, smoke_group, blanket_mesh, resident, remanence]:
		_world.mark_dynamic_lighting_branch(branch)
	for person: CharacterBody3D in people.values():
		_world.mark_dynamic_lighting_branch(person)

func apply_state(value: Dictionary) -> void:
	chapter_active = value.get("phase", "dormant") == "active"
	last_actions = value.get("actions", []).duplicate()
	for id: String in Director.PERSON_IDS:
		var next: String = str(value.get("people", {}).get(id, "waiting"))
		if next == "received" and statuses.get(id, "") != "received":
			people[id].global_position = RECEIVING[id]
			people[id].velocity = Vector3.ZERO
			cursors[id] = paths[id].size()
			arrived[id] = true
		statuses[id] = next
		person_targets[id].set_meta("used", next == "received")
	_update_people_labels(Vector3.INF)
	var opened: bool = "shutter" in last_actions
	shutter.position.y = -8.55 if opened else -10.65
	shutter_body.collision_layer = 0 if opened else 1
	shutter_body.collision_mask = 0 if opened else 1
	var contained: bool = "blanket" in last_actions
	fire_group.visible = not contained
	smoke_group.visible = not contained
	blanket_mesh.visible = contained
	fire_light.visible = not contained
	kitchen_light.light_color = Color("a3bdb8") if "isolation" in last_actions else Color("edd3a0")
	kitchen_light.light_energy = 0.95 if "isolation" in last_actions else 1.6
	var online: bool = "relay" in last_actions
	refuge_light.light_energy = 1.7 if online else 0.8
	relay_screen.material_override = _world.materials["lit_green"] if online else _world.materials["screen"]
	relay_sign.text = "RELAIS 20 · LIAISON RÉTABLIE\nTRANSMETTRE LE BILAN ICI" if online else "RELAIS 20 · ALIMENTATION DE SECOURS\nMAINTENIR E AU PANNEAU"
	for id: String in action_targets:
		action_targets[id].set_meta("used", id in last_actions)
	if "resident" in last_actions:
		resident_sign.text = "IL A BAISSÉ LES BRAS\n« La voix était déjà là avant. »"
		resident.get_node("RightArm").rotation.x = -0.15
		resident.get_node("LeftArm").rotation.x = -0.1

func advance(delta: float, player_position: Vector3, running: bool, allow_unease: bool, lamp_enabled: bool, reduced_motion: bool) -> void:
	if not running or not chapter_active or not is_finite(delta) or delta <= 0.0 or not player_position.is_finite():
		return
	var step: float = minf(delta, 0.05)
	for id: String in Director.PERSON_IDS:
		_advance_person(id, step, player_position)
	_update_people_labels(player_position)
	_sample_resident(player_position, lamp_enabled)
	if not allow_unease:
		remanence.hide()
		return
	if not remanence_seen and player_position.y < -16.7 and player_position.y > -18.5 and player_position.x < -3.2:
		remanence_clock += step
		# A repeated distant shape lasts longer than the first upper-floor cue,
		# but has no gameplay damage, camera takeover or confirmed explanation.
		remanence.visible = remanence_clock > 2.0 and remanence_clock < 6.5
		if remanence_clock >= 6.5:
			remanence_seen = true
			remanence.hide()
	elif remanence_seen:
		remanence.hide()
	if not reduced_motion and fire_group.visible:
		fire_light.light_energy = 0.8 + 0.10 * sin(Time.get_ticks_msec() * 0.007)

func smoke_exposure(position_value: Vector3) -> bool:
	return chapter_active and "blanket" not in last_actions and SMOKE_BOUNDS.has_point(position_value)

func resident_pressure(position_value: Vector3, lamp_enabled: bool) -> float:
	if not chapter_active or "resident" in last_actions or absf(position_value.y + 12.0) > 1.0:
		return 0.0
	var distance: float = position_value.distance_to(resident.global_position)
	return 1.1 if distance < 2.0 else (0.45 if distance < 4.0 and lamp_enabled else 0.0)

func physically_arrived(id: String) -> bool:
	if not people.has(id) or not bool(arrived.get(id, false)): return false
	var body: CharacterBody3D = people[id]
	return body.global_position.distance_to(RECEIVING[id]) < 0.28 and absf(body.velocity.y) < 0.15 and _support(body)

func snapshot() -> Dictionary:
	var positions: Dictionary = {}
	for id: String in Director.PERSON_IDS: positions[id] = people[id].global_position
	return {"positions": positions, "cursors": cursors.duplicate(), "statuses": statuses.duplicate(), "arrived": arrived.duplicate(), "actions": last_actions.duplicate(), "remanence_seen": remanence_seen}

func _advance_person(id: String, delta: float, player_position: Vector3) -> void:
	var body: CharacterBody3D = people[id]
	var allow: bool = statuses.get(id) == "following" and not bool(arrived[id]) and body.global_position.distance_to(player_position) <= LEAD_DISTANCE
	# Match the lead person's pace when two paths converge. World collision
	# remains authoritative, while civilians do not shove the player down stairs.
	if allow:
		for other: String in Director.PERSON_IDS:
			if other == id or statuses.get(other) != "following" or bool(arrived[other]): continue
			if id > other and body.global_position.distance_to(people[other].global_position) < 0.95:
				allow = false
	var planar: Vector3 = Vector3.ZERO
	if allow:
		var target: Vector3 = paths[id][int(cursors[id])]
		var offset := Vector3(target.x - body.global_position.x, 0, target.z - body.global_position.z)
		if offset.length() < 0.13 and absf(body.global_position.y - target.y) < 0.25 and _support(body):
			cursors[id] = int(cursors[id]) + 1
			if int(cursors[id]) >= paths[id].size():
				arrived[id] = true
			else:
				target = paths[id][int(cursors[id])]
				offset = Vector3(target.x - body.global_position.x, 0, target.z - body.global_position.z)
		if not bool(arrived[id]): planar = offset.normalized() * minf(SPEED, offset.length() / maxf(delta, 0.001))
	body.velocity.x = planar.x
	body.velocity.z = planar.z
	body.velocity.y = 0.0 if body.is_on_floor() else body.velocity.y - 16.0 * delta
	body.move_and_slide()
	if planar.length() > 0.01:
		figures[id].rotation.y = lerp_angle(figures[id].rotation.y, atan2(-planar.x, -planar.z), minf(1.0, delta * 8.0))
		walk_clocks[id] = float(walk_clocks[id]) + delta * 7.0
	_world._pose_human_walk(figures[id], float(walk_clocks[id]), clampf(planar.length() / SPEED, 0.0, 1.0))
	person_targets[id].set_meta("floor", clampi(roundi((body.global_position.y - 0.06) / 6.0) + 24, 20, 22))

func _support(body: CharacterBody3D) -> bool:
	var origin := body.global_position + Vector3.UP * 0.12
	var query := PhysicsRayQueryParameters3D.create(origin, origin + Vector3.DOWN * 0.40, 1, [body.get_rid()])
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and Vector3(hit.get("normal", Vector3.ZERO)).y > 0.65

func _update_people_labels(player_position: Vector3) -> void:
	for id: String in Director.PERSON_IDS:
		var close: bool = player_position.is_finite() and people[id].global_position.distance_to(player_position) <= LEAD_DISTANCE
		var status: String = str(statuses.get(id, "waiting"))
		var instruction: String = "AU REFUGE 20" if status == "received" else ("JE VOUS SUIS" if status == "following" and close else "J’ATTENDS · RESTEZ À MOINS DE 5 m" if status == "following" else "E · SUIVEZ-MOI / ATTENDEZ")
		name_labels[id].text = str(Director.PEOPLE[id]["name"]) + "\n" + instruction

func _build_people() -> void:
	for id: String in Director.PERSON_IDS:
		var body := CharacterBody3D.new()
		body.name = "Rescue_" + id
		body.collision_layer = 2
		body.collision_mask = 1
		body.floor_snap_length = 0.25
		var capsule := CapsuleShape3D.new()
		capsule.radius = 0.30
		capsule.height = 1.72
		var collider := CollisionShape3D.new()
		collider.shape = capsule
		collider.position.y = 0.87
		body.add_child(collider)
		add_child(body)
		body.global_position = STARTS[id]
		people[id] = body
		var figure: Node3D = _world._human(body, Vector3.ZERO, _world.materials[{"mina": "green", "theo": "white", "sofia": "blue"}[id]], false)
		figure.rotation.y = PI
		figures[id] = figure
		if id == "theo":
			_world._box(figure, Vector3(0, 1.04, -0.18), Vector3(0.4, 0.62, 0.035), _world.materials["cream"])
		elif id == "sofia":
			_world._box(figure, Vector3(0, 1.12, -0.19), Vector3(0.43, 0.055, 0.035), _world.materials["yellow"])
		else:
			_world._box(figure, Vector3(0.14, 1.25, -0.19), Vector3(0.10, 0.16, 0.02), _world.materials["white"])
		var target: Node3D = _world._interaction(body, Vector3.ZERO, "commerce_person", "commerce_person_" + id, Director.PEOPLE[id]["floor"], Director.PEOPLE[id]["name"], "Accompagnement à pied jusqu’aux marques du refuge 20. E pour suivre ou attendre ; rester à moins de 5 mètres.")
		target.set_meta("person_id", id)
		person_targets[id] = target
		name_labels[id] = _world._label(body, Vector3(0, 2.15, 0), "", 23, Color("c7e9dc"), 0.0048, true)
		paths[id] = _escort_path(id)
		cursors[id] = 0
		arrived[id] = false
		statuses[id] = "waiting"
		walk_clocks[id] = 0.0

func _escort_path(id: String) -> Array[Vector3]:
	var result: Array[Vector3] = []
	if id == "mina":
		result.assign([Vector3(8, -11.94, -5.1), Vector3(4.6, -11.94, -4.5), Vector3(1.3, -11.94, -4.5)])
		for point: Vector3 in Routes.for_id("S22_21")["path_points"]: result.append(point)
		result.append(Vector3(-1.3, -17.94, -4.5))
	elif id == "theo":
		result.assign([Vector3(8.5, -17.94, -4.5), Vector3(4.6, -17.94, -4.5), Vector3(-1.3, -17.94, -4.5)])
	if id in ["mina", "theo"]:
		result.append_array([Vector3(-4.4, -17.94, -4.5), Vector3(-4.4, -17.94, 4.5), Vector3(-1.3, -17.94, 4.5)])
		for point: Vector3 in Routes.for_id("S21_20")["path_points"]: result.append(point)
		result.append_array([Vector3(4.4, -23.94, 4.5), Vector3(4.4, -23.94, 3.8)])
	else:
		result.assign([Vector3(8.8, -23.94, -4.5), Vector3(4.4, -23.94, -4.5), Vector3(4.4, -23.94, 3.8)])
	result.append(RECEIVING[id])
	return result

func _build_gallery(parent: Node3D) -> void:
	var y := -12.0
	var m: Dictionary = _world.materials
	_world._label(parent, Vector3(7.5, y + 4.2, 9.8), "LES ALIZÉS\nGALERIE DE NACRE", 46, Color("e8d3a7"), 0.010, false).rotation.y = PI
	# Shop fixtures leave the whole +/-4.5 m cross and the north stair approach clear.
	for x: float in [6.2, 9.4]:
		for z: float in [1.8, 5.8]:
			_model(parent, "retail_display_case", Vector3(x, y, z), PI, true)
			_world._light(parent, Vector3(x, y + 2.7, z), Color("ebc998"), 0.22, 2.8)
	_model(parent, "cash_register", Vector3(10.1, y + 0.90, 9.4), PI, false)
	_world._box(parent, Vector3(9.6, y + 0.45, 9.5), Vector3(3.4, 0.9, 1.0), m["wood"], true)
	for z: float in [1.5, 6.7]:
		_world._planter(parent, Vector3(-9.8, y, z))
	_world._box(parent, Vector3(8, y + 1.6, -11.0), Vector3(7.4, 3.2, 0.18), m["wood"], true)
	_world._box(parent, Vector3(4.2, y + 1.6, -8.7), Vector3(0.18, 3.2, 4.8), m["wood"], true)
	for x: float in [5.5, 10.5]:
		_world._box(parent, Vector3(x, y + 1.6, -6.4), Vector3(2.6, 3.2, 0.18), m["wood"], true)
	shutter = Node3D.new()
	shutter.name = "MinaReserveShutter"
	parent.add_child(shutter)
	shutter.position = Vector3(8, y + 1.35, -6.4)
	for index in range(17):
		_world._box(shutter, Vector3(0, -1.28 + index * 0.16, 0), Vector3(2.25, 0.15, 0.085), m["metal"])
	shutter_body = StaticBody3D.new()
	var shutter_shape := BoxShape3D.new()
	shutter_shape.size = Vector3(2.25, 2.7, 0.14)
	var shutter_collider := CollisionShape3D.new()
	shutter_collider.shape = shutter_shape
	shutter_body.add_child(shutter_collider)
	shutter.add_child(shutter_body)
	# Front of the reserve wall is z=-6.31. The controller's back rests on
	# that face; its buttons point into the gallery, not into the wall.
	_model(parent, "shutter_control", Vector3(9.4, y + 1.05, -6.31 + Assets.dimensions("shutter_control").z * 0.5), PI, false)
	_action(parent, "shutter", Vector3(8, y, -6.08))
	_world._label(parent, Vector3(8, y + 3.55, -6.18), "RÉSERVE · VOLET COINCÉ", 26, Color("ead5a4"), 0.006, false)
	_world._light(parent, Vector3(8, y + 3.0, -8.5), Color("b2c9bf"), 0.85, 4.6)
	_clue(parent, "commerce_deliveries_22", Vector3(10.2, y, 8.15))
	# The resident has an authored protected alcove, not a random enemy spawn.
	resident = _world._human(parent, Vector3(-8.4, y, -8.1), m["dark"], false)
	resident.name = "LeRetranche"
	resident.rotation.y = PI
	resident_target = _action(parent, "resident", Vector3(-8.4, y, -7.9))
	resident_target.set_meta("focus_offset", Vector3(0, 1.35, 0))
	resident_sign = _world._label(parent, Vector3(-8.4, y + 2.5, -8.0), "GARDEZ VOTRE DISTANCE\nF · ABAISSER LA LAMPE", 23, Color("e5bd8c"), 0.0048, true)
	for x: float in [-10.5, -6.2]:
		_model(parent, "retail_display_case", Vector3(x, y, -6.6), 0.2, true)
	_world._label(parent, Vector3(0.7, y + 2.6, -4.4), "21 ↓ CUISINES\nESCALIER NORD", 24, Color("b3daca"), 0.005, true)

func _build_kitchen(parent: Node3D) -> void:
	var y := -18.0
	var m: Dictionary = _world.materials
	for z: float in [-9.5, -6.8]:
		_model(parent, "industrial_sink", Vector3(10.2, y, z), PI / 2, true)
	for z: float in [2.0, 3.3, 4.6]:
		_model(parent, "kitchen_stove", Vector3(10.1, y, z), PI / 2, true)
	# The 1.455 m canopies need more space than the 1.03 m ranges. Their
	# separate centres still cover each range without overlapping one another.
	for z: float in [1.8, 3.3, 4.8]:
		_model(parent, "extraction_hood", Vector3(10.1, y + 2.15, z), PI / 2, false)
		var duct_bottom: float = 2.15 + Assets.dimensions("extraction_hood").y
		_world._box(parent, Vector3(10.17, y + (duct_bottom + 5.4) * 0.5, z), Vector3(0.37, 5.4 - duct_bottom, 0.46), m["metal"], true).name = "ExtractionDuctToCeiling"
		for side: float in [-0.60, 0.60]:
			_world._cylinder(parent, Vector3(10.48, y + 3.88, z + side), 0.012, 3.04, m["metal"]).name = "CanopySuspensionRod"
	for z: float in [1.5, 5.4]:
		_model(parent, "service_trolley", Vector3(6.4, y, z), 0, true)
	_world._box(parent, Vector3(7.9, y + 0.49, 9.7), Vector3(6.0, 0.98, 1.2), m["metal"], true)
	_world._box(parent, Vector3(11.2, y + 1.6, 3.3), Vector3(0.16, 3.2, 8.2), m["tile"], true)
	_world._label(parent, Vector3(7.4, y + 3.7, -5.8), "OFFICE · CIRCUIT DU RÉCHAUFFEUR", 27, Color("d1ded3"), 0.006, true)
	_mounted_cabinet(parent, "utility_cutoff_panel", Vector3(6.0, y + 0.8, -2.1), PI, y, "KitchenIsolationMount")
	_action(parent, "isolation", Vector3(6.0, y, -1.85))
	_mounted_cabinet(parent, "fire_blanket_cabinet", Vector3(8.4, y + 1.0, 0.9), 0, y, "FireBlanketMount")
	_action(parent, "blanket", Vector3(8.4, y, 0.55))
	fire_group = Node3D.new()
	fire_group.name = "LocalWarmerFire"
	parent.add_child(fire_group)
	for index in range(5):
		_world._sphere(fire_group, Vector3(9.85 + (index % 2) * 0.18, y + 1.25 + index * 0.14, 2.0), Vector3(0.16, 0.34, 0.16), m["lit_amber"] if index % 2 else m["lit_red"])
	fire_light = _world._light(parent, Vector3(9.8, y + 1.9, 2.0), Color("ef9b52"), 0.9, 5.2)
	fire_light.light_bake_mode = Light3D.BAKE_DYNAMIC
	smoke_group = Node3D.new()
	smoke_group.name = "LocalKitchenSmoke"
	parent.add_child(smoke_group)
	for index in range(3):
		_world._sphere(smoke_group, Vector3(8.2 + index * 0.75, y + 3.4, 2.2 + index), Vector3(2.2, 0.55, 2.0), m["haze"])
	# The deployed cloth rests on the cold pan supports (~0.942 m), rather
	# than hovering 23 cm above them after the intervention.
	blanket_mesh = _world._box(parent, Vector3(10.1, y + 0.97, 2.0), Vector3(0.78, 0.05, 1.05), m["cream"])
	blanket_mesh.name = "DeployedFireBlanket"
	blanket_mesh.visible = false
	kitchen_light = _world._light(parent, Vector3(7.5, y + 3.3, -2.0), Color("edd3a0"), 1.6, 8.0)
	kitchen_light.light_bake_mode = Light3D.BAKE_DYNAMIC
	_clue(parent, "commerce_maintenance_21", Vector3(-8.7, y, 7.2))
	_world._box(parent, Vector3(-8.7, y + 1.4, 8.1), Vector3(3.1, 2.8, 0.18), m["metal"], true)
	_world._label(parent, Vector3(-4.3, y + 2.8, 3.7), "20 ↓ REFUGE\nESCALIER SUD · SUIVEZ LE BALISAGE", 24, Color("c2e8d3"), 0.005, true)
	for z: float in [-3.4, -1.5, 0.4, 2.4, 4.2]:
		_world._box(parent, Vector3(-4.4, y + 0.02, z), Vector3(0.55, 0.025, 0.12), m["lit_green"])
	remanence = _world._human(parent, Vector3(-10.3, y, -9.6), m["dark"], false)
	remanence.name = "UnconfirmedServiceDoorShape"
	remanence.scale = Vector3(0.95, 1.05, 0.28)
	remanence.hide()
	_world._box(parent, Vector3(-10.3, y + 1.55, -10.0), Vector3(1.8, 3.1, 0.15), m["dark"], true)

func _build_refuge(parent: Node3D) -> void:
	var y := -24.0
	var m: Dictionary = _world.materials
	for x: float in [5.8, 7.4, 9.0]:
		_model(parent, "folding_cot", Vector3(x, y, 7.4), 0, true)
		_world._box(parent, Vector3(x, y + 0.018, 3.8), Vector3(1.0, 0.025, 1.0), m["lit_green"])
	_model(parent, "privacy_screen", Vector3(8.2, y, 10.1), 0, true)
	_model(parent, "privacy_screen", Vector3(10.6, y, 7.8), PI / 2, true)
	_model(parent, "water_canister", Vector3(7.0, y + 0.809, -9.5), 0, false)
	_model(parent, "service_trolley", Vector3(7.0, y, -9.5), 0, true)
	var relay_panel: Node3D = _mounted_cabinet(parent, "utility_cutoff_panel", Vector3(-7.7, y + 0.8, -6.4), PI, y, "RefugeRelayMount")
	if relay_panel != null:
		# The shared cabinet mesh is labelled CUISINES A21. Its refuge instance
		# gets a real replacement plaque on the front, not a floating billboard.
		_world._box(relay_panel, Vector3(0, 0.09, -0.054), Vector3(0.255, 0.042, 0.003), m["cream"])
		var identification: Label3D = _world._label(relay_panel, Vector3(0, 0.09, -0.056), "RELAIS A20", 18, Color("172d31"), 0.0009, false)
		identification.rotation.y = PI
		identification.outline_size = 0
	_action(parent, "relay", Vector3(-7.7, y, -6.1))
	_world._box(parent, Vector3(-8.0, y + 0.50, -8.6), Vector3(3.2, 1.0, 1.1), m["metal"], true)
	_world._box(parent, Vector3(-7.7, y + 1.02, -8.43), Vector3(0.46, 0.04, 0.28), m["black_metal"])
	_world._box(parent, Vector3(-7.7, y + 1.15, -8.43), Vector3(0.12, 0.24, 0.10), m["black_metal"])
	relay_screen = _world._box(parent, Vector3(-7.7, y + 1.35, -8.4), Vector3(1.25, 0.68, 0.10), m["screen"])
	relay_screen.rotation.x = -0.18
	var terminal: Node3D = _world._interaction(parent, Vector3(-7.7, y, -7.8), "commerce_finish", "commerce_finish_20", 20, "Bilan du refuge 20", "Confirmer trois réceptions physiques et transmettre les deux nouveaux constats.")
	terminal.set_meta("focus_offset", Vector3(0, 1.3, 0))
	relay_sign = _world._label(parent, Vector3(-7.7, y + 2.6, -8.7), "", 25, Color("a9ddc3"), 0.006, true)
	_world._label(parent, Vector3(7.3, y + 3.4, 8.8), "REFUGE DES ÉQUIPES\nSECTEUR 20 · RÉCEPTION MÉDICALE", 32, Color("c6e3c9"), 0.007, true)
	refuge_light = _world._light(parent, Vector3(7.4, y + 3.9, 6.0), Color("f1d8ac"), 0.8, 9.5)
	refuge_light.light_bake_mode = Light3D.BAKE_DYNAMIC
	for record: Array in [["trauma_bag", Vector3(9.4, y + 0.8, -9.2)], ["portable_worklight", Vector3(5.2, y, 9.8)], ["rescue_radio", Vector3(-8.6, y + 1.0, -8.5)]]:
		var asset: Node3D = RescueAssets.instantiate(record[0])
		if asset != null:
			parent.add_child(asset)
			asset.position = record[1]
	_world._box(parent, Vector3(9.4, y + 0.4, -9.2), Vector3(1.5, 0.8, 0.7), m["wood"], true)
	_world._label(parent, Vector3(0, y + 2.8, -4.5), "PLUS BAS · ACCÈS CONDAMNÉ\nRECONNAISSANCE À POURSUIVRE", 24, Color("ddb579"), 0.005, true)

func _mounted_cabinet(parent: Node3D, id: String, position_value: Vector3, yaw: float, floor_y: float, mount_name: String) -> Node3D:
	# A floor-fixed service rack supports isolated cabinets without adding a
	# wall across an escort corridor. +Z is the cabinet's back before rotation.
	var size: Vector3 = Assets.dimensions(id)
	var rack := Node3D.new()
	rack.name = mount_name
	parent.add_child(rack)
	rack.position = Vector3(position_value.x, floor_y, position_value.z)
	rack.rotation.y = yaw
	var base_height: float = position_value.y - floor_y
	var rack_top: float = base_height + size.y + 0.08
	var width: float = maxf(0.50, size.x + 0.14)
	var back: float = size.z * 0.5 + 0.04
	_world._box(rack, Vector3(0, 0.04, back), Vector3(width + 0.12, 0.08, 0.36), _world.materials["black_metal"], true)
	for side: float in [-1.0, 1.0]:
		_world._box(rack, Vector3(side * (width - 0.06) * 0.5, rack_top * 0.5, back + 0.04), Vector3(0.06, rack_top, 0.06), _world.materials["metal"], true)
	_world._box(rack, Vector3(0, base_height + size.y * 0.5, back), Vector3(width, size.y + 0.12, 0.08), _world.materials["metal"], true)
	return _model(parent, id, position_value, yaw, false)

func _model(parent: Node3D, id: String, position_value: Vector3, yaw: float, solid: bool) -> Node3D:
	var instance: Node3D = Assets.instantiate(id)
	if instance == null: return null
	parent.add_child(instance)
	instance.position = position_value
	instance.rotation.y = yaw
	if solid:
		var body := StaticBody3D.new()
		body.name = "InteractionClearanceCollider"
		var shape := BoxShape3D.new()
		shape.size = Assets.dimensions(id)
		var collider := CollisionShape3D.new()
		collider.shape = shape
		collider.position.y = shape.size.y * 0.5
		body.add_child(collider)
		instance.add_child(body)
	return instance

func _action(parent: Node3D, id: String, position_value: Vector3) -> Node3D:
	var spec: Dictionary = Director.ACTIONS[id]
	var object: Node3D = _world._interaction(parent, position_value, "commerce_action", "commerce_action_" + id, spec["floor"], spec["title"], spec["message"])
	object.set_meta("action_id", id)
	object.set_meta("focus_offset", Vector3(0, 1.2, 0))
	action_targets[id] = object
	return object

func _clue(parent: Node3D, id: String, position_value: Vector3) -> void:
	var record: Dictionary = Director.CLUES[id]
	var object: Node3D = _world._interaction(parent, position_value, "commerce_clue", id, record["floor"], record["title"], record["text"])
	object.set_meta("focus_offset", Vector3(0, 1.25, 0.15))
	_world._box(object, Vector3(0, 0.5, -0.10), Vector3(0.95, 1.0, 0.65), _world.materials["wood"], true)
	_world._box(object, Vector3(0, 1.05, 0), Vector3(0.60, 0.04, 0.42), _world.materials["lit_blue"])
	_world._label(object, Vector3(0, 1.65, 0), "CONSTAT À RELEVER", 21, Color("b3d5df"), 0.0045, true)

func _sample_resident(player_position: Vector3, lamp_enabled: bool) -> void:
	if "resident" in last_actions: return
	var pressure: float = resident_pressure(player_position, lamp_enabled)
	resident.get_node("RightArm").rotation.x = -1.55 if pressure > 0.0 else -0.55
	resident.get_node("LeftArm").rotation.x = -1.1 if pressure > 0.0 else -0.2
	resident_sign.text = "RECULEZ · NE L’ÉBLOUISSEZ PAS\nF · ABAISSER LA LAMPE" if pressure > 0.0 else "GARDEZ ENVIRON 2 À 3 m\nLAMPE ABAISSÉE · MAINTENIR E POUR PARLER"
