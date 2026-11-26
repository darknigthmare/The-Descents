extends Node3D
class_name DescentResidentialPresentation
## A19–A17 residence, duplex and local telecommunications chapter.
## Rescue movement is physical and uses the reopened stair service circuit.
## Scene clocks are sampled by the mission; no hidden timers run behind UI.

const Director = preload("res://scripts/residential_director.gd")
const Routes = preload("res://scripts/route_catalog.gd")
const Assets = preload("res://scripts/residential_asset_catalog.gd")
const STARTS: Dictionary = {"jeanne": Vector3(8.0, -29.94, -8.5), "marc": Vector3(8.0, -35.94, 7.6), "ines": Vector3(-8.0, -41.94, 8.2)}
const RECEIVING: Dictionary = {"jeanne": Vector3(-9.0, -23.94, 7.2), "marc": Vector3(-7.4, -23.94, 7.2), "ines": Vector3(-5.8, -23.94, 7.2)}
const SPEEDS: Dictionary = {"jeanne": 0.88, "marc": 1.30, "ines": 1.30}
const LEAD_DISTANCE: float = 5.0
var people: Dictionary = {}
var figures: Dictionary = {}
var paths: Dictionary = {}
var cursors: Dictionary = {}
var arrived: Dictionary = {}
var walk_clocks: Dictionary = {}
var statuses: Dictionary = {}
var person_targets: Dictionary = {}
var action_targets: Dictionary = {}
var clue_targets: Dictionary = {}
var name_labels: Dictionary = {}
var service_gate: Node3D
var service_gate_body: StaticBody3D
var folded_gate: Node3D
var gate_sign: Label3D
var care_sign: Label3D
var relay_sign: Label3D
var reference_sign: Label3D
var relay_screen: MeshInstance3D
var telecom_light: OmniLight3D
var respondent: Node3D
var respondent_clock: float = 0.0
var respondent_seen: bool = false
var ventilation_blades: Array[Node3D] = []
var last_actions: Array = []
var chapter_active: bool = false
var _world: Node3D

func build(world: Node3D) -> void:
	_world = world
	name = "ResidencesDuplexAndTelecommunications"
	set_process(false)
	set_physics_process(false)
	_build_upper_residence(world.get_node("Floor19"))
	_build_lower_residence(world.get_node("Floor18"))
	_build_telecommunications(world.get_node("Floor17"))
	_build_receiving(world.get_node("Floor20"))
	_build_people()
	for branch: Node in [service_gate, folded_gate, respondent, relay_screen]:
		_world.mark_dynamic_lighting_branch(branch)
	for branch: Node in ventilation_blades:
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
	var opened: bool = "service_access" in last_actions
	service_gate.visible = not opened
	service_gate_body.collision_layer = 0 if opened else 1
	service_gate_body.collision_mask = 0 if opened else 1
	folded_gate.visible = opened
	gate_sign.text = "RETOUR 19 → 20 OUVERT\nESCORTE PAR L’ESCALIER" if opened else "GRILLE DE SERVICE COINCÉE\n3 · HALLIGAN / MAINTENIR E"
	care_sign.text = "JEANNE PEUT MARCHER LENTEMENT\nRESTEZ À SES CÔTÉS" if "care" in last_actions else "MISE EN SÉCURITÉ DE JEANNE\nMAINTENIR E · AUCUNE COURSE CHRONOMÉTRÉE"
	var powered: bool = "power" in last_actions
	var online: bool = "relay" in last_actions
	telecom_light.light_energy = 1.35 if powered else 0.55
	relay_screen.material_override = _world.materials["lit_green"] if online else _world.materials["screen"]
	relay_sign.text = "ÉMISSION VÉRIFIÉE · AUBE-20\nRETOUR DU RELAIS CONFIRMÉ" if online else ("ALIMENTATION RÉTABLIE\nCOMPARER LA PLAQUE AVANT D’ÉMETTRE" if powered else "RELAIS A17 SUR BATTERIE\nRÉTABLIR D’ABORD L’ALIMENTATION")
	reference_sign.modulate = Color("d9f2e4") if "reference" in last_actions else Color.WHITE
	for id: String in action_targets:
		action_targets[id].set_meta("used", id in last_actions)

func advance(delta: float, player_position: Vector3, running: bool, allow_unease: bool, _lamp_enabled: bool, reduced_motion: bool) -> void:
	if not running or not chapter_active or not is_finite(delta) or delta <= 0.0 or not player_position.is_finite():
		return
	var step: float = minf(delta, 0.05)
	for id: String in Director.PERSON_IDS:
		_advance_person(id, step, player_position)
	_update_people_labels(player_position)
	if "power" in last_actions and not reduced_motion:
		for blade: Node3D in ventilation_blades: blade.rotation.z += step * 1.3
	# This distant, optional silhouette occurs only in telecommunications.
	# It never enters the duplex lesson, attacks, blocks the path or changes saves.
	if not allow_unease:
		respondent.hide()
		return
	if not respondent_seen and player_position.y > -42.8 and player_position.y < -40.5 and player_position.x > 4.3 and "power" in last_actions:
		respondent_clock += step
		respondent.visible = respondent_clock > 2.5 and respondent_clock < 7.0
		if respondent_clock >= 7.0:
			respondent_seen = true
			respondent.hide()
	elif respondent_seen:
		respondent.hide()

func physically_arrived(id: String) -> bool:
	if not people.has(id) or not bool(arrived.get(id, false)): return false
	var body: CharacterBody3D = people[id]
	return body.global_position.distance_to(RECEIVING[id]) < 0.28 and absf(body.velocity.y) < 0.15 and _support(body)

func snapshot() -> Dictionary:
	var positions: Dictionary = {}
	for id: String in Director.PERSON_IDS: positions[id] = people[id].global_position
	return {"positions": positions, "cursors": cursors.duplicate(), "statuses": statuses.duplicate(), "arrived": arrived.duplicate(), "actions": last_actions.duplicate(), "respondent_seen": respondent_seen}

func _advance_person(id: String, delta: float, player_position: Vector3) -> void:
	var body: CharacterBody3D = people[id]
	var allow: bool = statuses.get(id) == "following" and not bool(arrived[id]) and body.global_position.distance_to(player_position) <= LEAD_DISTANCE
	if allow:
		for other: String in Director.PERSON_IDS:
			if other == id or statuses.get(other) != "following" or bool(arrived[other]): continue
			if id > other and body.global_position.distance_to(people[other].global_position) < 0.95: allow = false
	var planar := Vector3.ZERO
	var speed: float = float(SPEEDS[id])
	if allow:
		var target: Vector3 = paths[id][int(cursors[id])]
		var offset := Vector3(target.x - body.global_position.x, 0.0, target.z - body.global_position.z)
		if offset.length() < 0.13 and absf(body.global_position.y - target.y) < 0.25 and _support(body):
			cursors[id] = int(cursors[id]) + 1
			if int(cursors[id]) >= paths[id].size():
				arrived[id] = true
			else:
				target = paths[id][int(cursors[id])]
				offset = Vector3(target.x - body.global_position.x, 0.0, target.z - body.global_position.z)
		if not bool(arrived[id]): planar = offset.normalized() * minf(speed, offset.length() / maxf(delta, 0.001))
	body.velocity.x = planar.x
	body.velocity.z = planar.z
	body.velocity.y = 0.0 if body.is_on_floor() else body.velocity.y - 16.0 * delta
	body.move_and_slide()
	if planar.length() > 0.01:
		figures[id].rotation.y = lerp_angle(figures[id].rotation.y, atan2(-planar.x, -planar.z), minf(1.0, delta * 8.0))
		walk_clocks[id] = float(walk_clocks[id]) + delta * (5.0 if id == "jeanne" else 7.0)
	_world._pose_human_walk(figures[id], float(walk_clocks[id]), clampf(planar.length() / speed, 0.0, 1.0))
	person_targets[id].set_meta("floor", clampi(roundi((body.global_position.y - 0.06) / 6.0) + 24, 17, 20))

func _support(body: CharacterBody3D) -> bool:
	var origin: Vector3 = body.global_position + Vector3.UP * 0.12
	var query := PhysicsRayQueryParameters3D.create(origin, origin + Vector3.DOWN * 0.40, 1, [body.get_rid()])
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and Vector3(hit.get("normal", Vector3.ZERO)).y > 0.65

func _update_people_labels(player_position: Vector3) -> void:
	for id: String in Director.PERSON_IDS:
		var close: bool = player_position.is_finite() and people[id].global_position.distance_to(player_position) <= LEAD_DISTANCE
		var status: String = str(statuses.get(id, "waiting"))
		var instruction: String = "AU REFUGE 20" if status == "received" else ("JE VOUS SUIS · DOUCEMENT" if id == "jeanne" and status == "following" and close else "JE VOUS SUIS" if status == "following" and close else "J’ATTENDS · RESTEZ À MOINS DE 5 m" if status == "following" else "E · SUIVEZ-MOI / ATTENDEZ")
		name_labels[id].text = str(Director.PEOPLE[id]["name"]) + "\n" + instruction

func _build_people() -> void:
	for id: String in Director.PERSON_IDS:
		var body := CharacterBody3D.new()
		body.name = "ResidenceRescue_" + id
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
		var figure: Node3D = _world._human(body, Vector3.ZERO, _world.materials[{"jeanne": "cream", "marc": "green", "ines": "blue"}[id]], false)
		figure.rotation.y = PI
		figures[id] = figure
		if id == "jeanne":
			_world._box(figure, Vector3(0.0, 1.18, -0.18), Vector3(0.38, 0.29, 0.04), _world.materials["white"])
		elif id == "ines":
			_world._box(figure, Vector3(0.0, 1.12, -0.19), Vector3(0.43, 0.055, 0.035), _world.materials["yellow"])
			_world._box(figure, Vector3(-0.14, 1.25, -0.19), Vector3(0.10, 0.16, 0.02), _world.materials["white"])
		else:
			_world._box(figure, Vector3(0.15, 1.06, -0.19), Vector3(0.12, 0.20, 0.035), _world.materials["cream"])
		var target: Node3D = _world._interaction(body, Vector3.ZERO, "residential_person", "residential_person_" + id, Director.PEOPLE[id]["floor"], Director.PEOPLE[id]["name"], "Retour à pied par le passage de service jusqu’au refuge 20. E : suivre ou attendre. Rester à moins de cinq mètres.")
		target.set_meta("person_id", id)
		person_targets[id] = target
		name_labels[id] = _world._label(body, Vector3(0.0, 2.15, 0.0), "", 22, Color("d8e7d4"), 0.0046, true)
		paths[id] = _escort_path(id)
		cursors[id] = 0
		arrived[id] = false
		statuses[id] = "waiting"
		walk_clocks[id] = 0.0

func _append_stair_up(result: Array[Vector3], route_id: String) -> void:
	var route: Dictionary = Routes.for_id(route_id)
	var points: Array = route.get("path_points", []).duplicate()
	points.reverse()
	for point: Vector3 in points: result.append(point)

func _escort_path(id: String) -> Array[Vector3]:
	var result: Array[Vector3] = []
	if id == "ines":
		result.assign([Vector3(-8.0, -41.94, 4.5), Vector3(-4.4, -41.94, 4.5), Vector3(-4.4, -41.94, -4.5), Vector3(-1.3, -41.94, -4.5)])
		_append_stair_up(result, "S18_17")
		result.append_array([Vector3(1.3, -35.94, -4.5), Vector3(-4.4, -35.94, -4.5), Vector3(-4.4, -35.94, 4.5), Vector3(1.3, -35.94, 4.5)])
	elif id == "marc":
		result.assign([Vector3(8.0, -35.94, 4.5), Vector3(4.4, -35.94, 4.5), Vector3(1.3, -35.94, 4.5)])
	if id in ["ines", "marc"]:
		_append_stair_up(result, "S19_18")
		result.append_array([Vector3(-1.3, -29.94, 4.5), Vector3(-4.4, -29.94, 4.5), Vector3(-4.4, -29.94, -4.5), Vector3(-1.3, -29.94, -4.5)])
	else:
		result.assign([Vector3(8.0, -29.94, -4.5), Vector3(4.4, -29.94, -4.5), Vector3(-1.3, -29.94, -4.5)])
	_append_stair_up(result, "S20_19")
	result.append_array([Vector3(1.3, -23.94, -4.5), Vector3(-4.4, -23.94, -4.5), Vector3(-4.4, -23.94, 6.2), Vector3(float(RECEIVING[id].x), -23.94, 6.2), RECEIVING[id]])
	return result

func _build_upper_residence(parent: Node3D) -> void:
	var y := -30.0
	var m: Dictionary = _world.materials
	var linen: Material = m.get("residential_linen", m["cream"])
	# The apartment doorway is an actual opening in its corridor partition.
	_world._box(parent, Vector3(8.0, y + 1.55, -11.0), Vector3(6.4, 3.1, 0.16), linen, true)
	_world._box(parent, Vector3(4.8, y + 1.55, -8.5), Vector3(0.16, 3.1, 5.0), linen, true)
	for record: Array in [[5.55, 1.5], [10.40, 1.20]]:
		_world._box(parent, Vector3(record[0], y + 1.55, -6.0), Vector3(record[1], 3.1, 0.16), linen, true)
	_world._box(parent, Vector3(8.0, y + 2.95, -6.0), Vector3(3.4, 0.30, 0.18), m["wood"], true)
	_model(parent, "rest_armchair", Vector3(9.6, y, -9.65), PI * 0.8, true)
	_model(parent, "coffee_table", Vector3(9.4, y, -7.1), 0.0, true)
	_model(parent, "reading_lamp", Vector3(10.45, y, -10.2), 0.0, true)
	_model(parent, "medicine_cabinet", Vector3(10.9, y + 1.0, -8.45), PI / 2.0, false)
	_world._box(parent, Vector3(11.08, y + 1.65, -8.45), Vector3(0.16, 1.4, 1.0), linen, true)
	_model(parent, "wall_intercom", Vector3(5.55, y + 1.15, -5.86), PI, false)
	_action(parent, "care", Vector3(10.35, y, -8.4))
	care_sign = _world._label(parent, Vector3(8.0, y + 2.75, -8.5), "", 22, Color("e8dfbf"), 0.0048, true)
	_world._label(parent, Vector3(8.1, y + 3.45, -5.85), "RÉSIDENCES DE L’AUBE · 1902", 28, Color("e9d8b3"), 0.006, false)
	for z: float in [-8.8, 8.0]:
		_model(parent, "resident_bookcase", Vector3(-10.8, y, z), -PI / 2.0, true)
	_model(parent, "rest_armchair", Vector3(-8.1, y, -8.8), -PI / 4.0, true)
	_model(parent, "reading_lamp", Vector3(-9.1, y, -10.0), 0.0, true)
	_clue(parent, "residential_visits_19", Vector3(-7.0, y, -7.8))
	_world._label(parent, Vector3(-7.3, y + 3.2, -10.7), "BIBLIOTHÈQUE COMMUNE\nDES VISITES AVANT LE TYPHON", 26, Color("dbd1bc"), 0.006, true)
	_world._light(parent, Vector3(8.8, y + 3.8, -8.5), Color("f3d0a0"), 1.1, 6.0)
	_world._light(parent, Vector3(-8.6, y + 3.0, -8.6), Color("e6c897"), 0.9, 6.0)
	# Guardrails frame the real slab opening. The west terminal stays open.
	for z: float in [-2.18, 2.18]:
		_world._box(parent, Vector3(8.0, y + 0.52, z), Vector3(4.65, 1.04, 0.09), m["clear_glass"], true)
		_world._box(parent, Vector3(8.0, y + 1.08, z), Vector3(4.7, 0.08, 0.10), m["wood"], true)
	_world._box(parent, Vector3(10.38, y + 0.52, 0.0), Vector3(0.09, 1.04, 4.35), m["clear_glass"], true)
	_world._box(parent, Vector3(10.38, y + 1.08, 0.0), Vector3(0.10, 0.08, 4.45), m["wood"], true)
	_world._label(parent, Vector3(5.0, y + 2.45, 1.8), "DUPLEX 18 · APPUI VISIBLE\nRAPPEL PERSONNEL · RETOUR PAR LE SERVICE", 22, Color("bddeec"), 0.0047, true)
	_world._label(parent, Vector3(-0.9, y + 2.8, -4.5), "20 ↑ REFUGE\nRETOUR ACCOMPAGNÉ PAR L’ESCALIER", 22, Color("b9dfc9"), 0.0047, true)

func _build_lower_residence(parent: Node3D) -> void:
	var y := -36.0
	var m: Dictionary = _world.materials
	var linen: Material = m.get("residential_linen", m["cream"])
	_world._box(parent, Vector3(8.5, y + 1.55, 10.7), Vector3(6.0, 3.1, 0.16), linen, true)
	_world._box(parent, Vector3(11.1, y + 1.55, 8.0), Vector3(0.16, 3.1, 5.2), linen, true)
	_model(parent, "rest_armchair", Vector3(9.7, y, 9.0), PI, true)
	_model(parent, "coffee_table", Vector3(6.5, y, 9.2), 0.0, true)
	_model(parent, "reading_lamp", Vector3(10.6, y, 9.9), PI, true)
	_model(parent, "resident_bookcase", Vector3(-10.7, y, 8.8), -PI / 2.0, true)
	_clue(parent, "residential_crack_18", Vector3(-8.0, y, 7.6))
	_world._label(parent, Vector3(8.1, y + 3.5, 10.2), "LE SALON DU DESSUS EST OUVERT\nMARC · RETOUR VERS JEANNE", 24, Color("dcd5bc"), 0.0055, true)
	_world._light(parent, Vector3(8.0, y + 3.8, 7.8), Color("ebcca7"), 1.0, 6.0)
	_world._light(parent, Vector3(8.0, y + 3.2, 0.0), Color("bed6dc"), 0.8, 6.0)
	# This full-width gate closes the lower mouth of the local staircase.
	# The latch is reached from the A18 corridor after the safe duplex descent.
	service_gate = Node3D.new()
	service_gate.name = "ServiceReturnGate19_18"
	parent.add_child(service_gate)
	service_gate.position = Vector3(0.0, y + 1.4, 5.55)
	for x: float in [-2.4, -1.8, -1.2, -0.6, 0.0, 0.6, 1.2, 1.8, 2.4]:
		_world._box(service_gate, Vector3(x, 0.0, 0.0), Vector3(0.075, 2.8, 0.07), m["metal"])
	for zed: float in [-1.35, 0.0, 1.35]:
		_world._box(service_gate, Vector3(0.0, zed, 0.0), Vector3(5.15, 0.075, 0.07), m["metal"])
	service_gate_body = StaticBody3D.new()
	service_gate_body.name = "ClosedServiceGateCollision"
	var shape := BoxShape3D.new()
	shape.size = Vector3(5.25, 2.8, 0.16)
	var collider := CollisionShape3D.new()
	collider.shape = shape
	service_gate_body.add_child(collider)
	service_gate.add_child(service_gate_body)
	folded_gate = _world._box(parent, Vector3(2.64, y + 1.4, 5.65), Vector3(0.20, 2.8, 0.24), m["metal"])
	folded_gate.name = "OpenedServiceGateFoldedAtJamb"
	folded_gate.hide()
	_world._box(parent, Vector3(3.2, y + 1.35, 5.48), Vector3(0.65, 2.7, 0.20), m["metal"], true)
	_model(parent, "service_latch_panel", Vector3(3.2, y + 1.0, 5.28), 0.0, false)
	_action(parent, "service_access", Vector3(3.2, y, 4.9))
	gate_sign = _world._label(parent, Vector3(3.2, y + 2.35, 5.12), "", 21, Color("d8c59f"), 0.0042, true)
	# Keep the local stair label beyond the gate, clear of the nearby latch instruction.
	var service_stair: Node3D = _world.get_node("TraversalNetwork/S19_18")
	for child: Node in service_stair.get_children():
		if child is Label3D and child.position.y < y + 3.0:
			child.position = Vector3(1.3, y + 2.15, 7.4)
			child.font_size = 24
			child.pixel_size = 0.0047
	_world._label(parent, Vector3(-0.9, y + 2.8, -4.5), "17 ↓ TÉLÉCOMMUNICATIONS\nESCALIER NORD", 22, Color("b9dfd7"), 0.0048, true)
	for z: float in [-3.4, -1.5, 0.4, 2.4, 4.2]:
		_world._box(parent, Vector3(-4.4, y + 0.02, z), Vector3(0.55, 0.025, 0.12), m["lit_green"])

func _build_telecommunications(parent: Node3D) -> void:
	var y := -42.0
	var m: Dictionary = _world.materials
	for x: float in [6.0, 8.0, 10.0]:
		for z: float in [-8.8, -6.8]:
			_model(parent, "telecom_rack", Vector3(x, y, z), PI, true)
		_world._box(parent, Vector3(x, y + 3.25, -7.7), Vector3(0.35, 0.12, 5.0), m["metal"])
	_world._box(parent, Vector3(8.0, y + 3.25, -10.0), Vector3(4.7, 0.12, 0.35), m["metal"])
	_world._box(parent, Vector3(10.9, y + 1.4, -3.0), Vector3(0.16, 2.8, 3.0), m["metal"], true)
	_model(parent, "patch_panel", Vector3(10.72, y + 1.1, -3.0), PI / 2.0, false)
	_model(parent, "ups_battery", Vector3(9.6, y, 2.8), PI / 2.0, true)
	_action(parent, "power", Vector3(8.9, y, 2.8))
	_world._label(parent, Vector3(9.5, y + 1.8, 2.8), "ALIMENTATION SECOURUE\nCIRCUIT LOCAL A17", 21, Color("c9e0d7"), 0.0045, true)
	# The console sits in the western control office, outside circulation.
	_model(parent, "relay_console", Vector3(-8.0, y, -8.7), PI, true)
	relay_screen = _world._box(parent, Vector3(-8.0, y + 1.31, -8.64), Vector3(0.78, 0.01, 0.39), m["screen"])
	relay_screen.rotation.x = PI / 2.0 - 0.08
	_action(parent, "relay", Vector3(-8.0, y, -7.75))
	_world._box(parent, Vector3(-10.0, y + 1.35, -10.0), Vector3(0.10, 2.7, 2.0), m["metal"], true)
	_world._box(parent, Vector3(-9.93, y + 1.58, -10.0), Vector3(0.025, 0.70, 1.65), m["cream"])
	reference_sign = _world._label(parent, Vector3(-9.90, y + 1.58, -10.0), "DESTINATION : AUBE-20\nRÉFÉRENCE : NACRE-204", 27, Color("172e32"), 0.0036, false)
	reference_sign.rotation.y = PI / 2.0
	reference_sign.outline_size = 0
	_action(parent, "reference", Vector3(-9.25, y, -9.4))
	relay_sign = _world._label(parent, Vector3(-8.0, y + 2.9, -8.7), "", 24, Color("b9dfcf"), 0.005, true)
	_clue(parent, "residential_recordings_17", Vector3(-6.0, y, -8.0))
	_model(parent, "voice_recorder", Vector3(-6.0, y + 1.08, -8.0), PI, false)
	var terminal: Node3D = _world._interaction(parent, Vector3(-8.0, y, -6.5), "residential_finish", "residential_finish_17", 17, "Bilan du relais A17", "Confirmer les réceptions au refuge 20 et transmettre les constats par le relais vérifié.")
	terminal.set_meta("focus_offset", Vector3(0.0, 1.3, 0.0))
	_world._label(parent, Vector3(-8.0, y + 2.2, -6.5), "BILAN DU SECTEUR 19–17", 21, Color("b9dfcf"), 0.0045, true)
	# Protected technician office with a physical doorway on its east edge.
	_world._box(parent, Vector3(-10.8, y + 1.5, 8.3), Vector3(0.16, 3.0, 5.2), m["metal"], true)
	_world._box(parent, Vector3(-8.0, y + 1.5, 10.8), Vector3(5.6, 3.0, 0.16), m["metal"], true)
	_model(parent, "rest_armchair", Vector3(-9.2, y, 9.0), PI, true)
	_model(parent, "wall_intercom", Vector3(-10.65, y + 1.1, 7.1), -PI / 2.0, false)
	_world._label(parent, Vector3(-8.0, y + 3.5, 10.4), "LOCAL PROTÉGÉ · INÈS VIDAL", 25, Color("bdcec9"), 0.005, true)
	telecom_light = _world._light(parent, Vector3(-8.0, y + 3.8, -8.5), Color("c4d5c4"), 0.55, 6.5)
	telecom_light.light_bake_mode = Light3D.BAKE_DYNAMIC
	_world._light(parent, Vector3(8.1, y + 3.8, -7.6), Color("a4c5d6"), 0.7, 7.5)
	_world._light(parent, Vector3(-8.0, y + 3.5, 8.3), Color("e2d3b6"), 0.9, 6.0)
	# Ventilation never pushes bodies or places a hazard on a required route.
	for x: float in [6.0, 9.0]:
		_world._box(parent, Vector3(x, y + 4.0, -10.9), Vector3(1.25, 1.25, 0.16), m["black_metal"])
		var blade := Node3D.new()
		blade.name = "RelayVentilationRotor"
		parent.add_child(blade)
		blade.position = Vector3(x, y + 4.0, -10.78)
		for angle: float in [0.0, PI * 0.5]:
			var vane: MeshInstance3D = _world._box(blade, Vector3.ZERO, Vector3(0.92, 0.14, 0.03), m["metal"])
			vane.rotation.z = angle
		ventilation_blades.append(blade)
	_world._box(parent, Vector3(10.7, y + 1.55, 9.0), Vector3(1.6, 3.1, 0.16), m["dark"], true)
	respondent = _world._human(parent, Vector3(10.7, y, 8.75), m["dark"], false)
	respondent.name = "UnconfirmedNetworkRespondent"
	respondent.scale = Vector3(0.92, 1.07, 0.28)
	respondent.rotation.y = PI
	respondent.hide()

func _build_receiving(parent: Node3D) -> void:
	var y := -24.0
	var m: Dictionary = _world.materials
	for id: String in Director.PERSON_IDS:
		var point: Vector3 = RECEIVING[id]
		_world._box(parent, Vector3(point.x, y + 0.018, point.z), Vector3(1.05, 0.025, 1.0), m["lit_green"])
		_model(parent, "rest_armchair", Vector3(point.x, y, 9.2), PI, true)
	_world._label(parent, Vector3(-7.4, y + 3.1, 9.8), "RÉCEPTION DES RÉSIDENCES\nJEANNE · MARC · INÈS", 26, Color("d0e0c5"), 0.0055, true)
	_world._light(parent, Vector3(-7.4, y + 3.7, 8.0), Color("eddbb5"), 0.75, 6.0)

func _model(parent: Node3D, id: String, position_value: Vector3, yaw: float, solid: bool) -> Node3D:
	var instance: Node3D = Assets.instantiate(id)
	if instance == null: return null
	parent.add_child(instance)
	instance.position = position_value
	instance.rotation.y = yaw
	if solid:
		var body := StaticBody3D.new()
		body.name = "ResidentialPropCollider"
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
	var object: Node3D = _world._interaction(parent, position_value, "residential_action", "residential_action_" + id, spec["floor"], spec["title"], spec["message"])
	object.set_meta("action_id", id)
	object.set_meta("focus_offset", Vector3(0.0, 1.2, 0.0))
	action_targets[id] = object
	return object

func _clue(parent: Node3D, id: String, position_value: Vector3) -> void:
	var record: Dictionary = Director.CLUES[id]
	var object: Node3D = _world._interaction(parent, position_value, "residential_clue", id, record["floor"], record["title"], record["text"])
	object.set_meta("focus_offset", Vector3(0.0, 1.25, 0.15))
	_world._box(object, Vector3(0.0, 0.5, -0.1), Vector3(0.95, 1.0, 0.65), _world.materials["wood"], true)
	_world._box(object, Vector3(0.0, 1.05, 0.0), Vector3(0.60, 0.035, 0.42), _world.materials["lit_blue"])
	_world._label(object, Vector3(0.0, 1.75, 0.0), "CONSTAT À RELEVER", 20, Color("c0d7e2"), 0.0043, true)
	clue_targets[id] = object
